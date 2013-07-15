--
--  $Author: graham_s $
--  $Date: 2010-02-15 13:06:18 +0000 (Mon, 15 Feb 2010) $
--  $Revision: 8638 $
--
with AUnit.Assertions;              use AUnit.Assertions;
with base_model_types;              use base_model_types;
with Ada.Exceptions;                use Ada.Exceptions;

with raw_frs_conversions_0304;
with raw_frs_conversions_0405;



package body hh_test_raw is


        procedure Set_Up ( T : in out Test_Case ) is
        begin
	null;
        end Set_Up;


        procedure testWriteBinary ( T : in out AUnit.Test_Cases.Test_Case'Class ) is
        begin

                raw_frs_conversions_0304.write_everything_in_binary;
                raw_frs_conversions_0405.write_everything_in_binary;

        end testWriteBinary;




        --------------------
        -- Register_Tests --
        --------------------

        procedure Register_Tests (T : in out Test_Case) is
         use AUnit.Test_Cases.Registration;
        begin
                Register_Routine (T, testWriteBinary'Access, "testWriteBinary" );
        end Register_Tests;

        ----------
        -- Name --
        ----------

        function Name ( T : Test_Case ) return Message_String is
        begin
                return Format("Raw FRS tests.");
        end Name;

end hh_test_raw;
