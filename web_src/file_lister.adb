--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with Templates_Parser;
with legal_aid_web_commons; use legal_aid_web_commons;
with Ada.Calendar;          use Ada.Calendar;
with Ada.Directories;       use Ada.Directories;
with Text_IO;
with Text_Utils;
with web_constants;

-- Fortesqueue
package body file_lister is

   use type Templates_Parser.Vector_Tag;
   use Text_Utils.StdBoundedString;

   function make_full_name
     (username  : String;
      file_name : Bounded_String;
      ext       : String)
      return      String
   is
   begin
      return web_constants.SERVER_ROOT & username & "/" & To_String (file_name) & "." & ext;
   end make_full_name;

   procedure make_parameter_file_list
     (root_directory, username : String;
      trans                    : in out LA_Translate_Table;
      insert_Start_Position    : Integer)
   is
   begin
      make_file_list
        (root_directory & "/" & username & "/",
         "*.bpr",
         trans,
         insert_Start_Position);
   end make_parameter_file_list;

   procedure make_file_list
     (root_directory        : String;
      search_pattern        : String;
      trans                 : in out LA_Translate_Table;
      insert_Start_Position : Integer)
   is
      filenames, file_times, full_paths : Templates_Parser.Tag;

      search          : Search_Type;
      directory_entry : Directory_Entry_Type;
      FILES_FILTER    : constant Filter_Type := (Ordinary_File => True, others => False);
      mtime           : Time;
      time_string     : Bounded_String;
   begin
      --  FIXME: the delimiter must be defined somewhere
      Start_Search (search, root_directory, search_pattern, FILES_FILTER);
      while More_Entries (search) loop
         Get_Next_Entry (search, directory_entry);
         mtime       := Modification_Time (directory_entry);
         filenames   := filenames & Base_Name (Simple_Name (directory_entry));
         full_paths  := full_paths & Full_Name (directory_entry);
         time_string :=
            To_Bounded_String
              (Year (mtime)'Img & '-' & Month (mtime)'Img & "-" & Day (mtime)'Img);
         file_times  := file_times & To_String (time_string);

         --  Text_IO.Put ("adding filename " & Full_Name (directory_entry));
      end loop;
      trans (insert_Start_Position + 1) := Templates_Parser.Assoc ("filenames", filenames);
      trans (insert_Start_Position + 2) := Templates_Parser.Assoc ("full-paths", full_paths);
      trans (insert_Start_Position + 3) := Templates_Parser.Assoc ("file-times", file_times);

   end make_file_list;

end file_lister;
