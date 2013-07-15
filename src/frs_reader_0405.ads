--
-- $Revision: 2378 $
-- $Author $
-- $Date $
--
with raw_frs; use raw_frs;

with base_model_types; use base_model_types;

package FRS_Reader_0405 is

   DATA_DIR : constant String :=
      "/home/graham_s/VirtualWorlds/projects/scottish_legal_aid/data/0405/converted/";

   function loadAccount (file : string_io.File_Type) return Account_Rec;
   function loadAdult (file : string_io.File_Type) return Adult_Rec;
   function loadAsset (file : string_io.File_Type) return Asset_Rec;
   function loadBenefit (file : string_io.File_Type) return Benefit_Rec;
   function loadBenunit (file : string_io.File_Type) return Benunit_Rec;
   function loadCare (file : string_io.File_Type) return Care_Rec;
   function loadChild (file : string_io.File_Type) return Child_Rec;
   function loadEndowment (file : string_io.File_Type) return Endowment_Rec;
   function loadExtChild (file : string_io.File_Type) return ExtChild_Rec;
   function loadGovPay (file : string_io.File_Type) return GovPay_Rec;
   function loadHousehold (file : string_io.File_Type) return Household_Rec;
   function loadInsurance (file : string_io.File_Type) return Insurance_Rec;
   function loadJob (file : string_io.File_Type) return Job_Rec;
   function loadMaint (file : string_io.File_Type) return Maint_Rec;
   function loadMortCont (file : string_io.File_Type) return MortCont_Rec;
   function loadMortgage (file : string_io.File_Type) return Mortgage_Rec;
   function loadOddJob (file : string_io.File_Type) return OddJob_Rec;
   function loadOwner (file : string_io.File_Type) return Owner_Rec;
   function loadRentCont (file : string_io.File_Type) return RentCont_Rec;
   function loadRenter (file : string_io.File_Type) return Renter_Rec;
   function loadPenProv (file : string_io.File_Type) return PenProv_Rec;
   function loadPension (file : string_io.File_Type) return Pension_Rec;
   function loadPenAmt (file : string_io.File_Type) return PenAmt_Rec;

end FRS_Reader_0405;
