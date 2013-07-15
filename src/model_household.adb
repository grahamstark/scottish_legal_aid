--
--  $Author: graham_s $
--  $Date: 2007-03-26 17:39:10 +0100 (Mon, 26 Mar 2007) $
--  $Revision: 2424 $
--
with base_model_types; use base_model_types;
with model_uprate;     use model_uprate;
with Ada.Calendar;     use Ada.Calendar;
with Ada;              use Ada;
with Text_Utils;       use Text_Utils;
with Ada.Direct_IO;
--
--
--
package body model_household is

   function person_count (hh : Model_Household_Rec) return Integer is
      count : Integer := 0;
   begin
      for buno in  1 .. hh.num_benefit_units loop
         for adno in  head .. hh.benefit_units (buno).last_adult loop
            count := count + 1;
         end loop;
         count := count + hh.benefit_units (buno).num_children;
      end loop;
      return count;
   end person_count;

   function load (hhFile : hh_io.File_Type; hhseq : modelint) return Model_Household_Rec is
      hh           : Model_Household_Rec;
      currentHHPos : hh_io.Count;
   begin
      currentHHPos := hh_io.Count (hhseq);
      hh_io.Set_Index (hhFile, currentHHPos);
      hh_io.Read (hhFile, hh);
      --
      --  On load, we need to swap in the un-uprated one of our two new house price
      --  estimates, and use that to derive housing equity.
      --  On uprating, we just swap in the uprated version, rather than uprating using the
      --  macro variables ourselves.
      --
      hh.housing_costs.house_price := hh.housing_costs.estimated_house_price_actual;
      hh.housing_costs.home_equity := hh.housing_costs.house_price -
                                      hh.housing_costs.mortgages_outstanding;
      return hh;
   end load;

   --
   --  open files; load uprating information.
   --
   procedure initialise
     (hh_file : in out hh_io.File_Type;
      frsYear : data_constants.DataYears;
      sz      : in out Integer;
      write   : Boolean := False)
   is
   begin
      if (write) then
         hh_io.Create
           (hh_file,
            hh_io.Out_File,
            MODEL_DATA_DIR & "model_data_" & YEAR_STRS (frsYear) & ".bin");
         sz := 0;
      else
         hh_io.Open
           (hh_file,
            hh_io.In_File,
            MODEL_DATA_DIR & "model_data_" & YEAR_STRS (frsYear) & ".bin");
         sz := Integer (hh_io.Size (hh_file));
      end if;

   end initialise;

   function hasDependents (bu : Model_Benefit_Unit) return Boolean is
   begin
      return (bu.num_children > 0) or (bu.last_adult = spouse);
   end hasDependents;

   function toString (adult : Model_Adult) return String is
      outs : ustr.Unbounded_String := ustr.To_Unbounded_String ("");

   begin
      ustr.Append (outs, INDENT & INDENT & "****************************" & stda.LF);
      ustr.Append
        (outs,
         INDENT &
         INDENT &
         "age : " &
         adult.age'Img &
         " sex " &
         adult.sex'Img &
         " marital_status " &
         pretty_print (adult.marital_status) &
         " rel to HoH " &
         pretty_print (adult.relToHoH) &
         stda.LF);

      ustr.Append (outs, INDENT & INDENT & "is_lodger=" & adult.is_lodger'Img & stda.LF);
      ustr.Append (outs, " employment=" & pretty_print (adult.employment));
      ustr.Append (outs, " ILO employment=" & pretty_print (adult.ilo_employment));
      ustr.Append (outs, " has_company_car=" & adult.has_company_car'Img);
      ustr.Append (outs, " capital_stock=" & adult.capital_stock'Img & stda.LF);
      ustr.Append (outs, " ethnic = " & pretty_print (adult.ethnic_group) & stda.LF);

      for i in  Income_Items loop
         if (adult.incomes (i) /= 0.0) then
            ustr.Append
              (outs,
               INDENT & INDENT & i'Img & " :  " & adult.incomes (i)'Img & stda.LF);
         end if;
      end loop;
      ustr.Append (outs, INDENT & INDENT & "*** Expenses *** " & stda.LF);
      for i in  Expense_Items loop
         if (adult.expenses (i) /= 0.0) then
            ustr.Append
              (outs,
               INDENT & INDENT & i'Img & " :  " & adult.expenses (i)'Img & stda.LF);
         end if;
      end loop;
      ustr.Append (outs, INDENT & INDENT & "*** Finance *** " & stda.LF);
      for i in  Finance_Items loop
         if (adult.finance (i) /= 0.0) then
            ustr.Append (outs, "        " & i'Img & " :  " & adult.finance (i)'Img & stda.LF);
         end if;
      end loop;
      return ustr.To_String (outs);
   end toString;

   function toString (child : Model_Child) return String is
      outs : ustr.Unbounded_String := ustr.To_Unbounded_String ("");

   begin
      ustr.Append
        (outs,
         INDENT &
         INDENT &
         "age : " &
         child.age'Img &
         " sex " &
         child.sex'Img &
         " marital_status " &
         pretty_print (child.marital_status) &
         " rel to HoH " &
         pretty_print (child.relToHoH) &
         stda.LF);
      ustr.Append (outs, INDENT & "ethnic_group" & pretty_print (child.ethnic_group) & stda.LF);

      return ustr.To_String (outs);
   end toString;

   function toString (bu : Model_Benefit_Unit) return String is
      outs : ustr.Unbounded_String := ustr.To_Unbounded_String ("");

   begin

      ustr.Append
        (outs,
         INDENT & "non_dependency_type = " & pretty_print (bu.non_dependency_type) & stda.LF);
      ustr.Append
        (outs,
         INDENT & "economic_status = " & pretty_print (bu.economic_status) & stda.LF);
      ustr.Append (outs, INDENT & "bu_type = " & pretty_print (bu.bu_type) & stda.LF);
      ustr.Append (outs, INDENT & "age_range_of_head = " & bu.age_range_of_head'Img & stda.LF);

      ustr.Append
        (outs,
         "    ----------------- " & stda.LF & "last adult " & bu.last_adult'Img & stda.LF);
      for ad in  head .. bu.last_adult loop
         ustr.Append
           (outs,
            "    adult : " & ad'Img & stda.LF & toString (bu.adults (ad)) & stda.LF);
      end loop;
      ustr.Append
        (outs,
         "    ----------------- " & stda.LF & "num Children  " & bu.num_children'Img & stda.LF);
      for ch in  1 .. bu.num_children loop
         ustr.Append
           (outs,
            "    child : " & ch'Img & stda.LF & toString (bu.children (ch)) & stda.LF);
      end loop;
      ustr.Append (outs, "    ----------------- " & stda.LF);
      return ustr.To_String (outs);
   end toString;

   function toString (hh : Model_Household_Rec) return String is
      outs : ustr.Unbounded_String := ustr.To_Unbounded_String ("");
   begin
      ustr.Append (outs, "hh");

      ustr.Append
        (outs,
         INDENT &
         "interview_date=" &
         Year (hh.interview_date)'Img &
         "/" &
         Month (hh.interview_date)'Img &
         stda.LF);

      ustr.Append (outs, INDENT & "tenure " & pretty_print (hh.tenure) & stda.LF);
      ustr.Append (outs, INDENT & "acorn" & pretty_print (hh.acorn) & stda.LF);
      ustr.Append (outs, INDENT & "composition " & pretty_print (hh.composition) & stda.LF);
      ustr.Append (outs, INDENT & "income_band " & pretty_print (hh.income_band) & stda.LF);
      ustr.Append
        (outs,
         INDENT & "standard_region " & pretty_print (hh.standard_region) & stda.LF);
      ustr.Append (outs, INDENT & "old_region " & pretty_print (hh.old_region) & stda.LF);
      ustr.Append
        (outs,
         INDENT & "regional_stratifier " & pretty_print (hh.regional_stratifier) & stda.LF);

      ustr.Append (outs, INDENT & "grossing_factor=" & hh.grossing_factor'Img & stda.LF);
      ustr.Append (outs, INDENT & "tenure=" & pretty_print (hh.tenure) & stda.LF);

      ustr.Append (outs, "Housing costs ********** " & stda.LF);
      ustr.Append (outs, INDENT & "mortgages=" & hh.housing_costs.mortgages'Img & stda.LF);

      ustr.Append (outs, INDENT & "rates=" & hh.housing_costs.gross_council_tax'Img);
      ustr.Append (outs, INDENT & "water_rates=" & hh.housing_costs.water_rates'Img & stda.LF);
      ustr.Append (outs, INDENT & "ground_rent=" & hh.housing_costs.ground_rent'Img);
      ustr.Append
        (outs,
         INDENT & "service_charges=" & hh.housing_costs.service_charges'Img & stda.LF);
      ustr.Append
        (outs,
         INDENT & "repairs_and_insurance=" & hh.housing_costs.repairs_And_Insurance'Img);
      ustr.Append (outs, INDENT & "rent=" & hh.housing_costs.rent'Img & stda.LF);
      ustr.Append
        (outs,
         INDENT & "council_tax_rebates=" & hh.housing_costs.council_tax_rebates'Img);
      ustr.Append
        (outs,
         INDENT & "council_tax_rebates=" & hh.housing_costs.council_tax_rebates'Img & stda.LF);
      ustr.Append (outs, INDENT & "home equity=" & hh.housing_costs.home_equity'Img & stda.LF);
      ustr.Append (outs, INDENT & "house price=" & hh.housing_costs.house_price'Img & stda.LF);
      ustr.Append
        (outs,
         INDENT & "costs_are_shared=" & hh.housing_costs.costs_are_shared'Img & stda.LF & stda.LF);

      for bu in  1 .. hh.num_benefit_units loop
         ustr.Append
           (outs,
            " benefit unit : " & bu'Img & stda.LF & toString (hh.benefit_units (bu)) & stda.LF);
      end loop;
      return ustr.To_String (outs);
   end toString;

   --  wages, other_Income, capital, stateBenefits, rent,
   --                       mortgages, localTaxes, charges, repairs

   procedure uprateHousing (hcosts : in out Model_Housing_Costs; changes : MacroArray) is
   begin
      hcosts.mortgages             := money (real (hcosts.mortgages) * changes (mortgages));
      hcosts.gross_council_tax     :=
        money (real (hcosts.gross_council_tax) * changes (localTaxes));
      hcosts.water_rates           := money (real (hcosts.water_rates) * changes (localTaxes));
      hcosts.ground_rent           := money (real (hcosts.ground_rent) * changes (charges));
      hcosts.service_charges       := money (real (hcosts.service_charges) * changes (charges));
      hcosts.repairs_And_Insurance :=
        money (real (hcosts.repairs_And_Insurance) * changes (repairs));
      hcosts.rent                  := money (real (hcosts.rent) * changes (rent));
      --  hcosts.-- := money( real(hcosts.-- * increase ) );
      hcosts.council_tax_rebates :=
        money (real (hcosts.council_tax_rebates) * changes (localTaxes));
      --
      --  Mortgages and housing equity: note that we have a precomputed
      --  uprated house price, so we just swap the precomputed uprated one in.
      --
      hcosts.mortgages_outstanding :=
        money (real (hcosts.mortgages_outstanding) * changes (mortgages));

      hcosts.house_price := hcosts.estimated_house_price_indexed;
      hcosts.home_equity := hcosts.house_price - hcosts.mortgages_outstanding;
   end uprateHousing;

   procedure uprateExpenses (inc : in out Expenses_Array; changes : MacroArray) is
   begin
      for i in  Expense_Items loop
         inc (i) := money (real (inc (i)) * changes (wages));
      end loop;
   end uprateExpenses;

   procedure uprateLoans (inc : in out FinanceArray; changes : MacroArray) is
   begin
      for i in  Finance_Items loop
         inc (i) := money (real (inc (i)) * changes (capital));
      end loop;
   end uprateLoans;

   procedure uprateIncomes (inc : in out Incomes_Array; changes : MacroArray) is
   begin
      for i in  Benefits loop
         inc (i) := money (real (inc (i)) * changes (stateBenefits));
      end loop;
      for i in  wages .. self_Employment loop
         inc (i) := money (real (inc (i)) * changes (wages));
      end loop;
      for i in  investment_Income .. pensions loop
         inc (i) := money (real (inc (i)) * changes (wages));
      end loop;
      for i in  investment_Income .. pensions loop
         inc (i) := money (real (inc (i)) * changes (capital));
      end loop;
   end uprateIncomes;

   procedure uprateHousehold (hh : in out Model_Household_Rec) is
      changesArray : MacroArray;
   begin
      --  type UprateTypes is ( wages, other_Income, capital, stateBenefits );

      changesArray := model_uprate.changes (hh.interview_date);
      uprateHousing (hh.housing_costs, changesArray);
      for buno in  1 .. hh.num_benefit_units loop
         declare
            bu : Model_Benefit_Unit renames hh.benefit_units (buno);
         begin
            bu.capital_stock := money( real(bu.capital_stock) * changesArray (capital));
            for adno in  head .. bu.last_adult loop
               declare
                  ad : Model_Adult renames bu.adults (adno);
               begin
                  uprateIncomes (ad.incomes, changesArray);
                  uprateLoans (ad.finance, changesArray);
                  uprateExpenses (ad.expenses, changesArray);
                  ad.capital_stock := money( real(ad.capital_stock) * changesArray (capital));
               end;
            end loop;
         end;
      end loop;
   end uprateHousehold;

   procedure Multiply_Adult (mad : in out Model_Adult; mult : money) is
   begin
      mad.finance (loan_repayments) := mad.finance (loan_repayments) * mult;
      for e in  Expense_Items loop
         mad.expenses (e) := mad.expenses (e) * mult;
      end loop;

      for e in  Income_Items loop
            mad.incomes (e) := mad.incomes (e) * mult;
      end loop;
   end Multiply_Adult;

   procedure Multiply_BenefitUnit (mb : in out Model_Benefit_Unit; mult : money) is
   begin
      for hdsp in  head .. mb.last_adult loop
         Multiply_Adult (mb.adults (hdsp), mult);
      end loop;
   end Multiply_BenefitUnit;

   procedure Multiply (mhh : in out Model_Household_Rec; mult : money) is
   begin
      mhh.housing_costs.mortgages             := mhh.housing_costs.mortgages * mult;
      mhh.housing_costs.water_rates           := mhh.housing_costs.water_rates * mult;
      mhh.housing_costs.ground_rent           := mhh.housing_costs.ground_rent * mult;
      mhh.housing_costs.service_charges       := mhh.housing_costs.service_charges * mult;
      mhh.housing_costs.repairs_And_Insurance := mhh.housing_costs.repairs_And_Insurance * mult;
      mhh.housing_Costs.rent_rebates         := mhh.housing_Costs.rent_rebates * mult;
      mhh.housing_costs.council_tax_rebates := mhh.housing_costs.council_tax_rebates * mult;
      mhh.housing_costs.gross_council_tax   := mhh.housing_costs.gross_council_tax * mult;
      mhh.housing_costs.rent                := mhh.housing_costs.rent * mult;
      for buno in  1 .. mhh.num_benefit_units loop
         Multiply_BenefitUnit (mhh.benefit_units (buno), mult);
      end loop;
   end Multiply;

   procedure annualise (mhh : in out Model_Household_Rec) is
   begin
      Multiply (mhh, 52.0);
   end annualise;

end model_household;
