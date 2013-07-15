--
--  $Author: graham_s $
--  $Date: 2007-11-13 15:53:36 +0000 (Tue, 13 Nov 2007) $
--  $Revision: 4318 $
--
with Templates_Parser;      use Templates_Parser;
with user;
with legal_aid_runner;      use legal_aid_runner;
with base_model_types;      use base_model_types;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with AWS.Parameters;        use AWS.Parameters;
with AWS.Session;           use AWS.Session;
with format_utils;
with la_parameters;         use la_parameters;
with legal_aid_runner;
with legal_aid_optimiser;
with example_hh_generator;
with AWS.Log;               use AWS.Log;
with la_log;                use la_log;
with la_parameters;         use la_parameters;
with legal_aid_web_commons; use legal_aid_web_commons;
with legal_aid_runner;
with differences_generator;
with format_utils;
with Ada.Strings.Unbounded;
with run_settings;
with html_utils;
with Text_Utils;
with Text_IO;
with model_household;
with file_lister;
with FRS_Enums;             use FRS_Enums;
with Scotland_Specific_Constants;

pragma Elaborate_All (html_utils);

package body legal_aid_output_callback is

   use Text_Utils.StdBoundedString;
   use FourFT2; -- we need this use for the " compare_type = "compare lines below, I think.

   BREAKDOWN_CLASSES : constant html_utils.OptionsStr :=
     (To_Bounded_String ("up"),
      To_Bounded_String ("down"),
      To_Bounded_String ("normal"));

   --  current_cell, row_total, col_total, total
   CELL_TYPE_NAMES : constant html_utils.OptionsStr :=
     (To_Bounded_String ("levels"),
      To_Bounded_String ("row totals"),
      To_Bounded_String ("column totals"),
      To_Bounded_String ("overall totals"));

   CELL_TYPE_VALUES : constant html_utils.OptionsStr :=
     (To_Bounded_String ("CURRENT_CELL"),
      To_Bounded_String ("ROW_TOTAL"),
      To_Bounded_String ("COL_TOTAL"),
      To_Bounded_String ("TOTAL"));

   CELL_CONTENTS_OP_NAMES  : constant html_utils.OptionsStr :=
     (To_Bounded_String ("Counter"),
      To_Bounded_String ("System 1 Level"),
      To_Bounded_String ("System 2 Level"),
      To_Bounded_String ("Absolute Change"),
      To_Bounded_String ("Percentage Change"));
   CELL_CONTENTS_OP_VALUES : constant html_utils.OptionsStr :=
     (To_Bounded_String ("COUNTER"),
      To_Bounded_String ("SYS1_LEVEL"),
      To_Bounded_String ("SYS2_LEVEL"),
      To_Bounded_String ("ABS_CHANGE"),
      To_Bounded_String ("PCT_CHANGE"));

   CELL_CONTENTS_NAMES  : constant html_utils.OptionsStr :=
     (To_Bounded_String ("Potential Offers"),
      To_Bounded_String ("Predicted Takeup"),
      To_Bounded_String ("Predicted Gross Costs"),
      To_Bounded_String ("Predicted Net Costs"),
      To_Bounded_String ("Predicted Contributions"),
      To_Bounded_String( "Expenses From Opponents" ),
      To_Bounded_String( "Amounts Awarded" ),
      To_Bounded_String( "Total Income" ),
      To_Bounded_String( "Total Income :DIVORCE" ),
      To_Bounded_String( "Total Income :RELATIONSHIPS" ),
      To_Bounded_String( "Total Income :PERSONAL_INJURY" ),
      To_Bounded_String( "Total Income :OTHER_PROBLEM" ),
      To_Bounded_String( "Total Income :PROCEDURES" ),
      To_Bounded_String( "Gross Costs :DIVORCE" ),
      To_Bounded_String( "Gross Costs :RELATIONSHIPS" ),
      To_Bounded_String( "Gross Costs :PERSONAL_INJURY" ),
      To_Bounded_String( "Gross Costs :OTHER_PROBLEM" ),
      To_Bounded_String( "Gross Costs :PROCEDURES" ));
      
   CELL_CONTENTS_VALUES : constant html_utils.OptionsStr :=
     (To_Bounded_String ("1"),
      To_Bounded_String ("2"),
      To_Bounded_String ("3"),
      To_Bounded_String ("4"),
      To_Bounded_String ("5"),
      To_Bounded_String ("6"),
      To_Bounded_String ("7"),
      To_Bounded_String ("8"),
      To_Bounded_String ("9"),
      To_Bounded_String ("10"),
      To_Bounded_String ("11"),
      To_Bounded_String ("12"),
      To_Bounded_String ("13"),
      To_Bounded_String ("14"),
      To_Bounded_String ("15"),
      To_Bounded_String ("16"),
      To_Bounded_String ("17"),
      To_Bounded_String ("18"));
   procedure compare_makeOneSelectBox is new html_utils.makeOneSelectBox (FourFT2.Compare_Cell);

   procedure cell_contents_op_makeOneSelectBox is new html_utils.makeOneSelectBox (
      FourFT2.Cell_Compare_Type);

   procedure cell_contents_makeOneSelectBox is new html_utils.makeOneSelectBox (
      FourFT2.Values_Range);

   procedure make_examples_translations_table
     (examples              : FourFT2.Examples_array;
      trans                 : in out LA_Translate_Table;
      insert_Start_Position : Integer)
   is
      example_num, year, hh_ref : Templates_Parser.Tag;
   begin
      for i in  1 .. legal_aid_runner.MAX_NUM_EXAMPLES loop
         if (examples (i) (1) /= FourFT2.NO_EXAMPLE) then
            example_num := example_num & format_utils.format (i);
            hh_ref      := hh_ref & format_utils.format (examples (i) (1));
            year        := year & format_utils.format (examples (i) (2));
         end if;
      end loop;
      trans (insert_Start_Position + 1) := Templates_Parser.Assoc ("EXAMPLE-NUM", example_num);
      trans (insert_Start_Position + 2) := Templates_Parser.Assoc ("HH-REF", hh_ref);
      trans (insert_Start_Position + 3) := Templates_Parser.Assoc ("DYEAR", year);
   end make_examples_translations_table;

   function make_breakdown_contents
     (m            : money;
      compare_type : FourFT2.Compare_Cell)
      return         String
   is
      outstr : Bounded_String := To_Bounded_String ("<span class='");
   begin
      if (compare_type = FourFT2.current_cell) then
         return format_utils.format_with_commas (m);
      end if;
      if (m > 3.0) then
         outstr := outstr & BREAKDOWN_CLASSES (1);
      elsif (m < -3.0) then
         outstr := outstr & BREAKDOWN_CLASSES (2);
      else
         outstr := outstr & BREAKDOWN_CLASSES (3);
      end if;
      outstr := outstr & "'>";
      outstr := outstr & format_utils.format (m);
      outstr := outstr & "</span>";
      return To_String (outstr);
   end make_breakdown_contents;

   procedure Example_Breakdown_To_Translate
     (params      : AWS.Parameters.List;
      laSys       : Legal_Aid_Sys;
      settings    : run_settings.Settings_Rec;
      trans       : in out LA_Translate_Table;
      num_entries : Integer)
   is
      row, col, hhref, year : Integer;
      output                : legal_aid_runner.Model_Outputs;
      mhh                   : model_household.Model_Household_Rec;
      insert_start_position : Integer := 0;
   begin
      row    := Integer'Value (getStr (params, "row"));
      col    := Integer'Value (getStr (params, "col"));
      hhref  := Integer'Value (getStr (params, "hhref"));
      year   := Integer'Value (getStr (params, "year"));
      mhh    := legal_aid_runner.get_one_model_household (settings, hhref, year);
      output := legal_aid_runner.do_one_household (laSys, settings, hhref, year);
      example_hh_generator.make_example_translations_table
        (mhh,
         output,
         trans,
         insert_start_position);
   end Example_Breakdown_To_Translate;

   function makeValuesTemplate
     (cell_breakdown : FourFT2.Breakdown_Array;
      n              : Integer;
      compare_type   : FourFT2.Compare_Cell)
      return           Templates_Parser.Tag
   is
      tag : Templates_Parser.Tag;
   begin
      for i in  1 .. n loop
         tag := tag & make_breakdown_contents (cell_breakdown (i), compare_type);
      end loop;
      return tag;
   end makeValuesTemplate;

   procedure Cell_Breakdown_To_Translate
     (params      : AWS.Parameters.List;
      f_table     : FourFT2.Table_Rec;
      trans       : in out LA_Translate_Table;
      num_entries : in out Integer)
   is
      row, col       : Integer;
      cell_breakdown : FourFT2.Cell_Contents;
      p              : Integer              := num_entries;
      compare_type   : FourFT2.Compare_Cell := FourFT2.current_cell;
      output_str     : Bounded_String       := To_Bounded_String ("");
   begin
      compare_makeOneSelectBox
        (varname       => "compare-type",
         outputStr     => output_str,
         value         => compare_type,
         defaultValue  => FourFT2.current_cell,
         option_names  => CELL_TYPE_NAMES,
         option_values => CELL_TYPE_VALUES,
         help          => "",
         paramString   => getStr (params, "compare-type"),
         paramIsSet    => True);
      Write (logger, "got compare type as " & compare_type'Img);
      Text_IO.Put ("got compare type as " & compare_type'Img);
      row := Integer'Value (getStr (params, "row"));
      col := Integer'Value (getStr (params, "col"));

      Write (logger, "got row as " & row'Img);
      Text_IO.Put ("got row as " & row'Img);
      Write (logger, "got col as " & col'Img);
      Text_IO.Put ("got col as " & col'Img);
      --        compare := FourFT2.Compare_Cell'Value ( AWS.Parameters.Get (params, "compare-type",
      --1));
      trans (p) := Templates_Parser.Assoc ("row", row);

      p         := p + 1;
      trans (p) := Templates_Parser.Assoc ("col", col);

      p         := p + 1;
      trans (p) := Templates_Parser.Assoc ("compare-type", To_String (output_str));

      if (compare_type /= FourFT2.current_cell) then
         cell_breakdown := FourFT2.get_breakdown_differences (f_table, row, col, compare_type);
      else
         cell_breakdown := FourFT2.get_cell_breakdown (f_table, row, col);
      end if;

      -- ethnic group
      -- 1
      p         := p + 1;
      trans (p) :=
         Templates_Parser.Assoc ("ethnic-labels", FRS_Enums.get_aggregated_ethnic_group_template);
      p         := p + 1;
      trans (p) :=
         Templates_Parser.Assoc
           ("ethnic-values",
            makeValuesTemplate
               (cell_breakdown (1),
                Aggregated_Ethnic_Group'Pos (Aggregated_Ethnic_Group'Last)+1,
                compare_type));
      p         := p + 1;

      trans (p) := Templates_Parser.Assoc ("gender-labels", FRS_Enums.get_gender_template);
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc
           ("gender-values",
            makeValuesTemplate (cell_breakdown (2), Gender'Pos (Gender'Last)+1, compare_type));
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc ("marital-status-labels", FRS_Enums.get_marital_status_template);
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc
           ("marital-status-values",
            makeValuesTemplate
               (cell_breakdown (3),
                Marital_Status'Pos (Marital_Status'Last)+1,
                compare_type));
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc ("tenure-type-labels", FRS_Enums.get_tenure_type_template);
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc
           ("tenure-type-values",
            makeValuesTemplate
               (cell_breakdown (4),
                Tenure_Type'Pos (Tenure_Type'Last)+1,
                compare_type));
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc
           ("benefit-unit-economic-status-labels",
            FRS_Enums.get_benefit_unit_economic_status_template);
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc
           ("benefit-unit-economic-status-values",
            makeValuesTemplate
               (cell_breakdown (5),
                Benefit_Unit_Economic_Status'Pos (Benefit_Unit_Economic_Status'Last)+1,
                compare_type));
      p         := p + 1;
      trans (p) :=
         Templates_Parser.Assoc
           ("hbai-benefit-unit-type-labels",
            FRS_Enums.get_hbai_benefit_unit_type_template);
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc
           ("hbai-benefit-unit-type-values",
            makeValuesTemplate
               (cell_breakdown (6),
                HBAI_Benefit_Unit_Type'Pos (HBAI_Benefit_Unit_Type'Last)+1,
                compare_type));
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc
           ("age-group-labels",
            FRS_Enums.get_age_group_template);
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc
           ("age-group-values",
            makeValuesTemplate
               (cell_breakdown (7),
                Age_Group'Pos (Age_Group'Last)+1,
                compare_type));
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc
           ("bu-disabled-indicator-labels",
            FRS_Enums.get_bu_disabled_indicator_template);
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc
           ("bu-disabled-indicator-values",
            makeValuesTemplate
               (cell_breakdown (9),
                FRS_Enums.BU_Disabled_Indicator'Pos (FRS_Enums.BU_Disabled_Indicator'Last)+1,
                compare_type));
      p         := p + 1;
      trans (p) :=
         Templates_Parser.Assoc
           ("regional-stratifier-labels",
            scotland_specific_constants.get_scottish_regional_stratifier_template);
      p         := p + 1;

      trans (p) :=
         Templates_Parser.Assoc
           ("regional-stratifier-values", -- can't automatically get the '7' value: careful
            makeValuesTemplate (cell_breakdown (11), 7, compare_type));
      p         := p + 1;

      --  add pointers to example households, but only for internal cells for now.
      if (row > 0) and (col > 0) then
         make_examples_translations_table (f_table.cells (row) (col).examples, trans, p);
         trans (p + 4) := Templates_Parser.Assoc ("has-examples", 1);
      else
         trans (p + 4) := Templates_Parser.Assoc ("has-examples", 0);
      end if;
      num_entries := p + 3;
   end Cell_Breakdown_To_Translate;

   procedure FourFT2_To_Translate
     (params      : AWS.Parameters.List;
      f_table     : FourFT2.Table_Rec;
      trans       : in out LA_Translate_Table;
      num_entries : in out Integer;
      run_name    : Bounded_String;
      settings    : run_settings.Settings_Rec)
   is
      comp_Cell     : Compare_Cell      := FourFT2.current_cell;
      row, col      : Integer;
      p             : Integer           := 4;
      cell, compare : money             := 1.0;
      basicTable    : FourFT2.Basic_Factor_Array;
      output_str    : Bounded_String    := To_Bounded_String ("");
      cell_op       : Cell_Compare_Type := counter;
      value_To_Use  : Integer           := 1;
   begin
      compare_makeOneSelectBox
        (varname       => "compare-type",
         outputStr     => output_str,
         value         => comp_Cell,
         defaultValue  => FourFT2.current_cell,
         option_names  => CELL_TYPE_NAMES,
         option_values => CELL_TYPE_VALUES,
         help          => "",
         paramString   => getStr (params, "compare-type"),
         paramIsSet    => True);

      Write (logger, "got compare type as " & comp_Cell'Img);
      Text_IO.Put ("got compare type as " & comp_Cell'Img);
      p         := p + 1;
      trans (p) := Templates_Parser.Assoc ("compare-type", To_String (output_str));

      cell_contents_op_makeOneSelectBox
        (varname       => "cell-contents-op",
         outputStr     => output_str,
         value         => cell_op,
         defaultValue  => FourFT2.counter,
         option_names  => CELL_CONTENTS_OP_NAMES,
         option_values => CELL_CONTENTS_OP_VALUES,
         help          => "",
         paramString   => getStr (params, "cell-contents-op"),
         paramIsSet    => True);
      p := p + 1;

      trans (p) := Templates_Parser.Assoc ("cell-contents-op", To_String (output_str));
      cell_contents_makeOneSelectBox
        (varname       => "cell-contents",
         outputStr     => output_str,
         value         => value_To_Use,
         defaultValue  => 1,
         option_names  => CELL_CONTENTS_NAMES,
         option_values => CELL_CONTENTS_VALUES,
         help          => "",
         paramString   => getStr (params, "cell-contents"),
         paramIsSet    => True);
       p         := p + 1;
      trans (p) := Templates_Parser.Assoc ("cell-contents", To_String (output_str));
      p         := p + 1;
      Text_IO.Put ("got value_to_use as " & value_To_Use'Img);
      Text_IO.New_Line;
      trans (p)  := Templates_Parser.Assoc ("dump", FourFT2.toCDA (f_table));
      compare    := 1.0;
      basicTable := FourFT2.expressTable (f_table, comp_Cell, cell_op, value_To_Use);
      Text_IO.Put ("basicTable(1,1)=" & basicTable (1, 1)'Img);
      for row in  1 .. 4 loop
         for col in  1 .. 4 loop
            p         := p + 1;
            trans (p) :=
               Templates_Parser.Assoc
                 ("cell-" & format_utils.format (row) & "-" & format_utils.format (col),
                  cell_str (basicTable (row, col), compare));
         end loop;
      end loop;
      for col in  1 .. 4 loop
         p         := p + 1;
         trans (p) :=
            Templates_Parser.Assoc
              ("coltot-" & format_utils.format (col),
               cell_str (basicTable (5, col), compare));

      end loop;
      for row in  1 .. 4 loop
         p         := p + 1;
         trans (p) :=
            Templates_Parser.Assoc
              ("rowtot-" & format_utils.format (row),
               cell_str (basicTable (row, 5), compare));
      end loop;
      p           := p + 1;
      trans (p)   := Templates_Parser.Assoc ("total", cell_str (basicTable (5, 5), compare));
      p           := p + 1;
      trans (p)   := Templates_Parser.Assoc ("run-name", To_String (run_name));
      num_entries := p;
   end FourFT2_To_Translate;

   package User_Session_Data is new AWS.Session.Generic_Data (user.UserRec, user.INVALID_USER);

   function dump_parameters
     (laSys, defaultSys : Legal_Aid_Sys;
      ctype             : Claim_Type;
      username, id      : String)
      return              AWS.Response.Data
   is
      outfile      : Text_IO.File_Type;
      outfile_name : Unbounded_String;
   begin
      outfile_name :=
         To_Unbounded_String
           (file_lister.make_full_name (username, To_Bounded_String (id) & "_parameters", "csv"));
      Text_IO.Create (outfile, Text_IO.Out_File, To_String (outfile_name));
      Text_IO.Put
        (outfile,
         differences_generator.convert_parameters_to_csv (defaultSys, laSys, ctype));
      Text_IO.Close (outfile);
      return AWS.Response.File
               (Content_Type  => "text/comma_separated-values",   -- FIXME rfc says text/csv but
                                                                  --that doesn't seem to work
                User_Filename => id & "_parameters.csv",
                Filename      => To_String (outfile_name),
                Disposition   => AWS.Response.Attachment);

   end dump_parameters;

   function output_callback (request : in AWS.Status.Data) return AWS.Response.Data is
      --  pragma Unreferenced (Request);
      URI                 : constant String              := AWS.Status.URI (Request);
      username            : constant String              :=
         AWS.Status.Authorization_Name (Request);
      password            : constant String              :=
         AWS.Status.Authorization_Password (Request);
      action              : Unbounded_String;
      session_ID          : constant AWS.Session.Id      := AWS.Status.Session (Request);
      laSys, defaultSys   : Legal_Aid_Sys;
      output_translations : LA_Translate_Table;
      params              : constant AWS.Parameters.List := AWS.Status.Parameters (Request);
      table               : FourFT2.Table_Rec;
      settings            : run_settings.Settings_Rec;
      ctype               : Claim_Type                   := normalClaim;
      url, optimum_val    : Session_String.Bounded_String;
      ubv                 : Unbounded_String;
      row, col            : Integer;
      compare             : FourFT2.Compare_Cell;
      num_entries         : Integer                      := 1;

      this_user, existing_user : user.UserRec;
      optim_output             : legal_aid_optimiser.Optimisation_Output;
   begin

      if (username = "") then
         return AWS.Response.Authenticate ("AWS", AWS.Response.Basic);
      end if;
      this_user := user.validate (username, password);
      if (not user.isValid (this_user)) then
         return AWS.Response.Authenticate ("AWS", AWS.Response.Basic);
      else
         --
         --  put the user record in the session
         --
         existing_user := User_Session_Data.Get (session_ID, "user");
         if (not user.isValid (existing_user)) then      --  not in session, so
                                                         --successful new login:
                                                         --user to session then
                                                         --redirect to welcome page
            User_Session_Data.Set (session_ID, "user", this_user);
            return AWS.Response.URL (Location => "/slab/intro_page.thtml");
         end if;
      end if;

      action   := To_Unbounded_String (AWS.Parameters.Get (params, "action", 1));
      table    := Table_Session_Data.Get (session_ID, "benefit_unit_table"); -- FIXME: make this selectable household- adult- person-
      settings := Run_Settings_Session_Data.Get (session_ID, "run-settings");
      Write (logger, "got settings back as " & run_settings.to_string (settings));
      laSys := Parameters_Session_Data.Get (session_ID, "parameters");
      legal_aid_runner.getBaseSystem (settings, defaultSys, ctype);

      if (action = "display") or (action = "redraw") or (action = "optimise") then
         FourFT2_To_Translate
           (params,
            f_table     => table,
            trans       => output_translations,
            num_entries => num_entries,
            run_name    => settings.save_file_name,
            settings    => settings);
         Write (logger, "building output page ");
         differences_generator.make_differences_translations_table
           (defaultSys,
            laSys,
            output_translations,
            ctype,
            1);
         if (action = "optimise") then

            url                                   := String_Session_Data.Get (session_ID, "url");
            output_translations (num_entries + 1) :=
               Templates_Parser.Assoc ("url", Session_String.To_String (url));
            output_translations (num_entries + 2) := Templates_Parser.Assoc ("optimise", 1);
            output_translations (num_entries + 3) :=
               Templates_Parser.Assoc
                 ("lower_optimum",
                  format_utils.format_with_commas (laSys.lower_limit (income, ctype)));
            output_translations (num_entries + 4) :=
               Templates_Parser.Assoc
                 ("upper_optimum",
                  format_utils.format_with_commas (laSys.upper_limit (income, ctype)));

            optimum_val                           :=
               String_Session_Data.Get (session_ID, "optimum_val");
            output_translations (num_entries + 5) :=
               Templates_Parser.Assoc ("optimum_val", Session_String.To_String (optimum_val));

            optim_output := Optimiser_Session_Data.Get (session_ID, "optim_output");

            --   , costs_index, targetting_index

            output_translations (num_entries + 6) :=
               Templates_Parser.Assoc
                 ("disruption",
                  format_utils.format
                     (optim_output.intermediates (run_settings.off_diagonal_index)));

            output_translations (num_entries + 7) :=
               Templates_Parser.Assoc
                 ("cost",
                  format_utils.format (optim_output.intermediates (run_settings.costs_index)));

            output_translations (num_entries + 8) :=
               Templates_Parser.Assoc
                 ("targetting",
                  format_utils.format (optim_output.intermediates (run_settings.targetting_index)));
            output_translations (num_entries + 9) :=
               Templates_Parser.Assoc ("error", format_utils.format (optim_output.error));
         end if;
         return buildInputPage ("output", output_translations);
      elsif (action = "breakdown") then
         Write (logger, "starting breakdown generation");
         Text_IO.Put ("starting breakdown generation");
         Cell_Breakdown_To_Translate (params, table, output_translations, num_entries);
         return buildInputPage ("breakdown", output_translations);
      elsif (action = "profile") then
         return AWS.Response.File
                  ("text/comma-separated-values", --  note rfc says 'text/csv'
                   Image (session_ID) & "__profiles.csv",

                   Disposition => AWS.Response.Attachment);
      elsif (action = "param_dump") then
         return dump_parameters (defaultSys, laSys, ctype, username, Image (session_ID));
      elsif (action = "example") then
         laSys := Parameters_Session_Data.Get (session_ID, "parameters");
         Example_Breakdown_To_Translate
           (params,
            laSys,
            settings,
            output_translations,
            num_entries);
         return buildInputPage ("example_hh", output_translations);
      end if;

   end output_callback;

end legal_aid_output_callback;
