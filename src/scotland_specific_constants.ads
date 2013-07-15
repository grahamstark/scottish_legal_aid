--
--  $Author: graham_s $
--  $Date: 2007-08-01 17:52:48 +0100 (Wed, 01 Aug 2007) $
--  $Revision: 3660 $
--
with FRS_Enums; use FRS_Enums;
with Templates_Parser;

package scotland_specific_constants is

   SCOTLAND_ONLY : Boolean := True;
   ENG_AND_WALES_ONLY : Boolean := False;

   subtype DATA_YEARS is Integer range 2003 .. 2004;

   type Start_Stop_Pos is (start_pos, end_pos);

   type File_Positions_Array is array (DATA_YEARS, Start_Stop_Pos) of Integer;

   FILE_POSITIONS : constant File_Positions_Array :=
     (2003 => (22149, 26943),
      2004 => (13752, 18274));

   subtype Scottish_Regional_Stratifier is FRS_Enums.Regional_Stratifier range
     highland_grampian_tayside .. north_of_the_caledonian_canal;
     
   function get_int_value_of_stratifier( strat : Regional_Stratifier ) return integer;
   
   function get_scottish_regional_stratifier_template return  Templates_Parser.Tag;

end scotland_specific_constants;
