with base_model_types;      use base_model_types;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with format_utils;      use format_utils;
with AWS.Parameters;
with Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings;
--
--
--
--
package body html_utils is

   function reverse_table_lookup (table : AWS.Parameters.List; value : String) return String is
      table_size : Integer := AWS.Parameters.Count (table);
   --   elem : AWS.Containers.Tables.Element;
   begin
      for i in  1 .. table_size loop
         Text_IO.Put
           ("reverse_table_lookup item[" &
            i'Img &
            " has value " &
            AWS.Parameters.Get (table, i).Value &
            " name " &
            AWS.Parameters.Get (table, i).Name);
         if (AWS.Parameters.Get (table, i).Value = value) then
            return AWS.Parameters.Get (table, i).Name;
         end if;
      end loop;
      return "";
   end reverse_table_lookup;
  

   

   function makeInput
     (varname    : String;
      value      : Bounded_String;
      class      : String         := "";
      size       : Integer        := 12;
      extras     : String         := "";
      help       : String         := "";
      has_error  : Boolean        := False;
      error_text : Bounded_String := To_Bounded_String (""))
      return       String
   is
      s : Unbounded_String :=
         To_Unbounded_String
           ("<input type='text' size='" & format (size) & "' name='" & varname & "' ");
   begin
      if (class /= "") then
         s := s & "class='" & class & "' ";
      end if;
      if (extras /= "") then
         s := s & extras;
      end if;
      if (help /= "") then
         s := s & " alt='" & help & "' ";
      end if;
      s := s & " value='" & To_String (value) & "' ";
      s := s & " />";
      if (has_error) then
         s := s & "<br/>";
         s := s & "<span class='error'>" & To_String (error_text) & "</span>";
      end if;
      return To_String (s);
   end makeInput;

   function makeSelect
     (varname, selected : String;
      options           : OptionsStr;
      values            : OptionsStr;
      class             : String := "";
      extras            : String := "";
      help              : String := "")
      return              String
   is
      s : Unbounded_String := To_Unbounded_String ("<select" & " name='" & varname & "' ");
   begin
      if (class /= "") then
         s := s & "class='" & class & "' ";
      end if;
      if (extras /= "") then
         s := s & extras;
      end if;
      if (help /= "") then
         s := s & " alt='" & help & "' ";
      end if;

      s := s & ">";
      for i in  1 .. options'Length loop
         s := s & "<option ";
         if (To_Bounded_String (selected) = values (i)) then
            s := s & " selected = 'selected' ";
         end if;
         s := s &
              " value='" &
              To_String (values (i)) &
              "'>" &
              To_String (options (i)) &
              "</option>";
      end loop;
      s := s & "</select>";
      return To_String (s);
   end makeSelect;

   -- package Screen_Data_Session_Data is new AWS.Session.Generic_Data ( Inputs_Rec );

   function makeRadio
     (varname, selected : String;
      options           : OptionsStr;
      values            : OptionsStr;
      class             : String := "";
      extras            : String := "";
      help              : String := "")
      return              String
   is
      s : Unbounded_String := To_Unbounded_String ("");
   begin
      for i in  1 .. options'Length loop
         s := s & "<input type='radio' name='" & varname & "' ";
         if (class /= "") then
            s := s & "class='" & class & "' ";
         end if;
         if (extras /= "") then
            s := s & extras;
         end if;
         if (help /= "") then
            s := s & " alt='" & help & "' ";
         end if;
         if (selected = values (i)) then
            s := s & " default = 'default' ";
         end if;
         s := s & " value='" & To_String (values (i)) & "' />" & To_String (options (i));
         --  "</input>";
      end loop;
      return To_String (s);
   end makeRadio;

   function make_checkbox
     (varname : String;
      checked : Boolean;
      class   : String := "";
      extras  : String := "";
      help    : String := "")
      return    String
   is
      s : Unbounded_String := To_Unbounded_String ("");
   begin
      s := s & "<input type='checkbox' name='" & varname & "' ";
      if (class /= "") then
         s := s & "class='" & class & "' ";
      end if;
      if (extras /= "") then
         s := s & extras;
      end if;
      if (help /= "") then
         s := s & " alt='" & help & "' ";
      end if;
      if (checked) then
         s := s & " checked='checked' ";
      end if;
      s := s & " />";
      return To_String (s);
   end make_checkbox;
   --
   --   Does several (too many?) things at once:
   --   1) parses the value of paramString if paramString is true and sets value to that if
   --  there is no error
   --   2) makes an html input element, possibly with an attached error condition
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
      is_error     : in out Boolean)
   is

      valueStr : Bounded_String;
      class    : Bounded_String := To_Bounded_String ("normal_input");
      message  : Bounded_String := To_Bounded_String ("");
      x        : money          := 0.0;
   begin
      is_error := False;
      string_io.Put
        ("make one input varname=" &
         varname &
         " paramIsSet " &
         paramIsSet'Img &
         " paramString=" &
         paramString);
      if (paramIsSet) then
         format_utils.validate (paramString, x, message, min => min, max => max);

         valueStr := To_Bounded_String (paramString);
         if (message /= "") then
            class    := To_Bounded_String ("error_input");
            is_error := True;
         else
            value := x;
         end if;
      end if;
      if (not is_error) then
         if (value /= defaultValue) then
            class := To_Bounded_String ("changed_input");
         end if;
         valueStr := To_Bounded_String (format (value));
      end if;

      string_io.Put ("outputVarStr=" & To_String (valueStr));
      string_io.New_Line;
      outputStr :=
         To_Bounded_String
           (makeInput
               (varname    => varname,
                value      => valueStr,
                class      => To_String (class),
                help       => help,
                has_error  => is_error,
                error_text => message));

   end makeOneInput;

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
      min          : real    := -100.0;
      max          : real    := 100.0;
      isPercent    : Boolean := False;
      is_error     : in out Boolean)
   is

      valueStr : Bounded_String;
      class    : Bounded_String := To_Bounded_String ("normal_input");
      message  : Bounded_String := To_Bounded_String ("");
      x        : real           := 0.0;
   begin
      is_error := False;
      if (paramIsSet) then
         valueStr := To_Bounded_String (paramString);
         format_utils.validate (paramString, x, message, min => min, max => max);
         if (message /= "") then
            class    := To_Bounded_String ("error_input");
            is_error := True;
         else
            value := x;
            if (isPercent) then
               value := value / 100.0;
            end if;
         end if;
      end if;
      if (not is_error) then
         if (value /= defaultValue) then
            class := To_Bounded_String ("changed_input");
         end if;
         if (isPercent) then
            valueStr := To_Bounded_String (format (value * 100.0));
         else
            valueStr := To_Bounded_String (format (value));
         end if;
      end if;

      outputStr :=
         To_Bounded_String
           (makeInput
               (varname    => varname,
                value      => valueStr,
                class      => To_String (class),
                help       => help,
                has_error  => is_error,
                error_text => message));
   end makeOneInput;

   procedure makeOneInput
     (varname      : String;
      outputStr    : in out Bounded_String;
      value        : in out Integer;
      defaultValue : Integer;
      help         : String  := "";
      paramString  : String  := "";
      paramIsSet   : Boolean := False;
      min          : Integer := Integer'First;
      max          : Integer := Integer'Last;
      is_error     : in out Boolean)
   is

      valueStr : Bounded_String;
      class    : Bounded_String := To_Bounded_String ("normal_input");
      message  : Bounded_String := To_Bounded_String ("");
      x        : Integer        := 0;
   begin
      is_error := False;
      if (paramIsSet) then
         valueStr := To_Bounded_String (paramString);
         format_utils.validate (paramString, x, message, min => min, max => max);
         if (message /= "") then
            class    := To_Bounded_String ("error_input");
            is_error := True;
         else
            value := x;
         end if;
      end if;
      if (not is_error) then
         if (value /= defaultValue) then
            class := To_Bounded_String ("changed_input");
         end if;

         valueStr := To_Bounded_String (value'Img);
      end if;
      outputStr :=
         To_Bounded_String
           (makeInput
               (varname    => varname,
                value      => valueStr,
                class      => To_String (class),
                help       => help,
                has_error  => is_error,
                error_text => message));
   end makeOneInput;

   procedure makeOneStringInput
     (varname      : String;
      outputStr    : in out Bounded_String;
      value        : in out Bounded_String;
      defaultValue : Bounded_String := To_Bounded_String ("");
      help         : String         := "";
      paramString  : Bounded_String := To_Bounded_String ("");
      paramIsSet   : Boolean        := False;
      is_error     : in out Boolean;
      size         : Integer)
   is

      class   : Bounded_String := To_Bounded_String ("normal_input");
      message : Bounded_String := To_Bounded_String ("");
   begin
      is_error := False;
      if (paramIsSet) then
         value := paramString;
      end if;
      if (not is_error) then
         if (value /= defaultValue) then
            class := To_Bounded_String ("changed_input");
         end if;
      end if;
      outputStr :=
         To_Bounded_String
           (makeInput
               (varname    => varname,
                value      => value,
                class      => To_String (class),
                help       => help,
                has_error  => is_error,
                size       => size,
                error_text => message));
   end makeOneStringInput;

   procedure makeOneInput_Radio
     (varname      : String;
      outputStr    : in out Bounded_String;
      value        : in out Boolean;
      defaultValue : Boolean;
      option_names : OptionsStr := DEFAULT_BOOLEAN_LABELS;
      help         : String     := "";
      paramString  : String     := "";
      paramIsSet   : Boolean    := False)
   is

      class    : Bounded_String  := To_Bounded_String ("normal_input");
      selected : String (1 .. 1) := "1";
   begin
      if (paramIsSet) then
         if (paramString (1) = '1') then
            value := True;
         else
            value := False;
         end if;
      end if;
      if (value) then
         selected := "1";
      else
         selected := "0";
      end if;

      if (value /= defaultValue) then
         class := To_Bounded_String ("changed_input");
      end if;
      outputStr :=
         To_Bounded_String
           (makeRadio
               (varname  => varname,
                selected => selected,
                options  => option_names,
                values   => BOOLEAN_VALUES,
                class    => To_String (class),
                help     => help));
   end makeOneInput_Radio;

   procedure makeOneInput
     (varname      : String;
      outputStr    : in out Bounded_String;
      value        : in out Boolean;
      defaultValue : Boolean;
      option_names : OptionsStr := DEFAULT_BOOLEAN_LABELS;
      help         : String     := "";
      paramString  : String     := "";
      paramIsSet   : Boolean    := False;
      use_if_set   : Boolean    := False)
   is

      class : Bounded_String := To_Bounded_String ("normal_input");
   begin
      Text_IO.Put
        ("makeOneInput paramString = |" & paramString & "| paramIsSet = " & paramIsSet'Img);
      if (use_if_set) then
         value := paramIsSet; -- all we can test for is it's presence not its value.
      end if;
      Text_IO.Put ("got value as " & value'Img);
      if (value /= defaultValue) then
         class := To_Bounded_String ("changed_input");
      end if;
      outputStr :=
         To_Bounded_String
           (make_checkbox
               (varname => varname,
                checked => value,
                class   => To_String (class),
                help    => help));
   end makeOneInput;

   --  make_checkbox(
   --                  varname : String;
   --          	checked          : boolean;
   --          	class             : String := "";
   --                  extras            : String := "";
   --                  help              : String := "")

   procedure makeOneSelectBox
     (varname       : String;
      outputStr     : in out Bounded_String;
      value         : in out T;
      defaultValue  : T;
      option_names  : OptionsStr;
      option_values : OptionsStr;
      help          : String  := "";
      paramString   : String  := "";
      paramIsSet    : Boolean := False)
   is
      valstr : Bounded_String;
      class  : Bounded_String := To_Bounded_String ("normal_input");
   begin
      if (paramIsSet) then
         valstr := To_Bounded_String (paramString);
         for i in  T'First .. T'Last loop
            Text_IO.Put
              ("makeOneSelectBox; checking |" &
               T'Image (i) &
               "| against |" &
               To_String (valstr) &
               "| ");
            if (Trim (T'Image (i), Ada.Strings.Left) = valstr) then
               value := i;
               exit;
            end if;
         end loop;
      else
         valstr := To_Bounded_String (value'Img);
      end if;
      if (value /= defaultValue) then
         class := To_Bounded_String ("changed_input");
      end if;
      outputStr :=
         To_Bounded_String
           (makeSelect
               (varname,
                To_String (valstr),
                option_names,
                option_values,
                To_String (class),
                "",
                help));
   end makeOneSelectBox;

end html_utils;
