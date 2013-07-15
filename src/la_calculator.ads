--
--
--  $Author: graham_s $
--  $Date: 2007-03-27 19:15:11 +0100 (Tue, 27 Mar 2007) $
--  $Revision: 2430 $
--
with base_model_types; use base_model_types;
with model_household;  use model_household;
with model_output;     use model_output;
with tax_utils;        use tax_utils;
with la_parameters;    use la_parameters;
with FRS_Enums;        use FRS_Enums;

package la_calculator is

   --
   --  The interface to this module.
   --  uprate - switch for using uprated cost estimates - see tg's note
   function calcOneHHLegalAid
     (hh     : Model_Household_Rec;
      sys    : Legal_Aid_Sys;
      ctype  : Claim_Type;
      uprate : Boolean)
      return   LAOutputArray;

   --
   -- calculates a simple measure of the "error" between 2 systems
   -- error is: high if you gain & are rich
   --           high if you lose & are poor
   --           zero if no change
   --           higher for further moves (e.g full->none > full->partial
   -- the only measure used currently is equivalent decile, since number of children etc.
   -- is subsumed in that.
   --
   function ErrorIndex
     (bu   : Model_Benefit_Unit;
      res1 : One_LA_Output;
      res2 : One_LA_Output)
      return money;

   --
   --  These are made public only so we can unit test them. Please don't
   --  use directly.
   --

   function earnedcapital_disregard (inc : money; capsys : Capital_Sys) return money;
   procedure calcAllowances
     (benunit : Model_Benefit_Unit;
      allows  : Allowance_Sys;
      res     : in out One_LA_Output);
   function passportPerson (ad : Model_Adult; sys : Legal_Aid_Sys) return Boolean;
   function passportBenefitUnit
     (benunit : Model_Benefit_Unit;
      sys     : Legal_Aid_Sys)
      return    Boolean;
   function calcOneIncome
     (incomes          : Incomes_Array;
      included_incomes : Incomes_Array)
      return             money;
   procedure makePersonalIncome
     (adult     : Model_Adult;
      sys       : Legal_Aid_Sys;
      laResults : in out One_LA_Output);
   function calcRentshare_deduction
     (hh    : Model_Household_Rec;
      sys   : Legal_Aid_Sys;
      cType : Claim_Type)
      return  money;
   function householdersHousingCosts
     (tenure        : Tenure_Type;
      housing_Costs : Model_Housing_Costs)
      return          money;
   function calcchild_allowances
     (benunit : Model_Benefit_Unit;
      bands   : Basic_Int_Array;
      rates   : Basic_Array)
      return    money;

   procedure calcHousingCosts
     (hh    : Model_Household_Rec;
      sys   : Legal_Aid_Sys;
      res   : in out LAOutputArray;
      ctype : Claim_Type);
   function expensesOp (val : money; exp : One_Expense) return money;

   procedure calcCapitalAllowances
     (bu  : Model_Benefit_Unit;
      sys : Legal_Aid_Sys;
      res : in out One_LA_Output);

   procedure calcOneBULegalAid
     (hh    : Model_Household_Rec;
      buno  : modelint;
      res   : in out One_LA_Output;
      sys   : Legal_Aid_Sys;
      ctype : Claim_Type);

   procedure calcBenefitsInKind
     (bu  : Model_Benefit_Unit;
      sys : Legal_Aid_Sys;
      res : in out One_LA_Output);

   procedure calcGrossIncome
     (bu  : Model_Benefit_Unit;
      sys : Legal_Aid_Sys;
      res : in out One_LA_Output);

   --
   --  capital imputation: if any and there's a capital limit in place
   --  1.25% of the lesser of limit and capital. If a gross income test, just pass in everything
   --
   function calcAssumedinvestment_incomePA
     (capital_stock              : money;
      reported_investment_income : money;
      capital_lower_limit        : money;
      eligible_proportion        : money; -- the 1.0 or whatever from the incomes lists
      is_gross_test              : Boolean)
      return                       money;

end la_calculator;
