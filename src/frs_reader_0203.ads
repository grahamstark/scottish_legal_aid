with raw_frs; use raw_frs;

with base_model_types; use base_model_types;

package FRS_Reader_0203 is

        DATA_DIR : constant String := "/home/graham_s/VirtualWorlds/projects/ni_legal_aid/ada/data/0203/converted/";


        function loadAccount( file : string_io.FILE_TYPE ) return Account_Rec;
        function loadAdult ( file : string_io.FILE_TYPE ) return Adult_Rec;
        function loadAsset ( file : string_io.FILE_TYPE ) return Asset_Rec;
        function loadBenefit ( file : string_io.FILE_TYPE ) return Benefit_Rec;
        function loadBenunit ( file : string_io.FILE_TYPE ) return Benunit_Rec;
        function loadCare ( file : string_io.FILE_TYPE ) return Care_Rec ;
        function loadChild ( file : string_io.FILE_TYPE ) return Child_Rec;
        function loadEndowment ( file : string_io.FILE_TYPE ) return Endowment_Rec;
        function loadExtChild ( file : string_io.FILE_TYPE ) return ExtChild_Rec;
        function loadGovPay ( file : string_io.FILE_TYPE ) return GovPay_Rec;
        function loadHousehold ( file : string_io.FILE_TYPE ) return Household_Rec;
        function loadInsurance ( file : string_io.FILE_TYPE ) return Insurance_Rec;
        function loadJob ( file : string_io.FILE_TYPE ) return Job_Rec;
        function loadMaint ( file : string_io.FILE_TYPE ) return Maint_Rec;
        function loadMortCont ( file : string_io.FILE_TYPE ) return MortCont_Rec;
        function loadMortgage ( file : string_io.FILE_TYPE ) return Mortgage_Rec;
        function loadOddJob ( file : string_io.FILE_TYPE ) return OddJob_Rec;
        function loadOwner ( file : string_io.FILE_TYPE ) return Owner_Rec ;
        function loadRentCont ( file : string_io.FILE_TYPE ) return RentCont_Rec;
        function loadRenter ( file : string_io.FILE_TYPE ) return Renter_Rec;
        function loadVehicle ( file : string_io.FILE_TYPE ) return Vehicle_Rec;
        function loadPenProv( file : string_io.FILE_TYPE ) return PenProv_Rec;
        function loadPension( file : string_io.FILE_TYPE ) return Pension_Rec;
        function loadHBAI ( file : string_io.FILE_TYPE ) return HBAI_Rec;
        
        function loadTakeup_Estimates( file : string_io.FILE_TYPE ) return Takeup_Estimates_Rec;

        function loadHouse_Price_Estimates( file : string_io.FILE_TYPE ) return House_Price_Estimates_Rec;

end FRS_Reader_0203;
