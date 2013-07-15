--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with raw_frs;          use raw_frs;
with base_model_types; use base_model_types;
with Ada.Direct_IO;
with data_constants;   use data_constants;

package frs_binary_reads is

   function getHousehold (hhref : Integer) return Raw_Household;

   function openFiles (year : DataYears) return Integer;

   procedure CloseFiles;

   --
   --  FIXME: do we really need any these?? can't we do this locally?
   --
   package Account_io is new Ada.Direct_IO (Account_Rec);
   package Adult_io is new Ada.Direct_IO (Adult_Rec);
   package Asset_io is new Ada.Direct_IO (Asset_Rec);
   package Benefit_io is new Ada.Direct_IO (Benefit_Rec);
   package Benunit_io is new Ada.Direct_IO (Benunit_Rec);
   package Care_io is new Ada.Direct_IO (Care_Rec);
   package Child_io is new Ada.Direct_IO (Child_Rec);
   package Endowment_io is new Ada.Direct_IO (Endowment_Rec);
   package ExtChild_io is new Ada.Direct_IO (ExtChild_Rec);
   package GovPay_io is new Ada.Direct_IO (GovPay_Rec);
   package Household_io is new Ada.Direct_IO (Household_Rec);
   package Insurance_io is new Ada.Direct_IO (Insurance_Rec);
   package Job_io is new Ada.Direct_IO (Job_Rec);
   package Maint_io is new Ada.Direct_IO (Maint_Rec);
   package MortCont_io is new Ada.Direct_IO (MortCont_Rec);
   package Mortgage_io is new Ada.Direct_IO (Mortgage_Rec);
   package OddJob_io is new Ada.Direct_IO (OddJob_Rec);
   package Owner_io is new Ada.Direct_IO (Owner_Rec);
   package RentCont_io is new Ada.Direct_IO (RentCont_Rec);
   package Renter_io is new Ada.Direct_IO (Renter_Rec);
   package Pension_io is new Ada.Direct_IO (Pension_Rec);
   package PenProv_io is new Ada.Direct_IO (PenProv_Rec);
   package PenAmt_io is new Ada.Direct_IO (PenAmt_Rec);

   package Vehicle_io is new Ada.Direct_IO (Vehicle_Rec);

   package Index_io is new Ada.Direct_IO (Index_Rec);

   function bin_read_Adult (file : Adult_io.File_Type; cpos : modelint) return Adult_Rec;

   procedure bin_write_Adult (file : Adult_io.File_Type; rec : Adult_Rec);

   function bin_read_Account (file : Account_io.File_Type; cpos : modelint) return Account_Rec;
   procedure bin_write_Account (file : Account_io.File_Type; rec : Account_Rec);

   function bin_read_Asset (file : Asset_io.File_Type; cpos : modelint) return Asset_Rec;
   procedure bin_write_Asset (file : Asset_io.File_Type; rec : Asset_Rec);

   function bin_read_Benefit (file : Benefit_io.File_Type; cpos : modelint) return Benefit_Rec;

   procedure bin_write_Benefit (file : Benefit_io.File_Type; rec : Benefit_Rec);

   function bin_read_Benunit (file : Benunit_io.File_Type; cpos : modelint) return Benunit_Rec;
   procedure bin_write_Benunit (file : Benunit_io.File_Type; rec : Benunit_Rec);

   function bin_read_Care (file : Care_io.File_Type; cpos : modelint) return Care_Rec;

   procedure bin_write_Care (file : Care_io.File_Type; rec : Care_Rec);

   function bin_read_Child (file : Child_io.File_Type; cpos : modelint) return Child_Rec;

   procedure bin_write_Child (file : Child_io.File_Type; rec : Child_Rec);

   function bin_read_Endowment
     (file : Endowment_io.File_Type;
      cpos : modelint)
      return Endowment_Rec;

   procedure bin_write_Endowment (file : Endowment_io.File_Type; rec : Endowment_Rec);

   function bin_read_ExtChild
     (file : ExtChild_io.File_Type;
      cpos : modelint)
      return ExtChild_Rec;

   procedure bin_write_ExtChild (file : ExtChild_io.File_Type; rec : ExtChild_Rec);

   function bin_read_GovPay (file : GovPay_io.File_Type; cpos : modelint) return GovPay_Rec;

   procedure bin_write_GovPay (file : GovPay_io.File_Type; rec : GovPay_Rec);

   function bin_read_Household
     (file : Household_io.File_Type;
      cpos : modelint)
      return Household_Rec;
   procedure bin_write_Household (file : Household_io.File_Type; rec : Household_Rec);

   function bin_read_Insurance
     (file : Insurance_io.File_Type;
      cpos : modelint)
      return Insurance_Rec;
   procedure bin_write_Insurance (file : Insurance_io.File_Type; rec : Insurance_Rec);

   function bin_read_Job (file : Job_io.File_Type; cpos : modelint) return Job_Rec;
   procedure bin_write_Job (file : Job_io.File_Type; rec : Job_Rec);

   function bin_read_Maint (file : Maint_io.File_Type; cpos : modelint) return Maint_Rec;
   procedure bin_write_Maint (file : Maint_io.File_Type; rec : Maint_Rec);

   function bin_read_MortCont
     (file : MortCont_io.File_Type;
      cpos : modelint)
      return MortCont_Rec;
   procedure bin_write_MortCont (file : MortCont_io.File_Type; rec : MortCont_Rec);

   function bin_read_Mortgage
     (file : Mortgage_io.File_Type;
      cpos : modelint)
      return Mortgage_Rec;

   procedure bin_write_Mortgage (file : Mortgage_io.File_Type; rec : Mortgage_Rec);

   function bin_read_OddJob (file : OddJob_io.File_Type; cpos : modelint) return OddJob_Rec;

   procedure bin_write_OddJob (file : OddJob_io.File_Type; rec : OddJob_Rec);

   function bin_read_Owner (file : Owner_io.File_Type; cpos : modelint) return Owner_Rec;

   procedure bin_write_Owner (file : Owner_io.File_Type; rec : Owner_Rec);

   function bin_read_Pension (file : Pension_io.File_Type; cpos : modelint) return Pension_Rec;

   procedure bin_write_Pension (file : Pension_io.File_Type; rec : Pension_Rec);

   function bin_read_PenProv (file : PenProv_io.File_Type; cpos : modelint) return PenProv_Rec;

   procedure bin_write_PenProv (file : PenProv_io.File_Type; rec : PenProv_Rec);

   function bin_read_PenAmt (file : PenAmt_io.File_Type; cpos : modelint) return PenAmt_Rec;

   procedure bin_write_PenAmt (file : PenAmt_io.File_Type; rec : PenAmt_Rec);

   function bin_read_RentCont
     (file : RentCont_io.File_Type;
      cpos : modelint)
      return RentCont_Rec;

   procedure bin_write_RentCont (file : RentCont_io.File_Type; rec : RentCont_Rec);

   function bin_read_Renter (file : Renter_io.File_Type; cpos : modelint) return Renter_Rec;

   procedure bin_write_Renter (file : Renter_io.File_Type; rec : Renter_Rec);

   function bin_read_Vehicle (file : Vehicle_io.File_Type; cpos : modelint) return Vehicle_Rec;

   procedure bin_write_Vehicle (file : Vehicle_io.File_Type; rec : Vehicle_Rec);

   function bin_read_Index (file : Index_io.File_Type; cpos : Integer) return Index_Rec;

   procedure bin_write_Index (file : Index_io.File_Type; rec : Index_Rec);

end frs_binary_reads;
