--
--  $Author: graham_s $
--  $Date: 2007-11-14 18:07:29 +0000 (Wed, 14 Nov 2007) $
--  $Revision: 4327 $
--
with base_model_types; use base_model_types;
with model_household;  use model_household;
with tax_utils;        use tax_utils;
with FRS_Enums; use FRS_Enums;
--
--
package la_parameters is

   LATEST_AVAILABLE_YEAR : constant := 2005;
   --
   -- Handy constant for withdrawal rates, etc.
   --
   ONE_THIRD : constant Real := 1.0/3.0;
   
   DAILY_LUNCHEON_VOUCHER_MINIMUM : constant money := Money( 0.15 * 5.0 * 52.0 );
   
   COMP_CAR_THRESHHOLD            : constant money := 8500.0; --  jammed on as annual!!!!

   type System_Type is (
      civil,
      green_form,
     -- personal_injury,
      abwor,
      magistrates_court_criminal);

   type Claim_Type is (normalClaim, personalInjuryClaim, na);
   type Pensioner_State is (pensioner, nonPensioner, na);
   type Income_Or_Capital is (income, capital, na);
   type Net_Or_Gross is (net, gross, na);
   type Assessment_Period is (weekly, monthly, annualHistoric, annualForward);
   type Contribution_Type is (proportion, fixed);

   type Male_Female_Array is array (Male .. Female) of modelint;

   type Capital_Sys is
      record
         numDisregards : modelint    := 0;
         disregard     : Basic_Array := (others => 0.0);
         incomeLimit   : Basic_Array := (others => 0.0);
      end record;

   type Allowance_Sys is
      record
         living_allowance           : money           := 0.0;
         partners_allowance         : money           := 0.0;
         other_dependants_allowance : money           := 0.0;
         num_child_age_limits       : modelint        := 0;
         child_age_limit            : Basic_Int_Array := (others => 0);
         child_allowance            : Basic_Array     := (others => 0.0);
         dependent_allowance        : money           := 0.0;
         --
         --  these aren't exactly allowances
         --  but model the increase in the capital limits
         --  for gf/abwor by dependent.
         --
         num_dependent_allowances : integer := 0;
         dependent_allowances : Basic_Array := (others => 0.0);
      end record;

   type One_Expense is
      record
         is_flat : Boolean := False;
         amount  : real    := 1.0;
      end record;

   type Housing_Costs_Allowances is
      record
         mortgages             : One_Expense; --
         council_tax           : One_Expense;
         water_rates           : One_Expense; --  should be nil in NI
         ground_rent           : One_Expense;
         service_charges       : One_Expense;
         repairs_and_insurance : One_Expense;
         rent                  : One_Expense; --  see 167
         --  rent share see 169/2
         rent_rebates        : One_Expense;
         council_tax_rebates : One_Expense;
      end record;

   type One_Contribution is
      record
         numContributions        : modelint          := 0;
         cont_type               : Contribution_Type := proportion;
         contribution_proportion : BasicRealArray    := (others => 0.0);
         contribution_band       : Basic_Array       := (others => 0.0);
      end record;

   type Contribution_Array is array (Income_Or_Capital) of One_Contribution;

   type Included_Benefits is array (Benefits) of Boolean;
   type Limits_Array is array (Income_Or_Capital, Claim_Type) of money;
   type Allowance_Systems is array (Income_Or_Capital) of Allowance_Sys;
   type Capital_Systems is array (Pensioner_State) of Capital_Sys;
   type Income_Or_CapitalBasic_Arrays is array (Income_Or_Capital) of BasicRealArray;
   type Allowable_Expenses_Array is array (Expense_Items) of One_Expense;
   type Allowable_Finance_Array is array (Finance_Items) of One_Expense;

   --        type TitleString is new Bounded_String(80);

   type Legal_Aid_Sys is
      record
         title                    : Str80.Bounded_String :=
            Str80.To_Bounded_String ("uninitialised");
         sys_type                 : System_Type          := civil;
         reform_number            : modelint             := 0;
         gross_IncomeLimit        : money                := 0.0;
         gross_Income_lower_limit : money                := money'Last;

         equivalise_gross_income_limit : Boolean := False;
         equivalise_incomes            : Boolean := False;

         doCapital : Boolean := False;
         doIncome  : Boolean := False;
         --  passportStates : ;   ## set
         passport_benefits   : Included_Benefits := (others => False);
         use_own_income_test : money             := 0.0;
         income_to_use       : Net_Or_Gross      := na;

         lower_limit, upper_limit : Limits_Array;

         allowable_expenses : Allowable_Expenses_Array;
         allowable_finance  : Allowable_Finance_Array;

         period : Assessment_Period;
         allow  : Allowance_Systems;

         incomesList, gross_IncomesList : Incomes_Array;
         pensioner_age_limit            : Male_Female_Array := (male => 60, female => 60);
         capital_disregard              : Capital_Systems;
         contributions                  : Contribution_Array;
         --  misc allowances
         student_grant_disregard     : money := 0.0;
         mortgage_maximum            : money := 0.0;
         averagewater_rates          : money := 0.0;
         business_profits_projection : money := 0.0;
         pay_rise_assumption         : money := 0.0;
         SRP_Maximum                 : money := 0.0;
         rent_allowance_maximum      : money := 0.0;
         share_deduction             : money := 0.0;
         --  sysType : Legal_Aid_Sys_Type;
         do_housing_costs_limit           : Boolean := False;
         housing_CostsLimit               : money   := 0.0;
         housing_costs_person_max         : money   := 0.0;
         pension_contribution_max         : money   := 0.0;
         housing_allowances               : Housing_Costs_Allowances;
         single_persons_housing_costs_max : money   := 0.0;
         housing_equity_is_capital        : Boolean := False;
         housing_equity_disregard         : money   := 0.0;
      end record;

   --
   --  FIXME check this against IFS lists??
   --  This is just use to generate company car charges, which should kick in just above
   --  Comp_Car_Threshhold constant, using taxable income
   TAXABLE_INCOMES_LIST : constant Incomes_Array := (
         wages                                => 1.0,
         luncheon_Vouchers                    => 1.0,
         self_Employment                      => 1.0,
         investment_Income                    => 1.0,
         pensions                             => 1.0,
         other_Income                         => 1.0,
         income_Tax                           => 0.0,
         national_insurance                   => 0.0,
      --  disregarded
         disability_living_allowance          => 0.0,
         attendance_allowance                 => 0.0,
         constantattendance_allowance         => 0.0,
         social_fund                          => 0.0,
      --  included (or irrelevant)
         child_benefit                        => 0.0,
         guaranteed_pension_credit            => 0.0,
         savings_pension_credit               => 0.0,
         retirement_pension                   => 1.0,
         widows_pensions                      => 1.0,
         income_support                       => 0.0,
         maternity_allowance                  => 1.0,
         widowed_mothers_allowance            => 1.0,
         war_disablement_pension              => 1.0,
         war_widow_pension                    => 1.0,
         severe_disability_allowance          => 1.0,
         disabled_persons_tax_credit          => 1.0,
         invalid_care_allowance               => 0.0,
         income_related_jobseekers_allowance  => 1.0,
         contributory_jobseekers_allowance    => 1.0,
         industrial_injury_disablementBenefit => 1.0,
         incapacity_benefit                   => 1.0,
         working_families_tax_credit          => 0.0,
         new_deal                             => 1.0,
         working_tax_credit                   => 0.0,
         child_tax_credit                     => 0.0,
         any_other_benefit                    => 0.0,
         widows_payment                       => 1.0,

         unemployment_redundancy_insurance    => 1.0,
         winter_fuel_payments                 => 0.0,
         trade_union                          => 1.0,
         friendly_society_benefits            => 1.0,
         private_sickness_scheme              => 1.0,
         accident_insurance_scheme            => 1.0,
         hospital_savings_scheme              => 1.0,
         health_insurance                     => 1.0 );

   --
   --  Retrieve a predefined system.
   --
   function get_default_system return Legal_Aid_Sys;

   function Uprate (sys : Legal_Aid_Sys; amount : real) return Legal_Aid_Sys;

   function is_annual_system( sys_type : System_Type )  return Boolean;

   function getEnglishSystem return Legal_Aid_Sys;

   function Binary_Read_Params ( filename : String ) return Legal_Aid_Sys;

   procedure Binary_Write_Params( filename : String; params : Legal_Aid_Sys );
   --
   -- See: colin's tapering note of 2003 page 2.
   --
   function Make_Proposed_Contributions( use_current_below_upper : boolean := false ) return One_Contribution;

end la_parameters;
