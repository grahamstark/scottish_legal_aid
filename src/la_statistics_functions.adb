--
--  $Author:$
--  $Date:$
--  $Revision:$
--
with model_household;             use model_household;
with frs_to_model_mapper;
with la_parameters;               use la_parameters;
with base_model_types;            use base_model_types;
with Text_IO;
with format_utils;
with FRS_Enums;                   use FRS_Enums;
with format_utils;
with html_utils;
with la_calculator;               use la_calculator;
with Legal_Aid_Output_Types;
with scotland_specific_constants; use scotland_specific_constants;
with run_settings;
with legal_aid_runner; use legal_aid_runner;
with Costs_Model; use Costs_Model;
with Model_Output;


package body la_statistics_functions is

   type grossed_ungrossed is (grossed, ungrossed);
   
   type Scenario_Type is ( base_case, b, c, d, e, f );

   type Region_Counts is
     array (FRS_Enums.Standard_Region, 2003 .. 2004, grossed_ungrossed) of real;
   type Income_Counts is
     array (model_household.Income_Items, 2003 .. 2004, grossed_ungrossed) of real;
   type Tenure_Counts is array (FRS_Enums.Tenure_Type, 2003 .. 2004, grossed_ungrossed) of real;

   defaultParameters : Legal_Aid_Sys;
   newParameters     : Legal_Aid_Sys;
   
   --
   -- 
   -- 
   --
   function Get_Parameters_For_Scenario( scen : Scenario_Type ) return Legal_Aid_Sys is
      sys : Legal_Aid_Sys := Get_Default_System;
   begin
      --if( use_new_contributions ) then
      --   sys.contributions( income ) := Make_Proposed_Contributions( use_current_below_upper );
      --end if;
      if( scen /= base_case ) then
         sys.contributions (income).contribution_band :=
           (
            1      => 1_645.0,
            2      => 6_785.0,
            3      => 12_005.0,
            4      => 22_005.0,
            5      => 27_005.0,
            6      => money'Last,
            others => 0.0);
         sys.contributions (income).numContributions := 6;
      end if;
      case scen is
      when base_case => null;
      when b => 
                sys.contributions (income).contribution_proportion := ( 1=>One_Third, 2=>One_Third, 3=>0.40, 4=>0.75, 5=>1.0, 6=>1.0, others=>0.0 );
      when c => sys.contributions (income).contribution_proportion := ( 1=>0.25, 2=>0.36, 3=>0.40, 4=>0.75, 5=>1.0, 6=>1.0, others=>0.0 );
      when d => sys.contributions (income).contribution_proportion := ( 1=>One_Third, 2=>One_Third, 3=>0.50, 4=>1.0, 5=>1.0, 6=>1.0, others=>0.0 );
      when e => sys.contributions (income).contribution_proportion := ( 1=>One_Third, 2=>One_Third, 3=>0.50, 4=>0.75, 5=>0.75, 6=>1.0, others=>0.0 );
      when f => sys.contributions (income).contribution_proportion := ( 1=>0.25, 2=>0.30, 3=>0.40, 4=>0.75, 5=>0.75, 6=>1.0, others=>0.0 );
      end case;   
      return sys;
   end Get_Parameters_For_Scenario;


   procedure generate_tables ( outf : Text_Io.File_Type; scotland_only : Boolean) is
      sz             : Integer       := 0;
      mhh            : model_household.Model_Household_Rec;
      hh_file        : hh_io.File_Type;
      reg_counts     : Region_Counts := (others => (others => (others => 0.0)));
      inc_counts     : Income_Counts := (others => (others => (others => 0.0)));
      ten_counts     : Tenure_Counts := (others => (others => (others => 0.0)));
      in_scotland    : Boolean       := False;
      startHH, endHH : Integer;
   begin
      for year in  2003 .. 2004 loop
         model_household.initialise (hh_file, year, sz);
         if (scotland_only) then
            startHH := FILE_POSITIONS (year, start_pos);
            endHH   := FILE_POSITIONS (year, end_pos);
         else
            startHH := 1;
            endHH   := sz;
         end if;
         for href in  startHH .. endHH loop
            mhh := model_household.load (hh_file, href);
            if (not scotland_only) then
               if ((mhh.standard_region = scotland) and (not in_scotland)) then
                  in_scotland := True;
                  text_IO.Put ( outf, "<p> YEAR " & year'Img & "  1ST SCOTTISH HOUSEHOLD " & href'Img&"</p>");
                  Text_IO.New_Line( outf );
               end if;
               if ((mhh.standard_region /= scotland) and (in_scotland)) then
                  in_scotland := False;
                  text_IO.Put ( outf, "<p> YEAR " & year'Img & "  LAST SCOTTISH HOUSEHOLD " & href'Img&"</p>");
                  Text_IO.New_Line( outf );
               end if;
            end if;

            reg_counts (mhh.standard_region, year, grossed)   :=
              reg_counts (mhh.standard_region, year, grossed) + mhh.grossing_factor;
            reg_counts (mhh.standard_region, year, ungrossed) :=
              reg_counts (mhh.standard_region, year, ungrossed) + 1.0;
            ten_counts (mhh.tenure, year, grossed)            :=
              ten_counts (mhh.tenure, year, grossed) + mhh.grossing_factor;
            ten_counts (mhh.tenure, year, ungrossed)          :=
              ten_counts (mhh.tenure, year, ungrossed) + 1.0;
            for buno in  1 .. mhh.num_benefit_units loop
               for adno in  head .. mhh.benefit_units (buno).last_adult loop

                  for inc in  Income_Items'First .. Income_Items'Last loop
                  -- if( (mhh.benefit_units (buno).adults (adno).age > 60 ) and ( inc = income_support )) then
                        -- inc_to_add = guaranteed_pension_credit;
                  -- else
                     -- inc_to_add := inc;
                  -- end if;
                     if (mhh.benefit_units (buno).adults (adno).incomes (inc) /= 0.0) then
                        inc_counts (inc, year, grossed)   := inc_counts (inc, year, grossed) +
                                                             mhh.grossing_factor;
                        inc_counts (inc, year, ungrossed) := inc_counts (inc, year, ungrossed) +
                                                             1.0;
                     end if;
                  end loop; -- incomes
               end loop; -- ads
            end loop; -- bus
         end loop; -- hhld
         hh_io.Close (hh_file);
      end loop; -- year

      for year in  2003 .. 2004 loop
         text_IO.Put ( outf, "<h2>YEAR  " & year'Img & "</h2>");
         Text_IO.New_Line( outf );

         text_IO.Put ( outf, "<h3>TENURE</h3>");
         Text_IO.New_Line( outf );
         text_IO.Put ( outf, "<table class='datatable' width='90%'>");
         Text_IO.New_Line( outf );

         for t in  FRS_Enums.Tenure_Type'First .. FRS_Enums.Tenure_Type'Last loop
            Text_IO.Put
              ( outf, "<tr><th>" &
               FRS_Enums.pretty_print (t) &
               "</th><td>" &
               format_utils.format_with_commas (ten_counts (t, year, grossed)) &
               "</td><td>" &
               format_utils.format_with_commas (ten_counts (t, year, ungrossed)) &
               "</td></tr>");
            Text_IO.New_Line( outf );
         end loop;
         text_IO.Put ( outf, "</table>");
         Text_IO.New_Line( outf );
         text_IO.Put ( outf, "<h3>REGION</h3>");
         Text_IO.New_Line( outf );
         text_IO.Put ( outf, "<table class='datatable'  width='90%'>");
         Text_IO.New_Line( outf );
         for t in  FRS_Enums.Standard_Region'First .. FRS_Enums.Standard_Region'Last loop
            Text_IO.Put
                ( outf,
                 "<tr><th>" &
               FRS_Enums.pretty_print (t) &
               "</th><td>" &
               format_utils.format_with_commas (reg_counts (t, year, grossed)) &
               "</td><td>" &
               format_utils.format_with_commas (reg_counts (t, year, ungrossed)) &
               "</td></tr>");
            Text_IO.New_Line( outf );
         end loop;
         Text_IO.New_Line( outf );
         text_IO.Put ( outf, "</table>");
         Text_IO.New_Line( outf );
         text_IO.Put ( outf, "<h3>Incomes</h3>");
         Text_IO.New_Line( outf );
         text_IO.Put ( outf, "<table class='datatable'  width='90%'>");
         Text_IO.New_Line( outf );
         for t in  Income_Items'First .. Income_Items'Last loop
            Text_IO.Put
              ( outf, "<tr><th>" &
               t'Img &
               "</th><td>" &
               format_utils.format_with_commas (inc_counts (t, year, grossed)) &
               "</td><td>" &
               format_utils.format_with_commas (inc_counts (t, year, ungrossed)) &
               "</td></tr>");
            Text_IO.New_Line( outf );
         end loop;
         text_IO.Put ( outf, "</table>");
         Text_IO.New_Line( outf );
         Text_IO.New_Line( outf );
      end loop;

   end generate_tables;
   --
   --  very basic legal aid only run, returning an error index
   --  computed from the differences between the la_States under sys1 and 2
   --  measure depends on the target option in the run settings.
   --

   NUM_UPPER_LIMITS : constant integer := 100;
   INCREMENT : constant Money := 250.0;
   type all_breakdowns_array is array(1..NUM_UPPER_LIMITS+3) of FourFT2.Cell_Contents;
   type All_Values_Array is array( 1..2, 1 .. NUM_UPPER_LIMITS+3 ) of FourFT2.Values_Array;



   procedure print_Breakdown_Line(
      outf : Text_IO.File_Type;
      title : String;
      all_breakdowns : all_breakdowns_array;
      whichBreakdown, which_row : integer ) is
   begin
      text_io.put( outf, """" );
      text_io.put( outf, title );
      text_io.put( outf, """" );
      text_io.put( outf, "," );
      for i in 1 .. NUM_UPPER_LIMITS+3 loop
         text_io.put( outf, all_breakdowns(i)( whichBreakdown )( which_row )'Img );
         text_IO.Put ( outf,  "," );
      end loop;
      Text_IO.New_Line( outf );
   end print_Breakdown_Line;

   procedure print_Value_Line(
      outf : Text_IO.File_Type;
      title : String;
      all_values : All_Values_Array;
      which_sys,
      which_row : integer ) is

   begin
      text_io.put( outf, """" );
      text_io.put( outf, title );
      text_io.put( outf, """" );
      text_io.put( outf, "," );
      for i in 1 .. NUM_UPPER_LIMITS+3 loop
         text_io.put( outf, all_values( which_sys, i )( which_row )'Img );
         text_IO.Put ( outf,  "," );
      end loop;
      Text_IO.New_Line( outf );
   end print_Value_Line;

   procedure print_breakdowns ( outf : Text_IO.File_Type;
                                all_breakdowns : all_breakdowns_array;
                                all_values : All_Values_Array;
                                base_upper_limit : Money;
                                print_only_takeup : Boolean ) is

      upper_limit : money := base_upper_limit;
      p : integer := 9;
   begin
      text_IO.Put ( outf,  "upper limit,PASSPORTED,FULL_ENTITLED,PARTIALLY ENTITLED,," );
      for i in 1 .. NUM_UPPER_LIMITS loop
         text_IO.Put ( outf,  upper_limit'Img );
         text_io.put ( outf, "," );
         upper_limit := upper_limit + INCREMENT;
      end loop;
      Text_IO.New_Line ( outf );
      text_io.put( outf, "COST ESTIMATES " );
      Text_IO.New_Line( outf );
      text_io.put( outf, "SYSTEM 2"  );
      Text_IO.New_Line( outf );
      print_Value_Line( outf, "Potential Offers,", all_values, 2, 1 );
      print_Value_Line( outf, "Predicted Takeup,", all_values, 2, 2 );
      print_Value_Line( outf, "Predicted Gross Costs,", all_values, 2, 3 );
      print_Value_Line( outf, "Predicted Net Costs,", all_values, 2, 4 );
      print_Value_Line( outf, "Predicted Contributions,", all_values, 2, 5 );
      print_Value_Line( outf, "Expenses From Opponents,", all_values, 2, 6 );
      print_Value_Line( outf, "Amounts Awarded,", all_values, 2, 7 );
      print_Value_Line( outf, "Total Income,", all_values, 2, 8 );
      for ctype in Legal_Aid_Output_Types.LA_Problem_Type loop
         print_Value_Line( outf, "Total Income :" & ctype'Img&",", all_values, 2, p );
         p := p + 1;
      end loop;
      for ctype in Legal_Aid_Output_Types.LA_Problem_Type loop
         print_Value_Line( outf, "Gross Costs :" & ctype'Img&",", all_values, 2, p );
         p := p + 1;
      end loop;
      
      Text_IO.New_Line ( outf );
      if( print_only_takeup )then
         return;
      end if;
      text_io.put( outf, "ENTITLEMENT BREAKDOWNS" );
      Text_IO.New_Line( outf );
      text_io.put( outf, "ETHNIC " );
      Text_IO.New_Line( outf );
      p := 0;
      for eth in Aggregated_Ethnic_Group'First .. Aggregated_Ethnic_Group'Last loop
         p := p + 1;
         print_Breakdown_Line(
            outf,
            FRS_Enums.pretty_print( eth ),
            all_breakdowns,
            1,
            p );
      end loop;

      text_io.put( outf, "GENDER " );
      text_io.new_line( outf );
      p := 0;
      for eth in Gender'First .. Gender'Last loop
         p := p + 1;
         print_Breakdown_Line(
            outf,
            FRS_Enums.pretty_print( eth ),
            all_breakdowns,
            2,
            p );
      end loop;

      text_io.put( outf, "MARITAL STATUS " );
      text_io.new_line( outf );
      p := 0;
      for eth in Marital_Status'First .. Marital_Status'Last loop
         p := p + 1;
         print_Breakdown_Line(
            outf,
            FRS_Enums.pretty_print( eth ),
            all_breakdowns,
            3,
            p );
      end loop;

      text_io.put( outf, "TENURE TYPE" );
      text_io.new_line( outf );
      p := 0;
      for eth in Tenure_Type'First .. Tenure_Type'Last loop
         p := p + 1;
         print_Breakdown_Line(
            outf,
            FRS_Enums.pretty_print( eth ),
            all_breakdowns,
            4,
            p );
      end loop;

      text_io.put( outf, "ECONOMIC STATUS" );
      text_io.new_line( outf );
      p := 0;
      for eth in Benefit_Unit_Economic_Status'First .. Benefit_Unit_Economic_Status'Last loop
         p := p + 1;
         print_Breakdown_Line(
            outf,
            FRS_Enums.pretty_print( eth ),
            all_breakdowns,
            5,
            p );
      end loop;

      text_io.put( outf, "BENEFIT UNIT TYPE" );
      text_io.new_line( outf );
      p := 0;
      for eth in HBAI_Benefit_Unit_Type'First .. HBAI_Benefit_Unit_Type'Last loop
         p := p + 1;
         print_Breakdown_Line(
            outf,
            FRS_Enums.pretty_print( eth ),
            all_breakdowns,
            6,
            p );
      end loop;

      text_io.put( outf, "AGE GROUP" );
      text_io.new_line( outf );
      p := 0;
      for eth in Age_Group'First .. Age_Group'Last loop
         p := p + 1;
         print_Breakdown_Line(
            outf,
            FRS_Enums.pretty_print( eth ),
            all_breakdowns,
            7,
            p );
      end loop;

      text_io.put( outf, "DISABLED INDICATOR" );
      text_io.new_line( outf );
      p := 0;
      for eth in BU_Disabled_Indicator'First .. BU_Disabled_Indicator'Last loop
         p := p + 1;
         print_Breakdown_Line(
            outf,
            FRS_Enums.pretty_print( eth ),
            all_breakdowns,
            9,
            p );
      end loop;

      text_io.put( outf, "REGIONAL STRATIFIER" );
      text_io.new_line( outf );
      p := 0;
      for eth in Scottish_Regional_Stratifier'First .. Scottish_Regional_Stratifier'Last loop
         p := p + 1;
         print_Breakdown_Line(
            outf,
            FRS_Enums.pretty_print( eth ),
            all_breakdowns,
            11,
            p );
      end loop;

      text_io.new_line( outf );
   end print_breakdowns;

   -- procedure printBreakdowns

   procedure generate_upper_limits( outf : Text_IO.File_Type; scen : Scenario_Type ) is
      
      print_only_breakdowns : constant boolean := true; -- scen > base_case;
      
      sys : Legal_Aid_Sys := Get_Parameters_For_Scenario( scen );
      settings      : run_settings.Settings_Rec;
      output_tables  : Legal_Aid_Runner.Output_Tables;
      benefit_unit_level_breakdowns : All_Breakdowns_array;
      benefit_unit_level_values  : All_Values_Array;
      
      base_upper_limit : money;
   begin      
      settings := run_settings.DEFAULT_RUN_SETTINGS;
      base_upper_limit := sys.upper_limit( income, normalClaim );
      income_limit_loop:
         for i in 1 .. NUM_UPPER_LIMITS loop
            output_tables := legal_aid_runner.doRun( sys, "", settings );
            sys.upper_limit( income, normalClaim ) := sys.upper_limit( income, normalClaim ) + INCREMENT;
            --
            -- the d scenario terminates at 25,000
            -- so, make the final iteration exactly 25,000 and bale out at the one above that
            -- 
            if( scen = d ) then
               if( sys.upper_limit( income, normalClaim ) = 25_000.0+INCREMENT ) then
                  exit income_limit_loop;
               elsif( sys.upper_limit( income, normalClaim ) > 25_000.0 )then
                  sys.upper_limit( income, normalClaim ) := 25_000.0;               
               end if;
            end if;
            if( i = 1 ) then
               benefit_unit_level_breakdowns (1) := output_tables( benefit_unit ).col_totals ( 1 ).breakdown;
               benefit_unit_level_values(1,1) := output_tables( benefit_unit ).col_totals( 1 ).pre_values;
               benefit_unit_level_values(2,1) := output_tables( benefit_unit ).col_totals( 1 ).post_values;
               
               benefit_unit_level_breakdowns (2) := output_tables( benefit_unit ).col_totals ( 2 ).breakdown;
               benefit_unit_level_values(1,2) := output_tables( benefit_unit ).col_totals( 2 ).pre_values;
               benefit_unit_level_values(2,2) := output_tables( benefit_unit ).col_totals( 2 ).post_values;
               
               benefit_unit_level_breakdowns (3) := output_tables( benefit_unit ).col_totals ( 3 ).breakdown;
               benefit_unit_level_values(1,3) := output_tables( benefit_unit ).col_totals( 3 ).pre_values;
               benefit_unit_level_values(2,3) := output_tables( benefit_unit ).col_totals( 3 ).post_values;
               
            else
               benefit_unit_level_breakdowns(i+2) := output_tables( benefit_unit ).cells( 4 )( 3 ).breakdown;
               benefit_unit_level_values(1,i+2) := output_tables( benefit_unit ).cells( 4 )( 3 ).pre_values;
               benefit_unit_level_values(2,i+2) := output_tables( benefit_unit ).cells( 4 )( 3 ).post_values;
            end if;
         end loop income_limit_loop;
      text_io.put( "bu level ");text_io.new_line;
      print_breakdowns( outf, benefit_unit_level_breakdowns, benefit_unit_level_values, base_upper_limit, print_only_breakdowns );
   end generate_upper_limits;

   procedure generate_upper_limits is
      outf : Text_IO.File_Type;
   begin
      Text_IO.create( outf, text_io.out_file, "scenarios_a_2_f.csv" );
      for scen in Scenario_Type loop
         text_io.put( outf, "Case::" & scen'Img );
         text_io.new_line( outf );
         generate_upper_limits( outf, scen );
      end loop;
      text_io.close( outf );
   end generate_upper_limits;

   procedure generate_model_statistics is
      outf : Text_IO.File_Type;
   begin
      Text_IO.create( outf, text_io.out_file, "model_data_dump.html" );

      text_IO.Put ( outf, html_utils.HTML_HEADER_STRING);
      text_IO.Put ( outf, "<h1>UK</h1>");
      generate_tables ( outf, False);
      text_IO.Put ( outf, "<h1>Scotland</h1>");
      generate_tables ( outf, True);
      text_IO.Put ( outf, "</body></html>");
      Text_IO.New_Line( outf );

      Text_IO.Close( outf );

   end generate_model_statistics;

   procedure generate_counts_in_each_state is
      sys : Legal_Aid_Sys;
      sz  : Integer := 0;
      startHH, endHH : integer := 0;
      grossing_factor : real := 0.0;
      default_parameters : Legal_Aid_Sys;
      settings      : run_settings.Settings_Rec;
      mhh                    : model_household.Model_Household_Rec;
      outfile                : Text_IO.File_Type;
      hh_file                : hh_io.File_Type;
      output                 : Model_Output.LAOutputArray;
      ager : costs_model.Age_Range;
      num_years              : real                      :=
         real (settings.end_year - settings.start_year + 1);
      sex  : Gender;
      popn : Population_State_Array := ( others=>(others=>(others=> 0.0 )));
      values : FourFT2.Values_Array := (others => 0.0);
   begin

      settings := run_settings.DEFAULT_RUN_SETTINGS;
      default_parameters := get_default_system;
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
            mhh := model_household.load (hh_file, href);
            grossing_factor        := mhh.grossing_factor / num_years;
            if (la_parameters.is_annual_system (settings.run_type)) then
               model_household.annualise (mhh);
            end if;
            if (settings.uprate_to_current) then
               uprateHousehold (mhh);
            end if;
            output  :=
               calcOneHHLegalAid (mhh, default_parameters, normalClaim, settings.uprate_to_current);
            for buno in 1 .. mhh.num_benefit_units loop

                for adno in head .. mhh.benefit_units( buno ).last_adult loop
                        ager := costs_model.Get_Age_Range( mhh.benefit_units( buno ).adults( adno ).age );
                        sex := mhh.benefit_units( buno ).adults( adno ).sex;
                        popn( output(buno).la_State, ager, sex ) := popn( output(buno).la_State, ager, sex ) + grossing_factor;
                end loop; -- adults
                for chno in 1 .. mhh.benefit_units( buno ).num_children loop
                        ager := costs_model.Get_Age_Range( mhh.benefit_units( buno ).children( chno ).age );
                        sex := mhh.benefit_units( buno ).children( chno ).sex;
                        popn( output(buno).la_State, ager, sex ) := popn( output(buno).la_State, ager, sex ) + grossing_factor;
                end loop; -- children
            end loop; -- bus
        end loop; -- households
        hh_io.Close (hh_file);

      end loop; -- years
      text_io.put( " got to end " );
      Text_IO.create( outfile, text_io.out_file, "populations.ada" );
      text_io.put( "outfile created " );
      for state in legal_aid_output_types.Legal_Aid_State loop
         for ager in costs_model.Age_Range loop
            for sex in Gender loop
               text_io.put( outfile, "   POPNS( " & state'Img & ", " & ager'Img & ", " & sex'Img & " ) := "
                   & popn( state, ager, sex )'Img & ";" );
               text_io.new_line( outfile );
            end loop; -- age
         end loop; -- gender
      end loop; -- state
      Text_IO.Close( outfile );
   end generate_counts_in_each_state;

   procedure generate_costs_tests is
      use Legal_Aid_Output_Types;
      use Legal_Aid_Output_Types;
      use Format_Utils;
      off1  : Real;
      prop1 : Contribution_Proportion;
      av1   : Money;
      take_array : LA_Takeup_Array;
      sums   : LA_Costs_Component_Array;
      contrib : Money := 0.0;
      avcost  : Money := 0.0;
   begin
      off1 := Costs_Model.Get_Offer_Rate( fullyEntitled, 61, Male, divorce );
      Text_IO.put( "offer rate per 1000 " &  format(off1 * 1000.0 ) );
      prop1 := Costs_Model.Get_Proportion_Of_Offers_That_Are_Economic( divorce, 2000.0, false );
      Text_IO.put( "propn economic by caseload " &  format(prop1.by_caseload) & "  by values " &  format(prop1.by_value) );
      av1 := Costs_Model.Get_Average_Cost( divorce );
      Text_IO.put( "av cost " & av1'Img );

      take_array := Costs_Model.Calculate_One_Position( 61, male, fullyEntitled, 0.0 );
      for ptype in LA_Problem_Type loop
         for tt in LA_Costs_Component loop
            Text_IO.put( ptype'Img & "   " & tt'Img & "  " &
                         format(take_array( civil, tt, ptype )*100.0) );
            text_io.new_line;
         end loop;
      end loop;
      
        for i in 1 .. 50 loop
                text_io.put( "CONTRIB : " & format( contrib ));text_io.new_line;
                take_array := Costs_Model.Calculate_One_Position( 61, male, partiallyEntitled, contrib );
                for ptype in LA_Problem_Type loop
                        avcost := Costs_Model.Get_Average_Cost( ptype );
                        Text_IO.put( "Average Cost " & avcost'Img );text_io.new_line;
                        for tt in LA_Costs_Component loop
                                Text_IO.put( ptype'Img & "   " & tt'Img & "  " &
                                                                 (format(take_array( civil, tt, ptype ))));
                                text_io.new_line;
                        end loop;
                end loop;
                contrib := contrib + 100.0;
        end loop;

        sums := costs_model.Sum_Over_Problems( take_array );
        for tt in LA_Costs_Component loop
            Text_IO.put( tt'Img & "  " &
                         format(sums( tt )*100.0) );
            text_io.new_line;
        end loop;

   end generate_costs_tests;
   
   procedure check_costs_model is
   propn : Money := 0.0;
   begin
         null;
   end check_costs_model;
   
end la_statistics_functions;
