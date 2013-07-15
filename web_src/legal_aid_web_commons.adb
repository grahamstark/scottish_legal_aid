with ada.strings.unbounded;use ada.strings.unbounded;
with format_utils;
with AWS.Parameters;        use AWS.Parameters;

package body legal_aid_web_commons is

        function buildInputPage
               (page         : String;
                translations : Templates_Parser.Translate_Table)
                return         AWS.Response.Data
        is
                s : Unbounded_String;
        begin
                s := Templates_Parser.Parse ( "slab/" & page & ".thtml", translations);
                return AWS.Response.Build ("text/html", s);
        end buildInputPage;


        function as_str (m : money) return Bounded_String is
        begin
                return To_Bounded_String (format_utils.format (m));
        end as_str;

        function as_str (r : real) return Bounded_String is
        begin
                return To_Bounded_String (format_utils.format (r));
        end as_str;

        function as_str (i : Integer) return Bounded_String is
        begin
                return To_Bounded_String (i'Img);
        end as_str;

        function getStr (params : AWS.Parameters.List; key : String) return String is
                paramString : Unbounded_String;
        begin
                if (Exist (params, key)) then
                        paramString := To_Unbounded_String (Get (params, key));
                else
                        paramString := To_Unbounded_String ("");
                end if;
                return To_String (paramString);

        end getStr;

        function cell_str (n, compare : money) return String is
                x : money;
        begin
                if (compare = 1.0) then
                        return format_utils.format_with_commas (n);
                end if;
                if (compare /= 0.0) then
                        x := money (100.0 * real (n) / real (compare));
                else
                        x := 0.0;
                end if;
                return format_utils.format (x);
        end cell_str;



end legal_aid_web_commons;
