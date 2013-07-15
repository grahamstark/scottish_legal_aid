--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with model_household;               use model_household;
with base_model_types; use base_model_types;

package test_households is

        MAX_TEST_HOUSEHOLDS : constant modelint := 5;

        type TestHouseholdArray is array ( 1 .. MAX_TEST_HOUSEHOLDS ) of Model_Household_Rec;

        function makeSomeExpenses return Expenses_Array;

        function makeSomeFinances return FinanceArray;

        function makeExampleHouseholds return TestHouseholdArray;

        --
        --  households from equivilisation examples from cmd 6678 pp 28-9
        --
        function make_Equiv_Example_Households return TestHouseholdArray;

        --
        --  households from examples from cmd 6678 pp 7-8
        --
        function make_Criminal_Households return TestHouseholdArray;


        function rentHcosts return Model_Housing_Costs;

end test_households;
