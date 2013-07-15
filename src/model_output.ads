--
--  $Author: graham_s $
--  $Date: 2007-03-27 19:15:11 +0100 (Tue, 27 Mar 2007) $
--  $Revision: 2430 $
--
with base_model_types; use base_model_types;
with legal_aid_output_types; use legal_aid_output_types;
with model_household;
--
--
package model_output is


        type State_Array is array( Legal_Aid_State ) of Real;

        type One_LA_Output is record
                assessable_Capital : money := 0.0;
                excess_Capital : money := 0.0;
                excess_Income : money := 0.0;
                allowances : money := 0.0;
                capital_except_equity : money := 0.0;

                capital_Allowances : money := 0.0;
                assessable_Income : money := 0.0;
                disposable_Capital : money := 0.0;
                disposable_Income : money := 0.0;
                gross_Income : money := 0.0;
                benefits_In_Kind : money := 0.0;
                deductions_From_Income : money := 0.0;
                la_State : Legal_Aid_State := na;
                income_Contribution : money := 0.0;
                capital_Contribution : money := 0.0;
                housing_Costs : money := 0.0;
                rent_Share_Deduction : money := 0.0;
                net_income : money := 0.0;
                child_Allowances,
                partners_Allowances   : money := 0.0;

                targetting_index : money := 0.0;

                equivalence_scale : real := 0.0;

                costs :  legal_aid_output_types.LA_Takeup_Array := ( others=>(others=>(others=>0.0)));

                --criminal_costs : Criminal_Cost_Type_Array := ( others=> 0.0);

                gross_income_test_state : Gross_Income_Test_State_Type := na;

                means_test_state : Legal_Aid_State := na;
                capital_state : Legal_Aid_State := na;
                passport_state : Legal_Aid_State := na;

        end record;

        function recode_Gross_Income_Test_State_Type( gt : Gross_Income_Test_State_Type ) return modelint;
	function recode_LA_State( st : Legal_Aid_State  ) return modelint;


        --
        --  a record with differences (1-2) in all the numeric values.
        --
        function difference ( res1, res2 : One_LA_Output ) return One_LA_Output;

        --
        --  a fresh output record
        --
        function newOutput return One_LA_Output;

        function toString ( res : One_LA_Output ) return String;

        function toCDA ( res : One_LA_Output ) return String;

        type LAOutputArray is array (1 .. model_household.MAX_NUM_BENEFIT_UNITS) of One_LA_Output;


end model_output;
