--
--
--
--

with base_model_types; use base_model_types;


with text_utils; use text_utils;
with AWS.Parameters;
with Ada.Characters.Latin_1;

package html_utils is

        use StdBoundedString;
        package stda renames Ada.Characters.Latin_1;

        type OptionsStr is array (Positive range <>) of Bounded_String;

        HTML_HEADER_STRING : constant String :=
            "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN'" & stda.LF &
            " 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'> " &
            stda.LF &
            " <html xmlns='http://www.w3.org/1999/xhtml' lang='en' xml:lang='en'> " &
            stda.LF &
            "  <head>" &
            stda.LF &
            "      <style type='text/css' >" &
            stda.LF &
            "         .datatable{ " & stda.LF &
            "             border-collapse: collapse; " &
            stda.LF &
            "             text-align:right;" &
            stda.LF &
            "             font-size: 10pt;" &
            stda.LF &
            "             background-color: white;" &
            stda.LF &
            "          }" &
            stda.LF &
            "         .datatable tr{" &
            stda.LF &
            "             border-bottom: 1px dashed silver;" &
            stda.LF &
            "         }" &
            stda.LF &
            "        .datatable th{" &
            stda.LF &
            "            font-weight: normal;" &
            stda.LF &
            "            text-align: left;" &
            stda.LF &
            "         }" &
            stda.LF &
            "         h1{" &
            stda.LF &
            "             color: #992244;" &
            stda.LF &
            "         }" &
            stda.LF &
            "         h2{ " &
            stda.LF &
            "             color: #AA4466; " &
            stda.LF &
            "         } " &
            stda.LF &
            "         h3{ " &
            stda.LF &
            "             color: #BB5566; " &
            stda.LF &
            "         } " &
            stda.LF &
            "     </style> " &
            stda.LF &
            "<title>SUMMARIES</title> " &
            stda.LF &
            "</head><body>";


        BOOLEAN_VALUES         : constant OptionsStr :=
               (To_Bounded_String ("0"),
                To_Bounded_String ("1"));
        DEFAULT_BOOLEAN_LABELS : constant OptionsStr :=
               (To_Bounded_String ("No"),
                To_Bounded_String ("Yes"));



        --  function tr( inp : String ) return String;

        function makeInput
               (varname : String;
                value   : Bounded_String;
                class   : String  := "";
                size    : Integer := 12;
                extras  : String  := "";
                help    : String  := "";
                has_error : boolean := false;
                error_text : Bounded_String := to_bounded_string("") )
                return    String;


        function makeSelect
               (varname, selected : String;
                options           : OptionsStr;
                values            : OptionsStr;
                class             : String := "";
                extras            : String := "";
                help              : String := "")
                return              String;


        function makeRadio
               (varname, selected : String;
                options           : OptionsStr;
                values            : OptionsStr;
                class             : String := "";
                extras            : String := "";
                help              : String := "") return String;

        --
        --   Does several (too many?) things at once:
        --   1) parses the value of paramString if paramString is true and sets value to that if
        --  there is no error
        --   2) makes an html input element, possibly with an attached error condition
        --
        procedure makeOneInput
               (varname      : String;
                outputStr    : in out Bounded_String;
                value        : in out money;
                defaultValue : money;
                help         : String  := "";
                paramString  : String;
                paramIsSet   : Boolean := False;
                min          : money   := money'First;
                max          : money   := money'Last;
                is_error     : in out boolean );
        --
        --   Does several (too many?) things at once:
        --   1) parses the value of paramString if paramString is true and sets value to that if
        --  there is no error
        --   2) makes an html input element, possibly with an attached error condition
        --
        procedure makeOneInput
               (varname      : String;
                outputStr    : in out Bounded_String;
                value        : in out real;
                defaultValue : real;
                help         : String  := "";
                paramString  : String;
                paramIsSet   : Boolean := False;
                min          : real   := -100.0;
                max          : real   := 100.0;
                isPercent    : boolean := false;
                is_error     : in out boolean );

       procedure makeOneInput
               (varname      : String;
                outputStr    : in out Bounded_String;
                value        : in out integer;
                defaultValue : integer;
                help         : String  := "";
                paramString  : String  := "";
                paramIsSet   : Boolean := False;
                min          : integer   := integer'First;
                max          : integer   := integer'Last;
                is_error     : in out boolean);

 --      procedure makeOneInput
 --              (varname      : String;
--                  outputStr    : in out Bounded_String;
--                  value        : in out modelint;
--                  defaultValue : modelint;
--                  help         : String  := "";
--                  paramString  : String  := "";
--                  paramIsSet   : Boolean := False;
--                  min          : modelint := modelint'First;
--                  max          : modelint := modelint'Last;
--                  is_error     : in out boolean );

      procedure makeOneInput
               (varname      : String;
                outputStr    : in out Bounded_String;
                value        : in out Boolean;
                defaultValue : Boolean;
                option_names : OptionsStr := DEFAULT_BOOLEAN_LABELS;
                help         : String     := "";
                paramString  : String     := "";
                paramIsSet   : Boolean    := False;
                use_if_set   : boolean    := false );


      generic
                  type T is (<>);
      procedure makeOneSelectBox
               (varname      : String;
                outputStr    : in out Bounded_String;
                value        : in out T;
                defaultValue : T;
                option_names : OptionsStr;
                option_values : OptionsStr;
                help         : String     := "";
                paramString  : String     := "";
                paramIsSet    : Boolean    := False );
        --
        -- string - only case, with no direct validation
        --
      procedure makeOneStringInput
               (varname      : String;
                outputStr    : in out Bounded_String;
                value        : in out Bounded_String;
                defaultValue : Bounded_String := to_bounded_string("");
                help         : String  := "";
                paramString  : Bounded_String  := to_bounded_string("");
                paramIsSet   : Boolean := False;
                is_error     : in out boolean;
                size         : integer );
        --
        --  given one of aws' containters, look up the key corresponding to value, or return ""
        --  this is useful for hanlind submit buttons where the value is connstant and the actual target
        --  is in the action
        --
      function reverse_table_lookup ( table : AWS.Parameters.List; value : String ) return String;

end html_utils;
