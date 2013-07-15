--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with legal_aid_web_commons; use legal_aid_web_commons;
with text_utils;
package file_lister is

        use text_utils.StdBoundedString;

        function make_full_name ( username : String; file_name : Bounded_String; ext : String ) return String;

        procedure make_parameter_file_list
               (root_directory, username : String;
                trans                    : in out LA_Translate_Table;
                insert_Start_Position    : Integer);
        procedure make_file_list
               (root_directory        : String;
                search_pattern        : String;
                trans                 : in out LA_Translate_Table;
                insert_Start_Position : Integer);

end file_lister;
