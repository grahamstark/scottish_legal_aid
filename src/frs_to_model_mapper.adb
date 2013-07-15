--
--  $Author: graham_s $
--  $Date: 2007-03-29 12:52:28 +0100 (Thu, 29 Mar 2007) $
--  $Revision: 2440 $
--
with base_model_types; use base_model_types;
with raw_frs;          use raw_frs;
with FRS_Enums;        use FRS_Enums;
with FRS_Utils;        use FRS_Utils;
with model_household;  use model_household;
with Ada.Calendar;     use Ada.Calendar;
with model_uprate;
with AUnit.Assertions; use AUnit.Assertions;
--
--  FIXME: 1) revise capital estimates
--         2) check housing costs gross and net
--         3) takeup estimates don't really belong here
--         4) check incomes again against frs/hbai derived vars
--
package body frs_to_model_mapper is

   Oct_2003 : constant Time := Time_Of( 2003, 10, 1 );

   --
   --  this only works for households with an outstanding mortgage.
   --
   procedure make_home_equity (hh : Raw_Household; hcosts : in out Model_Housing_Costs) is
      priceChange : real;
      month, year : Integer;
   begin
      if ((hh.owner.BUYYEAR /= MISS) and (hh.owner.MONTH /= MISS)) then
         year               := Integer (hh.owner.BUYYEAR);
         month              := Integer (hh.owner.MONTH);
         priceChange        := model_uprate.housePriceChange (year, month);
         hcosts.house_price := money (priceChange * real (hh.owner.PURCAMT));
         for m in  1 .. hh.numMortgages loop
            hcosts.mortgages_outstanding := hcosts.mortgages_outstanding +
                                            money (hh.mortgages (m).MORTLEFT);
         end loop;
         hcosts.home_equity := hcosts.house_price - hcosts.mortgages_outstanding;
      end if;
   end make_home_equity;

   function makeHHCosts (hh : Raw_Household) return Model_Housing_Costs is
      mhh       : Model_Housing_Costs;
   begin

      mhh.mortgages := real_to_money (hh.household.MORTPAY);        --  including
      --  protection
      --  premia
      --  net_council_tax               := safe_add (hh.household.RTCHECK, hh.household.RTREBAMT);
      --NOT USED
      mhh.water_rates     := 0.0; --  should be nil in NI
      mhh.ground_rent     := real_to_money (hh.household.CHRGAMT1);
      mhh.service_charges :=
         safe_add
           (hh.household.CHRGAMT2,
            hh.household.CHRGAMT3,
            hh.household.CHRGAMT4,
            hh.household.CHRGAMT5,
            hh.household.CHRGAMT6,
            hh.household.CHRGAMT7,
            hh.household.CHRGAMT8,
            hh.household.CHRGAMT9);
      ---
      mhh.repairs_And_Insurance := real_to_money (hh.household.STRAMT2);
      if (hh.household.HHSTAT = 1) then
         --   (hh.renter.RENT, hh.renter.HBENAMT);  --  see 167
         mhh.costs_are_shared := False;
      else
         mhh.costs_are_shared := True;
      end if;
      --  rent share see 169/2
      --mhh.council_tax_rebates    := real_to_money (hh.household.RTREBAMT);
      mhh.costs_are_shared := False; --   FIXME
      make_home_equity (hh, mhh);
      mhh.rent := real_to_money (hh.household.HHRENT);   --  net_rent +
                                                         --mhh.council_tax_rebates;
      mhh.council_tax_rebates := int_to_money (hh.household.CTREBAMT);
      mhh.rent_rebates := real_to_money (hh.renter.HBENAMT);
      mhh.gross_council_tax :=
         safe_add (money (hh.household.CTREBAMT), money (hh.household.CTAMT));-- make_rate_rebates_f
                                                                              --rom_hbai( hh );
      return mhh;
   end makeHHCosts;

   function map_frs_benefit (ben_no : Integer) return Benefit_Types is
      b : Benefit_Types;
   begin
      case ben_no is
      when 1 =>
         b := dla_self_care;
      when 2 =>
         b := dla_mobility;
      when 3 =>
         b := child_benefit;
      when 4 =>
         b := pension_credit;
      when 5 =>
         b := retirement_pension_opp;
      when 6 =>
         b := widows_pension_bereavement_allowance;
      when 7 =>
         b := widowed_mothers_widowed_parents_allowance;
      when 8 =>
         b := war_disablement_pension;
      when 9 =>
         b := war_widows_widowers_pension;
      when 10 =>
         b := severe_disability_allowance;
      when 11 =>
         b := disabled_persons_tax_credit;
      when 12 =>
         b := attendence_allowance;
      when 13 =>
         b := invalid_care_allowance;
      when 14 =>
         b := jobseekers_allowance;
      when 15 =>
         b := industrial_injury_disablement_benefit;
      when 17 =>
         b := incapacity_benefit;
      when 18 =>
         b := working_families_tax_credit;
      when 19 =>
         b := income_support;
      when 20 =>
         b := new_deal;
      when 21 =>
         b := maternity_allowance;
      when 22 =>
         b := maternity_grant_from_social_fund;
      when 24 =>
         b := funeral_grant_from_social_fund;
      when 25 =>
         b := community_care_grant_from_social_fund;
      when 26 =>
         b := back_to_work_bonus_received;
      when 27 =>
         b := back_to_work_bonus_accrued;
      when 30 =>
         b := any_other_ni_or_state_benefit;
      when 31 =>
         b := trade_union_sick_strike_pay;
      when 32 =>
         b := friendly_society_benefits;
      when 33 =>
         b := private_sickness_scheme_benefits;
      when 34 =>
         b := accident_insurance_scheme_benefits;
      when 35 =>
         b := hospital_savings_scheme_benefits;
      when 36 =>
         b := government_training_allowances;
      when 37 =>
         b := guardians_allowance;
      when 39 =>
         b := social_fund_loan_budgeting;
      when 40 =>
         b := social_fund_loan_crisis;
      when 41 =>
         b := working_families_tax_credit_lump_sum;
      when 42 =>
         b := future_dla_self_care;
      when 43 =>
         b := future_dla_mobility;
      when 44 =>
         b := future_attendance_allowance;
      when 50 =>
         b := disabled_persons_tax_credit_lump_sum;
      when 51 =>
         b := child_maintenance_bonus;
      when 52 =>
         b := lone_parent_benefit_run_on;
      when 60 =>
         b := widows_payment;
      when 61 =>
         b := unemployment_redundancy_insurance;
      when 62 =>
         b := winter_fuel_payments;
      when 65 =>
         b := dwp_direct_payments_isa;
      when 66 =>
         b := dwp_direct_payments_jsa;
      when 78 =>
         b := hb_only_or_separately;
      when 79 =>
         b := ctb_only_or_separately;
      when 80 =>
         b := hb_ctb_paid_together;
      when 81 =>
         b := permanent_health_insurance;
      when 82 =>
         b := any_other_sickness_insurance;
      when 83 =>
         b := critical_illness_cover;
      when 90 =>
         b := working_tax_credit;
      when 91 =>
         b := child_tax_credit;
      when 92 =>
         b := working_tax_credit_lump_sum;
      when 93 =>
         b := child_tax_credit_lump_sum;
      when MISS =>
         b := missing;
      when others =>
         b := missing;
      end case;
      return b;
   end map_frs_benefit;

   function benefitType (btype : Benefit_Types) return Income_Items is
      item : Income_Items;
   begin
      case btype is
      when dla_self_care .. dla_mobility =>
         item := disability_living_allowance; --  DLA(self care)
      when child_benefit =>
         item := child_benefit;  --  Child Benefit
      when pension_credit =>
         item := guaranteed_pension_credit; --  Pension credit FIXME: split
      when retirement_pension_opp =>
         item := retirement_pension;   --  Retirement Pension /OPP
      when war_widows_widowers_pension =>
         item := war_widow_pension;   --  Widow's Pension/Bereavement Allowance
      when widowed_mothers_widowed_parents_allowance | widows_pension_bereavement_allowance =>
         item := widowed_mothers_allowance; --  Widowed Mothers/Widowed Parents Allowance
      when war_disablement_pension =>
         item := war_disablement_pension;  --  War Disablement Pension
      when severe_disability_allowance =>
         item := severe_disability_allowance;   --  Severe Disability Allowance
      when disabled_persons_tax_credit | disabled_persons_tax_credit_lump_sum =>
         item := disabled_persons_tax_credit;   --  Disabled Person's Tax Credit
      when attendence_allowance =>
         item := attendance_allowance;   --  Attendence Allowance
      when invalid_care_allowance =>
         item := invalid_care_allowance;   --  Invalid Care Allowance
      when jobseekers_allowance =>  -- !!! FIXME/contrib non contrib
         item := income_related_jobseekers_allowance;      -- contributory_jobseekers_allowance;
      --  inc/contJobseeker's
      --  Allowance
      when industrial_injury_disablement_benefit =>
         item := industrial_injury_disablementBenefit;     --  Industrial Injury
      --  Disablement Benefit
      when incapacity_benefit =>
         item := incapacity_benefit;   --  Incapacity Benefit
      when working_families_tax_credit | working_families_tax_credit_lump_sum =>
         item := working_families_tax_credit;       --  Working Families' Tax Credit
      --  CHECK 91!!
      when income_support => 
         item := income_support;  --  Income Support and jsa (14)
      when dwp_direct_payments_isa | dwp_direct_payments_jsa =>
         null;  --  | FIXME: these are deductions!!  
      when new_deal =>
         item := new_deal;   --  New Deal
      when maternity_allowance =>
         item := maternity_allowance;   --  Maternity Allowance
      when maternity_grant_from_social_fund      |
           funeral_grant_from_social_fund        |
           community_care_grant_from_social_fund |
           social_fund_loan_budgeting            |
           social_fund_loan_crisis               =>
         item := social_fund;   --  Maternity Grant from Social Fund
      when back_to_work_bonus_received =>
         item := any_other_benefit;   --  Back to Work Bonus (received)
      when back_to_work_bonus_accrued =>
         item := any_other_benefit;   --  Back to Work Bonus (accrued)
      when any_other_ni_or_state_benefit =>
         item := any_other_benefit;   --  Any other NI or State benefit
      when trade_union_sick_strike_pay =>
         item := trade_union;  --  Trade Union sick/strike pay
      when friendly_society_benefits =>
         item := friendly_society_benefits;   --  Friendly Society Benefits
      when private_sickness_scheme_benefits =>
         item := private_sickness_scheme;   --  Private sickness scheme benefits
      when accident_insurance_scheme_benefits =>
         item := accident_insurance_scheme;   --  Accident insurance scheme benefits
      when hospital_savings_scheme_benefits =>
         item := hospital_savings_scheme;   --  Hospital savings scheme benefits
      when government_training_allowances =>
         item := any_other_benefit;   --  Government training allowances
      when guardians_allowance =>
         item := any_other_benefit;   --  Guardians Allowance
      --  when  => item :=    --  Working Families' Tax Credit - Lump Sum
      when future_dla_self_care =>
         item := any_other_benefit;   --  Future: DLA Self Care
      when future_dla_mobility =>
         item := any_other_benefit;   --  Future: DLA Mobility
      when future_attendance_allowance =>
         item := any_other_benefit;   --  Future: Attendance Allowance
      when child_maintenance_bonus =>
         item := any_other_benefit;   --  Child Maintenance Bonus
      when lone_parent_benefit_run_on =>
         item := any_other_benefit;    --  Lone Parent Benefit run-on
      when widows_payment =>
         item := widows_payment;   --  Widow's Payment
      when unemployment_redundancy_insurance =>
         item := unemployment_redundancy_insurance;        --  Unemployment/Redundancy
      --  Insurance
      when winter_fuel_payments =>
         item := winter_fuel_payments;  --  Winter Fuel Payments
      --  when 65 => item :=    --  DWP direct payments - ISA
      --  when 66 => item :=    --  DWP direct payments - JSA
      --      when 78 =>
      --        item := council_tax_rebates;   --  HB only or separately
      --     when 79 =>
      --      item := council_tax_rebates;   --  CTB only or separately
      --   when 80 =>
      --      item := council_tax_rebates;   --  HB/CTB paid together
      when permanent_health_insurance =>
         item := health_insurance;   --  Permanent health insurance
      when any_other_sickness_insurance =>
         item := health_insurance;   --  Any other sickness insurance
      when critical_illness_cover =>
         item := health_insurance;   --  Critical Illness Cover
      when working_tax_credit_lump_sum | working_tax_credit =>
         item := working_tax_credit;  --  Working Tax Credit
      when child_tax_credit | child_tax_credit_lump_sum =>
         item := child_tax_credit;  --  Child Tax Credit
      when hb_only_or_separately .. hb_ctb_paid_together =>
         item := any_other_benefit; -- we're ignoring all housing benefit paid to individuals for
                                    --now
      when missing =>
         item := any_other_benefit;
      end case;
      return item;
   end benefitType;

   procedure assignBenefits (interview_date : Time; mad : in out Model_Adult; adult : Raw_Adult) is
      btype : Benefit_Types;
      ptype : Pension_Types;
      itype : Income_Items;
      penAmount : Real;
      found_savings_pension_credit : boolean := false;
      found_guaranteed_pension_credit : boolean := false;
   begin
      for bno in  1 .. adult.numBenefits loop
         string_io.put ( " num benefits = " & adult.numBenefits'Img );
         if (adult.benefits (bno).BENEFIT /= MISS) then
            string_io.put ( " on benefit type  = " & adult.benefits (bno).BENEFIT'Img );
            btype := map_frs_benefit (adult.benefits (bno).BENEFIT);
            string_io.put ( "got benefit type of " & frs_enums.pretty_print ( btype ));
            string_io.put( "amount " & adult.benefits (bno).BENAMT'Img );
            string_io.new_line;
            case btype is
               when missing | hb_only_or_separately .. hb_ctb_paid_together =>
                  string_io.put( "skipping benefit " );
                  null; -- skip hb at individual level
               when income_support =>
                  -- pensioner Migs, recorded in 1st half of 0304 counted as pension credit
                  if (( interview_date < Oct_2003 ) and ( mad.age > 59 ) )then
                     mad.incomes (guaranteed_pension_credit) := mad.incomes (guaranteed_pension_credit) + real_to_money (adult.benefits (bno).BENAMT);
                  else
                     mad.incomes (income_support) := mad.incomes (income_support) + real_to_money (adult.benefits (bno).BENAMT);
                  end if;
               when pension_credit =>
                  found_savings_pension_credit := false;
                  found_guaranteed_pension_credit := false;
                  if( adult.numPenAmts > 0 ) then -- Try splitting into savings/gtd using the penamt record;
                                                  -- this data has some records
                                                  -- for gtd and savings credits, but not all. So, search through
                                                  -- this record and use it to allocate if present, else fall back
                                                  -- on assuming it's all gtd and use the benefits record
                     for penno in  1 .. adult.numPenAmts loop
                        ptype := convert_pension_types(adult.penamts (penno).AMTTYPE);
                        penAmount := adult.penamts (penno).PENQ;
                        if( penAmount /= MISS_R ) then
                           if (ptype = pension_credit_savings_element_amt) then
                              mad.incomes (savings_pension_credit) := mad.incomes (savings_pension_credit) + real_to_money (penAmount);
                              found_savings_pension_credit := true;
                           elsif (ptype = pension_credit_guaranteed_element_amt) then
                              mad.incomes(guaranteed_pension_credit) := mad.incomes(guaranteed_pension_credit) + real_to_money (penAmount);
                              found_guaranteed_pension_credit := true;
                           end if;
                        end if;
                     end loop;
                  end if;
                  if( not ( found_savings_pension_credit or found_guaranteed_pension_credit )) then
                     --
                     --  nothing in the pension amounts records:
                     --  fall back on the
                     --
                     mad.incomes (guaranteed_pension_credit) := mad.incomes (guaranteed_pension_credit) + 
                           real_to_money (adult.benefits (bno).BENAMT);
                  end if;
               when jobseekers_allowance =>
                  --
                  --  undocumented, and reverse engineered from some old
                  --  code: VAR2 = 2 for means-tested jsa
                  --

                  if (adult.benefits (bno).VAR2 = 2) then
                     mad.incomes (income_related_jobseekers_allowance) := mad.incomes (income_related_jobseekers_allowance) +
                        real_to_money (adult.benefits (bno).BENAMT);
                  else 
                     mad.incomes (contributory_jobseekers_allowance) := mad.incomes (contributory_jobseekers_allowance) +
                        real_to_money (adult.benefits (bno).BENAMT);
                  end if;
               when others =>
                  itype               := benefitType (btype);
                  mad.incomes (itype) := mad.incomes (itype) + real_to_money (adult.benefits (bno).BENAMT);
                  if ( itype = social_fund ) or ( itype = winter_fuel_payments ) then
                     mad.incomes (itype) := mad.incomes (itype) / 52.0;
                     --  FIXME check against old IFS code!!!
                  end if;
                  string_io.put( "set income " & itype'Img & " to " & mad.incomes (itype)'Img );
                  string_io.new_line;
            end case;
         end if;
         string_io.new_line;
      end loop;

   end assignBenefits;

   function makeFinance (adult : Raw_Adult) return FinanceArray is
      fin : FinanceArray := (others => 0.0);
   begin
      fin (loan_repayments) :=
         safe_add
           (real (adult.adult.ED1AMT),
            real (adult.adult.ED2AMT),
            real (adult.adult.SLREPAMT));
      return fin;
   end makeFinance;

   function makeExpenses (adult : Raw_Adult) return Expenses_Array is
      exp : Expenses_Array := (others => 0.0);
   begin
      for jno in  1 .. adult.numJobs loop
         exp (pension) := safe_add (exp (pension), adult.jobs (jno).UDEDUC1);
         --  Amount deducted: pension
         exp (avcs) := safe_add (exp (avcs), adult.jobs (jno).UDEDUC2);
         --  Amount deducted: AVCs
         exp (union_fees) := safe_add (exp (union_fees), adult.jobs (jno).UDEDUC3);
         --  Amount deducted: Union fees
         exp (friendly_societies) :=
            safe_add (exp (friendly_societies), adult.jobs (jno).UDEDUC4);
         --  Amount deducted: friendly socs
         exp (sports) := safe_add (exp (sports), adult.jobs (jno).UDEDUC5);
         --  Amount deducted: sports/social
         exp (loan_repayments) := safe_add (exp (loan_repayments), adult.jobs (jno).UDEDUC6);
         --  Amount deducted: loan repayment
         exp (charities) := safe_add (exp (charities), adult.jobs (jno).UDEDUC8);
         --  Amount deducted: Charities

         --  Amount deducted: Medical Ins
         exp (medical_insurance) := safe_add (exp (medical_insurance), adult.jobs (jno).UDEDUC7);

      end loop;
      exp (travel_expenses) := real_to_money (adult.adult.TTWCOSTS);
      for mno in  1 .. adult.numMaintenances loop
         exp (maintenance_payments) :=
            safe_add (exp (maintenance_payments), adult.maintenances (mno).MRAMT);
      end loop;
      return exp;

   end makeExpenses;

   type JobNetRec is
      record
         isSE  : Boolean := False;
         gross : money   := 0.0;
         it    : money   := 0.0;
         ni    : money   := 0.0;
      end record;

   function makeOneEarnings (adult : Adult_Rec; job : Job_Rec) return JobNetRec is
      inc    : JobNetRec;
      refund : money;
   begin
      if (job.ETYPE = 1) then --  note frs coding of incseo2 checks working and jobaway here to
                              --  ensure they get current earnings, which is NOT what we want here.
                              --We want usual.
         inc.isSE := False;
         if (zero_or_missing (job.UGRSPAY)) then   -- this is the derived usual gross wage var,
                                                   --with bonuses, etc. added back in
            inc.gross := real_to_money (job.GRWAGE); -- take the wage, if present
         else
            inc.gross := real_to_money (job.UGRSPAY);
         end if;
         inc.ni := real_to_money (job.NATINS);
         inc.it := safe_add (job.PAYE, job.TAXDAMT);
         refund := real_to_money (job.TAXAMT);
         inc.it := money'Max (0.0, inc.it - refund); --
         Assert
           (zero_or_missing (job.SETAXAMT),
            "job.SETAXAMT " & job.SETAXAMT'Img & " sernum " & String (job.SERNUM));
         Assert
           (zero_or_missing (job.PROFIT1),
            "job.PROFIT1 " & job.PROFIT1'Img & " sernum " & String (job.SERNUM));
         Assert
           (zero_or_missing (job.SENILAMT),
            "job.SENILAMT" & job.SENILAMT'Img & " sernum " & String (job.SERNUM));
         Assert
           (zero_or_missing (job.SENIRAMT),
            "job.SENIRAMT" & job.SENIRAMT'Img & " sernum " & String (job.SERNUM));
      else
         --  ripped off with some minor changes from the frs derivation routine for
         --  incseo2.
         inc.isSE  := True;
         inc.gross := real_to_money (adult.INCSEO2);

         inc.it := real_to_money (adult.INCSEO2) - real_to_money (adult.NINCSEO2);
         string_io.Put
           ("gross se ( (adult.INCSEO2) " &
            adult.INCSEO2'Img &
            " net " &
            adult.NINCSEO2'Img &
            " ");
         string_io.New_Line;
         --  GKS The Irish Model had a Gross > Net Assertion here, but this fails in the UK Dataset
         --(rebates?)
         --  see hhld  1305803061   in 0304 database (adult record ).
         --  Assert
         --   (real_to_money (adult.INCSEO2) >= real_to_money (adult.NINCSEO2),
         --   "gross se income was lt net ");
         -- inc.it := safe_add( job.SETAXAMT , job.TAXDAMT );  -- not sure at all why we need
         --taxdamt here, but see e.g. 5000303061 p 1 job 2
         --                          if ( job.PROFIT1 /= MISS_R ) then                  -- note
         --that the frs coding of incseo2 checks on JOBBUS =1,2 which seems redundant to me if what
         --we want is usual earnings for se, not current.
         --                                  inc.gross := real_to_money( job.PROFIT1 ); --  gross
         --profit, if present
         --                                  if ( job.PROFIT2 = 2 ) then  --  profit is a loss,
         --really?
         --                                          inc.gross := -1.0*inc.gross;
         --                                  end if;
         --                          elsif ( job.SEINCAMT /= MISS_R ) then
         --                                  inc.gross := real_to_money( job.SEINCAMT );  --  "What
         --is your income from this business?"
         --                                  --  add back tax, as needed
         --                                  inc.it := real_to_money( job.TAXDAMT );
         --                                  if( job.CHECKTAX = 1 ) and ( job.CHKINCOM = 2 ) then
         --                                          inc.gross := inc.gross + inc.it;
         --                                  end if; -- add back income tax
         --                                  inc.ni := real_to_money( job.NIDAMT );
         --                                  if( job.CHECKTAX = 2 ) and ( job.CHKINCOM = 2 ) then
         --                                          inc.gross := inc.gross + inc.ni;
         --                                  end if;
         --                          end if;
         --                          -- FIXME: we need to uprate from account date, not interview
         --date, really.
         --                          if( job.OWNSUM = 1 ) then -- drawings from business
         --                                  --  FIXME: we need to check if this is in place of
         --                                  --  SEINCOME above, or as well as it.
         --                                  inc.gross := inc.gross + safe_add( job.OWNAMT,
         --job.OWNOTAMT );
         --                                  if( job.SENIREG = 1 ) then
         --                                          inc.ni := inc.ni + real_to_money(job.SENIRAMT
         --);
         --                                          inc.gross := inc.gross +
         --real_to_money(job.SENIRAMT );
         --                                  end if;
         --                                  if( job.SETAX = 1 ) then
         --                                          inc.it := inc.it + real_to_money(job.SETAXAMT
         --);
         --                                          inc.gross := inc.gross +
         --real_to_money(job.SETAXAMT );
         --                                  end if;
         --                                  if( job.SENILUMP = 1 ) then
         --                                          inc.ni := inc.ni + real_to_money(job.SENILAMT
         --);
         --                                          inc.gross := inc.gross +
         --real_to_money(job.SENILAMT );
         --                                  end if;
         --                          end if;
         --                          --  FIXME: I think we are losing various bits of SE NI here.
         --                          assert ( zero_Or_Missing ( job.UGROSS ), "job.UGROSS"
         --                                  & job.UGROSS'Img & " sernum " & string ( job.sernum ));
         --                          assert ( zero_Or_Missing ( job.NATINS ), "job.NATINS" &
         --job.NATINS'Img
         --                                  & " sernum " & string ( job.sernum ));
         --                          --   assert ( zero_Or_Missing ( job.TAXDAMT ), "job.TAXDAMT" &
         --job.TAXDAMT'Img
         --                          --        & " sernum " & string ( job.sernum ) & " etype = " &
         --job.ETYPE'Img  );
         --                  end if;
      end if;
      return inc;
   end makeOneEarnings;

   function makeOnePension (pens : Pension_Rec) return JobNetRec is
      outpens : JobNetRec;
   begin
      outpens.gross := real_to_money (pens.PENPAY);
      outpens.it    := real_to_money (pens.PTAMT);
      if (pens.PTINC = 2) then -- pension amount is net of tax
         outpens.gross := outpens.gross + outpens.it;
      end if;
      return outpens;
   end makeOnePension;

   function makeIncomes (adult : Raw_Adult; dyear : DataYears) return Incomes_Array is
      inc          : Incomes_Array := (others => 0.0);
      itype        : Income_Items;
      netI, grossI : money;
      earnRec      : JobNetRec;
      penRec       : JobNetRec;
   begin

      for jno in  1 .. adult.numJobs loop
         earnRec := makeOneEarnings (adult.adult, adult.jobs (jno));
         if (earnRec.isSE) then
            inc (self_Employment) := inc (self_Employment) + earnRec.gross;
         else
            inc (wages) := inc (wages) + earnRec.gross;
         end if;
         inc (income_Tax)         := inc (income_Tax) + earnRec.it;
         inc (national_insurance) := inc (national_insurance) + earnRec.ni;
      end loop;
      --   inc(wages) := real_to_money(adult.adult.INEARNS);
      --   inc(self_employment) := real_to_money(adult.adult.INCSEO2 );
      inc (investment_Income) := real_to_money (adult.adult.ININV);
      for pno in  1 .. adult.numpensions loop
         penRec           := makeOnePension (adult.pensions (pno));
         inc (pensions)   := inc (pensions) + penRec.gross;
         inc (income_Tax) := inc (income_Tax) + penRec.it;
      end loop;
      -- maintenance
      inc (other_Income) := safe_add (adult.adult.MNTAMT1, adult.adult.MNTAMT2);
      string_io.Put
        ("PENINC = " &
         adult.adult.INPENINC'Img &
         " " &
         "inc( pensions ) = " &
         inc (pensions)'Img);
      return inc;
   end makeIncomes;

     function makeAdult (
                         interview_date : Time;
                         adult          : Raw_Adult;
                         dyear          : DataYears) return Model_Adult is
      mad : Model_Adult;
   begin
      mad.age := adult.adult.AGE;
      mad.sex := FRS_Enums.convert_gender( adult.adult.SEX );

      mad.marital_status := FRS_Enums.convert_marital_status(adult.adult.DVMARDF);
      string_io.Put ("R01 = " & adult.adult.R01'Img);
      if (not (adult.adult.R01 = MISS)) then --  missing if you *are HoH"
         mad.relToHoH := FRS_Enums.convert_Relationship_To_Head_Of_Household(adult.adult.R01);
      end if;
      if (adult.adult.EMPSTATB /= MISS) then
         mad.employment := FRS_Enums.convert_Employment_Status(adult.adult.EMPSTATB);
      end if;
      if (adult.adult.EMPSTATI /= MISS) then
         mad.ilo_employment := FRS_Enums.convert_ILO_Employment_Status(adult.adult.EMPSTATI);
      end if;

      for jno in  1 .. adult.numJobs loop
         if (adult.jobs (jno).INKIND10 = 1) then
            mad.has_company_car := True;
         end if;
      end loop;
      mad.incomes   := makeIncomes (adult, dyear);
      assignBenefits (interview_date, mad, adult);
      mad.expenses  := makeExpenses (adult);
      mad.finance   := makeFinance (adult);
      mad.is_lodger := adult.adult.CONVBL = 1;
      return mad;
   end makeAdult;

   function mapCapital (TOTSAV : modelint) return money is
   begin
      case TOTSAV is
      when 1 =>
         return 500.0; --  Less than 1, 500
      when 2 =>
         return 2_250.0; --  From 1,500 up to 3,000
      when 3 =>
         return 5_500.0;  --  From 3,000 up to 8,000
      when 4 =>
         return 14_000.0;  -- 4 From 8,000 up to 20,000
      when 5 =>
         return 22_500.0; --  5	From 20,000 up to 25,000
      when 6 =>
         return 27_500.0; --  6	From 25,000 up to 30,000
      when 7 =>
         return 32_500.0; --- From 30,000 up to 35,000
      when 8 =>
         return 37_500.0; --  8	From 35,000 up to 40,000
      when 9 =>
         return 50_000.0; --           9	Over 40, 000
      when others =>
         return 0.0;       --  10	Does not wish to say : fixme: we could infer from
                           --other sources;
      end case;
   end mapCapital;

   function make_is_school_holidays (hh : Model_Household_Rec) return Boolean is
      thisMonth  : constant Integer := Month (hh.interview_date);
      is_holiday : Boolean          := False;
   begin
      --  NI is 1st July - 1st September (week 26 to week 35)
      -- assume june-july for Scotland july-aug for everywhere else
      if (hh.standard_region = scotland) then
         is_holiday := (thisMonth >= 6) and (thisMonth <= 7);
      else
         is_holiday := (thisMonth >= 7) and (thisMonth <= 8);
      end if;
      return is_holiday;
   end make_is_school_holidays;

   function make_In_Formal_Child_Care (rawChild : Child_Rec) return Boolean is
   begin
      --  CHLOOK01	ADT_107X	Childcare from: close relative
      --  CHLOOK02	ADT_107X	Childcare from: other relative
      --  CHLOOK03	ADT_107X	Childcare from: friend/neighbour
      --  ADT_107X	Childcare from: childminder
      --  CHLOOK05	ADT_107X	Childcare from: nursery/school/playgroup
      --  CHLOOK06	ADT_107X	Childcare from: creche
      --  CHLOOK07	ADT_107X	Childcare from: employer provide nursery
      --  CHLOOK08	ADT_107X	Childcare from: nanny/au pair
      --  CHLOOK09	ADT_107X	Childcare from: before/after school or holiday play scheme
      --  CHLOOK10	ADT_107X	Childcare from: other
      return (rawChild.CHLOOK04 = 1) or
             (rawChild.CHLOOK05 = 1) or
             (rawChild.CHLOOK06 = 1) or
             (rawChild.CHLOOK07 = 1) or
             (rawChild.CHLOOK08 = 1) or
             (rawChild.CHLOOK08 = 1) or
             (rawChild.CHLOOK09 = 1);
   end make_In_Formal_Child_Care;

   function child_Care_paid_in_kind (rawChild : Child_Rec) return Boolean is
   begin
      --  CHPAY1	ADN_10X	Whether payment in kind for childcare
      --  CHPAY2	ADN_10X	Whether childcare on an exchange basis
      --  CHPAY3	ADN_10X	Whether Payment made by "Other"
      return ((rawChild.CHPAY1 = 1) or (rawChild.CHPAY2 = 1) or (rawChild.CHPAY3 = 1));
   end child_Care_paid_in_kind;

   function make_Child_Care_Costs
     (mu                 : Model_Benefit_Unit;
      bu                 : Raw_Benefit_unit;
      is_school_holidays : Boolean)
      return               money
   is
      costs            : money         := 0.0;
      TERM_TIME_WEIGHT : constant real := (38.0 / 52.0);
      HOLIDAY_WEIGHT   : constant real := 1.0 - TERM_TIME_WEIGHT;
   begin
      --  CHAMT1		Costs of childcare during term time
      --  CHAMT2		Costs of childcare during holidays
      for chno in  1 .. bu.num_children loop
         --                	if( mu.children( chno ).in_formal_child_care )then
         if (not child_Care_paid_in_kind (bu.children (chno).child)) then
            costs := costs + safe_mult (TERM_TIME_WEIGHT, bu.children (chno).child.CHAMT1);
            costs := costs + safe_mult (HOLIDAY_WEIGHT, bu.children (chno).child.CHAMT2);

            --                        	if( is_school_holidays ) then--
            --	                        	costs := safe_add( costs, bu.children (chno).Child.CHAMT2 );
            --                                else
            --	                        	costs := safe_add( costs, bu.children (chno).Child.CHAMT1 );
            --                                end if;
         end if;
      end loop;
      return costs;
   end make_Child_Care_Costs;
   --
   -- 0304 version
   --

   function makeChild (ch : Raw_Child) return Model_Child is
      mch : Model_Child;
   begin
      mch.age                  := ch.child.AGE;
      mch.sex                  := FRS_Enums.convert_gender(ch.child.SEX);
      mch.in_formal_child_care := make_In_Formal_Child_Care (ch.child);
      return mch;
   end makeChild;

   function someone_employed (mu : Model_Benefit_Unit) return Boolean is
      emp : Employment_Status;
   begin
      for hdsp in  head .. mu.last_adult loop
         case mu.adults (hdsp).employment is
            when full_time_employee           |
                 part_time_employee           |
                 ft_employee_temporarily_sick |
                 pt_employee_temporarily_sick |
                 industrial_action            |
                 work_related_govt_training   =>
               return True;
            when others =>
               null;
         end case;
      end loop;
      return False;
   end someone_employed;

   procedure allocate_Child_Care_Costs
     (mu                 : in out Model_Benefit_Unit;
      bu                 : Raw_Benefit_unit;
      is_school_holidays : Boolean)
   is
      costs               : money          := 0.0;
      child_care_provider : Head_Or_Spouse := head;
   begin
      if (someone_employed (mu)) then
         costs := make_Child_Care_Costs (mu, bu, is_school_holidays);
      end if;
      if ((mu.last_adult = spouse) and
          ((mu.adults (spouse).employment = self_employed) or
           (mu.adults (spouse).employment = full_time_employee)))
      then
         child_care_provider := spouse;
      end if;
      mu.adults (child_care_provider).expenses (childminding) := costs;
   end allocate_Child_Care_Costs;

   --        	mu : in out Model_Benefit_Unit;

   function makeBenefitUnit ( interview_date : Time; bu : Raw_Benefit_unit; dyear : DataYears) return Model_Benefit_Unit is
      mb   : Model_Benefit_Unit;
      hdsp : Head_Or_Spouse := head;
   begin
      for adno in  1 .. bu.numAdults loop
         mb.adults (hdsp) := makeAdult (interview_date, bu.adults (adno), dyear);
         if (adno = 1) then
            hdsp := spouse;
         end if;
      end loop;
      if (bu.numAdults = 1) then
         mb.last_adult := head;
      else
         mb.last_adult := spouse;
      end if;

      mb.age_range_of_head := FRS_Enums.convert_age_group ( bu.benunit.BUAGEGR2 );
      mb.ethnic_group := FRS_Enums.convert_Aggregated_Ethnic_Group( bu.benunit.BUETHGRP );
      mb.disablement_status := FRS_Enums.convert_BU_Disabled_Indicator ( bu.benunit.DISINDHB );


      mb.num_children      := modelint (bu.num_children);
      for chno in  1 .. bu.num_children loop
         mb.children (modelint (chno))  := makeChild (bu.children (chno));
      end loop;
      --  allocate to head; doesn't matter really.
      --  mb.adults (head).capital_stock := mapCapital (bu.benunit.TOTSAV);
      mb.capital_stock := real_to_money( bu.benunit.totcapbu );
      if (bu.benunit.FAMTHBAI /= MISS) then
         mb.bu_type := FRS_Enums.convert_hbai_benefit_unit_type(bu.benunit.FAMTHBAI);
      end if;
      if (bu.benunit.ECSTATBU /= MISS) then
         mb.economic_status := FRS_Enums.convert_benefit_unit_economic_status(bu.benunit.ECSTATBU);
      end if;
      if (bu.benunit.DEPDEDS /= MISS) then
         mb.non_dependency_type := FRS_Enums.convert_non_dependency_class(bu.benunit.DEPDEDS);
      end if;
      return mb;
   end makeBenefitUnit;

   --
   --  responsibility for housing costs.
   --
   --  FIXME we need to infer this from HHLDR01 .. 09 and HHSTAT=1|2
   --  but eyballing the data shows it's practically all be 1
   --
   procedure allocate_Housing_Costs_Responsibility
     (hh    : Raw_Household;
      mhh   : in out Model_Household_Rec;
      dyear : DataYears)
   is
   begin
      for adno in  head .. mhh.benefit_units (1).last_adult loop
         mhh.benefit_units (1).adults (head).responsible_for_housing_costs := True;
      end loop;
   end allocate_Housing_Costs_Responsibility;

   function map (hh : Raw_Household; dyear : DataYears) return Model_Household_Rec is
      mhh                : Model_Household_Rec;
      iyear              : Year_Number;
      imonth             : Month_Number;
      yr, mn             : modelint := 0;
      is_school_holidays : Boolean  := False;

   begin
      mhh.sernum := hh.household.SERNUM;
      if (dyear = 2004) then
         mhh.grossing_factor := real (hh.household.GROSS3);
      else
         mhh.grossing_factor := real (hh.household.GROSS3);
      end if;

      --  mhh.acorn :=  Acorn_Number( hh.household.ACORN );
      --  date is mmddyyyy as longint
      string_io.New_Line;
      string_io.Put ("====  processing mhh.sernum = " & mhh.sernum);
      string_io.Put
        ("  hh.household.INTDATE " &
         hh.household.INTDATE'Img &
         " ======================================  ");
      string_io.New_Line;

      yr := hh.household.INTDATE mod 10000;
      string_io.Put ("yr = " & yr'Img);
      iyear := Year_Number (yr);
      string_io.Put ("iyear = " & iyear'Img);
      --  FIXME: wrong wrong wrong: must go back and treat the INTDATE as a String.
      if (hh.household.INTDATE > 10_000_000) then  --  2 digit day
         mn := hh.household.INTDATE / 10_000_000;
         string_io.Put ("10,000,000  case mn = " & mn'Img);
         imonth := Month_Number (mn);
      elsif (hh.household.INTDATE > 1_000_000) then      -- 1 digit day
         mn := hh.household.INTDATE / 1_000_000;
         string_io.Put ("1000000  case mn = " & mn'Img);
         imonth := Month_Number (mn);
      else
         mn := hh.household.INTDATE / 100_000;
         string_io.Put ("100000  case mn = " & mn'Img);
         imonth := Month_Number (mn);
      end if;
      --  discard days as we only ever uprate from 1st day in month
      mhh.interview_date    := Time_Of (iyear, imonth, 1);
      is_school_holidays    := make_is_school_holidays (mhh);
      mhh.housing_costs     := makeHHCosts (hh);
      mhh.num_benefit_units := modelint (hh.numBenUnits);

      string_io.Put ("  hh.household.TENURE " & hh.household.TENURE'Img);
      string_io.New_Line;
      mhh.tenure := FRS_Enums.convert_tenure_type(hh.household.TENURE);
      mhh.acorn := FRS_Enums.convert_acorn(hh.household.ACORN);
      mhh.composition := FRS_Enums.convert_household_composition(hh.household.HHCOMPS);
      mhh.income_band := FRS_Enums.convert_Household_Income_Band(hh.household.HHINCBND);
      mhh.standard_region := FRS_Enums.convert_standard_region( hh.household.GVTREGN );
      mhh.old_region := FRS_Enums.convert_old_region(hh.household.GOR);
      mhh.regional_stratifier := convert_regional_stratifier(hh.household.SSTRTREG);
      for buno in  1 .. hh.numBenUnits loop
         mhh.benefit_units (modelint (buno))  := makeBenefitUnit ( mhh.interview_date, hh.benunits (buno), dyear);
         allocate_Child_Care_Costs
           (mhh.benefit_units (buno),
            hh.benunits (buno),
            is_school_holidays);
      end loop;
      --
      allocate_Housing_Costs_Responsibility (hh, mhh, dyear);
      string_io.New_Line;

      return mhh;
   end map;

end frs_to_model_mapper;
