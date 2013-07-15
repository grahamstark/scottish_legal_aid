--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
--  FIXME: use clauses all over the place here.
--
with base_model_types;      use base_model_types;
with model_household;       use model_household;
with la_calculator;         use la_calculator;
with la_parameters;         use la_parameters;
with brent;                 use brent;
with model_output;          use model_output;
with Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with format_utils;
pragma Elaborate_All (la_parameters);
with run_settings;           use run_settings;
with legal_aid_output_types; use legal_aid_output_types;
with scotland_specific_constants; use scotland_specific_constants;

-- with legal_aid_costs_model;
-- with format_utils;

package body legal_aid_optimiser is
   --
   --  Very simple set of routines for feeding our Brent optimiser with
   --  values. Note that we have the parameters and run settings here as
   --  global (but hidden) variables, which probably means that in a web
   --  setting this is not thread safe as the 2nd person to run this while
   --  it's still running will probably overwrite what's there.
   --
   newParameters      : Legal_Aid_Sys;
   basicNewParameters : Legal_Aid_Sys;
   default_parameters  : Legal_Aid_Sys;

   ctype    : Claim_Type := normalClaim;
   settings : run_settings.Settings_Rec;

   PLOTTER_URL : constant String := "http://www.virtual-worlds.biz/legalaid/plotter.php?data=";

   --
   --  make a simple plotter URL with x,ys as comma-seperated pairs and each pair
   --  seperated with ";". Hard wired to point to a php graph servlet in
   --http://www.virtual-worlds.biz/legalaid/
   --
   function data_To_URL (points : Points_Array; num_points : Integer) return String is
      outs : Unbounded_String := To_Unbounded_String (PLOTTER_URL);
   begin
      for i in  1 .. num_points loop
         outs := outs &
                 format_utils.format (points (i).x * 100.0) &
                 "," &
                 format_utils.format (points (i).y);
         if (i < num_points) then
            outs := outs & ";";
         end if;
      end loop;
      return To_String (outs);
   end data_To_URL;

   --
   --  This is our disruption measure returns (e.g. 3.0 for a movement from
   --  passported to no entitlement, 1.0 for passported => full, and so on.
   --
   function Movement (state1, state2 : Legal_Aid_State) return real is
      s1, s2 : real;
   begin
      s1 := real (Legal_Aid_State'Pos (state1));
      s2 := real (Legal_Aid_State'Pos (state2));
      return abs (s1 - s2);
   end Movement;

   --
   --  very basic legal aid only run, returning an error index
   --  computed from the differences between the la_States under sys1 and 2
   --  measure depends on the target option in the run settings.
   --
   function doBasicRun return Target_Array is
      sz                                                                           : Integer := 0;
      mhh                                                                          :
        model_household.Model_Household_Rec;
      output                                                                       :
        array (1 .. 2) of LAOutputArray;
      totals                                                                       :
        array (1 .. 2) of State_Array := (1 => (others => 0.0), 2 => (others => 0.0));
      targetting_totals                                                            :
        array (1 .. 2) of real := (others => 0.0);
      hh_file                                                                      :
        hh_io.File_Type;
      targetting_output                                                            : Target_Array
         := (others => 0.0);
      cost_dev, off_diagonal, perfect_targetting_score, cost1, cost2, cost_measure : real := 0.0;
      latype                                                                       : constant
        LA_Costs_System_Type := civil;
--         legal_aid_costs_model.get_costs_type_from_param_types (newParameters.sys_type, ctype);
      alexys_error_index                                                           : real := 0.0;
      grossing_factor                                                              : real := 0.0;
      num_years                                                                    : real :=
         real (settings.end_year - settings.start_year + 1);
      startHH, endHH : integer;
   begin

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
            mhh             := model_household.load (hh_file, href);
            grossing_factor := mhh.grossing_factor / num_years;
            if (la_parameters.is_annual_system (settings.run_type)) then
               model_household.annualise (mhh);
            end if;
            if (settings.uprate_to_current) then
               uprateHousehold (mhh);
            end if;
            --if (settings.split_benefit_units) then
            --        mhh := model_household.break_up_household (mhh);
            --end if;
            output (1) :=
               calcOneHHLegalAid (mhh, default_parameters, ctype, settings.uprate_to_current);

            output (2) :=
               calcOneHHLegalAid (mhh, newParameters, ctype, settings.uprate_to_current);

            for bu in  1 .. mhh.num_benefit_units loop
               perfect_targetting_score := perfect_targetting_score + (grossing_factor);
               off_diagonal             := off_diagonal +
                                           (grossing_factor *
                                            Movement
                                               (output (1) (bu).la_State,
                                                output (2) (bu).la_State));

               for sys_no in  1 .. 2 loop
                  totals (sys_no) (output (sys_no) (bu).la_State)   :=
                    totals (sys_no) (output (sys_no) (bu).la_State) + grossing_factor;
               end loop;

               for sys_no in  1 .. 2 loop
                  targetting_totals (sys_no) := targetting_totals (sys_no) +
                                                (grossing_factor *
                                                 real (output (sys_no) (bu).targetting_index));
               end loop;
               cost1              := 0.0;
               -- cost1 +
                                     -- grossing_factor *
                                     -- output (1) (bu).costs (latype, expected_gross_costs,
                 -- all_problems);
               cost2  := 0.0;
               -- := cost2 +
                                     -- grossing_factor *
                                     -- output (2) (bu).costs (latype, expected_gross_costs,
                 -- all_problems);
               alexys_error_index := alexys_error_index +
                                     (grossing_factor *
                                      real (la_calculator.ErrorIndex
                                               (mhh.benefit_units (bu),
                                                output (1) (bu),
                                                output (2) (bu))));
               Text_IO.Put ("alexys_error_index is now " & alexys_error_index'Img);
            end loop; -- systems
         end loop; -- households
         hh_io.Close (hh_file);
      end loop; -- years

      --
      --  squared proportional difference in costs
      --
      cost_dev     := (cost1 - cost2) / cost1;
      cost_measure := 100.0 * abs (cost_dev);
      Text_IO.Put
        ("optimise; got costs index as " &
         format_utils.format (cost_measure) &
         "cost_dev = " &
         format_utils.format (cost_dev) &
         "costs1 = " &
         format_utils.format (cost1) &
         "costs2 = " &
         format_utils.format (cost2));
      Text_IO.New_Line;
      --  the best possible targeting score is 3, so if we accumulate
      --                -- 3*gf we get total best possible scores. FIXME 3 as constant
      --  perfect targeting is then 1.0 so we want to express this as a targetting error
      --so we're mininising
      --  alexys index has maximum of 30 (10 deciles x 3 state jumps); so exporess as
      --100/30*the score
      targetting_output (targetting_index) := 10.0 / 3.0 *
                                              (alexys_error_index / perfect_targetting_score);
      --  100.0 *  (1.0 - (targetting_totals (2) / (3.0 * perfect_targetting_score)));
      --  scale the other scores up arbitrarily by 100 so it's roughtly in line
      --  with the others
      targetting_output (off_diagonal_index) := (100.0 * off_diagonal) /
                                                perfect_targetting_score;
      targetting_output (costs_index)        := cost_measure;
      --  frs_binary_reads.CloseFiles;
      return targetting_output;
   end doBasicRun;

   --
   --  changes upper and lower income limits in the reformed parameters (a hidden global
   --variable)
   --  by mult percent
   --
   function change_limits_from_base (mult : money) return Legal_Aid_Sys is
      params : Legal_Aid_Sys;
   begin
      params                             := basicNewParameters;
      params.lower_limit (income, ctype) := params.lower_limit (income, ctype) * mult;
      params.upper_limit (income, ctype) := params.upper_limit (income, ctype) * mult;
      return params;
   end change_limits_from_base;

   --
   --  wraps the taxben runner above in a function that can be called by the
   --  optimiser routine.
   --
   function minimand (control : brent.Control_Rec; m : real) return brent.Optimisation_Output is
      error           : real           := 0.0;
      mult            : constant money := money (m);
      targetting_info : Target_Array;
      output          : brent.Optimisation_Output;
   begin
      newParameters := change_limits_from_base (mult);
      --  settings.target := Target_Type'Val( control.option1 );
      targetting_info := doBasicRun;
      --
      -- FIXME : move this to a proper utility function
      -- because of the callback structure, we have to store
      -- make sure they sum to 1.0 : disruption and cost are in front
      -- end so targetting is not independent. FIXME: we can move this somewhere?
      settings.targetting_weights (targetting_index) := 1.0 -
                                                        settings.targetting_weights (costs_index) -
                                                        settings.targetting_weights (
        off_diagonal_index);
      for m in  Target_Type loop
         error := error + (targetting_info (m) * settings.targetting_weights (m));
         Text_IO.Put
           ("mult now " &
            mult'Img &
            " error now " &
            error'Img &
            " targetting_info(" &
            m'Img &
            ") weight = " &
            settings.targetting_weights (m)'Img);
         Text_IO.New_Line;
         output.intermediate_data (Target_Type'Pos (m) + 1)  := real (targetting_info (m));
      end loop;
      Text_IO.Put (" returning with error " & error'Img);
      output.minimum := error;
      return output;
   end minimand;

   --
   --   Driver routine for the minimisation.
   --   Calls the Brent routine with mininmand above as a parameter.
   --
   function minimise
     (params : Legal_Aid_Sys;
      sets   : run_settings.Settings_Rec)
      return   Optimisation_Output
   is
      optimum_x, optimum_y : real                    := 0.0;
      tol                  : constant real           := real (money'Delta);
      control              : brent.Control_Rec;
      error_condition      : brent.Error_Conditions  := NoError;
      rpoints              : brent.Point_Array;
      optim_out            : Optimisation_Output;
      intermediate         : Intermediate_Data_Array := (others => 0.0);
   begin
      newParameters      := params;
      basicNewParameters := params;
      settings           := sets;
      getBaseSystem (settings, default_parameters, ctype);
      optim_out.num_iterations := 0;
      control.start            := 0.0;
      control.stop             := 3.0;
      control.tol              := tol;
      control.incr             := tol;
      --  control.option1 := Target_Type'Pos(sets.target);

      brent.Optimise
        (control,
         minimand'Access,
         optimum_x,
         optimum_y,
         rpoints,
         intermediate,
         optim_out.num_iterations,
         error_condition);
      optim_out.multiplier := money (optimum_x);
      optim_out.error      := money (optimum_y);
      for i in  1 .. optim_out.num_iterations loop
         optim_out.points (i).x := money (rpoints (i).x);
         optim_out.points (i).y := money (rpoints (i).y);
      end loop;
      optim_out.num_points := optim_out.num_iterations;
      Text_IO.Put ("optim_out.num_points = " & optim_out.num_points'Img);
      for m in  Target_Type loop
         optim_out.intermediates (m) := intermediate (Target_Type'Pos (m) + 1);
      end loop;

      return optim_out;
   end minimise;

   --
   --  Used for graphics, mainly.
   --  Just call the minimand routine for a fixed set of x-values and
   --  return the results as an array of pounts.
   --
   function iterate
     (params         : Legal_Aid_Sys;
      sets           : run_settings.Settings_Rec;
      num_iterations : Integer;
      start_Point    : real := 0.5;
      width          : real := 1.0)
      return           Points_Array
   is
      points  : Points_Array;
      incr    : constant real := width / real (num_iterations);
      mult    : real          := start_Point;
      control : brent.Control_Rec;
   begin
      newParameters      := params;
      basicNewParameters := params;
      settings           := sets;
      getBaseSystem (settings, default_parameters, ctype);
      --  control.option1 := Target_Type'Pos(sets.target);
      for i in  1 .. num_iterations loop
         points (i).x := money (mult);
         points (i).y := money (minimand (control, mult).minimum);
         mult         := incr + mult;
      end loop;
      return points;
   end iterate;

end legal_aid_optimiser;
