--
--  $Author: graham_s $
--  $Date: 2010-02-15 13:06:18 +0000 (Mon, 15 Feb 2010) $
--  $Revision: 8638 $
--
with AUnit.Assertions;              use AUnit.Assertions;
with base_model_types;              use base_model_types;
with model_household;               use model_household;
with model_output;                  use model_output;
with tax_utils;                     use tax_utils;
with la_parameters;                 use la_parameters;
with la_calculator;                 use la_calculator;
with test_households;               use test_households;
with Text_IO;                       use Text_IO;
with Ada.Text_IO;
with Ada.Text_IO.Editing; use Ada.Text_IO.Editing;
with Ada.Strings.Fixed;   use Ada.Strings.Fixed;
with Ada.Strings;   use Ada.Strings;
with format_utils;
with text_utils;
with html_utils;
with legal_aid_output_types; use legal_aid_output_types;
with legal_aid_runner;
with run_settings;
with equivalence_scales;
with frs_enums; use frs_enums;

pragma Elaborate_All( la_parameters );

package body hh_test_1 is

        use text_utils.StdBoundedString;

        package Decimal_Format is new Ada.Text_IO.Editing.Decimal_Output
             (Num                => Money,
              Default_Currency   => "",
              Default_Fill       => ' ',
              Default_Separator  => ',',
              Default_Radix_Mark => '.');


        package Real_IO is new Ada.Text_IO.Float_IO ( Real );

        testHouseholds : TestHouseholdArray;
        defaultParameters : Legal_Aid_Sys;



        procedure Set_Up ( T : in out Test_Case ) is
        begin
                defaultParameters := Get_Default_System;
                testHouseholds := makeExampleHouseholds;
        end Set_Up;

        procedure testUprate ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                newParameters : Legal_Aid_Sys;
                ba : Basic_Array;
        begin
                ba := (1 => 100.0, 2 => 200.0, 3 => 300.0, others => 0.0 );
                ba := uprateBands ( ba, 3, 1.1, 0.0 );
                assert ( ba (1) = 110.0, "1st should be 110.0; was " & ba (1)'Img);
                assert ( ba (3) = 330.0, "3rd should be 330.0; was " & ba (3)'Img);
                ba := (1 => 100.0, 2 => 200.0, 3 => 300.0, others => 0.0 );
                ba := uprateBands ( ba, 3, 1.1, 10.0 );
                assert ( ba (1) = 120.0, "rounded by 10; 1st should be 120.0; was " & ba (1)'Img);
                assert ( ba (3) = 360.0, "rounded by 10; 3rd should be 360.0; was " & ba (3)'Img);
                put ( "after uprating; b1 = " & ba (1)'Img & " 3=" & ba (3)'Img );
                new_line;
                newParameters := uprate ( defaultParameters, 0.1 );


        end testUprate;

        procedure Test_Equivalisation ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                scale : real := -999.99;
                equiv_hhlds : constant TestHouseholdArray := make_Equiv_Example_Households;
                eq1, eq2, eq3, eq4 : Money;
        begin
                scale := equivalence_scales.Calculate_McLements_Scale ( testHouseholds(1).benefit_units(1));
                assert ( scale = 0.88, "single parent with 1 kid should be 0.61+0.27=0.88; was " & scale'Img );
                scale := equivalence_scales.Calculate_McLements_Scale ( testHouseholds(2).benefit_units(1));
                assert ( scale = 1.95, "single parent with 1 kid should be 0.61+1.95; was " & scale'Img );
		--
                -- test cases from pp 29- of cmd
                --
                eq1 := equivalence_scales.equivalise_income(equiv_hhlds(1).benefit_units(1), 24000.0 );
                assert( eq1 = 39_344.26, "equivlised income case 1: should be 39_344; was " & eq1'Img );
                eq2 := equivalence_scales.equivalise_income(equiv_hhlds(2).benefit_units(1), 24000.0 );
                assert( eq2 = 24_000.0, "equivlised income case 2: should be 24,000; was " & eq2'Img );
                eq3 := equivalence_scales.equivalise_income(equiv_hhlds(3).benefit_units(1), 24000.0 );
                assert( eq3 = 20_338.98, "equivlised income case 3: should be 20_338.98; was " & eq3'Img );
                eq4 := equivalence_scales.equivalise_income(equiv_hhlds(4).benefit_units(1), 24000.0 );
                assert( eq4 = 17_266.19, "equivlised income case 3: should be 17266; was " & eq4'Img );

	end Test_Equivalisation;

	--
        --  These attempt to reproduces the 4 case studies on p6-7 of
        --  cmd  6678
        --
        procedure Make_CDS_Case_Studies ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                scale : real := -999.99;
                hhlds : constant TestHouseholdArray := make_Criminal_Households;
		--
                -- FIXME no criminal defined
                sys :Legal_Aid_Sys := Get_default_System;
                results : One_LA_Output;
                results2 : LAOutputArray;
        begin
                calcOneBULegalAid ( hhlds (1),
                                   	1,
                                        results,
                                        sys,

                                  	normalClaim );
                text_io.put( toString( results ));
                assert( results.gross_income = 39_344.26, "cda case 1: gross income should be 39_344; was " & results.gross_income'Img );
                assert( results.net_income = 24_000.0, "cda case 1: net income should be 39_344; was " &  results.net_income'Img ); -- note this is NOT equivalised
                assert( results.disposable_income = 18_702.76, "cda case 1: disposable income should be 34047.02; was "&results.disposable_income'Img );
                assert( results.la_State = disqualified, " should be disqualified " );
                results2 := calcOneHHLegalAid ( hhlds (2),
                                        sys,
                                  	normalClaim,
                                        false );

                text_io.put( toString( results2(1) ));
                assert( results2(1).gross_income = 24_000.0, "case 2: gross income should be 24,000 but was: "&results2(1).gross_income'Img );
                assert( results2(1).net_income = 17_876.0-5520.0, "case 2: net income should be 17,876 but was: "&results2(1).net_income'Img );
                assert( results2(1).disposable_income = 3672.0, "case 2: disposable income should be 3672 bus was:"&results2(1).disposable_income'Img );
                assert( results2(1).la_State = disqualified, " 2; should be disqualified " );

                results2 := calcOneHHLegalAid ( hhlds(3),
                                        sys,
                                  	normalClaim,
                                        false );
                text_io.put( toString( results2(1) ));
                assert( results2(1).gross_income = 20_338.98, "case 3: gross income should be 20,338.98 but was: "&results2(1).gross_income'Img );
                assert( results2(1).net_income = 17_876.0-5520.0, "case 3: net income should be 17,876 but was: "&results2(1).net_income'Img );
                assert( results2(1).disposable_income = 2108.88, "case 3: disposable income should be 2108.98 bus was:"&results2(1).disposable_income'Img );
                assert( results2(1).la_State = partiallyEntitled, "case 4; should be part entiteled was"& results2(1).la_State'Img);

                results2 := calcOneHHLegalAid ( hhlds(4),
                                        sys,
                                  	normalClaim,
                                        false );
                text_io.put( toString( results2(1) ));
                assert( results2(1).gross_income = 17_266.19, "case 4: gross income should be 20,338.98 but was: "&results2(1).gross_income'Img );
                assert( results2(1).la_State = fullyEntitled, "case 4; should be fullyEntitled but was"&results2(1).la_State'Img );

        end Make_CDS_Case_Studies;

        procedure testCreateInputs ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                message : Bounded_String;
                x       : real := 0.0;
                m       : money := 0.0;
                i       : integer := 0;
                output_str : Bounded_String;
                b          : boolean := false;
                has_error  : boolean := false;
        begin
                html_utils.makeOneInput( varname=>"fred-joe-iain", outputStr=>output_str, value=>x, defaultValue=>10.0, help=>"this is help", paramString => "11", paramIsSet=>true, is_error=>has_error );
                put( "output string is " & to_string(output_str) & "|" );new_line;
                assert ( x = 11.0, "x should be 11.0 ; was " & format_utils.format (x) );
                assert ( not has_error , "no error 1st time round " );
                html_utils.makeOneInput( varname=>"fred-joe-iain", outputStr=>output_str, value=>x, defaultValue=>10.0, help=>"this is help", paramString => "11xxx", paramIsSet=>true, is_error=>has_error );
                assert ( has_error , "error 2nd time round " );
                put( "output string is " & to_string(output_str) & "|" );new_line;
                assert ( x = 11.0, "x should be 11.0 ; was " & format_utils.format (x) );
                html_utils.makeOneInput( varname=>"fred-joe-iain", outputStr=>output_str, value=>m, defaultValue=>13.0, help=>"this is help", paramString => "15", paramIsSet=>true, is_error=>has_error );
                put( "output string is " & to_string(output_str) & "|" );new_line;
                assert ( m = 15.0, "m should be 15.0 ; was " & format_utils.format (m) );
                assert ( not has_error , "no error 3rd time round " );


                html_utils.makeOneInput ( "something-boolean", output_str, b, true );
                put( "basic boolean output string is " & to_string(output_str) & "|" );new_line;
                assert ( not b, "b should false ; was " & m'Img );

                html_utils.makeOneInput ( varname => "something-boolean", outputStr => output_str, value => b, defaultValue => true,
                                        help=>"Some Boolean Help", paramString=>"1", paramIsSet=>true );
                put( "basic boolean output string is " & to_string(output_str) & "|" );new_line;
                assert ( b, "b should true ; was " & b'Img );


        end testCreateInputs;




        procedure testValidation ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                message : Bounded_String;
                x       : real := 0.0;
                m       : money := 0.0;
                i       : integer := 0;

        begin
                format_utils.validate ( "292.12", x, message );
                put( "x correct; got message as " & to_string(message) & "|" );new_line;
                assert ( message = "", " should be blank; was " & to_string(message)  );
                assert ( x = 292.12, "x should ne 292.12 but was " & format_utils.format(x) );
                format_utils.validate ( "292.12xxxx", x, message );
                put( "x error; got message as " & to_string(message) & "|" );new_line;
                assert ( message = "This is not a valid real number", "Message was " & to_string(message) );
                assert ( x = 292.12, "x should be unchanged ; was " & format_utils.format(x) );

                format_utils.validate ( "292.0", m, message );
                put( "x correct; got message as " & to_string(message) & "|" );new_line;
                assert ( message = "", " should be blank; was " & to_string(message)  );
                assert ( m = 292.0, "m should ne 292 but was " & format_utils.format(m) );
                format_utils.validate ( "292.12xxxx", m, message );
                put( "m error; got message as " & to_string(message) & "|" );new_line;
                assert ( message = "This is not a valid decimal number", "m Message was " & to_string(message) );
                assert ( m = 292.0, "m should be unchanged ; was " & format_utils.format (m) );

                format_utils.validate ( "292", i, message );
                put( "x correct; got message as " & to_string(message) & "|" );new_line;
                assert ( message = "", " should be blank; was " & to_string(message)  );
                assert ( i = 292, "i should ne 292 but was " & i'Img );
                format_utils.validate ( "292.12xxxx", i, message );
                put( "m error; got message as " & to_string(message) & "|" );new_line;
                assert ( message = "This is not a valid integer", "m Message was " & to_string(message) );
                assert ( i = 292, "i should be unchanged ; was " & i'Img );

        end testValidation;

        procedure testMaths( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                p, q : money;
		x    : real;
        begin
                p := 10.0;
                q := money'Max( p, 11.0 );
                assert ( q = 11.0, "q should be 11; was " & q'Img );
                q := money'Value ( "1234.12" );
                assert( q = 1234.12, "1234.12" );
                q := money'Value ( "1234.1223" );
                assert( q = 1234.12, "1234.1223" );
                q := money'Value ( "1234" );
                assert( q = 1234.0, "1234" );

                x := real'Value ( "1234.124" );
                assert( x = 1234.124, "1234.124" );
                x := real'Value ( "1234" );
                assert( x = 1234.0, "1234" );
                x := real'Value ( ".1234" );
                assert ( x = 0.1234, ".1234" );
        end testMaths;

        procedure testFormatting ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                s : Unbounded_String;
                ss : String(1..20);
                m  : real := 1000000.222;
                PICTURE : constant Ada.Text_IO.Editing.Picture := Ada.Text_IO.Editing.To_Picture ("ZZZ_ZZZZ_ZZZ_ZZ9.99");
        begin
              put ( "10.0 translated to image is |" & to_string (s) & "|" );
                new_line;
                s := to_unbounded_string (money ( m )'Img );
        	put ( "10.0 translated to money'image is |" & to_string (s) & "|" );
                new_line;
                Real_IO.put( ss, m, 10, 2 );
                put ( "from Real_IO.put |" & ss & "|" );
                s := to_unbounded_string( trim( Decimal_Format.Image( money(m), PICTURE ), Side => Both) );
                put ( "from Ada.Text_IO.Editing version|" & to_string(s) & "|" );
                new_line;
                put ( "from Ada.Text_IO.Editing version10.1 formatted as |" & Decimal_Format.Image( money(10.1), PICTURE ) & "|" );
                new_line;

             --(  Value    : Number'Base;
             --   Base     : NumberBase := 10;
             --   PutPlus  : Boolean    := False
             --   RelSmall : Positive   := MaxSmall;
             --   AbsSmall : Integer    := -MaxSmall;
             --)  return String;
        end testFormatting;

        procedure testchild_allowances ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                allow : money;
        begin
                allow := calcchild_allowances(
                        testHouseholds(1).benefit_units(1),
                        defaultParameters.allow( income ).child_age_limit,
                        defaultParameters.allow( income ).child_allowance );
                assert( (allow = 2377.0), " hh1 allowances should be 2377; got " & allow'Img );
                allow := calcchild_allowances(
                        testHouseholds(2).benefit_units(1),
                        defaultParameters.allow( income ).child_age_limit,
                        defaultParameters.allow ( Income ).child_allowance );
                put( "got allowances as " & allow'Img );
                assert( allow = 2377.0*3.0, " hh2 allowances should be 7131 got " & allow'Img );
        end testchild_allowances;


        procedure testRateBands ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                taxable : money := 0.0;
                numBands : modelint := 1;
                rates   : BasicRealArray := ( 1 => 0.2, others => 0.0 );
                bands   : Basic_Array := ( 1 => Money'Last, others => 0.0 );
                result  : TaxResult;
        begin
                result := calcTaxDue ( taxable, rates, bands, numBands );
                assert ( result.endBand = 0, "basicTest taxable=0" & result.endBand'Img );
                assert ( result.due = 0.0, "basicTest taxable=0" & result.due'Img );
                taxable := 1000.0;
                result := calcTaxDue ( taxable, rates, bands, numBands );
                assert ( result.endBand = 1, "basicTest taxable=1000" & result.endBand'Img );
                assert ( result.due = 200.0, "basicTest taxable=1000" & result.due'Img );
                result := calcSteppedContribution ( taxable, rates, bands, numBands );
                assert ( result.endBand = 1, "basicTest taxable=1000" & result.endBand'Img );
                assert ( result.due = 0.2, "basicTest taxable=1000; stepped contribution" & result.due'Img );
        end testRateBands;



        procedure testIncomes ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                ne1 : money := 0.0;
                results : One_LA_Output;
        begin
                ne1 := calcOneIncome(
                        testHouseholds(1).benefit_units(1).adults( head ).incomes,
                        defaultParameters.incomesList );
                assert( ne1 = 9900.0," calcOneIncome should be 9900.0 was " & ne1'Img );
                calcGrossIncome( testHouseholds (1).benefit_units (1),
                                    defaultParameters,
                                    results );

                makePersonalIncome ( testHouseholds (1).benefit_units (1).adults( head ),
                                    defaultParameters,
                                    results );
                assert ( results.assessable_Income = 9900.0,
                           " testIncomes(2) netinc should be 9900.0 was" & results.assessable_Income'Img );
                assert ( results.gross_Income = 0.0,
                        " testIncomes(2) netinc should be 10000.0 was" & results.gross_Income'Img );

                testHouseholds(1).benefit_units(1).adults( head ).incomes(luncheon_vouchers) :=  0.15  * 5.0;
                makePersonalIncome( testHouseholds(1).benefit_units(1).adults( head ), defaultParameters, results );
                assert ( results.benefits_In_Kind = 0.0,
                        " makePersonalIncome(3) should be 0 was " & results.benefits_In_Kind'Img);

                testHouseholds(1).benefit_units(1).adults( head ).incomes(luncheon_vouchers) :=  10.0 + (0.15  * 5.0);
                makePersonalIncome ( testHouseholds (1).benefit_units (1).adults ( head ), defaultParameters, results );
                calcBenefitsInKind( testHouseholds (1).benefit_units (1),  defaultParameters, results );
                assert ( results.benefits_In_Kind = 10.0,
                        "makePersonalIncome(4) should be 10 was " & results.benefits_In_Kind'Img );

                testHouseholds(1).benefit_units(1).adults( head ).has_Company_Car := true;
                results.benefits_In_Kind := 0.0;

                makePersonalIncome ( testHouseholds (1).benefit_units (1).adults ( head ), defaultParameters, results );
                calcBenefitsInKind( testHouseholds (1).benefit_units (1),  defaultParameters, results );
                assert ( results.benefits_In_Kind = 3010.0,
                        "makePersonalIncome (5) should be 3010 was: " & results.benefits_In_Kind'Img );

        end testIncomes;


        procedure testRentshare_deduction ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                results : LAOutputArray;
                rent_Share_Deduction : money := 0.0;
        begin
                --  2 adults in 2nd bu hh2, so should be 0.15 * 2931.0
                rent_Share_Deduction :=  calcRentshare_deduction ( testHouseholds (1),
                                                               defaultParameters,
                                                               normalClaim );
                assert( rent_Share_Deduction = 0.0, "Rentshare_deduction; case 1 should be 0" );
                rent_Share_Deduction :=  calcRentshare_deduction ( testHouseholds (3),
                                                               defaultParameters,
                                                               normalClaim );

                assert ( rent_Share_Deduction = 439.65 * 2,
                        "2 adults in 2nd bu hh2, so should be 0.15 * 2931.0; got: " &  rent_Share_Deduction'Img );
        end testRentshare_deduction;

        procedure testHouseholdersHousingCosts ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                housing_Costs : Model_Housing_Costs;
                hcosts : money := 0.0;
        begin
                housing_Costs := rentHcosts;
                hcosts := householdersHousingCosts( rents, housing_Costs );
                assert( hcosts = 10000.0, "rented tests; should be 10000.0; is actually " & hcosts'Img );
                hcosts := householdersHousingCosts( buying_with_the_help_of_a_mortgage, housing_Costs );
                assert( hcosts = 13500.0, "mortgaged costs; should be 13500.0 got " & hcosts'Img );
        end testHouseholdersHousingCosts;

        procedure testexpensesOps ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                exp : One_Expense;
                x   : money := 0.0;
        begin
                exp.is_flat := false;
                exp.amount := 1.0;
                x := expensesOp ( 10.0, exp );
                assert ( x = 10.0, "testexpensesOps 1; should be 10; got " & x'Img );
                exp.amount := 1.0 / 3.0;
                x := expensesOp ( 10.0, exp );
                assert ( x = 3.33, "testexpensesOps 2; should be 3.33; got " & x'Img );
                exp.is_flat := true;
                exp.amount := 1.0;
                x := expensesOp ( 10.0, exp );
                assert ( x = 1.0, "testexpensesOps 3; should be 1.0; got " & x'Img );
                exp.amount := 12.0;
                x := expensesOp ( 10.0, exp );
                assert ( x = 10.0, "testexpensesOps 4; should be 10.0; got " & x'Img );
        end testexpensesOps;


        procedure testPassporting ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
        begin
                assert ( not passportPerson ( testHouseholds(2).benefit_units (1).adults (head), defaultParameters ),
                        "passport hh2(2).head" );
                assert ( passportPerson ( testHouseholds(2).benefit_units (1).adults (spouse), defaultParameters ),
                        "passport hh2(2).spouse" );
                assert ( not passportBenefitUnit ( testHouseholds(1).benefit_units (1), defaultParameters ),
                        "passport hh1(2)" );
                assert ( passportBenefitUnit ( testHouseholds(2).benefit_units (1), defaultParameters ),
                        "passport hh2(2)" );
        end  testPassporting;

        procedure testCapital ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
        begin
                assert ( earnedcapital_disregard ( 1600.0, defaultParameters.capital_disregard ( Pensioner ) ) = 20000.0,
                        " cap dis income 1870, pensioner" );
                assert ( earnedcapital_disregard ( 1600.0, defaultParameters.capital_disregard ( NonPensioner ) ) = 0.0,
                        " cap dis income non pensioner" );
                assert ( earnedcapital_disregard ( 1601.0, defaultParameters.capital_disregard ( Pensioner ) ) = 15000.0,
                        " cap dis income 5000" );
                assert ( earnedcapital_disregard ( 1601.0, defaultParameters.capital_disregard ( NonPensioner ) ) = 0.0,
                        " cap dis income 1871 non pens" );
                assert ( earnedcapital_disregard ( 0.0, defaultParameters.capital_disregard ( Pensioner ) ) = 35000.0,
                        " cap dis income 0" );
        end testCapital;

        procedure testAllowances ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                results : One_LA_Output;
        begin
                calcAllowances( testHouseholds(1).benefit_units(1), defaultParameters.allow(income), results );
                assert ( results.allowances = 2_377.0,
                          "allowances for hh(1)(1) was "  & results.allowances'Img );
                results.allowances  := 0.0;
                calcAllowances( testHouseholds(2).benefit_units(1), defaultParameters.allow(income), results );
                assert ( results.allowances = 1_702.0 + (2_377*3.0),
                          "allowances for hh(2)(1) was " & results.allowances'Img );
        end testAllowances;

        procedure testCapitalAllowances( T : in out AUnit.Test_Cases.Test_Case'Class ) is
                results : One_LA_Output;
        begin
                results.disposable_Income := 2000.0;
                calcCapitalAllowances( testHouseholds(4).benefit_units(1), defaultParameters, results );
                assert ( results.capital_Allowances = 5000.0,
                        " cap allow hh3; should be 5000; got " & results.capital_Allowances'Img );
                testHouseholds(4).benefit_units(1).adults( head ).age := 25;
                calcCapitalAllowances( testHouseholds(4).benefit_units(1), defaultParameters, results );
                assert ( results.capital_Allowances = 0.0,
                        "cap allow hh4 young should be 0; got" & results.capital_Allowances'Img );
        end testCapitalAllowances;


        procedure testFullSystem(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
                res : One_LA_Output;
        begin
                calcOneBULegalAid ( testHouseholds (1),
                                   	1,
                                        res,
                                        defaultParameters,

                                  normalClaim );
                --  assert( res.housing_Costs = 17500.0, "housing costs should be 17500; were " & res.housing_Costs'Img );
                assert( res.allowances = 2_288.28, "allowances should be 2_288.28 (1 child) was: " &res.allowances'Img  );
                assert( res.disposable_Income =  7611.72, " disposable should be 7611.72; was: "&res.disposable_Income'Img );
                assert ( res.la_State = partiallyEntitled, " hh1 should be part; was " & res.la_State'Img );
                res := newOutput;
                calcOneBULegalAid( testHouseholds(2), 1,
                                        res,
                                        defaultParameters,
                                        normalClaim );
                assert( res.allowances = 0.0, "hh2 allowances should be 0; was "&res.allowances'Img );
                assert( res.disposable_Income = 0.0, "disposable should be 0; was "&res.disposable_Income'Img );
                assert( res.la_State = passported, "hh2 should be passported; is"& res.la_State'Img  );
                res := newOutput;
                calcOneBULegalAid( testHouseholds(5), 1,
                                        res,
                                        defaultParameters,
                                        normalClaim );
                assert( res.disposable_Capital = 5000.0,  "hh5 should be 5000 was "& res.disposable_Capital'Img );
                assert( res.capital_Contribution = 2000.0, "capital contrib 2000; was " &res.capital_Contribution'Img  );
                assert ( res.la_State = partiallyEntitled, "LA state partial; was: " & res.la_State'Img );
                put( toString( res ) );
        end testFullSystem;




        --------------------
        -- Register_Tests --
        --------------------

        procedure Register_Tests (T : in out Test_Case) is
         use AUnit.Test_Cases.Registration;
        begin
                Register_Routine (T, testMaths'Access, "maths");
                Register_Routine (T, testchild_allowances'Access, "child_Allowances");
                Register_Routine (T, testRentshare_deduction'Access, "test Rent Share Deductions");
                Register_Routine (T, testHouseholdersHousingCosts'Access, "test Householders Housing Costs ");
                Register_Routine (T, testexpensesOps'Access, "test expensesOps ");
                Register_Routine (T, testIncomes'Access, "test incomes" );
                Register_Routine (T, testCapital'Access, "test capital" );
                Register_Routine (T, testPassporting'Access, "test passporting" );
                Register_Routine (T, testAllowances'Access, "test allowances" );
                Register_Routine (T, testCapitalAllowances'Access, "test capital allowances" );
                Register_Routine (T, testRateBands'Access, "test rate bands" );
                Register_Routine (T, testFullSystem'Access, "full system, pt1" );
                Register_Routine (T, testUprate'Access, "testUprate" );
                Register_Routine (T, testFormatting'Access, "testFormatting" );
                Register_Routine (T, testValidation'Access, "testValidation" );
                Register_Routine (T, testCreateInputs'Access, "testCreateInputs" );
                Register_Routine (T, Test_Equivalisation'Access, "testEquivalisation" );
                Register_Routine (T, Make_CDS_Case_Studies'Access, "CDS Case Studies" );
        end Register_Tests;

        ----------
        -- Name --
        ----------

        function Name ( T : Test_Case ) return Message_String is
        begin
                return Format("Legal Aid calculations unit tests.");
        end Name;

end hh_test_1;
