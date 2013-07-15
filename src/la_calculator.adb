--
--  $Author: graham_s $
--  $Date: 2007-11-14 18:07:29 +0000 (Wed, 14 Nov 2007) $
--  $Revision: 4327 $
--
with legal_aid_output_types; use legal_aid_output_types;
with base_model_types; use base_model_types;
with model_household;  use model_household;
with model_output;     use model_output;
with la_parameters;    use la_parameters;
with Text_IO;          use Text_IO;
with tax_utils;        use tax_utils;
with equivalence_scales;
with Costs_Model;
-- with legal_aid_costs_model;
-- with criminal_legal_aid_costs_model;

package body la_calculator is

        -- see sec 109 of manual
        ASSUMED_INTEREST_RATE : constant real := 0.0125; -- CHECK Correct as of apr 03??

        --
        --  capital imputation: if any and there's a capital limit in place
        --  1.25% of the lesser of limit and capital. If a gross inpcome test, just pass in everything
        --
        function calcAssumedinvestment_incomePA( capital_stock : Money;
                                                reported_investment_income : Money;
                                                capital_lower_limit : Money;
                                                eligible_proportion : Money; -- the 1.0 or whatever from the incomes lists
                                                is_gross_test : boolean ) return Money is
                income_from_savings : real := real(reported_investment_income);
                free_capital : constant real := real(Money'min( capital_stock, capital_lower_limit ));
        begin
                if( not is_gross_test )then
                        if( capital_lower_limit > 0.0 ) then
                                income_from_savings :=  free_capital * ASSUMED_INTEREST_RATE;
                        end if;
                end if;
                income_from_savings := income_from_savings * real(eligible_proportion);
                return Money(income_from_savings);
        end calcAssumedinvestment_incomePA;

        --
--  calculates a simple measure of the "error" between 2 systems
--  error is: high if you gain & are rich
--           high if you lose & are poor
--           zero if no change
--           higher for further moves (e.g full->none > full->partial
--  the only measure used currently is equivalent decile, since number of children etc.
--  is subsumed in that.
--
        function ErrorIndex ( bu : Model_Benefit_Unit;
                               res1 : One_LA_Output;
                               res2 : One_LA_Output
                             ) return Money is

                mis, dist : Money := 0.0;
                state1 : money;
                state2 : money;
                decile : money;
        begin
                mis := 0.0;
                state1 := money (Legal_Aid_State'Pos(res1.la_State));
                state2 := money (Legal_Aid_State'Pos(res2.la_State));
                decile := money ( bu.decile );
                --  put( "Error Index : state1 = " & state1'Img & " state2=" & state2'Img & " decile " & decile'Img );
                if state1 > state2 then -- gain; since pos goes FULL, PARTIAL, NONE, less is more  * )
                        dist := state1 - state2; -- worse the further you move *)
                        mis  := decile * dist;  --  worse the richer you are *)
                elsif state2 > state1 then
                        dist := state2 - state1;
                        mis  := (10.0 - decile ) * dist; -- worse the poorer you are *)
                end if;
                -- put( " returning mis = " & mis'Img );
                return mis;
        end ErrorIndex;

        --
        --  crude measure of how well targetted we are : higher for for full entitlement with low deciles
        --  and vice - versa
        --  returns a number from 0 (bad targetting) to 3 (perfect targetting).
        --
        function calc_targetting_index ( state : Legal_Aid_State; decile : Decile_Number ) return Money is
                index : money;
        begin
                case state is
                        when FullyEntitled | Passported =>
                                if ( decile < 3 ) then
                                        index := 3.0;
                                elsif ( decile < 5 ) then
                                        index := 2.0;
                                elsif (decile < 7) then
                                        index := 1.0 ;
                                else
                                        index := 0.0;
                                end if;

                        when PartiallyEntitled  =>
                                if ( decile < 3 ) then
                                        index := 2.0;
                                elsif ( decile < 5 ) then
                                        index := 3.0;
                                elsif (decile < 7) then
                                        index := 1.0;
                                else
                                        index := 0.0;
                                end if;
                        when disqualified =>
                                if ( decile < 3 ) then
                                        index := 0.0;
                                elsif ( decile < 5 ) then
                                        index := 1.0;
                                elsif (decile < 7) then
                                        index := 2.0;
                                else
                                        index := 3.0;
                                end if;
                        when na => null;       -- fixme raise an error?
                end case;
                return index;
        end calc_targetting_index;


        --  handle a single expense or allowance
        --  val - expense amount
        --  exp - this proportion eligible (0-1.0), or maximum value (0- inf)
        --       and boolean is_flat: allow a percentage or FLAT - allow up to prop as a maximum
        function expensesOp (val : money; exp : One_Expense) return money is
                outv : real := 0.0;
                rv   : real := 0.0;
        begin
                rv := real (val);
                if (not exp.is_flat) then
                        outv := rv * real (exp.amount);
                elsif (rv > exp.amount) then
                        outv := exp.amount;
                else
                        outv := rv;
                end if;
                return money (outv);
        end expensesOp;

        --
        --   children array of Model_Household_Rec.child objects
        --   bands - age bands
        --   manual sec[ ]
        --
        function calcchild_allowances
               (benunit : Model_Benefit_Unit;
                bands   : Basic_Int_Array;
                rates   : Basic_Array)
                return    money
        is
                allow : money  := 0.0;
                p     : modelint := 1;
        begin
                for chno in  1 .. benunit.num_children loop
                        p := 1;

                        while (bands (p) < benunit.children (chno).age) loop
                                p := p + 1;
                        end loop;
                        allow := allow + rates (p);
                end loop;
                return allow;
        end calcchild_allowances;

        --
        --
        --
        function calcOneIncome
               (incomes         : Incomes_Array;
                included_incomes : Incomes_Array)
                return            money
        is
                t : real := 0.0;
        begin
                for inc in  Income_Items loop
                        t := t + real (incomes (inc)) * real (included_incomes (inc));
                        --  put( "income type " & t'Img & " included_incomes(inc)=" & included_incomes (inc)'Img );new_line;
                end loop;
                return money (t);
        end calcOneIncome;

        --  see http://www.dss.gov.uk/asd/hbai/incd-6.html
        --  5 bn total value of company cars and fuel
        --   see:
        --  http://www.dwp.gov.uk/asd/hbai/quality_review/Quality_Review_Final_Report.pdf
        --
        --  We know nothing of this from the FRS. Wild guess at �3,000 p.a..
        --
        function valueOfCompanyCar (inc : money) return money is
                v : money := 0.0;
        begin
                if (inc > Comp_Car_Threshhold) then
                        v := 3000.0;
                end if;
                return v;
        end valueOfCompanyCar;

        function calcBenefitsInKind(
                adult : Model_Adult;
                sys : Legal_Aid_Sys ) return Money is
                lvs        : money := 0.0;
                taxFreeLVs : money := 0.0;
                benefits_In_Kind   : Money := 0.0;
                taxable_income : Money := 0.0;
        begin
            --
            -- FIXME: this is not at all taxable income
            --
                taxable_income := calcOneIncome( adult.incomes, TAXABLE_INCOMES_LIST );
                lvs                        := 0.0;
                taxFreeLVs                 := adult.incomes (luncheon_vouchers) -
                                              DAILY_LUNCHEON_VOUCHER_MINIMUM;
                -- put
                       -- (" taxFreeLVs " &
                        -- taxFreeLVs'Img &
                        -- " adult.incomes(luncheon_vouchers) = " &
                        -- adult.incomes (luncheon_vouchers)'Img);
                lvs := money'Max(0.0, taxFreeLVs);
                benefits_In_Kind := benefits_In_Kind + lvs;
                --  company cars
                if (adult.has_company_car) then
                        benefits_In_Kind := benefits_In_Kind +
                           valueOfCompanyCar( taxable_income );
                end if;
                return benefits_In_Kind;
        end calcBenefitsInKind;

        procedure calcBenefitsInKind(
                bu    : Model_Benefit_Unit;
                sys   : Legal_Aid_Sys;
                res   : in out One_LA_Output) is
        begin
                for ad in head .. bu.last_adult loop
                        res.benefits_In_Kind := res.benefits_In_Kind +
                          calcBenefitsInKind ( bu.adults( ad ), sys );
                end loop;
        end calcBenefitsInKind;

        procedure makePersonalIncome
               (adult     : Model_Adult;
                sys       : Legal_Aid_Sys;
                laResults : in out One_LA_Output)
        is
                netIncome  : money := 0.0;
        begin
                netIncome                  := calcOneIncome (adult.incomes, sys.incomesList);
                laResults.assessable_Income := laResults.assessable_Income + netIncome;
        end makePersonalIncome;

        --
        --  apply maxima/flat rate amounts to a housing costs record
        --  housing_Costs = housing_Costs record from Model_Household_Rec
        --
        function flattenHousingCosts
               (housing_Costs : Model_Housing_Costs;
                sys          : Legal_Aid_Sys)
                return         Model_Housing_Costs
        is
                outputCosts : Model_Housing_Costs;
        begin
                outputCosts.mortgages := expensesOp( housing_Costs.mortgages, sys.housing_allowances.mortgages );
                outputCosts.gross_council_tax := expensesOp( housing_costs.gross_council_tax, sys.housing_allowances.council_tax );
                outputCosts.water_rates := expensesOp( housing_Costs.water_rates, sys.housing_allowances.water_rates );
                outputCosts.ground_rent := expensesOp( housing_Costs.ground_rent, sys.housing_allowances.ground_rent );
                outputCosts.service_charges := expensesOp ( housing_Costs.service_charges,
                                                          sys.housing_allowances.service_charges );
                outputCosts.repairs_and_insurance := expensesOp ( housing_Costs.repairs_and_insurance,
                                                          sys.housing_allowances.repairs_and_insurance );
                outputCosts.rent := expensesOp( housing_Costs.rent, sys.housing_allowances.rent );
                --  rent share see 169/2
                outputCosts.council_tax_rebates := expensesOp( housing_Costs.council_tax_rebates, sys.housing_allowances.council_tax_rebates );
                outputCosts.rent_rebates := expensesOp ( housing_Costs.rent_rebates, sys.housing_allowances.rent_rebates );

                return outputCosts;
        end flattenHousingCosts;

        --
        --  housing costs for the householder (benefit unit 1, always, in this model.
        --  Manual sec[ ]
        --
        function householdersHousingCosts
               (tenure       : Tenure_Type;
                housing_Costs : Model_Housing_Costs
                 )
                return         money
        is
                costs    : money := 0.0;
                net_council_tax : money := 0.0;
                net_rent  : money := 0.0;
        begin
                net_council_tax := housing_costs.gross_council_tax - housing_Costs.council_tax_rebates;
                if (net_council_tax < 0.0) then
                        net_council_tax := 0.0;
                end if;
                net_rent := housing_Costs.rent - housing_Costs.rent_rebates;
                if (net_rent < 0.0) then
                        net_rent := 0.0;
                end if;
                case tenure is
                        when owns_it_outright =>
                                costs := net_council_tax  +
                                         housing_Costs.water_rates +
                                         housing_Costs.ground_rent +
                                         housing_Costs.service_charges +
                                         housing_Costs.repairs_and_insurance;
                        when buying_with_the_help_of_a_mortgage =>
                                costs := net_council_tax +
                                         housing_Costs.mortgages +
                                         housing_Costs.water_rates +
                                         housing_Costs.ground_rent +
                                         housing_Costs.service_charges +
                                         housing_Costs.repairs_and_insurance;
                        when part_own_part_rent =>
                                costs :=
                                       net_council_tax +
                                       net_rent +
                                       housing_Costs.mortgages +
                                       housing_Costs.water_rates +
                                       housing_Costs.ground_rent +
                                       housing_Costs.service_charges +
                                       housing_Costs.repairs_and_insurance;
                        when rents =>
                                costs := net_council_tax +
                                         net_rent +
                                         housing_Costs.water_rates +
                                         housing_Costs.service_charges;
                        when rent_free =>
                                costs := net_council_tax +
                                         net_rent +
                                         housing_Costs.water_rates +
                                         housing_Costs.service_charges;
                        when others =>
                                costs := 0.0;
                end case;
                -- put ( "householdersHousingCosts: returning " & costs'Img );
                -- new_line;
                return costs;
        end householdersHousingCosts;

        --
        --  See manual section [].
        --  Deductions from assumed rent paid by 1st benefit unit where there
        --  is more than 1 bu
        --
        function calcRentshare_deduction
               (hh    : Model_Household_Rec;
                sys   : Legal_Aid_Sys;
                cType : Claim_Type)
                return  money
        is
                rent_Share_Deduction : money := 0.0;
                ad                 : Model_Adult;
                ded                : money := 0.0;
        begin
                for buno in  2 .. hh.num_benefit_units loop
                        -- Put ("on bu " & buno'Img);
                        for adno in  head .. hh.benefit_units (buno).last_adult loop
                                ad := hh.benefit_units (buno).adults (adno);
                                --  Put ("on ad " & adno'Img);
                                if (not ((ad.is_lodger) or
                                         (ad.employment = work_related_govt_training) or
                                         (ad.relToHoH = spouse) or
                                         (ad.relToHoH = cohabitee)))
                                then
                                        ded :=
                                               (sys.share_deduction *
                                                sys.lower_limit (income, cType));
                                        --  Put ("adding a deduction of " & ded'Img);
                                        rent_Share_Deduction := rent_Share_Deduction + ded;
                                end if;
                        end loop;
                end loop;
                --  put ("returning with rent share = " & rent_Share_Deduction'Img);
                -- new_line;
                return rent_Share_Deduction;
        end calcRentshare_deduction;

        --
        --  Housing costs for all benefit units and tenure types.
        --  Sets the housing_Costs field in each benefit unit's output record.
        --  Manual sec[ ]
        procedure calcHousingCosts
               (hh    : Model_Household_Rec;
                sys   : Legal_Aid_Sys;
                res   : in out LAOutputArray;
                ctype : Claim_Type)
        is
                housing_Costs : Model_Housing_Costs;
        begin
                housing_Costs         := flattenHousingCosts (hh.housing_Costs, sys);

                res(1).housing_Costs := householdersHousingCosts(hh.tenure, housing_Costs );
                -- put( "res(1).housing_Costs = " & res(1).housing_Costs'Img );
                if ( not hasDependents ( hh.benefit_units (1))) then --  this is the English restriction.
                        res(1).housing_Costs := Money'Min( res(1).housing_Costs, sys.single_persons_housing_costs_max );
                end if;
                --  put( "res(1).housing_Costs after sys.single_persons_housing_costs_max = " & res(1).housing_Costs'Img );
                --  non dep deductions see 169/2
                if (((hh.tenure = part_own_part_rent) or (hh.tenure = rents)) and
                    (hh.num_benefit_units > 1) and
                    (not hh.housing_Costs.costs_are_shared))
                then
                        res (1).rent_Share_Deduction := calcRentshare_deduction (hh, sys, ctype);
                end if;
                --
                --  housing costs for secondary benefit units, if they are sharing costs or boarders
                for buno in  2 .. hh.num_benefit_units loop
                        for adno in  head .. hh.benefit_units (buno).last_adult loop
                                if (hh.benefit_units (buno).adults (adno).is_lodger or
                                    hh.housing_Costs.costs_are_shared)
                                then
                                        --  note that this is net rent!!! make sure we've taken any
                                        --  HB away already
                                        res (buno).housing_Costs :=
                                               hh.benefit_units (buno).adults (adno).expenses (
                                               shared_rent);
                                end if;
                        end loop;
                end loop;
        end calcHousingCosts;

        --
        --  Is an adult passported?
        --  This version just checks adult benefit receipts against the passport
        --  list. Previous versions had states checks (is pensioner, etc.).
        --  Manual sec[ ]
        function passportPerson (ad : Model_Adult; sys : Legal_Aid_Sys) return Boolean is
        begin
                for inc in  Benefits loop
                        if (sys.passport_benefits (inc) and ad.incomes (inc) /= 0.0) then
                                return True;
                        end if;
                end loop;
                return False;
        end passportPerson;

        --
        --  Does benefit unit passport, on assumption that they are not assessed
        --  individually?
        --  manual sec []
        function passportBenefitUnit
               (benunit : Model_Benefit_Unit;
                sys     : Legal_Aid_Sys)
                return    Boolean
        is
        begin
                for adno in  head .. benunit.last_adult loop
                        if (passportPerson (benunit.adults (adno), sys)) then
                                return True;
                        end if;
                end loop;
                return False;
        end passportBenefitUnit;

        --
        --   income: joint assesable income
        --   capsys: Capital_Sys class
        --   Manual sec [ ]
        function earnedcapital_disregard (inc : money; capsys : Capital_Sys) return money is

        begin
                for p in  1 .. capsys.numDisregards loop
                        if (inc <= capsys.incomeLimit (p)) then
                                return capsys.disregard (p);
                        end if;
                end loop;
                return 0.0;
        end earnedcapital_disregard;

        --
        --   allowances for partners, children
        --   benenunit : a benefit unit class
        --   allows Allowance_Sys
        --   res one result
        --   simply assume for now allowances for everyone in the benefit
        --   unit, and none for anyone else. Maybe we can improve on this
        --   FIXME: is this right for <= 17 year olds? It actually gives more money
        --   to 16 yos than older people.
        --   Manual sec [ ]
        --   FIXME: we might want income/capital specific versions of this
        procedure calcAllowances
               (benunit : Model_Benefit_Unit;
                allows  : Allowance_Sys;
                res     : in out One_LA_Output)
        is
                maxAll          : modelint := 0;
        begin
                res.child_Allowances :=
                        calcchild_allowances (benunit, allows.child_age_limit, allows.child_allowance);
                res.allowances  := res.allowances + res.child_Allowances;
                if (benunit.last_adult = spouse) then -- 170/1(b)
                        if ((benunit.adults (head).age > 17) and
                            (benunit.adults (spouse).age > 17))
                        then
                                res.partners_Allowances := allows.partners_allowance;
                        else
                                if( allows.num_child_age_limits > 0 ) then
                                        maxAll         := allows.num_child_age_limits;
                                        res.partners_Allowances := allows.child_allowance (maxAll);
                                end if;
                        end if;
                end if;
                --
                --  FIXME: auto-equivalised personal allowance
                --
                res.allowances := res.allowances + res. partners_Allowances;
                if( allows.living_allowance > 0.0 ) then
                        res.allowances := res.allowances + money( real( allows.living_allowance ) * res.equivalence_scale );
                end if;
                --   possibly a big Green Form thingy in here
        end calcAllowances;



        --
        --   Capital allowances for the benefit unit. Presently zero for all but pensioners;
        --   income - related for pensioners. But we can model more than this.
        --   reads disposable income from the results record and adds capital
        --   allowances to the results rec.
        --   Manual sec []
        procedure calcCapitalAllowances
               (bu  : Model_Benefit_Unit;
                sys : Legal_Aid_Sys;
                res : in out One_LA_Output)
        is
                penType : Pensioner_State := nonPensioner;
                alim    : modelint        := 0;
        begin
                --
                --  does anyone qualify as a pensioner?
                --
                for adno in  head .. bu.last_adult loop
                        alim := sys.pensioner_age_limit (bu.adults (adno).sex);
                        if (bu.adults (adno).age >= alim) then
                                if (penType = nonPensioner) then
                                        penType := pensioner;
                                end if;
                        end if;
                end loop;
                res.capital_Allowances :=
                        earnedcapital_disregard
                               (res.disposable_Income,
                                sys.capital_disregard (penType));
        end calcCapitalAllowances;


        --
        --  ?? make this generic ??
        --
        function calcPersonalExpenses (
                              expenses : Expenses_Array;
                              sys : Legal_Aid_Sys ) return money is
                expsum : money := 0.0;
                val : money := 0.0;
                exp : One_Expense;
        begin
                for k in Expense_Items loop
                        exp := sys.allowable_expenses(k);
                        val := expenses(k);
                        expsum := expsum + expensesOp( val, exp );
                end loop;
                return expsum;
        end calcPersonalExpenses;

        --
        --  ?? make generic ??
        --
        function calcFinanceExpenses (
                              finance : FinanceArray;
                              sys : Legal_Aid_Sys ) return money is
                expsum : money := 0.0;
                val : money := 0.0;
                exp : One_Expense;
        begin
                for k in Finance_Items loop
                        exp := sys.allowable_finance(k);
                        val := finance(k);
                        expsum := expsum + expensesOp( val, exp );
                end loop;
                return expsum;
        end calcFinanceExpenses;


        procedure calcGrossIncome
               (bu    : Model_Benefit_Unit;
                sys   : Legal_Aid_Sys;
                res   : in out One_LA_Output) is
        begin
                for adno in head .. bu.last_adult loop
                        res.gross_Income := res.gross_Income +
                                calcOneIncome (bu.adults(adno).incomes, sys.gross_IncomesList);
                end loop;
                res.gross_Income := res.gross_Income + res.benefits_In_Kind;

        end calcGrossIncome;
        --
        --  accumulate  and disposable incomes for one benefit unit
        --
        --  sys - la system
        --  bu - a benefit unit
        --  res - result for one bu
        procedure calcBenefitUnitIncomes
               (bu    : Model_Benefit_Unit;
                sys   : Legal_Aid_Sys;
                res   : in out One_LA_Output) is
        begin
                for adno in head .. bu.last_adult loop
                        res.deductions_From_Income := res.deductions_From_Income +
                          calcPersonalExpenses ( bu.adults(adno).expenses, sys ) +
                          calcFinanceExpenses( bu.adults(adno).finance, sys );
                        if( bu.adults(adno).ilo_employment = student ) then
                                res.deductions_From_Income := res.deductions_From_Income +
                                  money(sys.allowable_expenses (student_expenses).amount);
                        end if;
                        --  this adds benefits in kind,  and assesable income
                        makePersonalIncome( bu.adults(adno), sys, res );
                end loop;
                --
                --  equivalise assesable income for
                --  english style criminal test, but take off unequivalised costs. See: CMD6678 pp7-8
                --
                -- if( sys.equivalise_incomes ) then
                --        res.assessable_Income := money( real( res.assessable_Income )/res.equivalence_scale );
                -- end if;
                res.net_income := res.assessable_Income +
                                       res.benefits_In_Kind -
                                       res.deductions_From_Income -
                                       res.housing_Costs;
                res.disposable_Income := res.assessable_Income +
                                       res.benefits_In_Kind -
                                       res.deductions_From_Income -
                                       res.allowances -
                                       res.housing_Costs;

                --  res.disposable_Income := money'Max(0.0, res.disposable_Income);
                --  allow disposable income to go negative, as negative disposable
                --  income is allowed against capital
                --  res.gross_Income := res.gross_Income + res.benefits_In_Kind;
                if( sys.equivalise_incomes ) then
                        res.gross_Income := money( real( res.gross_Income )/res.equivalence_scale );
                end if;

        end calcBenefitUnitIncomes;

        --
        --  count of spouse plus num children, if any.
        --
        function totalNumDependents( bu : Model_Benefit_Unit ) return modelint is
                n : integer := 0;
        begin
                if( bu.last_adult = spouse ) then
                        n := 1;
                end if;
                n := n + bu.num_children;
                return n;
        end totalNumDependents;

        function calcDependentCountAllowances( dependent_allowances : Basic_Array; numDependents : modelint ) return Money is
                allow,amount : Money := 0.0;
                last : constant integer := dependent_allowances'Last;
        begin

                for i in 1 .. numDependents loop
                        if( i < last ) then
                                amount := dependent_allowances(i);
                        else
                                amount := dependent_allowances( last-1 );
                        end if;
                        amount := amount + allow;
                end loop;
                return amount;
        end calcDependentCountAllowances;


        --
        --   accumulate capital stock for one bu
        --   manual sec []
        --   sys - la system
        --   bu - a benefit unit
        --   res - result for one bu
        function calcBenefitUnitCapital
               (bu    : Model_Benefit_Unit;
                sys   : Legal_Aid_Sys) return Money is
                assessibleCapital : Money := 0.0;
        begin
      --          for adno in head .. bu.last_adult loop
       --                 assessibleCapital := assessibleCapital +
      --                       bu.adults(adno).capital_stock;
      --                  --  deductions from capital go here
      --          end loop;
      --      return assessibleCapital;
            return bu.capital_stock;
        end calcBenefitUnitCapital;

        --
        --  capital is accumulated capital stock and (for bu 1) any housing equity. THere is
        --  as seperate disregard for equity, and it isn't turned on in the base NI system.
        --
        procedure calcBenefitUnitGrossCapital
               (hh    : Model_Household_Rec;
                buno  : modelint;
                sys   : Legal_Aid_Sys;
                res   : in out One_LA_Output) is
                capital, equity : money := 0.0;
        begin

                capital := calcBenefitUnitCapital( hh.benefit_units( buno ), sys );
                if( (buno = 1 ) and ( sys.housing_equity_is_capital ) ) then
                        equity := Money'Max( 0.0, hh.housing_Costs.home_equity - sys.housing_equity_disregard );
                        capital := capital + equity;
                end if;
                res.assessable_Capital := capital + equity;
                res.capital_except_equity := capital;
        end calcBenefitUnitGrossCapital;

        --
        --  capital is accumulated capital stock and (for bu 1) any housing equity. THere is
        --  as seperate disregard for equity, and it isn't turned on in the base NI system.
        --
        procedure calcBenefitUnitNetCapital
               ( res   : in out One_LA_Output) is

        begin


                if( res.disposable_Income < 0.0 ) then -- allow negative disposable incomes as offset against capital
                        res.disposable_Capital := res.disposable_Capital + res.disposable_Income;
                end if;
                res.disposable_Capital := Money'Max( 0.0, res.assessable_Capital - res.capital_Allowances );
        end calcBenefitUnitNetCapital;


        procedure addinvestment_income(
                bu    : Model_Benefit_Unit;
                sys   : Legal_Aid_Sys;
                res   : in out One_LA_Output) is
                total_investment_income : Money := 0.0;
        begin
                total_investment_income := safe_add( bu.adults( head ).incomes( investment_income ),
                                               bu.adults( spouse ).incomes( investment_income ) );

                res.net_income := res.net_income + calcAssumedinvestment_incomePA(
                        res.capital_except_equity,
                        total_investment_income,
                        sys.lower_limit( capital, normalClaim ),
                        sys.incomesList( investment_income ),
                        false );
                res.gross_income := res.gross_income + calcAssumedinvestment_incomePA(
                        res.capital_except_equity,
                        total_investment_income,
                        sys.lower_limit( capital, normalClaim ),
                        sys.gross_IncomesList( investment_income ),
                        true );
        end  addinvestment_income;




        --
        --
        --
        --
        function calcContribution ( contSys : One_Contribution; inc : money ) return money is
                result : TaxResult;
        begin
                case contSys.cont_type is
                        when proportion =>
                                result := calcTaxDue ( inc,
                                                      contSys.contribution_proportion,
                                                      contSys.contribution_band,
                                                      contSys.numContributions );
                        when fixed =>
                                result := calcSteppedContribution ( inc,
                                                      contSys.contribution_proportion,
                                                      contSys.contribution_band,
                                                      contSys.numContributions );

                end case;
                return result.due;
        end calcContribution;

        function isAboveGrossIncomeCap( bu : Model_Benefit_Unit;
                                        gross_Income : money;

                                        sys         : Legal_Aid_Sys) return boolean is
        gross_IncomeLimit : money := sys.gross_IncomeLimit;
        begin
                --  FIXME: above 4 kids allowances
                if( sys.gross_IncomeLimit <= 0.0 ) then
                        return false;
                end if;
                if ( sys.equivalise_gross_income_limit ) then
                        gross_IncomeLimit := gross_IncomeLimit *
                          money ( equivalence_scales.calc_equivalence_scale ( bu, equivalence_scales.mcclements ));
                        --  text_io.put("equivalised gross income limit from " &
                        --               sys.gross_IncomeLimit'Img & " to " & gross_IncomeLimit'Img );
                end if;
                if( gross_Income >  gross_IncomeLimit) then
                        return true;
                end if;
                return false;
        end isAboveGrossIncomeCap;

        function isBelowGrossIncomeCap_Minimum( bu : Model_Benefit_Unit;
                                        gross_Income : money;
                                        sys         : Legal_Aid_Sys) return boolean is
        gross_IncomeLimit : money := sys.gross_IncomeLimit;
        begin
                --  FIXME: above 4 kids allowances
                if( (sys.gross_Income_lower_limit <= 0.0 ) or (sys.gross_Income_lower_limit = Money'Last)) then
                        return false;
                end if;
                if( gross_Income <= sys.gross_Income_lower_limit ) then
                        return true;
                end if;
                return false;
        end isBelowGrossIncomeCap_Minimum;

        --
        --
        --
        procedure calcCapitalLimits(
                bu: Model_Benefit_Unit;
                sys: Legal_Aid_Sys;
                ctype : Claim_Type;
                upper, lower : in out Money ) is
                num_dependents : integer;

        begin
                upper := sys.upper_limit( capital, cType );
                lower := sys.lower_limit( capital, cType );
                if(( sys.sys_type = green_form ) or (sys.sys_type = abwor ))  then
                        num_dependents := totalNumDependents( bu );
                        if( num_dependents > 0 ) then
                                lower := lower +
                                calcDependentCountAllowances(
                                        sys.allow( capital ).dependent_allowances,
                                        num_dependents );

                        end if;
                        upper := lower; -- both thresholds are the same for gf/abwor
                end if;
        end calcCapitalLimits;

 --
 --  Calc Legal Aid for a single benefit unit. Housing needs to be
 --  alread calculated before calling this, as that
 --  needs to be done at the household level.
 --
 --  sys - legal aid system (Legal_Aid_Sys class)
 --  bu - model benefit unit   (Benefit Unit class)
 --  res - OneResult class. Needs to be initialised on entry
 --  Claim_Type - Civil or PersonalInjury
 --
 procedure calcOneBULegalAid
        (hh    : Model_Household_Rec;
         buno  : modelint;
         res   : in out One_LA_Output;
         sys   : Legal_Aid_Sys;
         ctype : Claim_Type )
 is

         upper_limit, lower_limit : money := 0.0;
         aboveGross : boolean := false;
         bu    : Model_Benefit_Unit;
         belowGrossMinimum : boolean := false;
 begin
         bu := hh.benefit_units( buno );
         --  res := newOutput;
         res.equivalence_scale := equivalence_scales.Calculate_McLements_Scale ( hh.benefit_units(buno ));
         if( passportBenefitUnit( bu, sys ) )then
                 res.passport_state := passported;
         else
                 res.passport_state := na;

         end if;
         --  apply means tests to non-passported cases, except
         --  in greenform, where you can be disqualified even if notionally passported.

        calcBenefitsInKind( bu, sys, res );
        calcGrossIncome ( bu, sys, res );
        calcBenefitUnitGrossCapital( hh, buno, sys, res );
        addinvestment_income( bu, sys, res );
        calcAllowances( bu, sys.allow( income ), res );
        calcCapitalAllowances( bu, sys, res );
        calcBenefitUnitIncomes( bu, sys, res );
        calcBenefitUnitNetCapital( res );
        --
        --  FIXME this is messy and unnessesary: move these to 1 routine.
        --
        aboveGross := isAboveGrossIncomeCap ( bu, res.gross_Income, sys );
        belowGrossMinimum := isBelowGrossIncomeCap_Minimum( bu, res.gross_Income, sys );
        --  put( " gross_Income " & res.gross_Income'Img & " aboveGross= " & aboveGross'Img );
        res.gross_income_test_state := na;
        if( aboveGross ) then
                res.gross_income_test_state := above_maximum;
        elsif( belowGrossMinimum ) then-- above threshold
                res.gross_income_test_state := below_mininum;
        else
                res.gross_income_test_state := means_tested;
        end if;
        --  FIXME we use hh/buno here so we can pass in housing equity. Design fault
        if ( res.disposable_Income > sys.upper_limit( income, cType ) )then
                res.means_test_state := disqualified;
        elsif( res.disposable_Income > sys.lower_limit( income, cType ) )then
                res.means_test_state := partiallyEntitled;
                res.excess_Income := res.disposable_Income - sys.lower_limit( income, cType );
                res.income_Contribution := calcContribution (
                                 sys.contributions ( income ), res.excess_Income );
        else
                res.means_test_state := fullyEntitled;
        end if;
        --
        --  Expicit calculation of limits here as green form/abwor
        --  has them dependent on number of dependents.
        --
        calcCapitalLimits( bu, sys, cType, upper_limit, lower_limit );
        --  text_io.put( "res.disposable_Capital " & res.disposable_Capital'Img &
        --           " capital upper_limit " & upper_limit'Img &
        --           " lower_limit " & lower_limit'Img );
        if( res.disposable_Capital > upper_limit )then
         res.capital_state := disqualified;

        elsif( res.disposable_Capital > lower_limit )then

         res.capital_state := partiallyEntitled;
         res.excess_Capital := res.disposable_Capital - sys.lower_limit( capital, cType );
         res.capital_Contribution := calcContribution (
                                                       sys.contributions ( capital ), res.excess_Capital );
         --  text_io.put( "res.capital_Contribution " & res.capital_Contribution'Img &
         --             " res.capital_state " & res.capital_state'Img );
      else
         res.capital_state := fullyEntitled;
      end if;
        --  text_io.put( " res.capital_state " & res.capital_state'Img );

        if ( sys.sys_type = green_form ) then
                --  this is a hack. If passported and
                --  on green form/abwor, use that as a temporary income state
                --  and compare with capital, which can disqualify even notionally
                --  passported people. Really, we don't need to bother with the income tests
                --  in these cases.
                if ( res.capital_state = disqualified ) then
                        res.la_State := disqualified;
                elsif ( res.passport_state = passported ) then  -- stored passport from initial test
                        res.la_State := passported;
                else
                      if ( res.means_test_state > res.capital_state ) then
                                res.la_State := res.means_test_state;
                      else
                                res.la_State := res.capital_state;
                      end if;
                end if;
        else
                if( res.passport_state = passported ) then
                        res.la_State := passported;
                elsif( res.gross_income_test_state = below_mininum ) then
                        res.la_state := fullyEntitled;
                elsif( res.gross_income_test_state = above_maximum ) then
                        res.la_State := disqualified;
                else
                        --  position is the worse of res.capital_state
                        --  and income state. States are arranged from best to worse
                        --
                        if ( res.means_test_state >= res.capital_state ) then
                                res.la_State := res.means_test_state;
                        else
                                res.la_State := res.capital_state;
                        end if;
                end if;
        end if;
        if ( res.la_State /= partiallyEntitled ) then
                res.capital_Contribution := 0.0;
                res.income_Contribution := 0.0;
        end if;
        res.targetting_index := calc_targetting_index( res.la_State, bu.decile );

        --  new_line;
        --  put ( "output state " & res.la_State'Img );
        --  new_line;

end calcOneBULegalAid;

        --
        --
        --
        --
  function calcOneHHLegalAid
               (hh    : Model_Household_Rec;
                sys   : Legal_Aid_Sys;
                cType : Claim_Type;
                uprate : boolean )
                return  LAOutputArray
        is
                res : LAOutputArray;

   begin
      calcHousingCosts (hh, sys, res, ctype );
      for buNo in  1 .. hh.num_benefit_units loop
         --  text_io.put( "calcOneHHLegalAid; sys_type = |" & sys.sys_type'Img&" | uprate = " &uprate'Img );text_io.new_line;
         calcOneBULegalAid (hh, buNo, res(buNo), sys, ctype);
      end loop;
      Costs_Model.Apply_Costs_Model( hh, res );
      return res;
   end calcOneHHLegalAid;


end la_calculator;
