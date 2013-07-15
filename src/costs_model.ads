--
-- $Revision $
-- $Author $
-- $Date $
--

with base_model_types;    use base_model_types;
with FRS_Enums; use FRS_Enums;
with legal_aid_output_types; use Legal_Aid_Output_Types;
with model_household;  use model_household;
with model_output;     use model_output;

--
--
--
--
package Costs_Model is

   subtype Age_Range is integer range 1 .. 8;

-- COST_HISTOGRAM
--   1 Divorce
--  2 Family, relationships, children, domestic violence
--  3 Personal injury/negligence
--  4 Other legal needs
--  5 Procedures

   type Population_State_Array is array( Legal_Aid_State, Age_Range, Gender ) of Real;
  
   type Contribution_Proportion is record
      by_caseload : Real := 1.0;
      by_value : Real := 1.0;
   end record;

   function Get_Age_Range( age : integer ) return Age_Range;

   function Get_Offer_Rate(  state : Legal_Aid_State;
                             age : integer;
                             sex : Gender;
                             problem : LA_Problem_Type ) return Real;

   function Get_Proportion_Of_Offers_That_Are_Economic( ptype : LA_Problem_Type; contribution : Money;
        include_only_contrib_cases : boolean ) return Contribution_Proportion;

   function Get_Average_Cost( ptype : LA_Problem_Type ) return Money;

   procedure Apply_Costs_Model( hh : Model_Household_Rec; outp : in out LAOutputArray );

   function Calculate_One_Position( age : integer; sex : Gender; state : Legal_Aid_State; contribution : Money ) return LA_Takeup_Array;


   function Sum_Over_Problems( takeup : LA_Takeup_Array; ct : LA_Costs_System_Type := civil ) return LA_Costs_Component_Array;

   function Calc_Takeup_Probability( contrib : Money; beta : Real ) return Real;


end Costs_Model;
