--
--  $Revision: 2378 $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Author: graham_s $
--
with la_parameters;    use la_parameters;
with data_constants;
with base_model_types; use base_model_types;
with Text_Utils;
pragma Elaborate_All (base_model_types);

package run_settings is

   type Target_Type is (off_diagonal_index, costs_index, targetting_index);
   type Target_Array is array (Target_Type) of real;
   use Text_Utils.StdBoundedString;

   type Settings_Rec is
      record
         year                : data_constants.DataYears := 2003;
         uprate_to_current   : Boolean                  := True;
         run_type            : System_Type              := civil;
         targetting_weights  : Target_Array             := (others => 1.0 / 3.0);   -- target_type
                                                                                    --:=
                                                                                    --off_diagonal_i
                                                                                    --ndex;
         split_benefit_units : Boolean                  := False;
         save_file_name      : Bounded_String;
         start_year          : data_constants.DataYears := 2003;
         end_year            : data_constants.DataYears := 2004;

      end record;

   function to_string (settings : Settings_Rec) return String;

   DEFAULT_RUN_SETTINGS : constant Settings_Rec :=
     (year                => 2003,
      uprate_to_current   => True,
      run_type            => civil,
      targetting_weights  => (others => (1.0 / 3.0)),
      split_benefit_units => False,
      save_file_name      => To_Bounded_String (""),
      start_year          => 2003,
      end_year            => 2004);

   function Binary_Read_Settings (filename : String) return Settings_Rec;
   procedure Binary_Write_Settings (filename : String; settings : Settings_Rec);

end run_settings;
