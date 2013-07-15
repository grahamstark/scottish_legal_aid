--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--  things common between raw frs and model datasets, to cut down cross dependencies.
--
package data_constants is

        subtype DataYears is integer range 2003 .. 2004;
        subtype String4 is String (1 .. 4);
        type Year_Array is array (DataYears) of String4;
        YEAR_STRS  : constant Year_Array := ( 2003 => "0304", 2004=>"0405" );


end data_constants;

