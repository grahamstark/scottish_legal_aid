--
--
--
--

with base_model_types; use base_model_types;

package legal_aid_output_types is

        type Criminal_Cost_Type is (p_indict, p_summ, p_moto, p_magis );

        type Criminal_Cost_Type_Array is array ( Criminal_Cost_Type ) of real;

        type Legal_Aid_State is ( passported, fullyEntitled, partiallyEntitled, disqualified, na );
        
        type Recovery_Table_Component is (Contributions, Expenses_From_Opponents, Amounts_Awarded,
                                Expenses_And_Awards, Total_Income, Gross_Expenditure, Number_Of_Cases_Paid);
        
        type Recovery_Table_Component_Array is array(  Recovery_Table_Component ) of Real;       

        type LA_Problem_Type is ( divorce, relationships, personal_injury,
                                  other_problem, procedures );
-- criminal_justice, misc_problems, all_problems
        type LA_Costs_Component is (
                  expected_offers,
                  expected_takeup,
                  expected_gross_costs,
                  expected_net_costs,
                  contributions,
                  proportion_of_cases_economic,
                  proportion_of_value_economic,
                  proportion_of_economic_offers_taken_up_by_caseload,
                  proportion_of_economic_offers_taken_up_by_value,
                  proportion_of_uneconomic_offers_taken_up_by_caseload,
                  proportion_of_uneconomic_offers_taken_up_by_value,
                  Expenses_From_Opponents,
                  Amounts_Awarded,
                  Total_Income );
					 
        type  LA_Costs_Component_Array is array (  LA_Costs_Component ) of Real;
        
        type Recovery_Table is array( LA_Problem_Type ) of Recovery_Table_Component_Array; 

        --
        --  FIXME: this the 3rd verison of this we have, all subtly inconsistent with each other. Others are in
        --  la_parameters
        --
        type LA_Costs_System_Type is ( civil, civil_pi, ABWOR, green_form, magistrates_court_criminal );

        type LA_Takeup_Array is array( LA_Costs_System_Type, LA_Costs_Component, LA_Problem_Type ) of real;

        --  type LA_Age_Range is ( Not_known, age_0_15, age_16_19, age_20_29, age_30_44, age_45_59, age_60_plus );

        type Gross_Income_Test_State_Type is ( na, below_mininum, means_tested, above_maximum, passported );

	-- type Simple_Test_Result_Type is ( na, passed, failed );


end legal_aid_output_types;
