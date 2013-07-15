--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with raw_frs; use raw_frs;

package raw_frs_printer is

        function toString( hh : Raw_Household ) return String;
        function toString (v : Job_Rec) return String;
        function toString (v : Benunit_Rec) return String;
        --  function toString( hprice : House_Price_Estimates_Rec ) return String;
        --  function toString( takeup : Takeup_Estimates_Rec ) return String;

end raw_frs_printer;

