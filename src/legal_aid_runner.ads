--
--  $Author: graham_s $
--  $Date: 2007-11-13 15:53:36 +0000 (Tue, 13 Nov 2007) $
--  $Revision: 4318 $
--
with la_parameters;   use la_parameters;
with factor_table;
with run_settings;    use run_settings;
with la_calculator;
with model_household;
with Model_Output;
with data_constants;  use data_constants; -- datayears

pragma Elaborate_All (factor_table);

package legal_aid_runner is

   --
   --
   --
   CELL_SIZE          : constant := 4;
   NUM_BREAKDOWNS     : constant := 12;
   MAX_BREAKDOWN_SIZE : constant := 20;
   MAX_NUM_EXAMPLES   : constant := 40;
   NUM_VALUES         : constant := 20;
   EXAMPLE_SIZE       : constant := 2; -- hhref and year
   type Model_Outputs is array (1 .. 2) of Model_Output.LAOutputArray;    -- maybe make
                                                                                --generic & allow >
                                                                                --2 systems

   package FourFT2 is new factor_table (
          CELL_SIZE,
          NUM_VALUES,
          NUM_BREAKDOWNS,
          MAX_BREAKDOWN_SIZE,
          MAX_NUM_EXAMPLES,
          EXAMPLE_SIZE );

   type Aggregation_Level is (Household, Benefit_Unit, Adult, Person);
   type Output_Tables is array( Aggregation_Level ) of FourFT2.Table_Rec;
        --
        --  Retrieve a predefined system.
        --
   procedure getBaseSystem
         (settings : run_settings.Settings_Rec;
          sys      : in out Legal_Aid_Sys;
          ctype    : in out Claim_Type);
   
   function doRun
         (newParameters : Legal_Aid_Sys;
          id            : String;
          settings      : run_settings.Settings_Rec )
          return          Output_Tables; -- FourFT2.Table_Rec;
   --
   --  get a model household; suitable annualised and uprated.
   --
   --
   function get_one_model_household
         (settings : run_settings.Settings_Rec;
          hhref    : Integer;
          year     : Integer )
          return     model_household.Model_Household_Rec;
   
   
   
   function do_one_household
         (newParameters : Legal_Aid_Sys;
          settings      : run_settings.Settings_Rec;
          hhref         : Integer;
          year          : Integer )
          return          Model_Outputs;

end legal_aid_runner;
