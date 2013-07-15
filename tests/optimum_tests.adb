--
--  $Author: graham_s $
--  $Date: 2010-02-15 13:23:15 +0000 (Mon, 15 Feb 2010) $
--  $Revision: 8643 $
--
with AUnit.Assertions;              use AUnit.Assertions;
with brent; use brent;
with base_model_types; use base_model_types;
with la_parameters; use la_parameters;
with model_household; use model_household;
with legal_aid_runner; use legal_aid_runner;
with legal_aid_optimiser;use legal_aid_optimiser;
with text_io; use text_io;
with run_settings;

package body optimum_tests is

        procedure Set_Up ( T : in out Test_Case ) is
        begin
                null;
        end Set_Up;

        function XSQ ( control : Brent.Control_Rec; m : real ) return  Brent.Optimisation_Output is
               outp : Brent.Optimisation_Output := ( minimum=>0.0, intermediate_data=>(others=>0.0));
        begin
                outp.minimum := (m ** 2);
                return outp;
        end XSQ;

        function XSQM ( control : Brent.Control_Rec; m : real ) return Brent.Optimisation_Output is
               outp : Brent.Optimisation_Output := ( minimum=>0.0, intermediate_data=>(others=>0.0));
        begin
                outp.minimum := real(money(m) * money(m));
                return outp;
        end XSQM;

         procedure test_optimise_3(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
                params : Legal_Aid_Sys; sets : run_settings.Settings_Rec;
                points : Points_Array;
                mult, error : Money := -999.99;
                num_iterations : Integer := 0;
                outp : legal_aid_optimiser.Optimisation_Output;

        begin
                params := Get_Default_System;
		params.allow( income ).num_child_age_limits := 3; -- 1, really
                params.allow( income ).child_allowance( 1 ) := 0.0;   -- gf is 26.20*52.0; --  1362.39
                params.allow( income ).child_allowance( 2 ) := 0.0;  --  31.75*52.0; --  1651.0
                params.allow( income ).child_allowance( 3 ) := 0.0;
                params.allow( income ).partners_allowance := 0.0;   --  1547.0
                params.allow ( income ).other_dependants_allowance := 0.0;
                outp := minimise ( params, sets ); --, mult, error, points, num_iterations );
                for i in 1 .. num_iterations loop
                        put ( " optimise 3 " & i'Img & " mult = " & points (i).x'Img &
                             " error " & points (i).y'Img );
                        new_line;

                end loop;
		assert( mult > 1.0, "optimise3 should minimise at > 1.0; actually " & mult'Img );
		assert( error > 0.0, "optimise3 should minimise at > 0.0 error; actually " & error'Img );
                put( data_To_URL ( points, num_iterations ));

        end test_optimise_3;

        procedure test_optimise_2(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
                params : Legal_Aid_Sys; sets : run_settings.Settings_Rec;
                points : Points_Array;
                mult, error : Money := -999.99;
                num_iterations : Integer := 0;
                intermediate : Intermediate_Data_Array := ( others=>0.0 );
                outp : legal_aid_optimiser.Optimisation_Output;
        begin
                params := Get_Default_System;
                params.allowable_expenses(travel_expenses) := ( false, 0.0 );
                params.allowable_expenses(pension) := ( false, 0.0 );
                params.allowable_expenses( avcs ) := ( false, 0.0 );
                params.allowable_expenses( union_fees ) := ( false, 0.0 );
                params.allowable_expenses( childminding ):= ( false, 0.0 );
                params.allowable_expenses( friendly_societies ) := ( false, 0.0 );
                params.allowable_expenses( sports ) := ( false, 0.0 );
                params.allowable_expenses( loan_repayments ) := ( false, 0.0 );
                params.allowable_expenses( medical_insurance ) := ( false, 0.0 );
                params.allowable_expenses( charities ) := ( false, 0.0 );
                params.allowable_expenses( maintenance_payments ):= ( false, 0.0 );
                params.allowable_expenses( shared_rent ) := ( false, 0.0 );
                params.allowable_expenses( student_expenses ) := (true, 0.0 );
                params.allowable_finance( loan_repayments ) := ( false, 0.0 );
                params.allowable_finance ( fines_and_transfers ) := ( false, 0.0 );

                outp := minimise ( params, sets ); --, mult, error, points, num_iterations );
		assert( mult > 1.0, "optimise2 should minimise at > 1.0; actually " & mult'Img );
		assert( error > 0.0, "optimise2 should minimise at > 0.0 error; actually " & error'Img );
                for i in 1 .. num_iterations loop
                        put ( " optimise2 " & i'Img & " mult = " & points (i).x'Img &
                             " error " & points (i).y'Img );
                        new_line;

                end loop;
                put( data_To_URL ( points, num_iterations ));

        end test_optimise_2;


        procedure test_optimise(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
                params : Legal_Aid_Sys; sets : run_settings.Settings_Rec;
                points : Points_Array;
                mult, error : Money := -999.99;
                num_iterations : Integer := 0;
                intermediate   : Intermediate_Data_Array := ( others => 0.0 );
                outp : legal_aid_optimiser.Optimisation_Output;
        begin
                params := Get_Default_System;
                outp := minimise ( params, sets ); --, mult, error, points, intermediate, num_iterations );
		assert( mult = 1.0, " should minimise at 1.0; actually " & mult'Img );
		assert( error = 0.0, " should minimise at 0.0 error; actually " & error'Img );
                for i in 1 .. num_iterations loop
                        put ( " iter " & i'Img & " mult = " & points (i).x'Img &
                             " error " & points (i).y'Img );
                        new_line;

                end loop;
                put( data_To_URL ( points, num_iterations ));

        end test_optimise;


        procedure test_iterate (  T : in out AUnit.Test_Cases.Test_Case'Class ) is
                params : Legal_Aid_Sys; sets : run_settings.Settings_Rec;
                points : Points_Array;
                NUM_ITERATIONS : constant integer := 20;
                num_points : integer := NUM_ITERATIONS;

        begin
                params := Get_Default_System;
                params.allowable_expenses(travel_expenses) := ( false, 0.0 );
                params.allowable_expenses(pension) := ( false, 0.0 );
                params.allowable_expenses( avcs ) := ( false, 0.0 );
                params.allowable_expenses( union_fees ) := ( false, 0.0 );
                params.allowable_expenses( childminding ):= ( false, 0.0 );
                params.allowable_expenses( friendly_societies ) := ( false, 0.0 );
                params.allowable_expenses( sports ) := ( false, 0.0 );
                params.allowable_expenses( loan_repayments ) := ( false, 0.0 );
                params.allowable_expenses( medical_insurance ) := ( false, 0.0 );
                params.allowable_expenses( charities ) := ( false, 0.0 );
                params.allowable_expenses( maintenance_payments ):= ( false, 0.0 );
                params.allowable_expenses( shared_rent ) := ( false, 0.0 );
                params.allowable_expenses( student_expenses ) := (true, 0.0 );
                params.allowable_finance( loan_repayments ) := ( false, 0.0 );
                params.allowable_finance ( fines_and_transfers ) := ( false, 0.0 );
                points := iterate( params, sets, num_points );
                for i in 1 .. NUM_ITERATIONS loop
                        put ( " iterate 1 " & i'Img & " mult = " & points (i).x'Img &
                             " error " & points (i).y'Img );
                        new_line;

                end loop;
        end test_iterate;

        procedure test_iterate_2 (  T : in out AUnit.Test_Cases.Test_Case'Class ) is
                params : Legal_Aid_Sys; sets : run_settings.Settings_Rec;
                points : Points_Array;
                NUM_ITERATIONS : constant integer := 20;
                num_points : integer := NUM_ITERATIONS ;
        begin
                params := Get_Default_System;
                params.allow( income ).child_allowance( 1 ) := 0.0;   -- gf is 26.20*52.0; --  1362.39
                params.allow( income ).child_allowance( 2 ) := 0.0;  --  31.75*52.0; --  1651.0
                params.allow( income ).child_allowance( 3 ) := 0.0;
                params.allow( income ).partners_allowance := 0.0;   --  1547.0
                params.allow ( income ).other_dependants_allowance := 0.0;
                points := iterate( params, sets, num_points );
                for i in 1 .. NUM_ITERATIONS loop
                        put ( " iterate 2 " & i'Img & " mult = " & points (i).x'Img &
                             " error " & points (i).y'Img );
                        new_line;

                end loop;
        end test_iterate_2;

        procedure test_optimising_money (  T : in out AUnit.Test_Cases.Test_Case'Class ) is
                control : Brent.Control_Rec;
                error   : Brent.Error_Conditions := Brent.NoError;
                optimum_x, optimum_y : real := -999.99;
                tol                  : constant real := real (money'Delta);
                points               : brent.point_array;
                num_iterations       : integer := 0;
                intermediate : Intermediate_Data_Array := ( others=>0.0 );
         begin
                control.start := -1.0;
                control.stop  := 1.0;
                control.tol := tol;
                control.incr := tol;
                brent.Optimise ( control, XSQM'Access, optimum_x, optimum_y, points, intermediate, num_iterations, error );
                assert( error = Brent.NoError, "error condition raised " & error'Img );
                assert( abs(optimum_x) <= tol, "Money; y=x**2 mimumused at x=0; got" & optimum_x'Img );
                assert ( abs(optimum_y) <= tol , "Money; y=x**2 has minimum 0; got" & optimum_y'Img );
                control.start := -2.0;
                control.stop  := -1.0;
                control.tol := tol;
                control.incr := tol;
                optimum_x := -99999.9;
                optimum_y := -99999.9;
                brent.Optimise ( control, XSQM'Access, optimum_x, optimum_y, points, intermediate, num_iterations, error );
                assert( abs(optimum_x+1.0) <= tol, "Money; y=x**2  bracketed by -2,-1 mimumused at x=-1; got" & optimum_x'Img );
                assert ( abs(optimum_y-1.0 ) <= tol , "Money; y=x**2 bracketed by -2,-1 has minimum 1; got" & optimum_y'Img );


        end test_optimising_money;


        procedure test_optimising_1 (  T : in out AUnit.Test_Cases.Test_Case'Class ) is
                control : Brent.Control_Rec;
                error   : Brent.Error_Conditions := Brent.NoError;
                optimum_x, optimum_y : real := -999.99;
                points               : brent.point_array;
                num_iterations       : integer := 0;
                intermediate : Intermediate_Data_Array := ( others=>0.0 );
        begin
                control.start := -1.0;
                control.stop  := 1.0;
                control.tol := 0.0001;
                control.incr := 0.0001;
                brent.Optimise ( control, XSQ'Access, optimum_x, optimum_y, points, intermediate, num_iterations, error );
                assert( error = Brent.NoError, "error condition raised " & error'Img );
                assert( abs(optimum_x) < 0.00000001, "y=x**2 mimumused at x=0; got" & optimum_x'Img );
                assert ( abs(optimum_y) < 0.0000001 , "y=x**2 has minimum 0; got" & optimum_y'Img );
                control.start := -2.0;
                control.stop  := -1.0;
                control.tol := 0.000000001;
                control.incr := 0.000000001;
                optimum_x := -99999.9;
                optimum_y := -99999.9;
                brent.Optimise ( control, XSQ'Access, optimum_x, optimum_y, points, intermediate, num_iterations, error );
                assert( abs(optimum_x+1.0) < 0.00000001, "y=x**2  bracketed by -2,-1 mimumused at x=-1; got" & optimum_x'Img );
                assert ( abs(optimum_y-1.0 ) < 0.0000001 , "y=x**2 bracketed by -2,-1 has minimum 1; got" & optimum_y'Img );


        end test_optimising_1 ;



        --------------------
        -- Register_Tests --
        --------------------

        procedure Register_Tests (T : in out Test_Case) is
            use AUnit.Test_Cases.Registration;
        begin
                  Register_Routine (T, test_optimising_1'Access, "test_optimising" );
                  Register_Routine (T, test_optimising_money'Access, "test_optimising_money" );
                  Register_Routine (T, test_iterate'Access, "test_iterate" );
                  Register_Routine (T, test_optimise'Access, "test_optimise" );
                  Register_Routine (T, test_optimise_2'Access, "test_optimise 2" );
                  Register_Routine (T, test_optimise_3'Access, "test_optimise 3" );
                  Register_Routine (T, test_iterate_2'Access, "test_iterate 2" );
        end Register_Tests;

        ----------
        -- Name --
        ----------

        function Name ( T : Test_Case ) return Message_String is
        begin
                return Format("optimising unit tests.");
        end Name;

end optimum_tests;
