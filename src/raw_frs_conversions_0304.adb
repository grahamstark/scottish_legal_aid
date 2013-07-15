--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--

with Text_IO;
with base_model_types; use base_model_types;
with raw_frs;          use raw_frs;
--
--  change these to 0203/0304 as needed; make sure to comment out loadVehicle in 0203
--
with FRS_Reader_0304;  use FRS_Reader_0304;
with frs_binary_reads; use frs_binary_reads;
with FRS_Utils;        use FRS_Utils;

--
--  Conversion routine for frs data to binary
--  change _0304 to _0203 above as needed, and call write_everything_in_binary from somewhere.
--  For 0203, remove the call to Vehicles below as that data is not there.
--  Note that 0304 needs Takeup loads commented back in!!
--
package body raw_frs_conversions_0304 is

   procedure Write_Adults_In_Binary is
      infile  : string_io.File_Type;
      outfile : Adult_io.File_Type;
      adult   : Adult_Rec;
   begin
      Text_IO.Put ("opening |" & DATA_DIR & "Adult.dat" & "| OK");
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Adult.dat");

      Adult_io.Create (outfile, Adult_io.Out_File, DATA_DIR & "Adult.bin");
      while not (string_io.End_Of_File (infile)) loop
         adult := loadAdult (infile);
         Text_IO.Put
           ("adult.sernum " &
            String (adult.SERNUM) &
            " tu " &
            adult.BENUNIT'Img &
            " person " &
            adult.PERSON'Img);
         Text_IO.New_Line;

         bin_write_Adult (outfile, adult);
      end loop;
      string_io.Close (infile);
      Adult_io.Close (outfile);

   end Write_Adults_In_Binary;

   procedure Write_Account_In_Binary is
      infile  : string_io.File_Type;
      outfile : Account_io.File_Type;
      account : Account_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Account.dat");
      Account_io.Create (outfile, Account_io.Out_File, DATA_DIR & "Account.bin");
      while not (string_io.End_Of_File (infile)) loop
         account := loadAccount (infile);
         Text_IO.Put
           ("Accounts.sernum " &
            String (account.SERNUM) &
            " tu " &
            account.BENUNIT'Img &
            " person " &
            account.PERSON'Img);
         Text_IO.New_Line;

         bin_write_Account (outfile, account);
      end loop;
      string_io.Close (infile);
      Account_io.Close (outfile);

   end Write_Account_In_Binary;

   procedure Write_Asset_In_Binary is
      infile  : string_io.File_Type;
      outfile : Asset_io.File_Type;
      asset   : Asset_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Asset.dat");
      Asset_io.Create (outfile, Asset_io.Out_File, DATA_DIR & "Asset.bin");
      while not (string_io.End_Of_File (infile)) loop
         asset := loadAsset (infile);
         Text_IO.Put
           ("Assets.sernum " &
            String (asset.SERNUM) &
            " tu " &
            asset.BENUNIT'Img &
            " person " &
            asset.PERSON'Img);
         Text_IO.New_Line;

         bin_write_Asset (outfile, asset);
      end loop;
      string_io.Close (infile);
      Asset_io.Close (outfile);

   end Write_Asset_In_Binary;

   procedure Write_BenUnit_In_Binary is
      infile  : string_io.File_Type;
      outfile : Benunit_io.File_Type;
      benunit : Benunit_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Benunit.dat");
      Benunit_io.Create (outfile, Benunit_io.Out_File, DATA_DIR & "Benunit.bin");
      string_io.Put ("Write_BenUnit_In_Binary; files opened ok ");
      while not (string_io.End_Of_File (infile)) loop
         string_io.Put ("loading benefit unit ");
         benunit := loadBenunit (infile);
         Text_IO.Put
           ("Benunits.sernum " & String (benunit.SERNUM) & " tu " & benunit.BENUNIT'Img);
         Text_IO.New_Line;

         bin_write_Benunit (outfile, benunit);
      end loop;
      string_io.Close (infile);
      Benunit_io.Close (outfile);

   end Write_BenUnit_In_Binary;

   procedure Write_Benefits_In_Binary is
      infile  : string_io.File_Type;
      outfile : Benefit_io.File_Type;
      benefit : Benefit_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Benefit.dat");
      Benefit_io.Create (outfile, Benefit_io.Out_File, DATA_DIR & "Benefit.bin");
      while not (string_io.End_Of_File (infile)) loop
         benefit := loadBenefit (infile);
         Text_IO.Put
           ("Benunits.sernum " &
            String (benefit.SERNUM) &
            " tu " &
            benefit.BENUNIT'Img &
            " person " &
            benefit.PERSON'Img);
         Text_IO.New_Line;

         bin_write_Benefit (outfile, benefit);
      end loop;
      string_io.Close (infile);
      Benefit_io.Close (outfile);

   end Write_Benefits_In_Binary;

   procedure Write_Care_In_Binary is
      infile  : string_io.File_Type;
      outfile : Care_io.File_Type;
      care    : Care_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Care.dat");
      Care_io.Create (outfile, Care_io.Out_File, DATA_DIR & "Care.bin");
      while not (string_io.End_Of_File (infile)) loop
         care := loadCare (infile);
         Text_IO.Put ("Care.sernum " & String (care.SERNUM) & " tu " & care.BENUNIT'Img);
         Text_IO.New_Line;

         bin_write_Care (outfile, care);
      end loop;
      string_io.Close (infile);
      Care_io.Close (outfile);

   end Write_Care_In_Binary;

   procedure Write_Child_In_Binary is
      infile  : string_io.File_Type;
      outfile : Child_io.File_Type;
      child   : Child_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Child.dat");
      Child_io.Create (outfile, Child_io.Out_File, DATA_DIR & "Child.bin");
      while not (string_io.End_Of_File (infile)) loop
         child := loadChild (infile);
         Text_IO.Put ("Child.sernum " & String (child.SERNUM) & " tu " & child.BENUNIT'Img);
         Text_IO.New_Line;

         bin_write_Child (outfile, child);
      end loop;
      string_io.Close (infile);
      Child_io.Close (outfile);

   end Write_Child_In_Binary;

   procedure Write_Endowment_In_Binary is
      infile    : string_io.File_Type;
      outfile   : Endowment_io.File_Type;
      endowment : Endowment_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Endowment.dat");
      Endowment_io.Create (outfile, Endowment_io.Out_File, DATA_DIR & "Endowment.bin");
      while not (string_io.End_Of_File (infile)) loop
         endowment := loadEndowment (infile);
         Text_IO.Put ("Endowment.sernum " & String (endowment.SERNUM));
         Text_IO.New_Line;

         bin_write_Endowment (outfile, endowment);
      end loop;
      string_io.Close (infile);
      Endowment_io.Close (outfile);

   end Write_Endowment_In_Binary;

   procedure Write_ExtChild_In_Binary is
      infile   : string_io.File_Type;
      outfile  : ExtChild_io.File_Type;
      extChild : ExtChild_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "ExtChild.dat");
      ExtChild_io.Create (outfile, ExtChild_io.Out_File, DATA_DIR & "ExtChild.bin");
      while not (string_io.End_Of_File (infile)) loop
         extChild := loadExtChild (infile);
         Text_IO.Put
           ("Benunits.sernum " & String (extChild.SERNUM) & " tu " & extChild.BENUNIT'Img);
         Text_IO.New_Line;

         bin_write_ExtChild (outfile, extChild);
      end loop;
      string_io.Close (infile);
      ExtChild_io.Close (outfile);

   end Write_ExtChild_In_Binary;

   procedure Write_GovPay_In_Binary is
      infile  : string_io.File_Type;
      outfile : GovPay_io.File_Type;
      GovPay  : GovPay_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "GovPay.dat");
      GovPay_io.Create (outfile, GovPay_io.Out_File, DATA_DIR & "GovPay.bin");
      while not (string_io.End_Of_File (infile)) loop
         GovPay := loadGovPay (infile);
         Text_IO.Put ("Benunits.sernum " & String (GovPay.SERNUM) & " tu " & GovPay.BENUNIT'Img);
         Text_IO.New_Line;

         bin_write_GovPay (outfile, GovPay);
      end loop;
      string_io.Close (infile);
      GovPay_io.Close (outfile);

   end Write_GovPay_In_Binary;

   procedure Write_Household_In_Binary is
      infile    : string_io.File_Type;
      outfile   : Household_io.File_Type;
      household : Household_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Household.dat");
      Household_io.Create (outfile, Household_io.Out_File, DATA_DIR & "Household.bin");
      while not (string_io.End_Of_File (infile)) loop
         household := loadHousehold (infile);
         Text_IO.Put ("Household.sernum " & String (household.SERNUM));
         Text_IO.New_Line;

         bin_write_Household (outfile, household);
      end loop;
      string_io.Close (infile);
      Household_io.Close (outfile);

   end Write_Household_In_Binary;

   procedure Write_Insurance_In_Binary is
      infile    : string_io.File_Type;
      outfile   : Insurance_io.File_Type;
      insurance : Insurance_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Insurance.dat");
      Insurance_io.Create (outfile, Insurance_io.Out_File, DATA_DIR & "Insurance.bin");
      while not (string_io.End_Of_File (infile)) loop
         insurance := loadInsurance (infile);
         Text_IO.Put ("Insurance.sernum " & String (insurance.SERNUM));
         Text_IO.New_Line;

         bin_write_Insurance (outfile, insurance);
      end loop;
      string_io.Close (infile);
      Insurance_io.Close (outfile);

   end Write_Insurance_In_Binary;

   procedure Write_Job_In_Binary is
      infile  : string_io.File_Type;
      outfile : Job_io.File_Type;
      job     : Job_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Job.dat");
      Job_io.Create (outfile, Job_io.Out_File, DATA_DIR & "Job.bin");
      while not (string_io.End_Of_File (infile)) loop
         job := loadJob (infile);
         Text_IO.Put ("Job.sernum " & String (job.SERNUM));
         Text_IO.New_Line;

         bin_write_Job (outfile, job);
      end loop;
      string_io.Close (infile);
      Job_io.Close (outfile);

   end Write_Job_In_Binary;

   procedure Write_Maint_In_Binary is
      infile  : string_io.File_Type;
      outfile : Maint_io.File_Type;
      maint   : Maint_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Maint.dat");
      Maint_io.Create (outfile, Maint_io.Out_File, DATA_DIR & "Maint.bin");
      while not (string_io.End_Of_File (infile)) loop
         maint := loadMaint (infile);
         Text_IO.Put ("Maint.sernum " & String (maint.SERNUM));
         Text_IO.New_Line;
         bin_write_Maint (outfile, maint);
      end loop;
      string_io.Close (infile);
      Maint_io.Close (outfile);

   end Write_Maint_In_Binary;

   procedure Write_MortCont_In_Binary is
      infile   : string_io.File_Type;
      outfile  : MortCont_io.File_Type;
      MortCont : MortCont_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "MortCont.dat");
      MortCont_io.Create (outfile, MortCont_io.Out_File, DATA_DIR & "MortCont.bin");
      while not (string_io.End_Of_File (infile)) loop
         MortCont := loadMortCont (infile);
         Text_IO.Put ("MortCont.sernum " & String (MortCont.SERNUM));
         Text_IO.New_Line;
         bin_write_MortCont (outfile, MortCont);
      end loop;
      string_io.Close (infile);
      MortCont_io.Close (outfile);

   end Write_MortCont_In_Binary;

   procedure Write_Mortgage_In_Binary is
      infile   : string_io.File_Type;
      outfile  : Mortgage_io.File_Type;
      mortgage : Mortgage_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Mortgage.dat");
      Mortgage_io.Create (outfile, Mortgage_io.Out_File, DATA_DIR & "Mortgage.bin");
      while not (string_io.End_Of_File (infile)) loop
         mortgage := loadMortgage (infile);
         Text_IO.Put ("mortgage.sernum " & String (mortgage.SERNUM));
         Text_IO.New_Line;
         bin_write_Mortgage (outfile, mortgage);
      end loop;
      string_io.Close (infile);
      Mortgage_io.Close (outfile);

   end Write_Mortgage_In_Binary;

   procedure Write_OddJob_In_Binary is
      infile  : string_io.File_Type;
      outfile : OddJob_io.File_Type;
      OddJob  : OddJob_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "OddJob.dat");
      OddJob_io.Create (outfile, OddJob_io.Out_File, DATA_DIR & "OddJob.bin");
      while not (string_io.End_Of_File (infile)) loop
         OddJob := loadOddJob (infile);
         Text_IO.Put ("OddJob.sernum " & String (OddJob.SERNUM));
         Text_IO.New_Line;
         bin_write_OddJob (outfile, OddJob);
      end loop;
      string_io.Close (infile);
      OddJob_io.Close (outfile);

   end Write_OddJob_In_Binary;

   procedure Write_Owner_In_Binary is
      infile  : string_io.File_Type;
      outfile : Owner_io.File_Type;
      Owner   : Owner_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Owner.dat");
      Owner_io.Create (outfile, Owner_io.Out_File, DATA_DIR & "Owner.bin");
      while not (string_io.End_Of_File (infile)) loop
         Owner := loadOwner (infile);
         Text_IO.Put ("Owner.sernum " & String (Owner.SERNUM));
         Text_IO.New_Line;
         bin_write_Owner (outfile, Owner);
      end loop;
      string_io.Close (infile);
      Owner_io.Close (outfile);

   end Write_Owner_In_Binary;

   procedure Write_RentCont_In_Binary is
      infile   : string_io.File_Type;
      outfile  : RentCont_io.File_Type;
      RentCont : RentCont_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "RentCont.dat");
      RentCont_io.Create (outfile, RentCont_io.Out_File, DATA_DIR & "RentCont.bin");
      while not (string_io.End_Of_File (infile)) loop
         RentCont := loadRentCont (infile);
         Text_IO.Put ("RentCont.sernum " & String (RentCont.SERNUM));
         Text_IO.New_Line;
         bin_write_RentCont (outfile, RentCont);
      end loop;
      string_io.Close (infile);
      RentCont_io.Close (outfile);

   end Write_RentCont_In_Binary;

   procedure Write_Renter_In_Binary is
      infile  : string_io.File_Type;
      outfile : Renter_io.File_Type;
      renter  : Renter_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Renter.dat");
      Renter_io.Create (outfile, Renter_io.Out_File, DATA_DIR & "Renter.bin");
      while not (string_io.End_Of_File (infile)) loop
         renter := loadRenter (infile);
         Text_IO.Put ("Renter.sernum " & String (renter.SERNUM));
         Text_IO.New_Line;
         bin_write_Renter (outfile, renter);
      end loop;
      string_io.Close (infile);
      Renter_io.Close (outfile);

   end Write_Renter_In_Binary;

   procedure Write_Vehicle_In_Binary is
      infile  : string_io.File_Type;
      outfile : Vehicle_io.File_Type;
      vehicle : Vehicle_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Vehicle.dat");
      Vehicle_io.Create (outfile, Vehicle_io.Out_File, DATA_DIR & "Vehicle.bin");
      while not (string_io.End_Of_File (infile)) loop
         vehicle := loadVehicle (infile);
         Text_IO.Put ("Vehicle.sernum " & String (vehicle.SERNUM));
         Text_IO.New_Line;
         bin_write_Vehicle (outfile, vehicle);
      end loop;
      string_io.Close (infile);
      Vehicle_io.Close (outfile);

   end Write_Vehicle_In_Binary;

   procedure Write_Pension_In_Binary is
      infile  : string_io.File_Type;
      outfile : Pension_io.File_Type;
      Pension : Pension_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "Pension.dat");
      Pension_io.Create (outfile, Pension_io.Out_File, DATA_DIR & "Pension.bin");
      while not (string_io.End_Of_File (infile)) loop
         Pension := loadPension (infile);
         Text_IO.Put ("Pension.sernum " & String (Pension.SERNUM));
         Text_IO.New_Line;
         bin_write_Pension (outfile, Pension);
      end loop;
      string_io.Close (infile);
      Pension_io.Close (outfile);

   end Write_Pension_In_Binary;

   procedure Write_PenProv_In_Binary is
      infile  : string_io.File_Type;
      outfile : PenProv_io.File_Type;
      PenProv : PenProv_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "PenProv.dat");
      PenProv_io.Create (outfile, PenProv_io.Out_File, DATA_DIR & "PenProv.bin");
      while not (string_io.End_Of_File (infile)) loop
         PenProv := loadPenProv (infile);
         Text_IO.Put ("PenProv.sernum " & String (PenProv.SERNUM));
         Text_IO.New_Line;
         bin_write_PenProv (outfile, PenProv);
      end loop;
      string_io.Close (infile);
      PenProv_io.Close (outfile);

   end Write_PenProv_In_Binary;

   procedure Write_PenAmt_In_Binary is
      infile  : string_io.File_Type;
      outfile : PenAmt_io.File_Type;
      PenAmt : PenAmt_Rec;
   begin
      string_io.Open (infile, string_io.In_File, DATA_DIR & "PenAmt.dat");
      PenAmt_io.Create (outfile, PenAmt_io.Out_File, DATA_DIR & "PenAmt.bin");
      while not (string_io.End_Of_File (infile)) loop
         PenAmt := loadPenAmt (infile);
         Text_IO.Put ("PenAmt.sernum " & String (PenAmt.SERNUM));
         Text_IO.New_Line;
         bin_write_PenAmt (outfile, PenAmt);
      end loop;
      string_io.Close (infile);
      PenAmt_io.Close (outfile);

   end Write_PenAmt_In_Binary;
   
   
   function loadOneIndex (file : string_io.File_Type) return Index_Rec is
      tmp : Index_Rec;

   begin
      tmp.SERNUM := readSernum (file);
      Text_IO.Put ("loadOneIndex ; got sernum as " & String (tmp.SERNUM));
      for comp in  RecordComponents loop
         Text_IO.Put ("loadOneIndex; on record " & comp'Img);
         int_io.Get (file, tmp.pointers (comp).startPos);
         Text_IO.Put
           ("tmp.pointers ( " & comp'Img & " ).startPos=" & tmp.pointers (comp).startPos'Img);
         std_io.Get (file, tmp.pointers (comp).counter);
         Text_IO.Put
           ("tmp.pointers ( " & comp'Img & " ).counter=" & tmp.pointers (comp).counter'Img);
         Text_IO.New_Line;
      end loop;
      return tmp;
   end loadOneIndex;

   procedure Write_Index_In_Binary is
      infile  : string_io.File_Type;
      outfile : Index_io.File_Type;
      index   : Index_Rec;
   begin
      Text_IO.Put ("Write_Index_In_Binary; opening file " & DATA_DIR & "positions.dump");
      string_io.Open (infile, string_io.In_File, DATA_DIR & "positions.sorted");
      Index_io.Create (outfile, Index_io.Out_File, DATA_DIR & "index.bin");
      while not (string_io.End_Of_File (infile)) loop
         index := loadOneIndex (infile);
         Text_IO.Put ("Index.sernum " & String (index.SERNUM));
         Text_IO.New_Line;
         bin_write_Index (outfile, index);
      end loop;
      string_io.Close (infile);
      Index_io.Close (outfile);

   end Write_Index_In_Binary;

   procedure write_everything_in_binary is
   begin
      Write_Index_In_Binary;
      Write_Vehicle_In_Binary;
      string_io.Put ("write takeup in binary");
      string_io.New_Line;

      Write_Adults_In_Binary;
      string_io.Put ("Write_Adults_In_Binary");
      Write_Account_In_Binary;
      string_io.Put ("Write_Account_In_Binary;");
      Write_Asset_In_Binary;
      string_io.Put ("Write_Asset_In_Binary;");
      Write_BenUnit_In_Binary;
      string_io.Put ("Write_BenUnit_In_Binary;");

      Write_Benefits_In_Binary;
      string_io.Put ("Write_Benefits_In_Binary;");
      Write_Care_In_Binary;
      string_io.Put ("Write_Care_In_Binary;");
      Write_Child_In_Binary;
      string_io.Put ("Write_Child_In_Binary;");
      Write_Endowment_In_Binary;

      Write_ExtChild_In_Binary;
      Write_GovPay_In_Binary;
      Write_Household_In_Binary;
      Write_Insurance_In_Binary;
      Write_Job_In_Binary;
      Write_Maint_In_Binary;
      Write_MortCont_In_Binary;
      Write_Mortgage_In_Binary;
      Write_OddJob_In_Binary;
      Write_Owner_In_Binary;
      Write_PenProv_In_Binary;
      Write_PenAmt_In_Binary;

      Write_Pension_In_Binary;

      Write_RentCont_In_Binary;
      Write_Renter_In_Binary;

   end write_everything_in_binary;

   --  Job_io is n
   --  Maint_io is
   --  MortCont_io
   --  RentCont_io
   --  OddJob_io i
   --  Owner_io is
   --  RentCont_io
   --  Renter_io i
   --  Vehicle_io

end raw_frs_conversions_0304;
