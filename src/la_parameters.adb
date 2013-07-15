--
--  $Author: graham_s $
--  $Date: 2007-11-13 15:53:36 +0000 (Tue, 13 Nov 2007) $
--  $Revision: 4318 $
--
--
--

with Ada.Direct_IO;
with Text_IO;
with Ada.Exceptions; use Ada.Exceptions;

package body la_parameters is

        package Params_io is  new  Ada.Direct_IO ( Legal_Aid_Sys );

        function Binary_Read_Params ( filename : String ) return Legal_Aid_Sys is
                params : Legal_Aid_Sys;
                file     : Params_IO.File_Type;
        begin
                begin
                	Params_IO.Open( file, Params_IO.In_File, filename );
                	Params_IO.Read (file, params );
                	Params_IO.close ( file );
	        exception
        	        when The_Error : others =>
                        text_io.put ( "exception thrown reading params in binary " & filename );
                        text_io.new_line;
                        text_io.put( "Exception_Information " & Exception_Information( The_Error ) );
        	end;
                return params;
        end Binary_Read_Params;

        procedure Binary_Write_Params( filename : String; params : Legal_Aid_Sys ) is
                file     : Params_IO.File_Type;
        begin
                Params_IO.Create
                       ( file,
                         Params_IO.InOut_File,
                         filename );
                Params_IO.Write(file, params );
                Params_IO.close( file );

        end Binary_Write_Params;




   function getDefaultIncomes return Incomes_Array is
      incomes : Incomes_Array;
   begin
      incomes :=
        (wages                                => 1.0,
         luncheon_Vouchers                    => 1.0,
         self_Employment                      => 1.0,
         investment_Income                    => 1.0,
         pensions                             => 1.0,
         other_Income                         => 1.0,
         income_Tax                           => -1.0,
         national_insurance                   => -1.0,
      --  disregarded
         disability_living_allowance          => 0.0,
         attendance_allowance                 => 0.0,
         constantattendance_allowance         => 0.0,
         social_fund                          => 0.0,
      --  included (or irrelevant)
         child_benefit                        => 1.0,
         guaranteed_pension_credit            => 1.0,
         savings_pension_credit               => 1.0,
         retirement_pension                   => 1.0,
         widows_pensions                      => 1.0,
         income_support                       => 1.0,
         maternity_allowance                  => 1.0,
         widowed_mothers_allowance            => 1.0,
         war_disablement_pension              => 1.0,
         war_widow_pension                    => 1.0,
         severe_disability_allowance          => 1.0,
         disabled_persons_tax_credit          => 1.0,
         invalid_care_allowance               => 1.0,  -- carer's allowance in the manual
         income_related_jobseekers_allowance  => 1.0,
         contributory_jobseekers_allowance    => 1.0,
         industrial_injury_disablementBenefit => 1.0,
         incapacity_benefit                   => 1.0,
         working_families_tax_credit          => 1.0,
         new_deal                             => 1.0,
         working_tax_credit                   => 1.0,
         child_tax_credit                     => 1.0,
         any_other_benefit                    => 1.0,
         -- FIXME: guardian's allowance disregard, independent living allowance disreg, industrial death full, addns to ind disablement disreg
         -- statutory maternity pay disreg --
         -- SSP ?? where in the data ??? CHECK IFS code
         widows_payment                       => 1.0,

         unemployment_redundancy_insurance    => 1.0,
         winter_fuel_payments                 => 0.0,
         -- council_tax_rebates                  => 0.0,
         trade_union                          => 1.0,
         friendly_society_benefits            => 1.0,
         private_sickness_scheme              => 1.0,
         accident_insurance_scheme            => 1.0,
         hospital_savings_scheme              => 1.0,
         health_insurance                     => 1.0);
      return incomes;
   end getDefaultIncomes;

   function get_scottish_incomes return Incomes_Array is
      incomes : Incomes_Array := getDefaultIncomes;
   begin
      incomes( income_support ) := 0.0;
      incomes( income_related_jobseekers_allowance ) := 0.0;
      incomes( savings_pension_credit ) := 0.0;
      incomes( guaranteed_pension_credit ) := 0.0;
      incomes( war_disablement_pension ) := 0.0;
      incomes( war_widow_pension ) := 0.0; -- CHECK doesn't explicity say
      return incomes;
   end get_scottish_incomes;

   function uprate (sys : Legal_Aid_Sys; amount : real) return Legal_Aid_Sys is
      s : Legal_Aid_Sys;
   begin
      s                                            := sys;
      s.lower_limit (income, normalClaim)          :=
         uprate (s.lower_limit (income, normalClaim), amount);
      s.lower_limit (income, personalInjuryClaim)  :=
         uprate (s.lower_limit (income, personalInjuryClaim), amount);
      s.upper_limit (income, normalClaim)          :=
         uprate (s.upper_limit (income, normalClaim), amount);
      s.upper_limit (income, personalInjuryClaim)  :=
         uprate (s.upper_limit (income, personalInjuryClaim), amount);
      s.lower_limit (capital, normalClaim)         :=
         uprate (s.lower_limit (capital, normalClaim), amount);
      s.lower_limit (capital, personalInjuryClaim) :=
         uprate (s.lower_limit (capital, personalInjuryClaim), amount);
      s.upper_limit (capital, normalClaim)         :=
         uprate (s.upper_limit (capital, normalClaim), amount);
      s.upper_limit (capital, personalInjuryClaim) :=
         uprate (s.upper_limit (capital, personalInjuryClaim), amount);
      --  FIXME: loop round numchild_allowances here
      s.allow (income).child_allowance (1)        :=
         uprate (s.allow (income).child_allowance (1), amount);
      s.allow (income).child_allowance (2)        :=
         uprate (s.allow (income).child_allowance (2), amount);
      s.allow (income).child_allowance (3)        :=
         uprate (s.allow (income).child_allowance (3), amount);
      s.allow (income).partners_allowance         :=
         uprate (s.allow (income).partners_allowance, amount);
      s.allow (income).other_dependants_allowance :=
         uprate (s.allow (income).other_dependants_allowance, amount);
      s.allow (capital).dependent_allowances      :=
         uprateBands
           (s.allow (capital).dependent_allowances,
            s.allow (capital).num_dependent_allowances,
            amount);

      s.capital_disregard (pensioner).disregard   :=
         uprateBands
           (s.capital_disregard (pensioner).disregard,
            s.capital_disregard (pensioner).numDisregards,
            amount,
            10.0);
      s.capital_disregard (pensioner).incomeLimit :=
         uprateBands
           (s.capital_disregard (pensioner).incomeLimit,
            s.capital_disregard (pensioner).numDisregards,
            amount,
            10.0);

      s.contributions (capital).contribution_band :=
         uprateBands
           (s.contributions (capital).contribution_band,
            s.contributions (capital).numContributions,
            amount);
      s.contributions (income).contribution_band  :=
         uprateBands
           (s.contributions (income).contribution_band,
            s.contributions (capital).numContributions,
            amount);

      s.student_grant_disregard  := uprate (s.student_grant_disregard, amount);
      s.mortgage_maximum         := uprate (s.mortgage_maximum, amount);
      s.averagewater_rates       := uprate (s.averagewater_rates, amount);
      s.housing_equity_disregard := uprate (s.housing_equity_disregard, amount);
      return s;
   end uprate;

   --  OCtober 2005 uprating
   function getEnglishSystem return Legal_Aid_Sys is
      s : Legal_Aid_Sys;
   begin
      s.title                                     :=
         Str80.To_Bounded_String ("Default English System 2005/6");
      s.sys_type                                  := civil;
      s.lower_limit (income, normalClaim)         := 3_468.0;
      s.lower_limit (income, personalInjuryClaim) := 3_468.0;
      s.upper_limit (income, normalClaim)         := 8_064.0;
      s.upper_limit (income, personalInjuryClaim) := 8_484.0; -- FIXME CHECK july 07
      s.passport_benefits                         :=
        (income_support                      => True,
         guaranteed_pension_credit           => True,
         income_related_jobseekers_allowance => True,
         others => False);
      s.gross_IncomeLimit                         := 29_220.0;    -- FIXME: plus 2288 for each
                                                                  --child after the 4th

      s.lower_limit (capital, normalClaim)         := 3_000.0;
      s.lower_limit (capital, personalInjuryClaim) := 3_000.0;
      s.upper_limit (capital, normalClaim)         := 8_000.0;
      s.upper_limit (capital, personalInjuryClaim) := 8_000.0;

      s.allow (income).num_child_age_limits       := 3; -- 1, really
      s.allow (income).child_age_limit (1)        := 16;
      s.allow (income).child_age_limit (2)        := 19;
      s.allow (income).child_age_limit (3)        := 999;
      s.allow (income).child_allowance (1)        := 2_481.0;
      s.allow (income).child_allowance (2)        := 2_481.0;
      s.allow (income).child_allowance (3)        := 2_481.0;
      s.allow (income).partners_allowance         := 1_759.44;
      s.allow (income).other_dependants_allowance := 2_481.0;
      --
      s.pensioner_age_limit (male)                     := 60;
      s.pensioner_age_limit (female)                   := 60;
      s.capital_disregard (nonPensioner).numDisregards := 0;
      s.capital_disregard (pensioner).numDisregards    := 10;
      s.capital_disregard (pensioner).disregard        :=
        (1      => 100_000.0,
         2      => 90_000.0,
         3      => 80_000.0,
         4      => 70_000.0,
         5      => 60_000.0,
         6      => 50_000.0,
         7      => 40_000.0,
         8      => 30_000.0,
         9      => 20_000.0,
         10     => 10_000.0,
         others => 0.0);
      s.capital_disregard (pensioner).incomeLimit      :=
        (1      => 300.0,
         2      => 600.0,
         3      => 900.0,
         4      => 1_200.0,
         5      => 1_500.0,
         6      => 1_800.0,
         7      => 2_100.0,
         8      => 2_400.0,
         9      => 2_700.0,
         10     => 3_264.0,
         others => money'Last);

      s.incomesList                            := getDefaultIncomes;
      s.gross_IncomesList                      := getDefaultIncomes;
      s.gross_IncomesList (income_Tax)         := 0.0;
      s.gross_IncomesList (national_insurance) := 0.0;
      --
      --  see: http://www.legalservices.gov.uk/civil/calc/guidance.asp
      s.contributions (capital).numContributions        := 1;
      s.contributions (income).numContributions         := 3;
      s.contributions (income).contribution_proportion  :=
        (1      => 0.25,
         2      => 1.0 / 3.0,
         3      => 0.5,
         others => 0.0);
      s.contributions (capital).contribution_proportion := (1 => 1.0, others => 0.0);
      s.contributions (capital).contribution_band       := (1 => money'Last, others => 0.0);
      s.contributions (income).contribution_band        :=
        (1      => 1524.0,
         2      => 3096.0,
         3      => money'Last,
         others => 0.0);

      s.student_grant_disregard := 500.0;
      s.mortgage_maximum        := 100000.0;
      s.averagewater_rates      := 0.0;
      s.share_deduction         := 0.15;

      s.allowable_expenses (travel_expenses)      := (True, 45.0 * 12.0);
      s.allowable_expenses (pension)              := (False, 0.0);
      s.allowable_expenses (avcs)                 := (False, 0.0);
      s.allowable_expenses (union_fees)           := (False, 0.0);
      s.allowable_expenses (childminding)         := (True, 600.0 * 12.0);
      s.allowable_expenses (friendly_societies)   := (False, 0.0);
      s.allowable_expenses (sports)               := (False, 0.0);
      s.allowable_expenses (loan_repayments)      := (False, 0.0);
      s.allowable_expenses (medical_insurance)    := (False, 0.0);
      s.allowable_expenses (charities)            := (False, 0.0);
      s.allowable_expenses (maintenance_payments) := (False, 1.0);
      s.allowable_expenses (shared_rent)          := (False, 0.0);
      s.allowable_expenses (student_expenses)     := (False, 0.0);
      s.allowable_finance (loan_repayments)       := (False, 0.0);
      s.allowable_finance (fines_and_transfers)     := (False, 1.0);

      s.housing_allowances.mortgages             := (False, 1.0);
      s.housing_allowances.council_tax           := (False, 0.0);
      s.housing_allowances.water_rates           := (False, 0.0); --  should be nil in NI
      s.housing_allowances.ground_rent           := (False, 0.0);
      s.housing_allowances.service_charges       := (False, 0.0);
      s.housing_allowances.repairs_and_insurance := (True, 0.0);
      s.housing_allowances.rent                  := (False, 1.0); --  see 167
      --  rent share see 169/2
      s.housing_allowances.rent_rebates        := (False, 1.0);
      s.housing_allowances.council_tax_rebates := (False, 0.0);
      s.single_persons_housing_costs_max       := 6_540.0;
      s.housing_equity_is_capital              := True;
      s.housing_equity_disregard               := 100_000.0;
      return s;
   end getEnglishSystem;

   --
   -- See: colin's tapering note of 2003 page 2.
   -- colin's numbers are Below
	-- 
	-- £2,851   Nil contribution 
	-- £2,851 - £4,350   25%              
	-- £4,350 - £9,307   36%              
	-- £9,307 - £15,000  40%              
	-- £15,000 - £25,000 75%              
	-- Over £25,000       100%
	-- where 2851 is the zero band £9,307 is the upper limit
	-- and the 4350 is such that the 25 and 36 % bands have 33% for someone at top
	-- we adjust this so that we have just the bands between the limits (since the lower is treated seperately)
	-- and we're using 2995 and 9781 as the lower and upper limits
	--
   function make_proposed_contributions( use_current_below_upper : boolean := false ) return One_Contribution is
      cont : One_Contribution;
   begin
		cont.numContributions         := 5;
		cont.contribution_proportion :=
		  (     1      => 0.25,
			2      => 0.36,
			3      => 0.40,
			4      => 0.75,
			5      => 1.00,
			others => 0.0);
		cont.contribution_band :=
		  (     1      => 1_645.0,
			2      => 6_785.0,
			3      => 12_005.0,
			4      => 22_005.0,
			5      => money'Last,
			others => 0.0);
		if( use_current_below_upper ) then
			cont.contribution_proportion(1) := 1.0/3.0;
			cont.contribution_proportion(2) := 1.0/3.0;
      end if;
      return cont;
   end make_proposed_contributions;
   
   

   function get_default_system return Legal_Aid_Sys is
      s : Legal_Aid_Sys := getEnglishSystem;
   begin
      s.title                                     :=
         Str80.To_Bounded_String ("Default Scottish System 2006/7");
      s.incomesList :=  get_scottish_incomes;
      s.sys_type := civil;
      s.gross_IncomesList := ( others=>0.0 );
      s.allowable_expenses(travel_expenses) := ( false, 1.0 ); -- all travel allowable with no upper limit
      s.housing_allowances.council_tax           := (False, 1.0); -- all ct allowable
      s.housing_allowances.repairs_and_insurance := ( false, 1.0);
      s.capital_disregard (pensioner).disregard        :=
        (1      => 35_000.0,
         2      => 30_000.0,
         3      => 25_000.0,
         4      => 20_000.0,
         5      => 15_000.0,
         6      => 10_000.0,
         7      => 5_000.0,
         others => 0.0);
      s.capital_disregard (pensioner).incomeLimit      :=
        (1      => 350.0,
         2      => 800.0,
         3      => 1_200.0,
         4      => 1_600.0,
         5      => 2_050.0,
         6      => 2_450.0,
         7      => 999999999.99,
         others => 0.0 );
      s.housing_equity_is_capital              := false;
      s.housing_equity_disregard               := 0.0;
      s.allow (income).num_child_age_limits       := 3; -- 1, really
      s.allow (income).child_age_limit (1)        := 16;
      s.allow (income).child_age_limit (2)        := 19;
      s.allow (income).child_age_limit (3)        := 999;
      s.allow (income).child_allowance (1)        := 2_377.0;
      s.allow (income).child_allowance (2)        := 2_377.0;
      s.allow (income).child_allowance (3)        := 2_377.0;
      s.allow (income).partners_allowance         := 1_702.0;
      s.allow (income).other_dependants_allowance := 2_377.0;

      s.lower_limit (capital, normalClaim)         := 6_640.0;
      s.lower_limit (capital, personalInjuryClaim) := 6_640.0;
      s.upper_limit (capital, normalClaim)         := 11_070.0;
      s.upper_limit (capital, personalInjuryClaim) := 11_070.0;

      s.lower_limit (income, normalClaim)         := 2_995.0;
      s.lower_limit (income, personalInjuryClaim) := 3_264.0;
      s.upper_limit (income, normalClaim)         := 9_781.0;
      s.upper_limit (income, personalInjuryClaim) := 8_484.0;
      --
      -- CHECK THESE
      --
      s.allowable_expenses (pension)              := (False, 1.0);
      s.allowable_expenses (avcs)                 := (False, 1.0);
      s.allowable_expenses (union_fees)           := (False, 1.0);
      s.allowable_expenses (childminding)         := (False, 1.0);
      s.allowable_expenses (friendly_societies)   := (False, 1.0);
      s.allowable_expenses (sports)               := (False, 1.0);
      s.allowable_expenses (loan_repayments)      := (False, 1.0);
      s.allowable_expenses (medical_insurance)    := (False, 1.0);
      s.allowable_expenses (charities)            := (False, 1.0);
      s.allowable_expenses (maintenance_payments) := (False, 1.0);
      s.allowable_expenses (shared_rent)          := (False, 1.0);
      s.allowable_expenses (student_expenses)     := (False, 1.0);
      s.allowable_finance (loan_repayments)       := (False, 1.0);

      s.housing_allowances.mortgages             := (False, 1.0);
      s.housing_allowances.council_tax           := (False, 1.0);
      s.housing_allowances.water_rates           := (False, 1.0); --  should be nil in NI
      s.housing_allowances.ground_rent           := (False, 1.0);
      s.housing_allowances.service_charges       := (False, 1.0);
      s.housing_allowances.repairs_and_insurance := (False, 1.0);
      s.housing_allowances.rent_rebates := (False, 1.0);
      s.housing_allowances.council_tax_rebates := (False, 1.0);


      s.gross_IncomeLimit                         := Money'Last;
      s.contributions (income).numContributions         := 1;
      s.contributions (income).contribution_proportion  :=
        (1      => 1.0 / 3.0,
         others => 0.0);
      s.contributions (income).contribution_band       := (1 => money'Last, others => 0.0);
      s.passport_benefits                         :=
        (income_support                      => True,
         income_related_jobseekers_allowance => True,
         others => False);
      return s;
  end get_default_System;


   function is_annual_system( sys_type : System_Type ) return Boolean is
   begin
      return ( sys_type = civil );
   end is_annual_system;

end la_parameters;
