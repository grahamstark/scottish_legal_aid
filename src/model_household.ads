--
--  $Author: graham_s $
--  $Date: 2007-03-26 16:50:35 +0100 (Mon, 26 Mar 2007) $
--  $Revision: 2423 $
--
with base_model_types; use base_model_types;
with Ada.Calendar;     use Ada.Calendar;
with Ada.Direct_IO;
with FRS_Utils;
with FRS_Enums;        use FRS_Enums;
with data_constants;   use data_constants;
--
--  FIXME: takeup record should be moved both out of here and the raw frs
--  reference to raw_frs should then be deleted.
--
package model_household is

   MAX_NUM_BENEFIT_UNITS : constant := 9;
   MAX_NUM_CHILDREN      : constant := 9;
   MAX_CHILD_AGE         : constant := 21;   -- FIXME: Should this be 18??
   MIN_ADULT_AGE         : constant := 16;
   MAX_ADULT_AGE         : constant := 120;

   MODEL_DATA_DIR : constant String :=
      "/home/graham_s/VirtualWorlds/projects/scottish_legal_aid/model/data/";

   type Head_Or_Spouse is (head, spouse);

   subtype Decile_Number is Integer range 1 .. 10;

   subtype Child_Range is Integer range 0 .. MAX_NUM_CHILDREN;

   subtype Child_Age is Integer range 0 .. MAX_CHILD_AGE;

   subtype Adult_Age is Integer range MIN_ADULT_AGE .. MAX_ADULT_AGE;

   type Expense_Items is (
      travel_expenses,
      pension,
      avcs,
      union_fees,
      friendly_societies,
      sports,
      loan_repayments,
      medical_insurance, --
      charities,
      maintenance_payments, --
      childminding,
      shared_rent,
      student_expenses);

   type Expenses_Array is array (Expense_Items) of money;

   type Model_Housing_Costs is
      record
         mortgages             : money := 0.0; --s
         gross_council_tax     : money := 0.0;
         water_rates           : money := 0.0; --  should be nil in NI
         ground_rent           : money := 0.0;
         service_charges       : money := 0.0;
         repairs_And_Insurance : money := 0.0;
         rent                  : money := 0.0; --  see 167
         --  rent share see 169/2
         council_tax_rebates           : money   := 0.0;
         rent_rebates                  : money   := 0.0;
         costs_are_shared              : Boolean := False;  --  probably from HHSTAT
         home_equity                   : money   := 0.0;
         house_price                   : money   := 0.0;
         mortgages_outstanding         : money   := 0.0;
         estimated_house_price_actual  : money   := 0.0;
         estimated_house_price_indexed : money   := 0.0;
      end record;

   type Finance_Items is (loan_repayments, fines_and_transfers);

   type FinanceArray is array (Finance_Items) of money;

   type Income_Items is (
      wages, --
      luncheon_Vouchers, --
      self_Employment, --
      investment_Income, --
      pensions, --
      other_Income, --
      income_Tax, --
      national_insurance, --
   --  disregarded
      disability_living_allowance, --
      attendance_allowance, --
      constantattendance_allowance, --
      social_fund, --
   --  included
      child_benefit, --
      guaranteed_pension_credit, --
      savings_pension_credit, --
      retirement_pension, --
      widows_pensions, --
      income_support, --
      maternity_allowance, --
      widowed_mothers_allowance, --
      war_disablement_pension, --
      war_widow_pension, --
      severe_disability_allowance, --
      disabled_persons_tax_credit, --
      invalid_care_allowance, --
      income_related_jobseekers_allowance, --
      contributory_jobseekers_allowance, --
      industrial_injury_disablementBenefit, --
      incapacity_benefit, --
      working_families_tax_credit, --
      new_deal, --
      working_tax_credit, --
      child_tax_credit, --
      any_other_benefit, --
      widows_payment, --
      unemployment_redundancy_insurance, --
      winter_fuel_payments, --
   --  council_tax_rebates, --
   --
      trade_union, --
      friendly_society_benefits, --
      private_sickness_scheme, --
      accident_insurance_scheme, --
      hospital_savings_scheme, --
      health_insurance);

   subtype Benefits is Income_Items range disability_living_allowance .. winter_fuel_payments;

   type Incomes_Array is array (Income_Items) of money;

   type Model_Adult is
      record
         age            : Adult_Age                := MAX_ADULT_AGE;
         sex            : Gender                   := missing;
         marital_status : FRS_Enums.Marital_Status := missing;
         ethnic_group   : FRS_Enums.Ethnic_Group   := missing;
         -- MARITAL
         relToHoH : FRS_Enums.Relationship_To_Head_Of_Household := missing;
         -- RELP1(HD
         responsible_for_housing_costs : Boolean := False;

         finance : FinanceArray  := (loan_repayments => 0.0, fines_and_transfers => 0.0);
         incomes : Incomes_Array :=
           (wages                                => 0.0,
            luncheon_Vouchers                    => 0.0,
            self_employment                      => 0.0,
            investment_Income                    => 0.0,
            pensions                             => 0.0,
            other_income                         => 0.0,
            income_tax                           => 0.0,
            national_insurance                   => 0.0,
            disability_living_allowance          => 0.0,
            attendance_allowance                 => 0.0,
            constantattendance_allowance         => 0.0,
            social_fund                          => 0.0,
            child_benefit                        => 0.0,
            guaranteed_pension_credit            => 0.0,
            savings_pension_credit               => 0.0,
            retirement_pension                   => 0.0,
            widows_pensions                      => 0.0,
            income_support                       => 0.0,
            maternity_allowance                  => 0.0,
            widowed_mothers_allowance            => 0.0,
            war_disablement_pension              => 0.0,
            war_widow_pension                    => 0.0,
            severe_disability_allowance          => 0.0,
            disabled_persons_tax_credit          => 0.0,
            invalid_care_allowance               => 0.0,
            income_related_jobseekers_allowance  => 0.0,
            contributory_jobseekers_allowance    => 0.0,
            industrial_injury_disablementBenefit => 0.0,
            incapacity_benefit                   => 0.0,
            working_families_tax_credit          => 0.0,
            new_deal                             => 0.0,
            working_tax_credit                   => 0.0,
            child_tax_credit                     => 0.0,
            any_other_benefit                    => 0.0,
            widows_payment                       => 0.0,
            unemployment_redundancy_insurance    => 0.0,
            winter_fuel_payments                 => 0.0,
         --  council_tax_rebates                => 0.0,
            trade_union                          => 0.0,
            friendly_society_benefits            => 0.0,
            private_sickness_scheme              => 0.0,
            accident_insurance_scheme            => 0.0,
            hospital_savings_scheme              => 0.0,
            health_insurance                     => 0.0);

         expenses : Expenses_Array :=
           (travel_expenses      => 0.0,
            pension              => 0.0,
            avcs                 => 0.0,
            union_fees           => 0.0,
            friendly_societies   => 0.0,
            sports               => 0.0,
            loan_repayments      => 0.0,
            medical_insurance    => 0.0,
            charities            => 0.0,
            maintenance_payments => 0.0,
            childminding         => 0.0,
            shared_rent          => 0.0,
            student_expenses     => 0.0);

         is_lodger      : Boolean                     := False;
         employment     : FRS_Enums.Employment_Status := missing;
         ilo_employment : FRS_Enums.ILO_Employment_Status := missing;

         has_company_car : Boolean := False;
         capital_stock   : money   := 0.0;
         --  religion      : Religion_Type    := no_answer;
      end record;

   type Adult_Array is array (Head_Or_Spouse) of Model_Adult;

   type Model_Child is
      record
         age                  : Child_Age                                   := 0;
         sex                  : Gender                                      := male;
         marital_status       : FRS_Enums.Marital_Status                    := missing;
         relToHoH             : FRS_Enums.Relationship_To_Head_Of_Household := missing;
         ethnic_group         : FRS_Enums.Ethnic_Group                      := missing;
         in_formal_child_care : Boolean                                     := False;
      end record;

   type Child_Array is array (1 .. MAX_NUM_CHILDREN) of Model_Child;

   type Model_Benefit_Unit is
      record
         last_adult          : Head_Or_Spouse                         := head;
         adults              : Adult_Array;
         num_children        : Child_Range                            := 0;
         children            : Child_Array;
         decile              : Decile_Number                          := 5;
         non_dependency_type : FRS_Enums.Non_Dependency_Class         := missing;
         economic_status     : FRS_Enums.Benefit_Unit_Economic_Status := missing; -- ECSTATBU
         bu_type             : FRS_Enums.HBAI_Benefit_Unit_Type       := missing; -- FAMTYPBU

         age_range_of_head   : FRS_Enums.Age_Group := missing;
         ethnic_group        : FRS_Enums.Aggregated_Ethnic_Group := missing;
         disablement_status  : FRS_Enums.BU_Disabled_Indicator := missing;
         capital_stock       : Money := 0.0;
     end record;

   type Benefit_Unit_Array is array (1 .. MAX_NUM_BENEFIT_UNITS) of Model_Benefit_Unit;

   type Model_Household_Rec is
      record
         sernum              : FRS_Utils.SernumString;
         interview_date      : Time;
         grossing_factor     : real                            := 1.0;
         tenure              : FRS_Enums.Tenure_Type           := missing;
         acorn               : FRS_Enums.Acorn                 := missing;
         composition         : FRS_Enums.Household_Composition := missing;
         income_band         : FRS_Enums.Household_Income_Band := missing;
         standard_region     : FRS_Enums.Standard_Region       := missing;
         old_region          : FRS_Enums.Old_Region            := missing;
         regional_stratifier : FRS_Enums.Regional_Stratifier   := missing;

         housing_costs     : Model_Housing_Costs;
         num_benefit_units : modelint := 1;
         benefit_units     : Benefit_Unit_Array;
      end record;

   procedure uprateHousehold (hh : in out Model_Household_Rec);

   procedure annualise (mhh : in out Model_Household_Rec);

   function toString (hh : Model_Household_Rec) return String;

   function hasDependents (bu : Model_Benefit_Unit) return Boolean;

   package hh_io is new Ada.Direct_IO (Model_Household_Rec);
   --
   --  binary input
   --
   function load (hhFile : hh_io.File_Type; hhseq : modelint) return Model_Household_Rec;

   --  open files; load uprating information.
   --
   procedure initialise
     (hh_file : in out hh_io.File_Type;
      frsYear : DataYears;
      sz      : in out Integer;
      write   : Boolean := False);

   function person_count (hh : Model_Household_Rec) return Integer;

end model_household;
