--
--  $Revision: 2378 $
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--
with Ada.Direct_IO;
with text_io;

package body run_settings is

        package Settings_io is  new  Ada.Direct_IO ( Settings_Rec );

        function to_string( settings : Settings_Rec ) return String is
        begin
                return " year " & settings.year'Img &
                       " uprate_to_current " & settings.uprate_to_current'Img &
                       " run type " & settings.run_type'Img &
                       " off_diagonal_index " & settings.targetting_weights(off_diagonal_index) 'Img &
                       " costs_index " & settings.targetting_weights(costs_index) 'Img &
                       " targetting_index " & settings.targetting_weights(targetting_index) 'Img;

        end to_string;

        function Binary_Read_Settings ( filename : String ) return Settings_Rec is
                settings : Settings_Rec;
                file     : Settings_IO.File_Type;
        begin
                text_io.put( "opening file " & filename & " for reading " );
                Settings_io.Open
                       ( file,
                         Settings_io.In_File,
                         filename );
                Settings_io.Read (file, settings );
                Settings_io.close( file );
                return settings;
        end Binary_Read_Settings;

        procedure Binary_Write_Settings ( filename : String; settings : Settings_Rec ) is
                file     : Settings_IO.File_Type;
        begin
                text_io.put( "opening file " & filename & " for writing " );
                Settings_io.Create
                       ( file,
                         Settings_io.Out_File,
                         filename );
                Settings_io.Write(file, settings );
                Settings_io.close( file );

        end Binary_Write_Settings;

end run_settings;
