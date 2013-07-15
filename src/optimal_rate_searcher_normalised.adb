with model_household;             
with frs_to_model_mapper;
with la_parameters;               
with Text_IO;
with format_utils;
with FRS_Enums;                   
with format_utils;
with html_utils;
with la_calculator;               
with Legal_Aid_Output_Types;
with scotland_specific_constants; 
with run_settings;
with legal_aid_runner; use legal_aid_runner;
with Costs_Model; use Costs_Model;
with Model_Output;
with Factor_Table;
with Equivalence_Scales;

package body optimal_rate_searcher is

   use scotland_specific_constants;
   use la_calculator;
   use FRS_Enums;
   use model_household;
   use la_parameters;
   use text_io;
      
   cells : Cell_Array;
   
   procedure calibrate_settings( control : in out Control_Record ) is
   begin
      control.rate_increment := (control.rate_end - control.rate_start)/real( NUM_RATES );
      control.limit_increment := Money((real(control.limit_end - control.limit_start))/real( NUM_LIMITS ));
   end calibrate_settings;
   
   --
   -- excess income equivalised and split into 250 pound bands
   --
   function calc_income_group( bu : Model_Benefit_Unit; excess_income : Money ) return Income_Counter is
      increment        : constant Money := 250.0;
      limit            : Money := 0.0;
      equiv_income     : Money := Equivalence_Scales.equivalise_income( bu, excess_income );
   begin
      for i in Income_Counter loop
         if ( equiv_income < limit ) then
            return i;
         end if;
         limit := limit + increment;
      end loop; 
      return NUM_INCOME_DIVISIONS;
   end calc_income_group;
   
   
   procedure generate_matrix_for_hh( 
      sys : Legal_Aid_Sys; 
      mhh : model_household.Model_Household_Rec;
      settings : run_settings.Settings_Rec;
      grossing_factor : real;
      ctl : Control_Record;
      base_output : Model_Output.LAOutputArray
      ) is
      rate       : Real := ctl.rate_start;
      limit      : Money          ;
      gross      : SReal := SReal( grossing_factor );
      localSys   :  Legal_Aid_Sys := sys;
      output     : Model_Output.LAOutputArray;
      total_cost  : SReal := 0.0;
      total_cases : SReal := 0.0;
      excess_income : Money;
      income_band   : Income_Counter;
   begin
      new_line;
      rates_loop: for r in Rate_Counter loop
         limit := ctl.limit_start;
         put( "searching on rate " & r'Img );
         limits_loop: for l in Limit_Counter loop
            cells( r, l ).rate := rate;
            cells( r, l ).upper_limit := limit;
            localSys.upper_limit( income, normalClaim ) := limit;
            localSys.contributions (income).contribution_proportion(2) := rate;
            output  := calcOneHHLegalAid (mhh, localSys, normalClaim, settings.uprate_to_current);
            limit := limit + ctl.limit_increment;  
            --
            -- accumulate. Note we accumulate in single - precision to save memory (cells is potentially a huge matrix), 
            -- hence the
            -- annoying casts here, and gross (single prec) for grossing_factor (double).
            --
            benefit_units_loop: for buno in 1 .. mhh.num_benefit_units loop
               total_cost  := 0.0;
               total_cases := 0.0;
               --
               -- costs additions and associated breakdowns
               --
               for t in LA_Problem_Type loop
                     total_cost  := total_cost + sreal( output( buno ).costs( civil, expected_net_costs, t ) - 
                        base_output( buno ).costs( civil, expected_net_costs, t ));
                     total_cases := total_cases + sreal( output( buno ).costs( civil, expected_takeup, t ) - 
                        base_output( buno ).costs( civil, expected_takeup, t ));
               end loop;
               cells( r, l ).total_cost := cells( r, l ).total_cost + (total_cost * gross ); 
               cells( r, l ).total_num_cases := cells( r, l ).total_num_cases + (total_cases * gross ); 
               for c in  LA_Costs_Component loop
                  for t in LA_Problem_Type loop
                     cells( r, l ).costs_breakdown( c , t ) :=  
                        cells( r, l ).costs_breakdown( c , t ) + SReal( 
                           output( buno ).costs( civil, c, t ) - base_output( buno ).costs( civil, c, t ) ) * gross; 
                  end loop;
               end loop;
               --
               -- people/bus/adults counts for the newly qualified
               --
               if(( base_output( buno ).la_State = disqualified ) and ( output( buno ).la_State /= disqualified )) then
                  --
                  -- excess of assesed income over the original upper income limit 
                  -- expressed this convoluted way because our excess income has had the lower income 
                  -- limit subtracted from it already
                  -- 
                  excess_income :=  output( buno ).excess_Income + 
                     sys.lower_limit (income, normalClaim) - sys.upper_limit (income, normalClaim);
                  income_band := calc_income_group( mhh.benefit_units( buno ), excess_income );
                  cells( r, l ).cases_by_income( income_band ) := 
                     cells( r, l ).cases_by_income( income_band ) + ( total_cases * gross );
                  
                  cells( r, l ).num_benefit_units := cells( r, l ).num_benefit_units +  gross; 
                  for adno in head .. mhh.benefit_units( buno ).last_adult loop
                     cells( r, l ).num_adults := cells( r, l ).num_adults +  gross;
                     cells( r, l ).num_people := cells( r, l ).num_people +  gross;
                  end loop;
                  for chno in 1 .. mhh.benefit_units( buno ).num_children loop
                     cells( r, l ).num_people := cells( r, l ).num_people +  gross;
                  end loop;
               end if;               
            end loop benefit_units_loop;
         end loop  limits_loop;
         rate := rate + ctl.rate_increment;
      end loop rates_loop;
      new_line;
   end generate_matrix_for_hh;
   
   procedure generate_searches( sys : Legal_Aid_Sys; control : Control_Record ) is
      settings : constant run_settings.Settings_Rec := run_settings.DEFAULT_RUN_SETTINGS;
      ctl : Control_Record := control; -- local copy so we can change it
      sz  : Integer := 0;
      startHH, endHH : integer := 0;
      grossing_factor : real := 0.0;
      base_output            : Model_Output.LAOutputArray;
      mhh                    : model_household.Model_Household_Rec;
      hh_file                : hh_io.File_Type;
      num_years              : real                      :=
         real (settings.end_year - settings.start_year + 1);
   begin
      calibrate_settings( ctl );
      put( "size in bytes of the record is " & cells'Size'Img & " bytes " );
      put( "ctl.limit_increment = " & ctl.limit_increment'Img );
      put( "ctl.rate_increment = " & ctl.rate_increment'Img );
      for year in  settings.start_year .. settings.end_year loop
         model_household.initialise (hh_file, year, sz, False);

         if (SCOTLAND_ONLY) then
            startHH := FILE_POSITIONS (year, start_pos);
            endHH   := FILE_POSITIONS (year, end_pos);
         else
            startHH := 1;
            endHH   := sz;
         end if;
         for href in  startHH .. endHH loop
            put( "on household " & href'Img );
            mhh := model_household.load (hh_file, href);
            grossing_factor        := mhh.grossing_factor / num_years;
            if (la_parameters.is_annual_system (settings.run_type)) then
               model_household.annualise (mhh);
            end if;
            if (settings.uprate_to_current) then
               uprateHousehold (mhh);
            end if;
            base_output  :=
               calcOneHHLegalAid (mhh, sys, normalClaim, settings.uprate_to_current);
            generate_matrix_for_hh( sys, mhh, settings, grossing_factor, ctl, base_output );
        end loop; -- households
        hh_io.Close (hh_file);
      end loop; -- years
      new_line;
   end  generate_searches;
  
  
   procedure print_searches( file_name : String ) is
      outfile : File_Type;
    begin
      put( "writing costs" );new_line;
      create( outfile, Out_File, file_name & ".sql");
      new_line( outfile );
      for r in Rate_Counter loop
         for l in Limit_Counter loop
            put( outfile, "insert into costs values " );
            put( outfile,"( " );
            put( outfile, format_utils.format( cells( r, l ).rate*100.0 ) );
            put( outfile, ", " );
            put( outfile,  format_utils.format( cells( r, l ).upper_limit ) );
            put( outfile, ", " );
            put( outfile,  format_utils.format( cells( r, l ).num_benefit_units ) );
            put( outfile, ", " );
            put( outfile,  format_utils.format( cells( r, l ).num_adults ) );
            put( outfile,  ", " );
            put( outfile,  format_utils.format( cells( r, l ).num_people ) );
            put( outfile, ", " );
            put( outfile,  format_utils.format( cells( r, l ).total_cost ) );
            put( outfile, ", " );
            put( outfile,  format_utils.format( cells( r, l ).total_num_cases ) );
            put( outfile,  " )" );
            put( outfile, ";" );
            new_line( outfile );
         end loop;
      end loop;
      put( "writing cost components" );new_line;
      new_line( outfile );new_line( outfile );
      for r in Rate_Counter loop
         for l in Limit_Counter loop
            for c in  LA_Costs_Component loop
               for t in LA_Problem_Type loop
                  put( outfile, "insert into breakdown values " );
                  put( outfile,"( " );
                  put( outfile, format_utils.format( cells( r, l ).rate*100.0 ) );
                  put( outfile, ", " );
                  put( outfile,  format_utils.format( cells( r, l ).upper_limit ) );
                  put( outfile, ", " );                  
                  put( outfile, "'"&LA_Costs_Component'Image( c )&"'" );
                  put( outfile, ", " );                  
                  put( outfile, "'"&LA_Problem_Type'Image( t )&"'" );
                  put( outfile, ", " );                  
                  put( outfile,  format_utils.format( cells( r, l ).costs_breakdown(c,t) ) );
                  put( outfile,  " )" );
                  put( outfile, ";" );
                  new_line( outfile );
               end loop;
            end loop;
         end loop;
      end loop;
      new_line( outfile );new_line( outfile );
      put( "writing income dist" );new_line;
      for r in Rate_Counter loop
         for l in Limit_Counter loop
            for i in Income_Counter   loop
               put( outfile, "insert into cases_by_income values " );
               put( outfile,"( " );
               put( outfile, format_utils.format( cells( r, l ).rate*100.0 ) );
               put( outfile, ", " );
               put( outfile,  format_utils.format( cells( r, l ).upper_limit ) );
               put( outfile, ", " );
               put( outfile,  format_utils.format( i ) );
               put( outfile, ", " );               
               put( outfile,  format_utils.format( cells( r, l ).cases_by_income( i )));
               put( outfile,  " )" );
               put( outfile, ";" );
               new_line( outfile );
            end loop;
         end loop;
      end loop;
      new_line( outfile );
      close( outfile );
   end print_searches;


end optimal_rate_searcher;
