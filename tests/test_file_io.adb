--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with file_lister;
with AUnit.Test_Cases.Registration; use AUnit.Test_Cases.Registration;
with AUnit.Assertions;              use AUnit.Assertions;

package body test_file_io is
	        --------------------
        -- Register_Tests --
        --------------------

        procedure Register_Tests (T : in out Test_Case) is
        begin
                Register_Routine (T, testListFiles'Access, "List Files");
        end Register_Tests;

        ----------
        -- Name --
        ----------

        function Name ( T : Test_Case ) return String_Access is
        begin
                return new String'("Legal Aid calculations unit tests.");
        end Name;


end test_file_io;
