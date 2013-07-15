--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with model_household;       use model_household;
with legal_aid_web_commons; use legal_aid_web_commons;
with legal_aid_runner;

package example_hh_generator is

        procedure make_example_translations_table
          (mhh : Model_Household_Rec;
           output            : legal_aid_runner.Model_Outputs;
           trans             : in out LA_Translate_Table;
           insert_Start_Position : integer );

end example_hh_generator;
