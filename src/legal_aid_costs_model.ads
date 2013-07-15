--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with model_household; use model_household;
with model_output; use model_output;
with la_parameters; use la_parameters;
with legal_aid_output_types; use legal_aid_output_types;
with base_model_types; use base_model_types;
--
--  FIXME: we need to remove the dependencies on the full dataset,
--  which is currently where takeup_estimates is defined.
--
package legal_aid_costs_model is

        use type la_parameters.Claim_Type;

        function Calculate_Costs( bu : Model_Benefit_Unit;
                                  results : model_output.One_LA_Output;
                                  sys : System_Type;
                                  ctype   : Claim_Type;
                                  indexed : boolean ) return LA_Takeup_Array;

        --
        -- This is a horrible hack because we have 3 incompatible
        -- versions of system type. Has to be here because of cross-dependencies.
        --
        function get_costs_type_from_param_types(
                sys : System_Type;
                ctype : Claim_Type ) return LA_Costs_System_Type;



end legal_aid_costs_model;
