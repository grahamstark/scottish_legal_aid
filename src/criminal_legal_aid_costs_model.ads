with model_household; use model_household;
with legal_aid_output_types; use legal_aid_output_types;

package criminal_legal_aid_costs_model is

        function Calculate_Costs( bu : Model_Benefit_Unit;
                                  decile : Decile_Number;
                                  la_state : Legal_Aid_State ) return Criminal_Cost_Type_Array;


end criminal_legal_aid_costs_model;
