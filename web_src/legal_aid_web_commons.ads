with base_model_types; use base_model_types;
with la_parameters;
with legal_aid_optimiser;
with user;
with legal_aid_runner;
with AWS.Session;
with AWS.Response;
with AWS.Parameters;
with Text_Utils;
with ada.strings.bounded; use ada.strings.bounded;
with ada.strings.unbounded; use ada.strings.unbounded;
with run_settings;

with Templates_Parser;

pragma elaborate_all( AWS.Session );
pragma elaborate_all( la_parameters );

package legal_aid_web_commons is

        use Text_Utils.StdBoundedString;

        package Session_String is new Ada.Strings.Bounded.Generic_Bounded_Length (1000);

        BLANK_SESSION_STRING : constant Session_String.bounded_string := Session_String.to_bounded_string ( " " );

        -- BLANK_SESSION_STRING : constant unbounded_string := to_unbounded_string ( " " );


        package Optimiser_Session_Data is new AWS.Session.Generic_Data (
                legal_aid_optimiser.Optimisation_Output,
                legal_aid_optimiser.BLANK_OPTIMISATION_OUTPUT );


        package String_Session_Data is new AWS.Session.Generic_Data (
                Session_String.bounded_string,
                BLANK_SESSION_STRING );

        package Parameters_Session_Data is new AWS.Session.Generic_Data (
                la_parameters.Legal_Aid_Sys,
                la_parameters.Get_Default_System);

        package User_Session_Data is new AWS.Session.Generic_Data (
                user.UserRec,
                user.INVALID_USER);

        package Table_Session_Data is new AWS.Session.Generic_Data (
                legal_aid_runner.FourFT2.Table_Rec,
                legal_aid_runner.FourFT2.BLANK_TABLE );

        package Run_Settings_Session_Data is new AWS.Session.Generic_Data (
                run_settings.Settings_Rec,
                run_settings.DEFAULT_RUN_SETTINGS );

        function buildInputPage
               (page         : String;
                translations : Templates_Parser.Translate_Table)
                return         AWS.Response.Data;

        function as_str (m : money) return Bounded_String;

        function as_str (r : real) return Bounded_String;

        function as_str (i : Integer) return Bounded_String;

        function getStr (params : AWS.Parameters.List; key : String) return String;

        subtype LA_TABLE_SIZE is Integer range 1 .. 4000;

        subtype LA_Translate_Table is Templates_Parser.Translate_Table (LA_TABLE_SIZE);

        function cell_str (n, compare : money) return String;

end legal_aid_web_commons;
