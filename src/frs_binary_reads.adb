--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with Ada.Direct_IO;
with raw_frs;          use raw_frs;
with Ada.Exceptions;   use Ada.Exceptions;
with AUnit.Assertions; use AUnit.Assertions;
with Text_IO;

package body frs_binary_reads is

   currentYear : DataYears;

   Account_File   : Account_io.File_Type;
   Adult_File     : Adult_io.File_Type;
   Asset_File     : Asset_io.File_Type;
   Benefit_File   : Benefit_io.File_Type;
   Benunit_File   : Benunit_io.File_Type;
   Care_File      : Care_io.File_Type;
   Child_File     : Child_io.File_Type;
   Endowment_File : Endowment_io.File_Type;
   ExtChild_File  : ExtChild_io.File_Type;
   GovPay_File    : GovPay_io.File_Type;
   Household_File : Household_io.File_Type;
   Insurance_File : Insurance_io.File_Type;
   Job_File       : Job_io.File_Type;
   Maint_File     : Maint_io.File_Type;
   MortCont_File  : MortCont_io.File_Type;
   Mortgage_File  : Mortgage_io.File_Type;
   OddJob_File    : OddJob_io.File_Type;
   Owner_File     : Owner_io.File_Type;
   RentCont_File  : RentCont_io.File_Type;
   Renter_File    : Renter_io.File_Type;
   Vehicle_File   : Vehicle_io.File_Type;
   Pension_File   : Pension_io.File_Type;
   PenAmt_File   : PenAmt_io.File_Type;
   PenProv_File    : PenProv_io.File_Type;

   Index_File : Index_io.File_Type;

   procedure CloseFiles is
   begin
      Account_io.Close (Account_File);
      Adult_io.Close (Adult_File);
      Asset_io.Close (Asset_File);
      Benefit_io.Close (Benefit_File);
      Benunit_io.Close (Benunit_File);
      Care_io.Close (Care_File);
      Child_io.Close (Child_File);
      Endowment_io.Close (Endowment_File);
      ExtChild_io.Close (ExtChild_File);
      GovPay_io.Close (GovPay_File);
      Household_io.Close (Household_File);
      Insurance_io.Close (Insurance_File);
      Job_io.Close (Job_File);
      Maint_io.Close (Maint_File);
      MortCont_io.Close (MortCont_File);
      Mortgage_io.Close (Mortgage_File);
      OddJob_io.Close (OddJob_File);
      Owner_io.Close (Owner_File);
      RentCont_io.Close (RentCont_File);
      Renter_io.Close (Renter_File);
      if (currentYear = 2003) then
         Vehicle_io.Close (Vehicle_File);
      end if;
      Pension_io.Close (Pension_File);
      PenAmt_io.Close (PenAmt_File);
      PenProv_io.Close (PenProv_File);
      Index_io.Close (Index_File);

   end CloseFiles;

   function openFiles (year : DataYears) return Integer is
   begin
      currentYear := year;  -- year we're on as global variable
      string_io.Put (BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Account.bin");

      Account_io.Open
        (Account_File,
         Account_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Account.bin");
      Adult_io.Open
        (Adult_File,
         Adult_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Adult.bin");
      string_io.Put (BASE_DATA_DIR & String (YEAR_STRS (year)) &  "/converted/Adult.bin");
      Asset_io.Open
        (Asset_File,
         Asset_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Asset.bin");
      Benefit_io.Open
        (Benefit_File,
         Benefit_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Benefit.bin");
      Benunit_io.Open
        (Benunit_File,
         Benunit_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Benunit.bin");
      string_io.Put (BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Benunit.bin");
      Care_io.Open
        (Care_File,
         Care_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Care.bin");
      Child_io.Open
        (Child_File,
         Child_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Child.bin");
      Endowment_io.Open
        (Endowment_File,
         Endowment_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Endowment.bin");
      ExtChild_io.Open
        (ExtChild_File,
         ExtChild_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/ExtChild.bin");
      GovPay_io.Open
        (GovPay_File,
         GovPay_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/GovPay.bin");
      Household_io.Open
        (Household_File,
         Household_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Household.bin");
      Insurance_io.Open
        (Insurance_File,
         Insurance_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Insurance.bin");
      Job_io.Open
        (Job_File,
         Job_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Job.bin");
      string_io.Put (BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Job.bin");
      Maint_io.Open
        (Maint_File,
         Maint_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Maint.bin");
      MortCont_io.Open
        (MortCont_File,
         MortCont_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/MortCont.bin");
      Mortgage_io.Open
        (Mortgage_File,
         Mortgage_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Mortgage.bin");
      OddJob_io.Open
        (OddJob_File,
         OddJob_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/OddJob.bin");
      Owner_io.Open
        (Owner_File,
         Owner_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Owner.bin");

      Pension_io.Open
        (Pension_File,
         Pension_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Pension.bin");

      PenProv_io.Open
        (PenProv_File,
         PenProv_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/PenProv.bin");

      PenAmt_io.Open
        (PenAmt_File,
         PenAmt_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/PenAmt.bin");

      RentCont_io.Open
        (RentCont_File,
         RentCont_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/RentCont.bin");
      Renter_io.Open
        (Renter_File,
         Renter_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Renter.bin");
      if (year = 2003) then
         Vehicle_io.Open
           (Vehicle_File,
            Vehicle_io.In_File,
            BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/Vehicle.bin");
      end if;

      Index_io.Open
        (Index_File,
         Index_io.In_File,
         BASE_DATA_DIR & String (YEAR_STRS (year)) & "/converted/index.bin");
      return Integer (Index_io.Size (Index_File));
   exception
      when ex : others =>
         string_io.Put ("exception in OpenFiles ");
         string_io.Put (Exception_Name (ex));
         string_io.New_Line;
         string_io.Put (Exception_Message (ex));
         string_io.New_Line;
         return -1;
   end openFiles;

   function bin_read_Index (file : Index_io.File_Type; cpos : Integer) return Index_Rec is
      var : Index_Rec;
   begin
      Index_io.Read (file, var, Index_io.Count (cpos));
      return var;
   end bin_read_Index;

   procedure bin_write_Index (file : Index_io.File_Type; rec : Index_Rec) is
   begin
      Index_io.Write (file, rec);
   end bin_write_Index;

   function bin_read_Adult (file : Adult_io.File_Type; cpos : modelint) return Adult_Rec is
      var : Adult_Rec;
   begin
      Adult_io.Read (file, var, Adult_io.Count (cpos));
      return var;
   end bin_read_Adult;

   procedure bin_write_Adult (file : Adult_io.File_Type; rec : Adult_Rec) is
   begin
      Adult_io.Write (file, rec);
   end bin_write_Adult;

   function bin_read_Account (file : Account_io.File_Type; cpos : modelint) return Account_Rec is
      var : Account_Rec;
   begin
      Account_io.Read (file, var, Account_io.Count (cpos));
      return var;
   end bin_read_Account;

   procedure bin_write_Pension (file : Pension_io.File_Type; rec : Pension_Rec) is
   begin
      Pension_io.Write (file, rec);
   end bin_write_Pension;

   function bin_read_Pension (file : Pension_io.File_Type; cpos : modelint) return Pension_Rec is
      var : Pension_Rec;
   begin
      Pension_io.Read (file, var, Pension_io.Count (cpos));
      return var;
   end bin_read_Pension;

   procedure bin_write_PenAmt (file : PenAmt_io.File_Type; rec : PenAmt_Rec) is
   begin
      PenAmt_io.Write (file, rec);
   end bin_write_PenAmt;

   function bin_read_PenAmt (file : PenAmt_io.File_Type; cpos : modelint) return PenAmt_Rec is
      var : PenAmt_Rec;
   begin
      PenAmt_io.Read (file, var, PenAmt_io.Count (cpos));
      return var;
   end bin_read_PenAmt;

   procedure bin_write_PenProv (file : PenProv_io.File_Type; rec : PenProv_Rec) is
   begin
      PenProv_io.Write (file, rec);
   end bin_write_PenProv;

   function bin_read_PenProv (file : PenProv_io.File_Type; cpos : modelint) return PenProv_Rec is
      var : PenProv_Rec;
   begin
      PenProv_io.Read (file, var, PenProv_io.Count (cpos));
      return var;
   end bin_read_PenProv;



   procedure bin_write_Account (file : Account_io.File_Type; rec : Account_Rec) is
   begin
      Account_io.Write (file, rec);
   end bin_write_Account;

   function bin_read_Asset (file : Asset_io.File_Type; cpos : modelint) return Asset_Rec is
      var : Asset_Rec;
   begin
      Asset_io.Read (file, var, Asset_io.Count (cpos));
      return var;
   end bin_read_Asset;

   procedure bin_write_Asset (file : Asset_io.File_Type; rec : Asset_Rec) is
   begin
      Asset_io.Write (file, rec);
   end bin_write_Asset;

   function bin_read_Benefit (file : Benefit_io.File_Type; cpos : modelint) return Benefit_Rec is
      var : Benefit_Rec;
   begin
      Benefit_io.Read (file, var, Benefit_io.Count (cpos));
      return var;
   end bin_read_Benefit;

   procedure bin_write_Benefit (file : Benefit_io.File_Type; rec : Benefit_Rec) is
   begin
      Benefit_io.Write (file, rec);
   end bin_write_Benefit;

   function bin_read_Benunit (file : Benunit_io.File_Type; cpos : modelint) return Benunit_Rec is
      var : Benunit_Rec;
   begin
      Benunit_io.Read (file, var, Benunit_io.Count (cpos));
      return var;
   end bin_read_Benunit;

   procedure bin_write_Benunit (file : Benunit_io.File_Type; rec : Benunit_Rec) is
   begin
      Benunit_io.Write (file, rec);
   end bin_write_Benunit;

   function bin_read_Care (file : Care_io.File_Type; cpos : modelint) return Care_Rec is
      var : Care_Rec;
   begin
      Care_io.Read (file, var, Care_io.Count (cpos));
      return var;
   end bin_read_Care;

   procedure bin_write_Care (file : Care_io.File_Type; rec : Care_Rec) is
   begin
      Care_io.Write (file, rec);
   end bin_write_Care;

   function bin_read_Child (file : Child_io.File_Type; cpos : modelint) return Child_Rec is
      var : Child_Rec;
   begin
      Child_io.Read (file, var, Child_io.Count (cpos));
      return var;
   end bin_read_Child;

   procedure bin_write_Child (file : Child_io.File_Type; rec : Child_Rec) is
   begin
      Child_io.Write (file, rec);
   end bin_write_Child;

   function bin_read_Endowment
     (file : Endowment_io.File_Type;
      cpos : modelint)
      return Endowment_Rec
   is
      var : Endowment_Rec;
   begin
      Endowment_io.Read (file, var, Endowment_io.Count (cpos));
      return var;
   end bin_read_Endowment;

   procedure bin_write_Endowment (file : Endowment_io.File_Type; rec : Endowment_Rec) is
   begin
      Endowment_io.Write (file, rec);
   end bin_write_Endowment;

   function bin_read_ExtChild
     (file : ExtChild_io.File_Type;
      cpos : modelint)
      return ExtChild_Rec
   is
      var : ExtChild_Rec;
   begin
      ExtChild_io.Read (file, var, ExtChild_io.Count (cpos));
      return var;
   end bin_read_ExtChild;

   procedure bin_write_ExtChild (file : ExtChild_io.File_Type; rec : ExtChild_Rec) is
   begin
      ExtChild_io.Write (file, rec);
   end bin_write_ExtChild;

   function bin_read_GovPay (file : GovPay_io.File_Type; cpos : modelint) return GovPay_Rec is
      var : GovPay_Rec;
   begin
      GovPay_io.Read (file, var, GovPay_io.Count (cpos));
      return var;
   end bin_read_GovPay;

   procedure bin_write_GovPay (file : GovPay_io.File_Type; rec : GovPay_Rec) is
   begin
      GovPay_io.Write (file, rec);
   end bin_write_GovPay;

   function bin_read_Household
     (file : Household_io.File_Type;
      cpos : modelint)
      return Household_Rec
   is
      var : Household_Rec;
   begin
      Household_io.Read (file, var, Household_io.Count (cpos));
      return var;
   end bin_read_Household;

   procedure bin_write_Household (file : Household_io.File_Type; rec : Household_Rec) is
   begin
      Household_io.Write (file, rec);
   end bin_write_Household;

   function bin_read_Insurance
     (file : Insurance_io.File_Type;
      cpos : modelint)
      return Insurance_Rec
   is
      var : Insurance_Rec;
   begin
      Insurance_io.Read (file, var, Insurance_io.Count (cpos));
      return var;
   end bin_read_Insurance;

   procedure bin_write_Insurance (file : Insurance_io.File_Type; rec : Insurance_Rec) is
   begin
      Insurance_io.Write (file, rec);
   end bin_write_Insurance;

   function bin_read_Job (file : Job_io.File_Type; cpos : modelint) return Job_Rec is
      var : Job_Rec;
   begin
      Job_io.Read (file, var, Job_io.Count (cpos));
      return var;
   end bin_read_Job;

   procedure bin_write_Job (file : Job_io.File_Type; rec : Job_Rec) is
   begin
      Job_io.Write (file, rec);
   end bin_write_Job;

   function bin_read_Maint (file : Maint_io.File_Type; cpos : modelint) return Maint_Rec is
      var : Maint_Rec;
   begin
      Maint_io.Read (file, var, Maint_io.Count (cpos));
      return var;
   end bin_read_Maint;

   procedure bin_write_Maint (file : Maint_io.File_Type; rec : Maint_Rec) is
   begin
      Maint_io.Write (file, rec);
   end bin_write_Maint;

   function bin_read_MortCont
     (file : MortCont_io.File_Type;
      cpos : modelint)
      return MortCont_Rec
   is
      var : MortCont_Rec;
   begin
      MortCont_io.Read (file, var, MortCont_io.Count (cpos));
      return var;
   end bin_read_MortCont;

   procedure bin_write_MortCont (file : MortCont_io.File_Type; rec : MortCont_Rec) is
   begin
      MortCont_io.Write (file, rec);
   end bin_write_MortCont;

   function bin_read_Mortgage
     (file : Mortgage_io.File_Type;
      cpos : modelint)
      return Mortgage_Rec
   is
      var : Mortgage_Rec;
   begin
      Mortgage_io.Read (file, var, Mortgage_io.Count (cpos));
      return var;
   end bin_read_Mortgage;

   procedure bin_write_Mortgage (file : Mortgage_io.File_Type; rec : Mortgage_Rec) is
   begin
      Mortgage_io.Write (file, rec);
   end bin_write_Mortgage;

   function bin_read_OddJob (file : OddJob_io.File_Type; cpos : modelint) return OddJob_Rec is
      var : OddJob_Rec;
   begin
      OddJob_io.Read (file, var, OddJob_io.Count (cpos));
      return var;
   end bin_read_OddJob;

   procedure bin_write_OddJob (file : OddJob_io.File_Type; rec : OddJob_Rec) is
   begin
      OddJob_io.Write (file, rec);
   end bin_write_OddJob;

   function bin_read_Owner (file : Owner_io.File_Type; cpos : modelint) return Owner_Rec is
      var : Owner_Rec;
   begin
      Owner_io.Read (file, var, Owner_io.Count (cpos));
      return var;
   end bin_read_Owner;

   procedure bin_write_Owner (file : Owner_io.File_Type; rec : Owner_Rec) is
   begin
      Owner_io.Write (file, rec);
   end bin_write_Owner;

   function bin_read_RentCont
     (file : RentCont_io.File_Type;
      cpos : modelint)
      return RentCont_Rec
   is
      var : RentCont_Rec;
   begin
      RentCont_io.Read (file, var, RentCont_io.Count (cpos));
      return var;
   end bin_read_RentCont;

   procedure bin_write_RentCont (file : RentCont_io.File_Type; rec : RentCont_Rec) is
   begin
      RentCont_io.Write (file, rec);
   end bin_write_RentCont;

   function bin_read_Renter (file : Renter_io.File_Type; cpos : modelint) return Renter_Rec is
      var : Renter_Rec;
   begin
      Renter_io.Read (file, var, Renter_io.Count (cpos));
      return var;
   end bin_read_Renter;

   procedure bin_write_Renter (file : Renter_io.File_Type; rec : Renter_Rec) is
   begin
      Renter_io.Write (file, rec);
   end bin_write_Renter;

   function bin_read_Vehicle (file : Vehicle_io.File_Type; cpos : modelint) return Vehicle_Rec is
      var : Vehicle_Rec;
   begin
      Vehicle_io.Read (file, var, Vehicle_io.Count (cpos));
      return var;
   end bin_read_Vehicle;

   procedure bin_write_Vehicle (file : Vehicle_io.File_Type; rec : Vehicle_Rec) is
   begin
      Vehicle_io.Write (file, rec);
   end bin_write_Vehicle;

   --
   --  panic measure to match against Tony's takeup estimates
   --  which seem to be in a different order sometimes (e.g. hh 5000903071
   --  in 0304).
   --
   function find_by_age_and_sex (benunit : Raw_Benefit_unit; age, sex : Integer) return Integer is
   begin
      for adno in  1 .. benunit.numAdults loop
         if (benunit.adults (adno).adult.AGE = age)
           and then (benunit.adults (adno).adult.SEX = sex)
         then
            return adno;
         end if;
      end loop;
      return -1;
   end find_by_age_and_sex;

   function find_by_age_and_sex (children : Child_Array; age, sex : Integer) return Integer is
   begin
      for chno in  1 .. MAX_NUM_CHILDREN loop
         if (children (chno).child.AGE = age) and then (children (chno).child.SEX = sex) then
            return chno;
         end if;
      end loop;
      return -1;
   end find_by_age_and_sex;

   function getHousehold (hhref : Integer) return Raw_Household is
      type BuCounterArray is array (1 .. MAX_NUM_BENEFIT_UNITS) of Integer;
      type Person_Mapping is
         record
            buno : Integer;
            adno : Integer;
         end record;
      type Person_Mapping_Array is array (1 .. MAX_NUM_PERSONS) of Person_Mapping;

      personMapping : Person_Mapping_Array := (others => (buno => 0, adno => 0));

      hh      : Raw_Household;
      index   : Index_Rec;
      ptr     : modelint;
      benunit : Benunit_Rec;
      buno    : Integer;
   begin
      string_io.Put ("getHousehold; entered");
      index := bin_read_Index (Index_File, hhref);
      string_io.Put ("read index; hh start pos is " & index.pointers (householdRec).startPos'Img);
      hh.household := bin_read_Household (Household_File, index.pointers (householdRec).startPos);
      string_io.Put ("read hh record; sernum = " & String (hh.household.SERNUM));
      if (index.pointers (renterRec).startPos > 0) then
         hh.renter := bin_read_Renter (Renter_File, index.pointers (renterRec).startPos);
         Assert
           (String (hh.renter.SERNUM) = String (hh.household.SERNUM),
            "renter sernum mismatch renter" &
            String (hh.renter.SERNUM) &
            " hh " &
            String (hh.household.SERNUM));
      end if;
      string_io.Put ("read index record");

      if (index.pointers (ownerRec).startPos > 0) then
         hh.owner := bin_read_Owner (Owner_File, index.pointers (ownerRec).startPos);
         Assert
           (String (hh.owner.SERNUM) = String (hh.household.SERNUM),
            "owner sernum mismatch " &
            String (hh.owner.SERNUM) &
            " hh " &
            String (hh.household.SERNUM));

      end if;
      string_io.Put
        (" index.pointers ( vehicleRec ).startPos " & index.pointers (vehicleRec).startPos'Img);
      if (index.pointers (vehicleRec).startPos > 0) then
         hh.numVehicles := index.pointers (vehicleRec).counter;
         for p in  1 .. index.pointers (vehicleRec).counter loop
            ptr             := index.pointers (vehicleRec).startPos + modelint (p) - 1;
            hh.vehicles (p) := bin_read_Vehicle (Vehicle_File, ptr);
            Assert
              (String (hh.vehicles (p).SERNUM) = String (hh.household.SERNUM),
               "veh sernum mismatch " &
               String (hh.vehicles (p).SERNUM) &
               " hh " &
               String (hh.household.SERNUM));
         end loop;
      end if;
      string_io.Put ("Vehicle OK");

      if (index.pointers (mortgageRec).startPos > 0) then
         hh.numMortgages := index.pointers (mortgageRec).counter;
         for p in  1 .. index.pointers (mortgageRec).counter loop
            ptr              := index.pointers (mortgageRec).startPos + modelint (p) - 1;
            hh.mortgages (p) := bin_read_Mortgage (Mortgage_File, ptr);
            Assert
              (String (hh.mortgages (p).SERNUM) = String (hh.household.SERNUM),
               "mort sernum mismatch mort" &
               String (hh.mortgages (p).SERNUM) &
               " hh " &
               String (hh.household.SERNUM));
         end loop;
      end if;
      string_io.Put ("Mortgage OK");
      if (index.pointers (mortContRec).startPos > 0) then
         hh.numMortConts := index.pointers (mortContRec).counter;
         for p in  1 .. index.pointers (mortContRec).counter loop
            ptr                        := index.pointers (mortContRec).startPos +
                                          modelint (p) -
                                          1;
            hh.mortCont (Integer (p))  := bin_read_MortCont (MortCont_File, ptr);
            Assert
              (String (hh.mortCont (p).SERNUM) = String (hh.household.SERNUM),
               "mort mortCont mismatch mort" &
               String (hh.mortCont (p).SERNUM) &
               " hh " &
               String (hh.household.SERNUM));
         end loop;
      end if;
      string_io.Put ("Mortcont OK");
      string_io.Put
        ("index.pointers ( rentcontRec ).startPos=" & index.pointers (rentContRec).startPos'Img);
      string_io.Put
        ("  index.pointers ( rentcontRec ).counter=" & index.pointers (rentContRec).counter'Img);
      string_io.New_Line;
      if (index.pointers (rentContRec).startPos > 0) then
         hh.numRentConts := index.pointers (rentContRec).counter;
         for p in  1 .. index.pointers (rentContRec).counter loop
            ptr                        := index.pointers (rentContRec).startPos +
                                          modelint (p) -
                                          1;
            hh.rentCont (Integer (p))  := bin_read_RentCont (RentCont_File, ptr);
            Assert
              (String (hh.rentCont (p).SERNUM) = String (hh.household.SERNUM),
               "mort rentCont mismatch mort" &
               String (hh.rentCont (p).SERNUM) &
               " hh " &
               String (hh.household.SERNUM));
         end loop;
      end if;
      string_io.Put ("RentCont OK");

      if (index.pointers (benunitRec).startPos > 0) then
         hh.numBenUnits := index.pointers (benunitRec).counter;
         for p in  1 .. index.pointers (benunitRec).counter loop
            ptr                        := index.pointers (benunitRec).startPos +
                                          modelint (p) -
                                          1;
            benunit                    := bin_read_Benunit (Benunit_File, ptr);
            buno                       := Integer (benunit.BENUNIT);
            hh.benunits (buno).benunit := benunit;
            Assert
              (String (hh.benunits (buno).benunit.SERNUM) = String (hh.household.SERNUM),
               " benunits sernum mismatch" &
               String (hh.benunits (p).benunit.SERNUM) &
               " hh " &
               String (hh.household.SERNUM));
         end loop;
      end if;

      string_io.Put ("BenUnits OK");

      if (index.pointers (careRec).startPos > 0) then
         declare
            buCounter : BuCounterArray := (others => 0);
            care      : Care_Rec;
         begin
            for p in  1 .. index.pointers (careRec).counter loop
               ptr                                          := index.pointers (careRec).startPos +
                                                               modelint (p) -
                                                               1;
               care                                         := bin_read_Care (Care_File, ptr);
               buno                                         := Integer (care.BENUNIT);
               buCounter (buno)                             := buCounter (buno) + 1;
               hh.benunits (buno).cares (buCounter (buno))  := care;
               Assert
                 (String (hh.benunits (buno).cares (buCounter (buno)).SERNUM) =
                  String (hh.household.SERNUM),
                  "benunit sernum mismatch" &
                  String (hh.benunits (p).cares (buCounter (buno)).SERNUM) &
                  " hh " &
                  String (hh.household.SERNUM));
            end loop;
         end;
      end if;
      string_io.Put ("Care OK");

      if (index.pointers (extChildRec).startPos > 0) then
         declare
            buCounter : BuCounterArray := (others => 0);
            extChild  : ExtChild_Rec;
         begin
            for p in  1 .. index.pointers (extChildRec).counter loop
               ptr                                             :=
                 index.pointers (extChildRec).startPos + modelint (p) - 1;
               extChild                                        :=
                  bin_read_ExtChild (ExtChild_File, ptr);
               buno                                            := Integer (extChild.BENUNIT);
               buCounter (buno)                                := buCounter (buno) + 1;
               hh.benunits (buno).extchild (buCounter (buno))  := extChild;
               Assert
                 (String (hh.benunits (buno).extchild (buCounter (buno)).SERNUM) =
                  String (hh.household.SERNUM),
                  " benunits sernum ");
            end loop;
         end;
      end if;
      string_io.Put ("read extchild OK");
      if (index.pointers (childRec).startPos > 0) then
         declare
            child : Child_Rec;
            chno  : Child_Count;
         begin
            for p in  1 .. index.pointers (childRec).counter loop
               ptr                                      := index.pointers (childRec).startPos +
                                                           modelint (p) -
                                                           1;
               child                                    := bin_read_Child (Child_File, ptr);
               buno                                     := Integer (child.BENUNIT);
               hh.benunits (buno).num_children           := hh.benunits (buno).num_children + 1;
               chno                                     :=
                 Child_Count (hh.benunits (buno).num_children);
               hh.benunits (buno).children (chno).child := child;
               Assert
                 (String (child.SERNUM) = String (hh.household.SERNUM),
                  "child sernum mismatch");
            end loop;
         end;
      end if;
      string_io.Put ("child");
      if (index.pointers (adultRec).startPos > 0) then
         declare
            adult  : Adult_Rec;
            adNo   : Integer;
            person : Integer;
         begin
            for p in  1 .. index.pointers (adultRec).counter loop
               ptr    := index.pointers (adultRec).startPos + modelint (p) - 1;
               adult  := bin_read_Adult (Adult_File, ptr);
               buno   := Integer (adult.BENUNIT);
               person := Integer (adult.PERSON);
               if (hh.benunits (buno).numAdults = 0) then
                  adNo                         := 1;
                  hh.benunits (buno).numAdults := 1;
               else
                  adNo                         := 2;
                  hh.benunits (buno).numAdults := 2;
               end if;
               personMapping (person).buno            := buno;
               personMapping (person).adno            := adNo;
               hh.benunits (buno).adults (adNo).adult := adult;
               Assert
                 (String (adult.SERNUM) = String (hh.household.SERNUM),
                  "adult sernum mismatch");
            end loop;
         end;
      end if;
      string_io.Put ("adult OK");
      string_io.New_Line;
      string_io.Put
        (" index.pointers (jobRec).startPos " &
         index.pointers (jobRec).startPos'Img &
         " index.pointers (jobRec).counter " &
         index.pointers (jobRec).counter'Img);
      if (index.pointers (jobRec).startPos > 0) then
         declare
            job    : Job_Rec;
            person : Integer;
            jobNo  : Job_Count;
            adNo   : Integer;
         begin
            for p in  1 .. index.pointers (jobRec).counter loop
               ptr    := index.pointers (jobRec).startPos + modelint (p) - 1;
               job    := bin_read_Job (Job_File, ptr);
               buno   := Integer (job.BENUNIT);
               person := Integer (job.PERSON);
               jobNo  := Job_Count (job.JOBTYPE); -- 1..3
               --  this is safe since the jobs are always in ascending
               --  order
               buno                                          := personMapping (person).buno;
               adNo                                          := personMapping (person).adno;
               hh.benunits (buno).adults (adNo).numJobs      := jobNo;
               hh.benunits (buno).adults (adNo).jobs (jobNo) := job;
               Assert (String (job.SERNUM) = String (hh.household.SERNUM), "job sernum mismatch");
            end loop;
         end;
      end if;
      string_io.Put ("job OK");

      if (index.pointers (accountRec).startPos > 0) then
         declare
            accounts   : Account_Rec;
            person     : Integer;
            accountsNo : Account_Count;
            adNo       : Integer;
         begin
            for p in  1 .. index.pointers (accountRec).counter loop
               ptr                                                    :=
                 index.pointers (accountRec).startPos + modelint (p) - 1;
               accounts                                               :=
                  bin_read_Account (Account_File, ptr);
               buno                                                   :=
                 Integer (accounts.BENUNIT);
               person                                                 := Integer (accounts.PERSON);
               buno                                                   :=
                 personMapping (person).buno;
               adNo                                                   :=
                 personMapping (person).adno;
               hh.benunits (buno).adults (adNo).numAccounts           :=
                 hh.benunits (buno).adults (adNo).numAccounts + 1;
               accountsNo                                             :=
                 Account_Count (hh.benunits (buno).adults (adNo).numAccounts);
               hh.benunits (buno).adults (adNo).accounts (accountsNo) := accounts;
               Assert
                 (String (accounts.SERNUM) = String (hh.household.SERNUM),
                  "accounts sernum mismatch");
            end loop;
         end;
      end if;
      string_io.Put ("accounts OK");

      if (index.pointers (assetRec).startPos > 0) then
         declare
            assets   : Asset_Rec;
            person   : Integer;
            assetsNo : Asset_Count;
            adNo     : Integer;
         begin
            for p in  1 .. index.pointers (assetRec).counter loop
               ptr                                                :=
                 index.pointers (assetRec).startPos + modelint (p) - 1;
               assets                                             :=
                  bin_read_Asset (Asset_File, ptr);
               buno                                               := Integer (assets.BENUNIT);
               person                                             := Integer (assets.PERSON);
               buno                                               := personMapping (person).buno;
               adNo                                               := personMapping (person).adno;
               hh.benunits (buno).adults (adNo).numAssets         :=
                 hh.benunits (buno).adults (adNo).numAssets + 1;
               assetsNo                                           :=
                 Asset_Count (hh.benunits (buno).adults (adNo).numAssets);
               hh.benunits (buno).adults (adNo).assets (assetsNo) := assets;
               Assert
                 (String (assets.SERNUM) = String (hh.household.SERNUM),
                  "assets sernum mismatch");
            end loop;
         end;
      end if;
      string_io.Put ("assets OK");

      if (index.pointers (benefitRec).startPos > 0) then
         declare
            benefits   : Benefit_Rec;
            person     : Integer;
            benefitsNo : Benefit_Count;
            adNo       : Integer;
         begin
            for p in  1 .. index.pointers (benefitRec).counter loop
               ptr      := index.pointers (benefitRec).startPos + modelint (p) - 1;
               benefits := bin_read_Benefit (Benefit_File, ptr);

               buno   := Integer (benefits.BENUNIT);
               person := Integer (benefits.PERSON);
               buno   := personMapping (person).buno;
               adNo   := personMapping (person).adno;
               if ((buno = 0) or (adNo = 0)) then
                  --  FIXME:: THIS IS A HACK: Children's benefits assign to adult(1,1) for now
                  --  Since child records don't have benefit slots.
                  adNo := 1;
                  buno := 1;
               end if;
               string_io.Put
                 ("benefits: sernum = " &
                  String (benefits.SERNUM) &
                  "adno " &
                  adNo'Img &
                  "buno " &
                  buno'Img);
               hh.benunits (buno).adults (adNo).numBenefits           :=
                 hh.benunits (buno).adults (adNo).numBenefits + 1;
               benefitsNo                                             :=
                 Benefit_Count (hh.benunits (buno).adults (adNo).numBenefits);
               hh.benunits (buno).adults (adNo).benefits (benefitsNo) := benefits;
               Assert
                 (String (benefits.SERNUM) = String (hh.household.SERNUM),
                  "benefits sernum mismatch");
            end loop;
         end;
      end if;
      string_io.Put ("benefits OK");

      if (index.pointers (govPayRec).startPos > 0) then
         declare
            govPays   : GovPay_Rec;
            person    : Integer;
            govPaysNo : GovPay_Count;
            adNo      : Integer;
         begin
            for p in  1 .. index.pointers (govPayRec).counter loop
               ptr                                                 :=
                 index.pointers (govPayRec).startPos + modelint (p) - 1;
               govPays                                             :=
                  bin_read_GovPay (GovPay_File, ptr);
               buno                                                := Integer (govPays.BENUNIT);
               person                                              := Integer (govPays.PERSON);
               buno                                                := personMapping (person).buno;
               adNo                                                := personMapping (person).adno;
               hh.benunits (buno).adults (adNo).numGovpays         :=
                 hh.benunits (buno).adults (adNo).numGovpays + 1;
               govPaysNo                                           :=
                 GovPay_Count (hh.benunits (buno).adults (adNo).numGovpays);
               hh.benunits (buno).adults (adNo).govpay (govPaysNo) := govPays;
               Assert
                 (String (govPays.SERNUM) = String (hh.household.SERNUM),
                  "govPays sernum mismatch");
            end loop;
         end;
      end if;
      string_io.Put ("govPays OK");

      if (index.pointers (maintRec).startPos > 0) then
         declare
            maintenance : Maint_Rec;
            person      : Integer;
            maintNo     : Maintenance_Count;
            adNo        : Integer;
         begin
            for p in  1 .. index.pointers (maintRec).counter loop
               ptr         := index.pointers (maintRec).startPos + modelint (p) - 1;
               maintenance := bin_read_Maint (Maint_File, ptr);
               buno        := Integer (maintenance.BENUNIT);
               person      := Integer (maintenance.PERSON);
               --  this is safe since the jobs are always in ascending
               --order
               buno                                                    :=
                 personMapping (person).buno;
               adNo                                                    :=
                 personMapping (person).adno;
               hh.benunits (buno).adults (adNo).numMaintenances        :=
                 hh.benunits (buno).adults (adNo).numMaintenances + 1;
               maintNo                                                 :=
                 Maintenance_Count (hh.benunits (buno).adults (adNo).numMaintenances);
               hh.benunits (buno).adults (adNo).maintenances (maintNo) := maintenance;
               Assert
                 (String (maintenance.SERNUM) = String (hh.household.SERNUM),
                  "maintenance sernum mismatch");
            end loop;
         end;
      end if;
      string_io.Put ("Maints OK");

      if (index.pointers (oddJobRec).startPos > 0) then
         declare
            oddJobs   : OddJob_Rec;
            person    : Integer;
            oddJobsNo : OddJob_Count;
            adNo      : Integer;
         begin
            for p in  1 .. index.pointers (oddJobRec).counter loop
               ptr     := index.pointers (oddJobRec).startPos + modelint (p) - 1;
               oddJobs := bin_read_OddJob (OddJob_File, ptr);
               buno    := Integer (oddJobs.BENUNIT);
               person  := Integer (oddJobs.PERSON);
               --  this is safe since the jobs are always in ascending
               --order
               buno                                                 := personMapping (person).buno;
               adNo                                                 := personMapping (person).adno;
               hh.benunits (buno).adults (adNo).numOddJobs          :=
                 hh.benunits (buno).adults (adNo).numOddJobs + 1;
               oddJobsNo                                            :=
                 OddJob_Count (hh.benunits (buno).adults (adNo).numOddJobs);
               hh.benunits (buno).adults (adNo).oddJobs (oddJobsNo) := oddJobs;
               Assert
                 (String (oddJobs.SERNUM) = String (hh.household.SERNUM),
                  "oddjobs sernum mismatch");

            end loop;
         end;
      end if;

      if (index.pointers (pensionRec).startPos > 0) then
         declare
            pensions   : Pension_Rec;
            person     : Integer;
            pensionsNo : Pension_Count;
            adNo       : Integer;
         begin
            for p in  1 .. index.pointers (pensionRec).counter loop
               ptr      := index.pointers (pensionRec).startPos + modelint (p) - 1;
               pensions := bin_read_Pension (Pension_File, ptr);
               buno     := Integer (pensions.BENUNIT);
               person   := Integer (pensions.PERSON);
               --  this is safe since the jobs are always in ascending
               --order
               buno                                                   :=
                 personMapping (person).buno;
               adNo                                                   :=
                 personMapping (person).adno;
               hh.benunits (buno).adults (adNo).numpensions           :=
                 hh.benunits (buno).adults (adNo).numpensions + 1;
               pensionsNo                                             :=
                 Pension_Count (hh.benunits (buno).adults (adNo).numpensions);
               hh.benunits (buno).adults (adNo).pensions (pensionsNo) := pensions;
               Assert
                 (String (pensions.SERNUM) = String (hh.household.SERNUM),
                  "pensions sernum mismatch");
            end loop;
         end;
      end if;

      if (index.pointers (PenProvRec).startPos > 0) then
         declare
            PenProvs   : PenProv_Rec;
            person     : Integer;
            PenProvsNo : Pension_Count;
            adNo       : Integer;
         begin
            for p in  1 .. index.pointers (PenProvRec).counter loop
               ptr      := index.pointers (PenProvRec).startPos + modelint (p) - 1;
               PenProvs := bin_read_PenProv (PenProv_File, ptr);
               buno     := Integer (PenProvs.BENUNIT);
               person   := Integer (PenProvs.PERSON);
               --  this is safe since the jobs are always in ascending
               --order
               buno                                                   :=
                 personMapping (person).buno;
               adNo                                                   :=
                 personMapping (person).adno;
               hh.benunits (buno).adults (adNo).numPenProvs           :=
                 hh.benunits (buno).adults (adNo).numPenProvs + 1;
               PenProvsNo                                             :=
                 Pension_Count (hh.benunits (buno).adults (adNo).numPenProvs);
               hh.benunits (buno).adults (adNo).PenProvs (PenProvsNo) := PenProvs;
               Assert
                 (String (PenProvs.SERNUM) = String (hh.household.SERNUM),
                  "PenProvs sernum mismatch");
            end loop;
         end;
      end if;

      if (index.pointers (PenAmtRec).startPos > 0) then
         declare
            PenAmts   : PenAmt_Rec;
            person     : Integer;
            PenAmtsNo : Pension_Count;
            adNo       : Integer;
         begin
            for p in  1 .. index.pointers (PenAmtRec).counter loop
               ptr      := index.pointers (PenAmtRec).startPos + modelint (p) - 1;
               PenAmts := bin_read_PenAmt (PenAmt_File, ptr);
               buno     := Integer (PenAmts.BENUNIT);
               person   := Integer (PenAmts.PERSON);
               --  this is safe since the jobs are always in ascending
               --order
               buno                                                   :=
                 personMapping (person).buno;
               adNo                                                   :=
                 personMapping (person).adno;
               hh.benunits (buno).adults (adNo).numPenAmts           :=
                 hh.benunits (buno).adults (adNo).numPenAmts + 1;
               PenAmtsNo                                             :=
                 Pension_Count (hh.benunits (buno).adults (adNo).numPenAmts);
               hh.benunits (buno).adults (adNo).PenAmts (PenAmtsNo) := PenAmts;
               Assert
                 (String (PenAmts.SERNUM) = String (hh.household.SERNUM),
                  "PenAmts sernum mismatch");
            end loop;
         end;
      end if;

      return hh;

   end getHousehold;

end frs_binary_reads;
