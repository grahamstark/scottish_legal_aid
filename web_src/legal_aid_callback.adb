--
--  $Author: graham_s $
--  $Date: 2007-03-26 13:45:57 +0100 (Mon, 26 Mar 2007) $
--  $Revision: 2422 $
--
with Templates_Parser;
with user;
with web_constants;
with legal_aid_runner;      use legal_aid_runner;
with base_model_types;      use base_model_types;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with AWS.Parameters;        use AWS.Parameters;
with AWS.Session;           use AWS.Session;
with html_utils;            use html_utils;
with la_parameters;         use la_parameters;
with model_household;       use model_household;
with Text_Utils;
with AWS.Log;               use AWS.Log;
with la_log;                use la_log;
with model_household;       use model_household;
with la_parameters;         use la_parameters;
with legal_aid_web_commons;  use legal_aid_web_commons;
with legal_aid_optimiser;
with format_utils;
with ada.strings.unbounded;
with run_settings; use run_settings;
with text_io;
with file_lister;
with Ada.Directories;
with FRS_Enums; use FRS_Enums;

pragma Elaborate_All( html_utils );

package body legal_aid_callback is

        use Text_Utils.StdBoundedString;

        uprate_amount : real := 0.0;
                --

        EXPENSES_LABELS : constant OptionsStr :=
               (To_Bounded_String ("Percentage"),
                To_Bounded_String ("Flat-Rate"));
        YESNO_LABELS    : constant OptionsStr :=
               (To_Bounded_String ("No"),
                To_Bounded_String ("Yes"));

        SYSTEM_VALUES : constant OptionsStr :=
          (To_Bounded_String ("DEFAULTNI"),
           To_Bounded_String ("DEFAULTENGLISH"),
           To_Bounded_String ("GREEN_FORM"),
           To_Bounded_String ("NI_PERSONAL_INJURY"),
           To_Bounded_String ("ABWOR" ),
           To_Bounded_String( "MAGISTRATES_COURT_CRIMINAL") );
        SYSTEM_NAMES : constant OptionsStr :=
          (To_Bounded_String ("Civil Legal Aid"),
           To_Bounded_String ("English Civil System"),
           To_Bounded_String ("Green Form"),
           To_Bounded_String ("NI Personal Injury"),
           To_Bounded_String ("ABWOR" ),
           To_Bounded_String ("Magistrates Court Criminal Cases" ));

        TARGET_NAMES : constant OptionsStr :=
          (To_Bounded_String ("Weighed Off Diagonal"),
           To_Bounded_String ("Squared Differences in Totals"),
           To_Bounded_String ("Targetting Differences") );
        TARGET_VALUES : constant OptionsStr :=
          (To_Bounded_String ("OFF_DIAGONAL_INDEX"),
           To_Bounded_String ("COSTS_INDEX"),
           To_Bounded_String ("TARGETTING_INDEX") );

        procedure intro_makeOneSelectBox is new html_utils.makeOneSelectBox( System_Type );
        procedure optimise_makeOneSelectBox is new html_utils.makeOneSelectBox( Target_Type );

        procedure  make_intro_translations_table(
                settings   : in out run_settings.Settings_Rec;
                params     : AWS.Parameters.List;
                trans      : in out LA_Translate_Table;
                has_errors : in out Boolean;
                username   : String;
                use_if_exists : boolean := true )
        is
                defaultSys  : constant Legal_Aid_Sys := Get_Default_System;
                outputStr   : Bounded_String       := To_Bounded_String ("");
                exists      : Boolean := true;
                paramString : Unbounded_String;
                is_in_error : Boolean              := False;
                tablePos    : LA_TABLE_SIZE        := 1;
        begin
--                 is ( defaultNI, defaultEnglish, green_form, ni_personal_injury, abwor ); --  and so on
--                settings.year;
--                settings.uprate_to_current;
--	                settings.systemType -- ( defaultNI, defaultEnglish, green_form, ni_personal_injury, abwor ); --  and so on
--		exists := Exist (params, "passport_benefits-constantattendance_allowance");
                exists := Exist (params, "uprate-to-current");

                html_utils.makeOneInput
                       (varname      => "uprate-to-current",
                        outputStr    => outputStr,
                        value        => settings.uprate_to_current,
                        defaultValue => true, -- always default to uprate
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "uprate-to-current"),
                        paramIsSet   => exists );

                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("uprate-to-current",
                                To_String (outputStr));
                exists := Exist (params, "run-type") and use_if_exists;
                intro_makeOneSelectBox(
                        varname   => "run-type",
                	outputStr => outputStr,
	                value     => settings.run_type,
	                defaultValue => civil,
	                option_names => SYSTEM_NAMES,
                	option_values => SYSTEM_VALUES,
	                help         => "",
	                paramString  => getStr (params, "run-type"),
	                paramIsSet   => exists);

                tablePos := tablePos + 1;
                trans (tablePos) :=
                          Templates_Parser.Assoc
                                 ("run-type",
                                  To_String (outputStr));

                --  targetting_weights
                --  off_diagonal_index, costs_index, targetting_index
                exists := Exist (params, "weights-disruption") and use_if_exists;
                html_utils.makeOneInput
                       (varname      => "weights-disruption",
                        outputStr    => outputStr,
                        value        => settings.targetting_weights( off_diagonal_index ),
                        defaultValue => 1.0/3.0,
                        help         => "",
                        paramString  => getStr (params, "weights-disruption"),
                        paramIsSet   => exists,
                        min          => 0.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("weights-disruption",
                                To_String (outputStr));

		----  targetting_weights
                --  off_diagonal_index, costs_index, targetting_index
                exists := Exist (params, "weights-cost") and use_if_exists;
                html_utils.makeOneInput
                       (varname      => "weights-cost",
                        outputStr    => outputStr,
                        value        => settings.targetting_weights( costs_index ),
                        defaultValue => 1.0/3.0,
                        help         => "",
                        paramString  => getStr (params, "weights-cost"),
                        paramIsSet   => exists,
                        min          => 0.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("weights-cost",
                                To_String (outputStr));

		text_io.put( "on entry; settings.split_benefit_units = "&settings.split_benefit_units'Img );
                exists := Exist (params, "split-bus") and use_if_exists;
                html_utils.makeOneInput
                       (varname      => "split-bus",
                        outputStr    => outputStr,
                        value        => settings.split_benefit_units,
                        defaultValue => false, -- always default to uprate
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "split-bus"),
                        paramIsSet   => exists );
		text_io.put( "on exit; settings.split_benefit_units = "&settings.split_benefit_units'Img );
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("split-bus",
                                To_String (outputStr));


                exists := Exist (params, "save-file-name") and use_if_exists;
                text_io.put( "save-file-name before input = " & to_string(settings.save_file_name));
                text_io.new_line;
                html_utils.makeOneStringInput ( "save-file-name",
                  	  outputStr    => outputStr,
                          value        => settings.save_file_name,
                          defaultValue => to_bounded_string(""),
                          paramString  => to_bounded_string(getStr (params, "save-file-name")),
                          paramIsSet   => exists,
                          size         => 50,
                          is_error     => is_in_error );
                tablePos         := tablePos + 1;
                text_io.put ( "save-file-name after input = " & to_string (settings.save_file_name));
                text_io.new_line;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("save-file-name",
                                To_String (outputStr));
                has_errors := has_errors or is_in_error;
		file_lister.make_parameter_file_list( web_constants.SERVER_ROOT, username, trans, tablePos );

        end make_intro_translations_table;


	--
        --
        --
        -- use_if_exists : parse the value from the input form if there is one - for checkboxes where there will be nothing eirther
        --    if unchecked OR if this is just displayinh the page at start, not from a form submission.
        procedure make_incomes_translations_table
               (lasys      : in out Legal_Aid_Sys;
                params     : AWS.Parameters.List;
                trans      : in out LA_Translate_Table;
                settings   : run_settings.Settings_Rec;
                has_errors : in out Boolean;
                use_if_exists : boolean )
        is
                defaultSys  : Legal_Aid_Sys;
                outputStr   : Bounded_String       := To_Bounded_String ("");
                exists      : Boolean;
                paramString : Unbounded_String;
                is_in_error : Boolean              := False;
                tablePos    : LA_TABLE_SIZE        := 1;
                ctype       : Claim_Type := normalClaim;
        begin
                trans (tablePos) :=
                        Templates_Parser.Assoc ("run-name", To_String ( settings.save_file_name ));
		tablePos := tablePos + 1;
                Write (logger, "make_main_translations_table: entered");
                --  base system, depending on
                --
                --

                legal_aid_runner.getBaseSystem ( settings, defaultSys, ctype );
                exists := Exist (params, "uprate-amount");
                html_utils.makeOneInput
                       (varname      => "uprate-amount",
                        outputStr    => outputStr,
                        value        => uprate_amount,
                        defaultValue => 0.0,
                        help         => "",
                        paramString  => getStr (params, "uprate-amount"),
                        paramIsSet   => exists,
                        min          => -100.0,
                        max          => 100.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("uprate-amount", To_String (outputStr));

                Write (logger, "added uprate value OK");

                --   ========= AUTOGENERATED STARTS =======
                exists := Exist (params, "lower_limit-income-ctype");
                html_utils.makeOneInput
                       (varname      => "lower_limit-income-ctype",
                        outputStr    => outputStr,
                        value        => lasys.lower_limit (income, ctype ),
                        defaultValue => defaultSys.lower_limit (income, ctype),
                        help         => "",
                        paramString  => getStr (params, "lower_limit-income-ctype"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("lower_limit-income-ctype",
                                To_String (outputStr));

                exists := Exist (params, "upper_limit-income-ctype");
                html_utils.makeOneInput
                       (varname      => "upper_limit-income-ctype",
                        outputStr    => outputStr,
                        value        => lasys.upper_limit (income, ctype),
                        defaultValue => defaultSys.upper_limit (income, ctype),
                        help         => "",
                        paramString  => getStr (params, "upper_limit-income-ctype"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("upper_limit-income-ctype",
                                To_String (outputStr));


		exists := Exist (params, "gross_IncomeLimit");
                html_utils.makeOneInput
                       (varname      => "gross_IncomeLimit",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomeLimit,
                        defaultValue => defaultSys.gross_IncomeLimit,
                        help         => "",
                        paramString  => getStr (params, "gross_IncomeLimit"),
                        paramIsSet   => exists,
                        min          => 0.0,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("gross_IncomeLimit", To_String (outputStr));


		exists := Exist (params, "gross_Income_lower_limit");
                html_utils.makeOneInput
                       (varname      => "gross_Income_lower_limit",
                        outputStr    => outputStr,
                        value        => lasys.gross_Income_lower_limit,
                        defaultValue => defaultSys.gross_Income_lower_limit,
                        help         => "",
                        paramString  => getStr (params, "gross_Income_lower_limit"),
                        paramIsSet   => exists,
                        min          => 0.0,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("gross_Income_lower_limit", To_String (outputStr));


                exists := Exist (params, "lower_limit-capital-ctype");
                html_utils.makeOneInput
                       (varname      => "lower_limit-capital-ctype",
                        outputStr    => outputStr,
                        value        => lasys.lower_limit (capital, ctype),
                        defaultValue => defaultSys.lower_limit (capital, ctype),
                        help         => "",
                        paramString  => getStr (params, "lower_limit-capital-ctype"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("lower_limit-capital-ctype",
                                To_String (outputStr));

                exists := Exist (params, "upper_limit-capital-ctype");
                html_utils.makeOneInput
                       (varname      => "upper_limit-capital-ctype",
                        outputStr    => outputStr,
                        value        => lasys.upper_limit (capital, ctype),
                        defaultValue => defaultSys.upper_limit (capital, ctype),
                        help         => "",
                        paramString  => getStr (params, "upper_limit-capital-ctype"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("upper_limit-capital-ctype",
                                To_String (outputStr));

                exists := Exist (params, "allow-income-child_age_limit-1");
                html_utils.makeOneInput
                       (varname      => "allow-income-child_age_limit-1",
                        outputStr    => outputStr,
                        value        => lasys.allow (income).child_age_limit (1),
                        defaultValue => defaultSys.allow (income).child_age_limit (1),
                        help         => "",
                        paramString  => getStr (params, "allow-income-child_age_limit-1"),
                        paramIsSet   => exists,
                        min          => 0,
                        max          => 999,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allow-income-child_age_limit-1",
                                To_String (outputStr));

                exists := Exist (params, "allow-income-child_age_limit-2");
                html_utils.makeOneInput
                       (varname      => "allow-income-child_age_limit-2",
                        outputStr    => outputStr,
                        value        => lasys.allow (income).child_age_limit (2),
                        defaultValue => defaultSys.allow (income).child_age_limit (2),
                        help         => "",
                        paramString  => getStr (params, "allow-income-child_age_limit-2"),
                        paramIsSet   => exists,
                        min          => 0,
                        max          => 999,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allow-income-child_age_limit-2",
                                To_String (outputStr));

                exists := Exist (params, "allow-income-child_age_limit-3");
                html_utils.makeOneInput
                       (varname      => "allow-income-child_age_limit-3",
                        outputStr    => outputStr,
                        value        => lasys.allow (income).child_age_limit (3),
                        defaultValue => defaultSys.allow (income).child_age_limit (3),
                        help         => "",
                        paramString  => getStr (params, "allow-income-child_age_limit-3"),
                        paramIsSet   => exists,
                        min          => 0,
                        max          => 999,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allow-income-child_age_limit-3",
                                To_String (outputStr));

                exists := Exist (params, "allow-income-child_allowance-1");
                html_utils.makeOneInput
                       (varname      => "allow-income-child_allowance-1",
                        outputStr    => outputStr,
                        value        => lasys.allow (income).child_allowance (1),
                        defaultValue => defaultSys.allow (income).child_allowance (1),
                        help         => "",
                        paramString  => getStr (params, "allow-income-child_allowance-1"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allow-income-child_allowance-1",
                                To_String (outputStr));

                exists := Exist (params, "allow-income-child_allowance-2");
                html_utils.makeOneInput
                       (varname      => "allow-income-child_allowance-2",
                        outputStr    => outputStr,
                        value        => lasys.allow (income).child_allowance (2),
                        defaultValue => defaultSys.allow (income).child_allowance (2),
                        help         => "",
                        paramString  => getStr (params, "allow-income-child_allowance-2"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allow-income-child_allowance-2",
                                To_String (outputStr));

                exists := Exist (params, "allow-income-child_allowance-3");
                html_utils.makeOneInput
                       (varname      => "allow-income-child_allowance-3",
                        outputStr    => outputStr,
                        value        => lasys.allow (income).child_allowance (3),
                        defaultValue => defaultSys.allow (income).child_allowance (3),
                        help         => "",
                        paramString  => getStr (params, "allow-income-child_allowance-3"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allow-income-child_allowance-3",
                                To_String (outputStr));

                exists := Exist (params, "allow-income-partners_allowance");
                html_utils.makeOneInput
                       (varname      => "allow-income-partners_allowance",
                        outputStr    => outputStr,
                        value        => lasys.allow (income).partners_allowance,
                        defaultValue => defaultSys.allow (income).partners_allowance,
                        help         => "",
                        paramString  => getStr (params, "allow-income-partners_allowance"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allow-income-partners_allowance",
                                To_String (outputStr));

                exists := Exist (params, "allow-income-other_dependants_allowance");
                html_utils.makeOneInput
                       (varname      => "allow-income-other_dependants_allowance",
                        outputStr    => outputStr,
                        value        => lasys.allow (income).other_dependants_allowance,
                        defaultValue => defaultSys.allow (income).other_dependants_allowance,
                        help         => "",
                        paramString  => getStr (params, "allow-income-other_dependants_allowance"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;

                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allow-income-other_dependants_allowance",
                                To_String (outputStr));

                exists := Exist (params, "allow-income-living-allowance");
                html_utils.makeOneInput
                       (varname      => "allow-income-living-allowance",
                        outputStr    => outputStr,
                        value        => lasys.allow (income).living_allowance,
                        defaultValue => defaultSys.allow (income).living_allowance,
                        help         => "",
                        paramString  => getStr (params, "allow-income-living-allowance"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allow-income-living-allowance",
                                To_String (outputStr));

                --  housing_equity_disregard

                exists := Exist (params, "housing-equity-disregard");
                Write (logger, "'housing-equity-disregard' exists in parameters " & exists'Img);
                html_utils.makeOneInput
                       (varname      => "housing-equity-disregard",
                        outputStr    => outputStr,
                        value        => lasys.housing_equity_disregard,
                        defaultValue => defaultSys.housing_equity_disregard,
                        help         => "",
                        paramString  => getStr (params, "housing-equity-disregard"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("housing-equity-disregard", To_String (outputStr));

                exists := Exist (params, "housing-equity-is-capital");
                html_utils.makeOneInput
                       (varname      => "housing-equity-is-capital",
                        outputStr    => outputStr,
                        value        => lasys.housing_equity_is_capital,
                        defaultValue => defaultSys.housing_equity_is_capital,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "housing-equity-is-capital"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing-equity-is-capital",
                               To_String (outputStr));
                exists := Exist (params, "equivalise-gross-income-limit");
                html_utils.makeOneInput
                       (varname      => "equivalise-gross-income-limit",
                        outputStr    => outputStr,
                        value        => laSys.equivalise_gross_income_limit,
                        defaultValue => false,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "equivalise-gross-income-limit"),
                        paramIsSet   => exists );

                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("equivalise-gross-income-limit",
                                To_String (outputStr));

                exists := Exist (params, "equivalise-incomes");
                html_utils.makeOneInput
                       (varname      => "equivalise-incomes",
                        outputStr    => outputStr,
                        value        => laSys.equivalise_incomes,
                        defaultValue => false,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "equivalise-incomes"),
                        paramIsSet   => exists );

                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("equivalise-incomes",
                                To_String (outputStr));

       end make_incomes_translations_table;



        procedure make_capital_translations_table
               (lasys      : in out Legal_Aid_Sys;
                params     : AWS.Parameters.List;
                trans      : in out LA_Translate_Table;
                settings   : run_settings.Settings_Rec;
                has_errors : in out Boolean;
                use_if_exists : boolean )
        is
                defaultSys  : Legal_Aid_Sys;
                outputStr   : Bounded_String       := To_Bounded_String ("");
                exists      : Boolean;
                paramString : Unbounded_String;
                is_in_error : Boolean              := False;
                tablePos    : LA_TABLE_SIZE        := 1;
                ctype       : Claim_Type := normalClaim;

                allowance_type_flag : integer              := 2;
        begin
                trans (tablePos) :=
                        Templates_Parser.Assoc ("run-name", To_String ( settings.save_file_name ));
		tablePos := tablePos + 1;
                Write (logger, "make_main_translations_table: entered");
                --  base system, depending on
                --
                --

                legal_aid_runner.getBaseSystem ( settings, defaultSys, ctype );
                exists := Exist (params, "uprate-amount");
                html_utils.makeOneInput
                       (varname      => "uprate-amount",
                        outputStr    => outputStr,
                        value        => uprate_amount,
                        defaultValue => 0.0,
                        help         => "",
                        paramString  => getStr (params, "uprate-amount"),
                        paramIsSet   => exists,
                        min          => -100.0,
                        max          => 100.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("uprate-amount", To_String (outputStr));

                Write (logger, "added uprate value OK");

                exists := Exist (params, "pensioner_age_limit-male");
                html_utils.makeOneInput
                       (varname      => "pensioner_age_limit-male",
                        outputStr    => outputStr,
                        value        => lasys.pensioner_age_limit (male),
                        defaultValue => defaultSys.pensioner_age_limit (male),
                        help         => "",
                        paramString  => getStr (params, "pensioner_age_limit-male"),
                        paramIsSet   => exists,
                        min          => 0,
                        max          => 100,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("pensioner_age_limit-male", To_String (outputStr));

                exists := Exist (params, "pensioner_age_limit-female");
                html_utils.makeOneInput
                       (varname      => "pensioner_age_limit-female",
                        outputStr    => outputStr,
                        value        => lasys.pensioner_age_limit (female),
                        defaultValue => defaultSys.pensioner_age_limit (female),
                        help         => "",
                        paramString  => getStr (params, "pensioner_age_limit-female"),
                        paramIsSet   => exists,
                        min          => 0,
                        max          => 100,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("pensioner_age_limit-female", To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-disregard1");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-disregard1",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).disregard (1),
                        defaultValue => defaultSys.capital_disregard (pensioner).disregard (1),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-disregard1"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-disregard1",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-incomeLimit1");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-incomeLimit1",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).incomeLimit (1),
                        defaultValue => defaultSys.capital_disregard (pensioner).incomeLimit (1),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-incomeLimit1"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-incomeLimit1",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-disregard2");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-disregard2",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).disregard (2),
                        defaultValue => defaultSys.capital_disregard (pensioner).disregard (2),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-disregard2"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-disregard2",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-incomeLimit2");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-incomeLimit2",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).incomeLimit (2),
                        defaultValue => defaultSys.capital_disregard (pensioner).incomeLimit (2),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-incomeLimit2"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-incomeLimit2",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-disregard3");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-disregard3",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).disregard (3),
                        defaultValue => defaultSys.capital_disregard (pensioner).disregard (3),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-disregard3"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-disregard3",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-incomeLimit3");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-incomeLimit3",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).incomeLimit (3),
                        defaultValue => defaultSys.capital_disregard (pensioner).incomeLimit (3),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-incomeLimit3"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-incomeLimit3",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-disregard4");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-disregard4",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).disregard (4),
                        defaultValue => defaultSys.capital_disregard (pensioner).disregard (4),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-disregard4"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-disregard4",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-incomeLimit4");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-incomeLimit4",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).incomeLimit (4),
                        defaultValue => defaultSys.capital_disregard (pensioner).incomeLimit (4),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-incomeLimit4"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-incomeLimit4",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-disregard5");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-disregard5",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).disregard (5),
                        defaultValue => defaultSys.capital_disregard (pensioner).disregard (5),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-disregard5"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-disregard5",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-incomeLimit5");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-incomeLimit5",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).incomeLimit (5),
                        defaultValue => defaultSys.capital_disregard (pensioner).incomeLimit (5),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-incomeLimit5"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-incomeLimit5",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-disregard6");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-disregard6",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).disregard (6),
                        defaultValue => defaultSys.capital_disregard (pensioner).disregard (6),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-disregard6"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-disregard6",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-incomeLimit6");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-incomeLimit6",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).incomeLimit (6),
                        defaultValue => defaultSys.capital_disregard (pensioner).incomeLimit (6),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-incomeLimit6"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-incomeLimit6",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-disregard7");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-disregard7",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).disregard (7),
                        defaultValue => defaultSys.capital_disregard (pensioner).disregard (7),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-disregard7"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-disregard7",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-incomeLimit7");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-incomeLimit7",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).incomeLimit (7),
                        defaultValue => defaultSys.capital_disregard (pensioner).incomeLimit (7),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-incomeLimit7"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-incomeLimit7",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-disregard8");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-disregard8",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).disregard (8),
                        defaultValue => defaultSys.capital_disregard (pensioner).disregard (8),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-disregard8"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-disregard8",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-incomeLimit8");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-incomeLimit8",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).incomeLimit (8),
                        defaultValue => defaultSys.capital_disregard (pensioner).incomeLimit (8),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-incomeLimit8"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-incomeLimit8",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-disregard9");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-disregard9",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).disregard (9),
                        defaultValue => defaultSys.capital_disregard (pensioner).disregard (9),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-disregard9"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-disregard9",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-incomeLimit9");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-incomeLimit9",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).incomeLimit (9),
                        defaultValue => defaultSys.capital_disregard (pensioner).incomeLimit (9),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-incomeLimit9"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-incomeLimit9",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-disregard10");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-disregard10",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).disregard (10),
                        defaultValue => defaultSys.capital_disregard (pensioner).disregard (10),
                        help         => "",
                        paramString  => getStr (params, "capital_disregard-pensioner-disregard10"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-disregard10",
                                To_String (outputStr));

                exists := Exist (params, "capital_disregard-pensioner-incomeLimit10");
                html_utils.makeOneInput
                       (varname      => "capital_disregard-pensioner-incomeLimit10",
                        outputStr    => outputStr,
                        value        => lasys.capital_disregard (pensioner).incomeLimit (10),
                        defaultValue => defaultSys.capital_disregard (pensioner).incomeLimit (10),
                        help         => "",
                        paramString  =>
                                getStr (params, "capital_disregard-pensioner-incomeLimit10"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital_disregard-pensioner-incomeLimit10",
                                To_String (outputStr));
                tablePos         := tablePos + 1;
                if ( (settings.run_type = green_form) or ( settings.run_type = abwor ))then
                        allowance_type_flag := 1;

                else
                        allowance_type_flag := 2;

                end if;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("capital-allowance-type-flag",
                                allowance_type_flag );
        end make_capital_translations_table;

        procedure make_contributions_translations_table
               (lasys      : in out Legal_Aid_Sys;
                params     : AWS.Parameters.List;
                trans      : in out LA_Translate_Table;
                settings   : run_settings.Settings_Rec;
                has_errors : in out Boolean;
                use_if_exists : boolean )
        is
                defaultSys  : Legal_Aid_Sys;
                outputStr   : Bounded_String       := To_Bounded_String ("");
                exists      : Boolean;
                paramString : Unbounded_String;
                is_in_error : Boolean              := False;
                tablePos    : LA_TABLE_SIZE        := 1;
                ctype       : Claim_Type := normalClaim;
        begin

        --   ========= AUTOGENERATED STARTS =======
                exists := Exist(params, "contributionsincome-contribution_proportion1");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_proportion1",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_proportion(1),
                        defaultValue => defaultSys.contributions(income).contribution_proportion(1),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_proportion1" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_proportion1",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_band1");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_band1",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_band(1),
                        defaultValue => defaultSys.contributions(income).contribution_band(1),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_band1" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_band1",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_proportion2");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_proportion2",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_proportion(2),
                        defaultValue => defaultSys.contributions(income).contribution_proportion(2),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_proportion2" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_proportion2",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_band2");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_band2",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_band(2),
                        defaultValue => defaultSys.contributions(income).contribution_band(2),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_band2" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_band2",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_proportion3");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_proportion3",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_proportion(3),
                        defaultValue => defaultSys.contributions(income).contribution_proportion(3),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_proportion3" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_proportion3",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_band3");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_band3",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_band(3),
                        defaultValue => defaultSys.contributions(income).contribution_band(3),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_band3" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_band3",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_proportion4");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_proportion4",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_proportion(4),
                        defaultValue => defaultSys.contributions(income).contribution_proportion(4),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_proportion4" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_proportion4",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_band4");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_band4",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_band(4),
                        defaultValue => defaultSys.contributions(income).contribution_band(4),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_band4" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_band4",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_proportion5");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_proportion5",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_proportion(5),
                        defaultValue => defaultSys.contributions(income).contribution_proportion(5),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_proportion5" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_proportion5",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_band5");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_band5",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_band(5),
                        defaultValue => defaultSys.contributions(income).contribution_band(5),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_band5" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_band5",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_proportion6");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_proportion6",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_proportion(6),
                        defaultValue => defaultSys.contributions(income).contribution_proportion(6),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_proportion6" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_proportion6",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_band6");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_band6",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_band(6),
                        defaultValue => defaultSys.contributions(income).contribution_band(6),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_band6" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_band6",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_proportion7");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_proportion7",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_proportion(7),
                        defaultValue => defaultSys.contributions(income).contribution_proportion(7),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_proportion7" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_proportion7",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_band7");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_band7",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_band(7),
                        defaultValue => defaultSys.contributions(income).contribution_band(7),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_band7" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_band7",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_proportion8");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_proportion8",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_proportion(8),
                        defaultValue => defaultSys.contributions(income).contribution_proportion(8),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_proportion8" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_proportion8",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_band8");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_band8",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_band(8),
                        defaultValue => defaultSys.contributions(income).contribution_band(8),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_band8" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_band8",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_proportion9");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_proportion9",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_proportion(9),
                        defaultValue => defaultSys.contributions(income).contribution_proportion(9),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_proportion9" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_proportion9",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_band9");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_band9",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_band(9),
                        defaultValue => defaultSys.contributions(income).contribution_band(9),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_band9" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_band9",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_proportion10");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_proportion10",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_proportion(10),
                        defaultValue => defaultSys.contributions(income).contribution_proportion(10),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_proportion10" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_proportion10",
                                 To_String (outputStr));


                exists := Exist(params, "contributionsincome-contribution_band10");
                html_utils.makeOneInput
                       (varname      => "contributionsincome-contribution_band10",
                        outputStr    => outputStr,
                        value        => lasys.contributions(income).contribution_band(10),
                        defaultValue => defaultSys.contributions(income).contribution_band(10),
                        help         => "",
                        paramString  => getStr( params, "contributionsincome-contribution_band10" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionsincome-contribution_band10",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_proportion1");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_proportion1",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_proportion(1),
                        defaultValue => defaultSys.contributions(capital).contribution_proportion(1),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_proportion1" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_proportion1",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_band1");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_band1",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_band(1),
                        defaultValue => defaultSys.contributions(capital).contribution_band(1),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_band1" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_band1",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_proportion2");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_proportion2",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_proportion(2),
                        defaultValue => defaultSys.contributions(capital).contribution_proportion(2),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_proportion2" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_proportion2",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_band2");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_band2",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_band(2),
                        defaultValue => defaultSys.contributions(capital).contribution_band(2),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_band2" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_band2",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_proportion3");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_proportion3",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_proportion(3),
                        defaultValue => defaultSys.contributions(capital).contribution_proportion(3),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_proportion3" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_proportion3",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_band3");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_band3",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_band(3),
                        defaultValue => defaultSys.contributions(capital).contribution_band(3),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_band3" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_band3",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_proportion4");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_proportion4",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_proportion(4),
                        defaultValue => defaultSys.contributions(capital).contribution_proportion(4),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_proportion4" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_proportion4",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_band4");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_band4",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_band(4),
                        defaultValue => defaultSys.contributions(capital).contribution_band(4),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_band4" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_band4",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_proportion5");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_proportion5",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_proportion(5),
                        defaultValue => defaultSys.contributions(capital).contribution_proportion(5),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_proportion5" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_proportion5",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_band5");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_band5",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_band(5),
                        defaultValue => defaultSys.contributions(capital).contribution_band(5),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_band5" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_band5",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_proportion6");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_proportion6",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_proportion(6),
                        defaultValue => defaultSys.contributions(capital).contribution_proportion(6),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_proportion6" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_proportion6",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_band6");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_band6",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_band(6),
                        defaultValue => defaultSys.contributions(capital).contribution_band(6),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_band6" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_band6",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_proportion7");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_proportion7",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_proportion(7),
                        defaultValue => defaultSys.contributions(capital).contribution_proportion(7),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_proportion7" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_proportion7",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_band7");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_band7",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_band(7),
                        defaultValue => defaultSys.contributions(capital).contribution_band(7),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_band7" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_band7",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_proportion8");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_proportion8",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_proportion(8),
                        defaultValue => defaultSys.contributions(capital).contribution_proportion(8),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_proportion8" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_proportion8",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_band8");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_band8",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_band(8),
                        defaultValue => defaultSys.contributions(capital).contribution_band(8),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_band8" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_band8",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_proportion9");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_proportion9",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_proportion(9),
                        defaultValue => defaultSys.contributions(capital).contribution_proportion(9),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_proportion9" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_proportion9",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_band9");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_band9",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_band(9),
                        defaultValue => defaultSys.contributions(capital).contribution_band(9),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_band9" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_band9",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_proportion10");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_proportion10",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_proportion(10),
                        defaultValue => defaultSys.contributions(capital).contribution_proportion(10),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_proportion10" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 1.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_proportion10",
                                 To_String (outputStr));


                exists := Exist(params, "contributionscapital-contribution_band10");
                html_utils.makeOneInput
                       (varname      => "contributionscapital-contribution_band10",
                        outputStr    => outputStr,
                        value        => lasys.contributions(capital).contribution_band(10),
                        defaultValue => defaultSys.contributions(capital).contribution_band(10),
                        help         => "",
                        paramString  => getStr( params, "contributionscapital-contribution_band10" ),
                        paramIsSet   => exists,
                        min => Money'First,
                        max => Money'Last,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("contributionscapital-contribution_band10",
                                 To_String (outputStr));



        --   ========= AUTOGENERATED ENDS =======

        end make_contributions_translations_table;

        procedure make_benefits_translations_table
               (lasys      : in out Legal_Aid_Sys;
                params     : AWS.Parameters.List;
                trans      : in out LA_Translate_Table;
                settings   : run_settings.Settings_Rec;
                has_errors : in out Boolean;
                use_if_exists : boolean )
        is
                defaultSys  : Legal_Aid_Sys;
                outputStr   : Bounded_String       := To_Bounded_String ("");
                exists      : Boolean;
                paramString : Unbounded_String;
                is_in_error : Boolean              := False;
                tablePos    : LA_TABLE_SIZE        := 1;
                ctype       : Claim_Type := normalClaim;
        begin

                trans (tablePos) :=
                        Templates_Parser.Assoc ("run-name", To_String ( settings.save_file_name ));
                tablePos := tablePos + 1;
                Write (logger, "make_main_translations_table: entered");
                --  base system, depending on
                --
                --

                legal_aid_runner.getBaseSystem ( settings, defaultSys, ctype );
                exists := Exist (params, "uprate-amount");
                html_utils.makeOneInput
                       (varname      => "uprate-amount",
                        outputStr    => outputStr,
                        value        => uprate_amount,
                        defaultValue => 0.0,
                        help         => "",
                        paramString  => getStr (params, "uprate-amount"),
                        paramIsSet   => exists,
                        min          => -100.0,
                        max          => 100.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("uprate-amount", To_String (outputStr));

                Write (logger, "added uprate value OK");

                exists := Exist (params, "incomesList-wages");
                html_utils.makeOneInput
                       (varname      => "incomesList-wages",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (wages),
                        defaultValue => defaultSys.incomesList (wages),
                        help         => "",
                        paramString  => getStr (params, "incomesList-wages"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("incomesList-wages", To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-wages");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-wages",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (wages),
                        defaultValue => defaultSys.gross_IncomesList (wages),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-wages"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("gross_IncomesList-wages", To_String (outputStr));

                exists := Exist (params, "incomesList-luncheon_vouchers");
                html_utils.makeOneInput
                       (varname      => "incomesList-luncheon_vouchers",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (luncheon_vouchers),
                        defaultValue => defaultSys.incomesList (luncheon_vouchers),
                        help         => "",
                        paramString  => getStr (params, "incomesList-luncheon_vouchers"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-luncheon_vouchers",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-luncheon_vouchers");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-luncheon_vouchers",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (luncheon_vouchers),
                        defaultValue => defaultSys.gross_IncomesList (luncheon_vouchers),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-luncheon_vouchers"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-luncheon_vouchers",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-self_employment");
                html_utils.makeOneInput
                       (varname      => "incomesList-self_employment",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (self_employment),
                        defaultValue => defaultSys.incomesList (self_employment),
                        help         => "",
                        paramString  => getStr (params, "incomesList-self_employment"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-self_employment",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-self_employment");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-self_employment",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (self_employment),
                        defaultValue => defaultSys.gross_IncomesList (self_employment),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-self_employment"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-self_employment",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-investment_income");
                html_utils.makeOneInput
                       (varname      => "incomesList-investment_income",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (investment_income),
                        defaultValue => defaultSys.incomesList (investment_income),
                        help         => "",
                        paramString  => getStr (params, "incomesList-investment_income"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-investment_income",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-investment_income");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-investment_income",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (investment_income),
                        defaultValue => defaultSys.gross_IncomesList (investment_income),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-investment_income"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-investment_income",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-pensions");
                html_utils.makeOneInput
                       (varname      => "incomesList-pensions",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (pensions),
                        defaultValue => defaultSys.incomesList (pensions),
                        help         => "",
                        paramString  => getStr (params, "incomesList-pensions"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("incomesList-pensions", To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-pensions");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-pensions",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (pensions),
                        defaultValue => defaultSys.gross_IncomesList (pensions),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-pensions"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-pensions",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-other_income");
                html_utils.makeOneInput
                       (varname      => "incomesList-other_income",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (other_Income),
                        defaultValue => defaultSys.incomesList (other_Income),
                        help         => "",
                        paramString  => getStr (params, "incomesList-other_income"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("incomesList-other_income", To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-other_income");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-other_income",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (other_Income),
                        defaultValue => defaultSys.gross_IncomesList (other_Income),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-other_income"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-other_income",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-income_tax");
                html_utils.makeOneInput
                       (varname      => "incomesList-income_tax",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (income_tax),
                        defaultValue => defaultSys.incomesList (income_tax),
                        help         => "",
                        paramString  => getStr (params, "incomesList-income_tax"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("incomesList-income_tax", To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-income_tax");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-income_tax",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (income_tax),
                        defaultValue => defaultSys.gross_IncomesList (income_tax),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-income_tax"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-income_tax",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-national_insurance");
                html_utils.makeOneInput
                       (varname      => "incomesList-national_insurance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (national_insurance),
                        defaultValue => defaultSys.incomesList (national_insurance),
                        help         => "",
                        paramString  => getStr (params, "incomesList-national_insurance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-national_insurance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-national_insurance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-national_insurance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (national_insurance),
                        defaultValue => defaultSys.gross_IncomesList (national_insurance),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-national_insurance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-national_insurance",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-disability_living_allowance");
                html_utils.makeOneInput
                       (varname      => "incomesList-disability_living_allowance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (disability_living_allowance),
                        defaultValue => defaultSys.incomesList (disability_living_allowance),
                        help         => "",
                        paramString  => getStr (params, "incomesList-disability_living_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-disability_living_allowance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-disability_living_allowance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-disability_living_allowance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (disability_living_allowance),
                        defaultValue => defaultSys.gross_IncomesList (disability_living_allowance),
                        help         => "",
                        paramString  =>
                                getStr (params, "gross_IncomesList-disability_living_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-disability_living_allowance",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-disability_living_allowance");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-disability_living_allowance",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (disability_living_allowance),
                        defaultValue => defaultSys.passport_benefits (disability_living_allowance),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "passport_benefits-disability_living_allowance"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-disability_living_allowance",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-attendance_allowance");
                html_utils.makeOneInput
                       (varname      => "incomesList-attendance_allowance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (attendance_allowance),
                        defaultValue => defaultSys.incomesList (attendance_allowance),
                        help         => "",
                        paramString  => getStr (params, "incomesList-attendance_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-attendance_allowance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-attendance_allowance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-attendance_allowance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (attendance_allowance),
                        defaultValue => defaultSys.gross_IncomesList (attendance_allowance),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-attendance_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-attendance_allowance",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-attendance_allowance");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-attendance_allowance",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (attendance_allowance),
                        defaultValue => defaultSys.passport_benefits (attendance_allowance),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-attendance_allowance"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-attendance_allowance",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-constantattendance_allowance");
                html_utils.makeOneInput
                       (varname      => "incomesList-constantattendance_allowance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (constantattendance_allowance),
                        defaultValue => defaultSys.incomesList (constantattendance_allowance),
                        help         => "",
                        paramString  => getStr (params, "incomesList-constantattendance_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-constantattendance_allowance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-constantattendance_allowance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-constantattendance_allowance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (constantattendance_allowance),
                        defaultValue => defaultSys.gross_IncomesList (constantattendance_allowance),
                        help         => "",
                        paramString  =>
                                getStr (params, "gross_IncomesList-constantattendance_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-constantattendance_allowance",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-constantattendance_allowance");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-constantattendance_allowance",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (constantattendance_allowance),
                        defaultValue => defaultSys.passport_benefits (constantattendance_allowance),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "passport_benefits-constantattendance_allowance"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-constantattendance_allowance",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-social_fund");
                html_utils.makeOneInput
                       (varname      => "incomesList-social_fund",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (social_fund),
                        defaultValue => defaultSys.incomesList (social_fund),
                        help         => "",
                        paramString  => getStr (params, "incomesList-social_fund"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("incomesList-social_fund", To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-social_fund");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-social_fund",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (social_fund),
                        defaultValue => defaultSys.gross_IncomesList (social_fund),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-social_fund"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-social_fund",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-social_fund");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-social_fund",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (social_fund),
                        defaultValue => defaultSys.passport_benefits (social_fund),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-social_fund"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-social_fund",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-child_benefit");
                html_utils.makeOneInput
                       (varname      => "incomesList-child_benefit",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (child_benefit),
                        defaultValue => defaultSys.incomesList (child_benefit),
                        help         => "",
                        paramString  => getStr (params, "incomesList-child_benefit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("incomesList-child_benefit", To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-child_benefit");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-child_benefit",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (child_benefit),
                        defaultValue => defaultSys.gross_IncomesList (child_benefit),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-child_benefit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-child_benefit",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-child_benefit");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-child_benefit",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (child_benefit),
                        defaultValue => defaultSys.passport_benefits (child_benefit),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-child_benefit"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-child_benefit",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-guaranteed_pension_credit");
                html_utils.makeOneInput
                       (varname      => "incomesList-guaranteed_pension_credit",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (guaranteed_pension_credit),
                        defaultValue => defaultSys.incomesList (guaranteed_pension_credit),
                        help         => "",
                        paramString  => getStr (params, "incomesList-guaranteed_pension_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-guaranteed_pension_credit",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-guaranteed_pension_credit");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-guaranteed_pension_credit",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (guaranteed_pension_credit),
                        defaultValue => defaultSys.gross_IncomesList (guaranteed_pension_credit),
                        help         => "",
                        paramString  =>
                                getStr (params, "gross_IncomesList-guaranteed_pension_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-guaranteed_pension_credit",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-guaranteed_pension_credit");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-guaranteed_pension_credit",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (guaranteed_pension_credit),
                        defaultValue => defaultSys.passport_benefits (guaranteed_pension_credit),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "passport_benefits-guaranteed_pension_credit"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-guaranteed_pension_credit",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-savings_pension_credit");
                html_utils.makeOneInput
                       (varname      => "incomesList-savings_pension_credit",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (savings_pension_credit),
                        defaultValue => defaultSys.incomesList (savings_pension_credit),
                        help         => "",
                        paramString  => getStr (params, "incomesList-savings_pension_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-savings_pension_credit",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-savings_pension_credit");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-savings_pension_credit",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (savings_pension_credit),
                        defaultValue => defaultSys.gross_IncomesList (savings_pension_credit),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-savings_pension_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-savings_pension_credit",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-savings_pension_credit");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-savings_pension_credit",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (savings_pension_credit),
                        defaultValue => defaultSys.passport_benefits (savings_pension_credit),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-savings_pension_credit"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-savings_pension_credit",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-retirement_pension");
                html_utils.makeOneInput
                       (varname      => "incomesList-retirement_pension",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (retirement_pension),
                        defaultValue => defaultSys.incomesList (retirement_pension),
                        help         => "",
                        paramString  => getStr (params, "incomesList-retirement_pension"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-retirement_pension",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-retirement_pension");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-retirement_pension",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (retirement_pension),
                        defaultValue => defaultSys.gross_IncomesList (retirement_pension),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-retirement_pension"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-retirement_pension",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-retirement_pension");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-retirement_pension",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (retirement_pension),
                        defaultValue => defaultSys.passport_benefits (retirement_pension),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-retirement_pension"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-retirement_pension",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-widows_pensions");
                html_utils.makeOneInput
                       (varname      => "incomesList-widows_pensions",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (widows_pensions),
                        defaultValue => defaultSys.incomesList (widows_pensions),
                        help         => "",
                        paramString  => getStr (params, "incomesList-widows_pensions"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-widows_pensions",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-widows_pensions");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-widows_pensions",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (widows_pensions),
                        defaultValue => defaultSys.gross_IncomesList (widows_pensions),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-widows_pensions"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-widows_pensions",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-widows_pensions");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-widows_pensions",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (widows_pensions),
                        defaultValue => defaultSys.passport_benefits (widows_pensions),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-widows_pensions"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-widows_pensions",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-income_support");
                html_utils.makeOneInput
                       (varname      => "incomesList-income_support",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (income_support),
                        defaultValue => defaultSys.incomesList (income_support),
                        help         => "",
                        paramString  => getStr (params, "incomesList-income_support"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-income_support",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-income_support");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-income_support",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (income_support),
                        defaultValue => defaultSys.gross_IncomesList (income_support),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-income_support"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-income_support",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-income_support");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-income_support",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (income_support),
                        defaultValue => defaultSys.passport_benefits (income_support),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-income_support"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-income_support",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-maternity_allowance");
                html_utils.makeOneInput
                       (varname      => "incomesList-maternity_allowance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (maternity_allowance),
                        defaultValue => defaultSys.incomesList (maternity_allowance),
                        help         => "",
                        paramString  => getStr (params, "incomesList-maternity_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-maternity_allowance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-maternity_allowance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-maternity_allowance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (maternity_allowance),
                        defaultValue => defaultSys.gross_IncomesList (maternity_allowance),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-maternity_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-maternity_allowance",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-maternity_allowance");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-maternity_allowance",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (maternity_allowance),
                        defaultValue => defaultSys.passport_benefits (maternity_allowance),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-maternity_allowance"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-maternity_allowance",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-widowed_mothers_allowance");
                html_utils.makeOneInput
                       (varname      => "incomesList-widowed_mothers_allowance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (widowed_mothers_allowance),
                        defaultValue => defaultSys.incomesList (widowed_mothers_allowance),
                        help         => "",
                        paramString  => getStr (params, "incomesList-widowed_mothers_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-widowed_mothers_allowance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-widowed_mothers_allowance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-widowed_mothers_allowance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (widowed_mothers_allowance),
                        defaultValue => defaultSys.gross_IncomesList (widowed_mothers_allowance),
                        help         => "",
                        paramString  =>
                                getStr (params, "gross_IncomesList-widowed_mothers_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-widowed_mothers_allowance",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-widowed_mothers_allowance");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-widowed_mothers_allowance",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (widowed_mothers_allowance),
                        defaultValue => defaultSys.passport_benefits (widowed_mothers_allowance),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "passport_benefits-widowed_mothers_allowance"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-widowed_mothers_allowance",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-war_disablement_pension");
                html_utils.makeOneInput
                       (varname      => "incomesList-war_disablement_pension",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (war_disablement_pension),
                        defaultValue => defaultSys.incomesList (war_disablement_pension),
                        help         => "",
                        paramString  => getStr (params, "incomesList-war_disablement_pension"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-war_disablement_pension",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-war_disablement_pension");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-war_disablement_pension",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (war_disablement_pension),
                        defaultValue => defaultSys.gross_IncomesList (war_disablement_pension),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-war_disablement_pension"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-war_disablement_pension",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-war_disablement_pension");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-war_disablement_pension",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (war_disablement_pension),
                        defaultValue => defaultSys.passport_benefits (war_disablement_pension),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-war_disablement_pension"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-war_disablement_pension",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-war_widow_pension");
                html_utils.makeOneInput
                       (varname      => "incomesList-war_widow_pension",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (war_widow_pension),
                        defaultValue => defaultSys.incomesList (war_widow_pension),
                        help         => "",
                        paramString  => getStr (params, "incomesList-war_widow_pension"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-war_widow_pension",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-war_widow_pension");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-war_widow_pension",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (war_widow_pension),
                        defaultValue => defaultSys.gross_IncomesList (war_widow_pension),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-war_widow_pension"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-war_widow_pension",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-war_widow_pension");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-war_widow_pension",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (war_widow_pension),
                        defaultValue => defaultSys.passport_benefits (war_widow_pension),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-war_widow_pension"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-war_widow_pension",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-severe_disability_allowance");
                html_utils.makeOneInput
                       (varname      => "incomesList-severe_disability_allowance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (severe_disability_allowance),
                        defaultValue => defaultSys.incomesList (severe_disability_allowance),
                        help         => "",
                        paramString  => getStr (params, "incomesList-severe_disability_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-severe_disability_allowance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-severe_disability_allowance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-severe_disability_allowance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (severe_disability_allowance),
                        defaultValue => defaultSys.gross_IncomesList (severe_disability_allowance),
                        help         => "",
                        paramString  =>
                                getStr (params, "gross_IncomesList-severe_disability_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-severe_disability_allowance",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-severe_disability_allowance");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-severe_disability_allowance",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (severe_disability_allowance),
                        defaultValue => defaultSys.passport_benefits (severe_disability_allowance),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "passport_benefits-severe_disability_allowance"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-severe_disability_allowance",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-disabled_persons_tax_credit");
                html_utils.makeOneInput
                       (varname      => "incomesList-disabled_persons_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (disabled_persons_tax_credit),
                        defaultValue => defaultSys.incomesList (disabled_persons_tax_credit),
                        help         => "",
                        paramString  => getStr (params, "incomesList-disabled_persons_tax_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-disabled_persons_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-disabled_persons_tax_credit");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-disabled_persons_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (disabled_persons_tax_credit),
                        defaultValue => defaultSys.gross_IncomesList (disabled_persons_tax_credit),
                        help         => "",
                        paramString  =>
                                getStr (params, "gross_IncomesList-disabled_persons_tax_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-disabled_persons_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-disabled_persons_tax_credit");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-disabled_persons_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (disabled_persons_tax_credit),
                        defaultValue => defaultSys.passport_benefits (disabled_persons_tax_credit),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "passport_benefits-disabled_persons_tax_credit"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-disabled_persons_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-invalid_care_allowance");
                html_utils.makeOneInput
                       (varname      => "incomesList-invalid_care_allowance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (invalid_care_allowance),
                        defaultValue => defaultSys.incomesList (invalid_care_allowance),
                        help         => "",
                        paramString  => getStr (params, "incomesList-invalid_care_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-invalid_care_allowance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-invalid_care_allowance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-invalid_care_allowance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (invalid_care_allowance),
                        defaultValue => defaultSys.gross_IncomesList (invalid_care_allowance),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-invalid_care_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-invalid_care_allowance",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-invalid_care_allowance");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-invalid_care_allowance",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (invalid_care_allowance),
                        defaultValue => defaultSys.passport_benefits (invalid_care_allowance),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-invalid_care_allowance"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-invalid_care_allowance",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-income_related_jobseekers_allowance");
                html_utils.makeOneInput
                       (varname      => "incomesList-income_related_jobseekers_allowance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (income_related_jobseekers_allowance),
                        defaultValue => defaultSys.incomesList (income_related_jobseekers_allowance),
                        help         => "",
                        paramString  =>
                                getStr (params, "incomesList-income_related_jobseekers_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-income_related_jobseekers_allowance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-income_related_jobseekers_allowance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-income_related_jobseekers_allowance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (income_related_jobseekers_allowance),
                        defaultValue =>
                               defaultSys.gross_IncomesList (income_related_jobseekers_allowance),
                        help         => "",
                        paramString  =>
                                getStr
                                       (params,
                                        "gross_IncomesList-income_related_jobseekers_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-income_related_jobseekers_allowance",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-income_related_jobseekers_allowance");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-income_related_jobseekers_allowance",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (income_related_jobseekers_allowance),
                        defaultValue =>
                               defaultSys.passport_benefits (income_related_jobseekers_allowance),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr
                                       (params,
                                        "passport_benefits-income_related_jobseekers_allowance"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-income_related_jobseekers_allowance",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-contributory_jobseekers_allowance");
                html_utils.makeOneInput
                       (varname      => "incomesList-contributory_jobseekers_allowance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (contributory_jobseekers_allowance),
                        defaultValue => defaultSys.incomesList (contributory_jobseekers_allowance),
                        help         => "",
                        paramString  =>
                                getStr (params, "incomesList-contributory_jobseekers_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-contributory_jobseekers_allowance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-contributory_jobseekers_allowance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-contributory_jobseekers_allowance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (contributory_jobseekers_allowance),
                        defaultValue =>
                               defaultSys.gross_IncomesList (contributory_jobseekers_allowance),
                        help         => "",
                        paramString  =>
                                getStr
                                       (params,
                                        "gross_IncomesList-contributory_jobseekers_allowance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-contributory_jobseekers_allowance",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-contributory_jobseekers_allowance");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-contributory_jobseekers_allowance",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (contributory_jobseekers_allowance),
                        defaultValue =>
                               defaultSys.passport_benefits (contributory_jobseekers_allowance),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr
                                       (params,
                                        "passport_benefits-contributory_jobseekers_allowance"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-contributory_jobseekers_allowance",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-industrial_injury_disablementBenefit");
                html_utils.makeOneInput
                       (varname      => "incomesList-industrial_injury_disablementBenefit",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (industrial_injury_disablementBenefit),
                        defaultValue =>
                               defaultSys.incomesList (industrial_injury_disablementBenefit),
                        help         => "",
                        paramString  =>
                                getStr (params, "incomesList-industrial_injury_disablementBenefit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-industrial_injury_disablementBenefit",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-industrial_injury_disablementBenefit");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-industrial_injury_disablementBenefit",
                        outputStr    => outputStr,
                        value        =>
                               lasys.gross_IncomesList (industrial_injury_disablementBenefit),
                        defaultValue =>
                               defaultSys.gross_IncomesList (industrial_injury_disablementBenefit),
                        help         => "",
                        paramString  =>
                                getStr
                                       (params,
                                        "gross_IncomesList-industrial_injury_disablementBenefit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-industrial_injury_disablementBenefit",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-industrial_injury_disablementBenefit");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-industrial_injury_disablementBenefit",
                        outputStr    => outputStr,
                        value        =>
                               lasys.passport_benefits (industrial_injury_disablementBenefit),
                        defaultValue =>
                               defaultSys.passport_benefits (industrial_injury_disablementBenefit),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr
                                       (params,
                                        "passport_benefits-industrial_injury_disablementBenefit"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-industrial_injury_disablementBenefit",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-incapacity_benefit");
                html_utils.makeOneInput
                       (varname      => "incomesList-incapacity_benefit",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (incapacity_benefit),
                        defaultValue => defaultSys.incomesList (incapacity_benefit),
                        help         => "",
                        paramString  => getStr (params, "incomesList-incapacity_benefit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-incapacity_benefit",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-incapacity_benefit");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-incapacity_benefit",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (incapacity_benefit),
                        defaultValue => defaultSys.gross_IncomesList (incapacity_benefit),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-incapacity_benefit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-incapacity_benefit",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-incapacity_benefit");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-incapacity_benefit",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (incapacity_benefit),
                        defaultValue => defaultSys.passport_benefits (incapacity_benefit),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-incapacity_benefit"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-incapacity_benefit",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-working_families_tax_credit");
                html_utils.makeOneInput
                       (varname      => "incomesList-working_families_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (working_families_tax_credit),
                        defaultValue => defaultSys.incomesList (working_families_tax_credit),
                        help         => "",
                        paramString  => getStr (params, "incomesList-working_families_tax_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-working_families_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-working_families_tax_credit");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-working_families_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (working_families_tax_credit),
                        defaultValue => defaultSys.gross_IncomesList (working_families_tax_credit),
                        help         => "",
                        paramString  =>
                                getStr (params, "gross_IncomesList-working_families_tax_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-working_families_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-working_families_tax_credit");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-working_families_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (working_families_tax_credit),
                        defaultValue => defaultSys.passport_benefits (working_families_tax_credit),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "passport_benefits-working_families_tax_credit"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-working_families_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-new_deal");
                html_utils.makeOneInput
                       (varname      => "incomesList-new_deal",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (new_deal),
                        defaultValue => defaultSys.incomesList (new_deal),
                        help         => "",
                        paramString  => getStr (params, "incomesList-new_deal"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("incomesList-new_deal", To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-new_deal");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-new_deal",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (new_deal),
                        defaultValue => defaultSys.gross_IncomesList (new_deal),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-new_deal"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("gross_IncomesList-new_deal", To_String (outputStr));

                exists := Exist (params, "passport_benefits-new_deal");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-new_deal",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (new_deal),
                        defaultValue => defaultSys.passport_benefits (new_deal),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-new_deal"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("passport_benefits-new_deal", To_String (outputStr));


                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-social_fundPayments",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-working_tax_credit");
                html_utils.makeOneInput
                       (varname      => "incomesList-working_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (working_tax_credit),
                        defaultValue => defaultSys.incomesList (working_tax_credit),
                        help         => "",
                        paramString  => getStr (params, "incomesList-working_tax_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-working_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-working_tax_credit");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-working_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (working_tax_credit),
                        defaultValue => defaultSys.gross_IncomesList (working_tax_credit),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-working_tax_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-working_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-working_tax_credit");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-working_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (working_tax_credit),
                        defaultValue => defaultSys.passport_benefits (working_tax_credit),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-working_tax_credit"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-working_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-child_tax_credit");
                html_utils.makeOneInput
                       (varname      => "incomesList-child_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (child_tax_credit),
                        defaultValue => defaultSys.incomesList (child_tax_credit),
                        help         => "",
                        paramString  => getStr (params, "incomesList-child_tax_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-child_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-child_tax_credit");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-child_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (child_tax_credit),
                        defaultValue => defaultSys.gross_IncomesList (child_tax_credit),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-child_tax_credit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-child_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-child_tax_credit");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-child_tax_credit",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (child_tax_credit),
                        defaultValue => defaultSys.passport_benefits (child_tax_credit),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-child_tax_credit"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-child_tax_credit",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-any_other_benefit");
                html_utils.makeOneInput
                       (varname      => "incomesList-any_other_benefit",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (any_other_benefit),
                        defaultValue => defaultSys.incomesList (any_other_benefit),
                        help         => "",
                        paramString  => getStr (params, "incomesList-any_other_benefit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-any_other_benefit",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-any_other_benefit");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-any_other_benefit",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (any_other_benefit),
                        defaultValue => defaultSys.gross_IncomesList (any_other_benefit),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-any_other_benefit"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-any_other_benefit",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-any_other_benefit");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-any_other_benefit",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (any_other_benefit),
                        defaultValue => defaultSys.passport_benefits (any_other_benefit),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-any_other_benefit"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-any_other_benefit",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-widows_payment");
                html_utils.makeOneInput
                       (varname      => "incomesList-widows_payment",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (widows_payment),
                        defaultValue => defaultSys.incomesList (widows_payment),
                        help         => "",
                        paramString  => getStr (params, "incomesList-widows_payment"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-widows_payment",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-widows_payment");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-widows_payment",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (widows_payment),
                        defaultValue => defaultSys.gross_IncomesList (widows_payment),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-widows_payment"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-widows_payment",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-widows_payment");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-widows_payment",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (widows_payment),
                        defaultValue => defaultSys.passport_benefits (widows_payment),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-widows_payment"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-widows_payment",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-unemployment_redundancy_insurance");
                html_utils.makeOneInput
                       (varname      => "incomesList-unemployment_redundancy_insurance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (unemployment_redundancy_insurance),
                        defaultValue => defaultSys.incomesList (unemployment_redundancy_insurance),
                        help         => "",
                        paramString  =>
                                getStr (params, "incomesList-unemployment_redundancy_insurance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-unemployment_redundancy_insurance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-unemployment_redundancy_insurance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-unemployment_redundancy_insurance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (unemployment_redundancy_insurance),
                        defaultValue =>
                               defaultSys.gross_IncomesList (unemployment_redundancy_insurance),
                        help         => "",
                        paramString  =>
                                getStr
                                       (params,
                                        "gross_IncomesList-unemployment_redundancy_insurance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-unemployment_redundancy_insurance",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-unemployment_redundancy_insurance");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-unemployment_redundancy_insurance",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (unemployment_redundancy_insurance),
                        defaultValue =>
                               defaultSys.passport_benefits (unemployment_redundancy_insurance),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr
                                       (params,
                                        "passport_benefits-unemployment_redundancy_insurance"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-unemployment_redundancy_insurance",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-winter_fuel_payments");
                html_utils.makeOneInput
                       (varname      => "incomesList-winter_fuel_payments",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (winter_fuel_payments),
                        defaultValue => defaultSys.incomesList (winter_fuel_payments),
                        help         => "",
                        paramString  => getStr (params, "incomesList-winter_fuel_payments"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-winter_fuel_payments",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-winter_fuel_payments");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-winter_fuel_payments",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (winter_fuel_payments),
                        defaultValue => defaultSys.gross_IncomesList (winter_fuel_payments),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-winter_fuel_payments"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-winter_fuel_payments",
                                To_String (outputStr));

                exists := Exist (params, "passport_benefits-winter_fuel_payments");
                html_utils.makeOneInput
                       (varname      => "passport_benefits-winter_fuel_payments",
                        outputStr    => outputStr,
                        value        => lasys.passport_benefits (winter_fuel_payments),
                        defaultValue => defaultSys.passport_benefits (winter_fuel_payments),
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "passport_benefits-winter_fuel_payments"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("passport_benefits-winter_fuel_payments",
                                To_String (outputStr));

                -- exists := Exist (params, "incomesList-council_tax_rebates");
                -- html_utils.makeOneInput
                       -- (varname      => "incomesList-council_tax_rebates",
                        -- outputStr    => outputStr,
                        -- value        => lasys.incomesList (council_tax_rebates),
                        -- defaultValue => defaultSys.incomesList (council_tax_rebates),
                        -- help         => "",
                        -- paramString  => getStr (params, "incomesList-council_tax_rebates"),
                        -- paramIsSet   => exists,
                        -- min          => -1.0,
                        -- max          => 1.0,
                        -- is_error     => is_in_error);
                -- has_errors       := has_errors or is_in_error;
                -- tablePos         := tablePos + 1;
                -- trans (tablePos) :=
                        -- Templates_Parser.Assoc ("incomesList-council_tax_rebates", To_String (outputStr));
--
                -- exists := Exist (params, "gross_IncomesList-council_tax_rebates");
                -- html_utils.makeOneInput
                       -- (varname      => "gross_IncomesList-council_tax_rebates",
                        -- outputStr    => outputStr,
                        -- value        => lasys.gross_IncomesList (council_tax_rebates),
                        -- defaultValue => defaultSys.gross_IncomesList (council_tax_rebates),
                        -- help         => "",
                        -- paramString  => getStr (params, "gross_IncomesList-council_tax_rebates"),
                        -- paramIsSet   => exists,
                        -- min          => -1.0,
                        -- max          => 1.0,
                        -- is_error     => is_in_error);
                -- has_errors       := has_errors or is_in_error;
                -- tablePos         := tablePos + 1;
                -- trans (tablePos) :=
                        -- Templates_Parser.Assoc
                               -- ("gross_IncomesList-council_tax_rebates",
                                -- To_String (outputStr));
--
                -- exists := Exist (params, "passport_benefits-council_tax_rebates");
                -- html_utils.makeOneInput
                       -- (varname      => "passport_benefits-council_tax_rebates",
                        -- outputStr    => outputStr,
                        -- value        => lasys.passport_benefits (council_tax_rebates),
                        -- defaultValue => defaultSys.passport_benefits (council_tax_rebates),
                        -- use_if_set     => use_if_exists,
                        -- help         => "",
                        -- paramString  => getStr (params, "passport_benefits-council_tax_rebates"),
                        -- paramIsSet   => exists);
                -- tablePos         := tablePos + 1;
                -- trans (tablePos) :=
                        -- Templates_Parser.Assoc
                               -- ("passport_benefits-council_tax_rebates",
                                -- To_String (outputStr));
--
                -- exists := Exist (params, "incomesList-council_tax_rebates");
                -- html_utils.makeOneInput
                       -- (varname      => "incomesList-council_tax_rebates",
                        -- outputStr    => outputStr,
                        -- value        => lasys.incomesList (council_tax_rebates),
                        -- defaultValue => defaultSys.incomesList (council_tax_rebates),
                        -- help         => "",
                        -- paramString  => getStr (params, "incomesList-council_tax_rebates"),
                        -- paramIsSet   => exists,
                        -- min          => -1.0,
                        -- max          => 1.0,
                        -- is_error     => is_in_error);
                -- has_errors       := has_errors or is_in_error;
                -- tablePos         := tablePos + 1;
                -- trans (tablePos) :=
                        -- Templates_Parser.Assoc ("incomesList-council_tax_rebates", To_String (outputStr));
--
                -- exists := Exist (params, "gross_IncomesList-council_tax_rebates");
                -- html_utils.makeOneInput
                       -- (varname      => "gross_IncomesList-council_tax_rebates",
                        -- outputStr    => outputStr,
                        -- value        => lasys.gross_IncomesList (council_tax_rebates),
                        -- defaultValue => defaultSys.gross_IncomesList (council_tax_rebates),
                        -- help         => "",
                        -- paramString  => getStr (params, "gross_IncomesList-council_tax_rebates"),
                        -- paramIsSet   => exists,
                        -- min          => -1.0,
                        -- max          => 1.0,
                        -- is_error     => is_in_error);
                -- has_errors       := has_errors or is_in_error;
                -- tablePos         := tablePos + 1;
                -- trans (tablePos) :=
                        -- Templates_Parser.Assoc
                               -- ("gross_IncomesList-council_tax_rebates",
                                -- To_String (outputStr));
--
                -- exists := Exist (params, "passport_benefits-council_tax_rebates");
                -- html_utils.makeOneInput
                       -- (varname      => "passport_benefits-council_tax_rebates",
                        -- outputStr    => outputStr,
                        -- value        => lasys.passport_benefits (council_tax_rebates),
                        -- defaultValue => defaultSys.passport_benefits (council_tax_rebates),
                        -- use_if_set     => use_if_exists,
                        -- help         => "",
                        -- paramString  => getStr (params, "passport_benefits-council_tax_rebates"),
                        -- paramIsSet   => exists);
                -- tablePos         := tablePos + 1;
                -- trans (tablePos) :=
                        -- Templates_Parser.Assoc
                               -- ("passport_benefits-council_tax_rebates",
                                -- To_String (outputStr));

                exists := Exist (params, "incomesList-trade_union");
                html_utils.makeOneInput
                       (varname      => "incomesList-trade_union",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (trade_union),
                        defaultValue => defaultSys.incomesList (trade_union),
                        help         => "",
                        paramString  => getStr (params, "incomesList-trade_union"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("incomesList-trade_union", To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-trade_union");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-trade_union",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (trade_union),
                        defaultValue => defaultSys.gross_IncomesList (trade_union),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-trade_union"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-trade_union",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-friendly_society_benefits");
                html_utils.makeOneInput
                       (varname      => "incomesList-friendly_society_benefits",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (friendly_society_benefits),
                        defaultValue => defaultSys.incomesList (friendly_society_benefits),
                        help         => "",
                        paramString  => getStr (params, "incomesList-friendly_society_benefits"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-friendly_society_benefits",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-friendly_society_benefits");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-friendly_society_benefits",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (friendly_society_benefits),
                        defaultValue => defaultSys.gross_IncomesList (friendly_society_benefits),
                        help         => "",
                        paramString  =>
                                getStr (params, "gross_IncomesList-friendly_society_benefits"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-friendly_society_benefits",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-private_sickness_scheme");
                html_utils.makeOneInput
                       (varname      => "incomesList-private_sickness_scheme",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (private_sickness_scheme),
                        defaultValue => defaultSys.incomesList (private_sickness_scheme),
                        help         => "",
                        paramString  => getStr (params, "incomesList-private_sickness_scheme"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-private_sickness_scheme",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-private_sickness_scheme");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-private_sickness_scheme",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (private_sickness_scheme),
                        defaultValue => defaultSys.gross_IncomesList (private_sickness_scheme),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-private_sickness_scheme"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-private_sickness_scheme",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-accident_insurance_scheme");
                html_utils.makeOneInput
                       (varname      => "incomesList-accident_insurance_scheme",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (accident_insurance_scheme),
                        defaultValue => defaultSys.incomesList (accident_insurance_scheme),
                        help         => "",
                        paramString  => getStr (params, "incomesList-accident_insurance_scheme"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-accident_insurance_scheme",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-accident_insurance_scheme");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-accident_insurance_scheme",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (accident_insurance_scheme),
                        defaultValue => defaultSys.gross_IncomesList (accident_insurance_scheme),
                        help         => "",
                        paramString  =>
                                getStr (params, "gross_IncomesList-accident_insurance_scheme"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-accident_insurance_scheme",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-hospital_savings_scheme");
                html_utils.makeOneInput
                       (varname      => "incomesList-hospital_savings_scheme",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (hospital_savings_scheme),
                        defaultValue => defaultSys.incomesList (hospital_savings_scheme),
                        help         => "",
                        paramString  => getStr (params, "incomesList-hospital_savings_scheme"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-hospital_savings_scheme",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-hospital_savings_scheme");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-hospital_savings_scheme",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (hospital_savings_scheme),
                        defaultValue => defaultSys.gross_IncomesList (hospital_savings_scheme),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-hospital_savings_scheme"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-hospital_savings_scheme",
                                To_String (outputStr));

                exists := Exist (params, "incomesList-health_insurance");
                html_utils.makeOneInput
                       (varname      => "incomesList-health_insurance",
                        outputStr    => outputStr,
                        value        => lasys.incomesList (health_insurance),
                        defaultValue => defaultSys.incomesList (health_insurance),
                        help         => "",
                        paramString  => getStr (params, "incomesList-health_insurance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("incomesList-health_insurance",
                                To_String (outputStr));

                exists := Exist (params, "gross_IncomesList-health_insurance");
                html_utils.makeOneInput
                       (varname      => "gross_IncomesList-health_insurance",
                        outputStr    => outputStr,
                        value        => lasys.gross_IncomesList (health_insurance),
                        defaultValue => defaultSys.gross_IncomesList (health_insurance),
                        help         => "",
                        paramString  => getStr (params, "gross_IncomesList-health_insurance"),
                        paramIsSet   => exists,
                        min          => -1.0,
                        max          => 1.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("gross_IncomesList-health_insurance",
                                To_String (outputStr));
  end make_benefits_translations_table;


  procedure make_expenses_translations_table
               (lasys      : in out Legal_Aid_Sys;
                params     : AWS.Parameters.List;
                trans      : in out LA_Translate_Table;
                settings   : run_settings.Settings_Rec;
                has_errors : in out Boolean;
                use_if_exists : boolean )
    is
                defaultSys  : Legal_Aid_Sys;
                outputStr   : Bounded_String       := To_Bounded_String ("");
                exists      : Boolean;
                paramString : Unbounded_String;
                is_in_error : Boolean              := False;
                tablePos    : LA_TABLE_SIZE        := 1;
                ctype       : Claim_Type := normalClaim;

                allowance_type_flag : integer              := 2;
    begin
                trans (tablePos) :=
                        Templates_Parser.Assoc ("run-name", To_String ( settings.save_file_name ));
		tablePos := tablePos + 1;
                Write (logger, "make_main_translations_table: entered");
                --  base system, depending on
                --
                --

                legal_aid_runner.getBaseSystem ( settings, defaultSys, ctype );
                exists := Exist (params, "uprate-amount");
                html_utils.makeOneInput
                       (varname      => "uprate-amount",
                        outputStr    => outputStr,
                        value        => uprate_amount,
                        defaultValue => 0.0,
                        help         => "",
                        paramString  => getStr (params, "uprate-amount"),
                        paramIsSet   => exists,
                        min          => -100.0,
                        max          => 100.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("uprate-amount", To_String (outputStr));

                Write (logger, "added uprate value OK");

                exists := Exist (params, "allowable_expenses-travel_expenses-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-travel_expenses-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (travel_expenses).is_flat,
                        defaultValue => defaultSys.allowable_expenses (travel_expenses).is_flat,
                        use_if_set     => use_if_exists,
                        -- option_names => EXPENSES_LABELS,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-travel_expenses-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-travel_expenses-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-travel_expenses-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-travel_expenses-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (travel_expenses).amount,
                        defaultValue => defaultSys.allowable_expenses (travel_expenses).amount,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-travel_expenses-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-travel_expenses-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-pension-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-pension-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (pension).is_flat,
                        defaultValue => defaultSys.allowable_expenses (pension).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-pension-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-pension-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-pension-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-pension-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (pension).amount,
                        defaultValue => defaultSys.allowable_expenses (pension).amount,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-pension-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-pension-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-avcs-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-avcs-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (avcs).is_flat,
                        defaultValue => defaultSys.allowable_expenses (avcs).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-avcs-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-avcs-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-avcs-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-avcs-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (avcs).amount,
                        defaultValue => defaultSys.allowable_expenses (avcs).amount,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-avcs-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-avcs-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-union_fees-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-union_fees-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (union_fees).is_flat,
                        defaultValue => defaultSys.allowable_expenses (union_fees).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-union_fees-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-union_fees-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-union_fees-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-union_fees-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (union_fees).amount,
                        defaultValue => defaultSys.allowable_expenses (union_fees).amount,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-union_fees-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-union_fees-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-childMinding-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-childMinding-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (childminding).is_flat,
                        defaultValue => defaultSys.allowable_expenses (childminding).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-childMinding-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-childMinding-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-childMinding-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-childMinding-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (childminding).amount,
                        defaultValue => defaultSys.allowable_expenses (childminding).amount,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-childMinding-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-childMinding-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-friendly_societies-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-friendly_societies-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (friendly_societies).is_flat,
                        defaultValue => defaultSys.allowable_expenses (friendly_societies).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-friendly_societies-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-friendly_societies-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-friendly_societies-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-friendly_societies-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (friendly_societies).amount,
                        defaultValue => defaultSys.allowable_expenses (friendly_societies).amount,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-friendly_societies-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-friendly_societies-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-sports-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-sports-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (sports).is_flat,
                        defaultValue => defaultSys.allowable_expenses (sports).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-sports-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-sports-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-sports-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-sports-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (sports).amount,
                        defaultValue => defaultSys.allowable_expenses (sports).amount,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-sports-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-sports-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-loan_repayments-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-loan_repayments-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (loan_repayments).is_flat,
                        defaultValue => defaultSys.allowable_expenses (loan_repayments).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-loan_repayments-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-loan_repayments-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-loan_repayments-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-loan_repayments-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (loan_repayments).amount,
                        defaultValue => defaultSys.allowable_expenses (loan_repayments).amount,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-loan_repayments-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-loan_repayments-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-medical_insurance-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-medical_insurance-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (medical_insurance).is_flat,
                        defaultValue => defaultSys.allowable_expenses (medical_insurance).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "allowable_expenses-medical_insurance-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-medical_insurance-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-medical_insurance-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-medical_insurance-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (medical_insurance).amount,
                        defaultValue => defaultSys.allowable_expenses (medical_insurance).amount,
                        help         => "",
                        paramString  =>
                                getStr (params, "allowable_expenses-medical_insurance-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-medical_insurance-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-charities-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-charities-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (charities).is_flat,
                        defaultValue => defaultSys.allowable_expenses (charities).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-charities-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-charities-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-charities-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-charities-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (charities).amount,
                        defaultValue => defaultSys.allowable_expenses (charities).amount,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-charities-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-charities-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-maintenance_payments-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-maintenance_payments-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (maintenance_payments).is_flat,
                        defaultValue => defaultSys.allowable_expenses (maintenance_payments).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "allowable_expenses-maintenance_payments-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-maintenance_payments-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-maintenance_payments-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-maintenance_payments-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (maintenance_payments).amount,
                        defaultValue => defaultSys.allowable_expenses (maintenance_payments).amount,
                        help         => "",
                        paramString  =>
                                getStr (params, "allowable_expenses-maintenance_payments-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-maintenance_payments-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-shared_rent-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-shared_rent-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (shared_rent).is_flat,
                        defaultValue => defaultSys.allowable_expenses (shared_rent).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-shared_rent-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-shared_rent-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-shared_rent-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-shared_rent-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (shared_rent).amount,
                        defaultValue => defaultSys.allowable_expenses (shared_rent).amount,
                        help         => "",
                        paramString  => getStr (params, "allowable_expenses-shared_rent-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-shared_rent-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-student_expenses-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-student_expenses-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (student_expenses).is_flat,
                        defaultValue => defaultSys.allowable_expenses (student_expenses).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "allowable_expenses-student_expenses-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-student_expenses-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_expenses-student_expenses-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_expenses-student_expenses-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_expenses (student_expenses).amount,
                        defaultValue => defaultSys.allowable_expenses (student_expenses).amount,
                        help         => "",
                        paramString  =>
                                getStr (params, "allowable_expenses-student_expenses-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_expenses-student_expenses-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_finance-loan_repayments-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_finance-loan_repayments-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_finance (loan_repayments).is_flat,
                        defaultValue => defaultSys.allowable_finance (loan_repayments).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "allowable_finance-loan_repayments-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_finance-loan_repayments-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_finance-loan_repayments-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_finance-loan_repayments-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_finance (loan_repayments).amount,
                        defaultValue => defaultSys.allowable_finance (loan_repayments).amount,
                        help         => "",
                        paramString  => getStr (params, "allowable_finance-loan_repayments-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_finance-loan_repayments-amount",
                                To_String (outputStr));

                exists := Exist (params, "allowable_finance-fines_and_transfers-is_flat");
                html_utils.makeOneInput
                       (varname      => "allowable_finance-fines_and_transfers-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.allowable_finance (fines_and_transfers).is_flat,
                        defaultValue => defaultSys.allowable_finance (fines_and_transfers).is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "allowable_finance-fines_and_transfers-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_finance-fines_and_transfers-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "allowable_finance-fines_and_transfers-amount");
                html_utils.makeOneInput
                       (varname      => "allowable_finance-fines_and_transfers-amount",
                        outputStr    => outputStr,
                        value        => lasys.allowable_finance (fines_and_transfers).amount,
                        defaultValue => defaultSys.allowable_finance (fines_and_transfers).amount,
                        help         => "",
                        paramString  =>
                                getStr (params, "allowable_finance-fines_and_transfers-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("allowable_finance-fines_and_transfers-amount",
                                To_String (outputStr));
        end make_expenses_translations_table;

        procedure make_housing_translations_table
               (lasys      : in out Legal_Aid_Sys;
                params     : AWS.Parameters.List;
                trans      : in out LA_Translate_Table;
                settings   : run_settings.Settings_Rec;
                has_errors : in out Boolean;
                use_if_exists : boolean )
        is
                defaultSys  : Legal_Aid_Sys;
                outputStr   : Bounded_String       := To_Bounded_String ("");
                exists      : Boolean;
                paramString : Unbounded_String;
                is_in_error : Boolean              := False;
                tablePos    : LA_TABLE_SIZE        := 1;
                ctype       : Claim_Type := normalClaim;

                allowance_type_flag : integer              := 2;
        begin
                trans (tablePos) :=
                        Templates_Parser.Assoc ("run-name", To_String ( settings.save_file_name ));
		tablePos := tablePos + 1;
                Write (logger, "make_main_translations_table: entered");
                --  base system, depending on
                --
                --

                legal_aid_runner.getBaseSystem ( settings, defaultSys, ctype );
                exists := Exist (params, "uprate-amount");
                html_utils.makeOneInput
                       (varname      => "uprate-amount",
                        outputStr    => outputStr,
                        value        => uprate_amount,
                        defaultValue => 0.0,
                        help         => "",
                        paramString  => getStr (params, "uprate-amount"),
                        paramIsSet   => exists,
                        min          => -100.0,
                        max          => 100.0,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                trans (tablePos) :=
                        Templates_Parser.Assoc ("uprate-amount", To_String (outputStr));

                Write (logger, "added uprate value OK");

                exists := Exist (params, "housing_allowances-mortgages-is_flat");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-mortgages-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.mortgages.is_flat,
                        defaultValue => defaultSys.housing_allowances.mortgages.is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-mortgages-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-mortgages-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-mortgages-amount");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-mortgages-amount",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.mortgages.amount,
                        defaultValue => defaultSys.housing_allowances.mortgages.amount,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-mortgages-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-mortgages-amount",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-council_tax-is_flat");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-council_tax-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.council_tax.is_flat,
                        defaultValue => defaultSys.housing_allowances.council_tax.is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-council_tax-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-council_tax-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-council_tax-amount");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-council_tax-amount",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.council_tax.amount,
                        defaultValue => defaultSys.housing_allowances.council_tax.amount,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-council_tax-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-council_tax-amount",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-water_rates-is_flat");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-water_rates-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.water_rates.is_flat,
                        defaultValue => defaultSys.housing_allowances.water_rates.is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-water_rates-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-water_rates-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-water_rates-amount");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-water_rates-amount",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.water_rates.amount,
                        defaultValue => defaultSys.housing_allowances.water_rates.amount,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-water_rates-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-water_rates-amount",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-ground_rent-is_flat");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-ground_rent-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.ground_rent.is_flat,
                        defaultValue => defaultSys.housing_allowances.ground_rent.is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-ground_rent-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-ground_rent-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-ground_rent-amount");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-ground_rent-amount",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.ground_rent.amount,
                        defaultValue => defaultSys.housing_allowances.ground_rent.amount,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-ground_rent-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-ground_rent-amount",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-service_charges-is_flat");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-service_charges-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.service_charges.is_flat,
                        defaultValue => defaultSys.housing_allowances.service_charges.is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-service_charges-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-service_charges-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-service_charges-amount");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-service_charges-amount",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.service_charges.amount,
                        defaultValue => defaultSys.housing_allowances.service_charges.amount,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-service_charges-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-service_charges-amount",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-repairs_and_insurance-is_flat");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-repairs_and_insurance-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.repairs_and_insurance.is_flat,
                        defaultValue => defaultSys.housing_allowances.repairs_and_insurance.is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  =>
                                getStr (params, "housing_allowances-repairs_and_insurance-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-repairs_and_insurance-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-repairs_and_insurance-amount");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-repairs_and_insurance-amount",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.repairs_and_insurance.amount,
                        defaultValue => defaultSys.housing_allowances.repairs_and_insurance.amount,
                        help         => "",
                        paramString  =>
                                getStr (params, "housing_allowances-repairs_and_insurance-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-repairs_and_insurance-amount",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-rent-is_flat");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-rent-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.rent.is_flat,
                        defaultValue => defaultSys.housing_allowances.rent.is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-rent-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-rent-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-rent-amount");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-rent-amount",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.rent.amount,
                        defaultValue => defaultSys.housing_allowances.rent.amount,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-rent-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-rent-amount",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-rent_rebates-is_flat");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-rent_rebates-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.rent_rebates.is_flat,
                        defaultValue => defaultSys.housing_allowances.rent_rebates.is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-rent_rebates-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-rent_rebates-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-rent_rebates-amount");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-rent_rebates-amount",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.rent_rebates.amount,
                        defaultValue => defaultSys.housing_allowances.rent_rebates.amount,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-rent_rebates-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-rent_rebates-amount",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-council_tax_rebates-is_flat");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-council_tax_rebates-is_flat",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.council_tax_rebates.is_flat,
                        defaultValue => defaultSys.housing_allowances.council_tax_rebates.is_flat,
                        use_if_set     => use_if_exists,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-council_tax_rebates-is_flat"),
                        paramIsSet   => exists);
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-council_tax_rebates-is_flat",
                                To_String (outputStr));

                exists := Exist (params, "housing_allowances-council_tax_rebates-amount");
                html_utils.makeOneInput
                       (varname      => "housing_allowances-council_tax_rebates-amount",
                        outputStr    => outputStr,
                        value        => lasys.housing_allowances.council_tax_rebates.amount,
                        defaultValue => defaultSys.housing_allowances.council_tax_rebates.amount,
                        help         => "",
                        paramString  => getStr (params, "housing_allowances-council_tax_rebates-amount"),
                        paramIsSet   => exists,
                        min          => real'First,
                        max          => real'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("housing_allowances-council_tax_rebates-amount",
                                To_String (outputStr));

                exists := Exist (params, "single_persons_housing_costs_max");
                html_utils.makeOneInput
                       (varname      => "single_persons_housing_costs_max",
                        outputStr    => outputStr,
                        value        => lasys.single_persons_housing_costs_max,
                        defaultValue => defaultSys.single_persons_housing_costs_max,
                        help         => "",
                        paramString  => getStr (params, "single_persons_housing_costs_max"),
                        paramIsSet   => exists,
                        min          => money'First,
                        max          => money'Last,
                        is_error     => is_in_error);
                has_errors       := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans (tablePos) :=
                        Templates_Parser.Assoc
                               ("single_persons_housing_costs_max",
                                To_String (outputStr));


                 exists := Exist(params, "allow-capital-dependent_allowances1");
                html_utils.makeOneInput
                       (varname      => "allow-capital-dependent_allowances1",
                        outputStr    => outputStr,
                        value        => lasys.allow( capital ).dependent_allowances(1),
                        defaultValue => defaultSys.allow( capital ).dependent_allowances(1),
                        help         => "",
                        paramString  => getStr( params, "allow-capital-dependent_allowances1" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 100_000.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("allow-capital-dependent_allowances1",
                                 To_String (outputStr));


                exists := Exist(params, "allow-capital-dependent_allowances2");
                html_utils.makeOneInput
                       (varname      => "allow-capital-dependent_allowances2",
                        outputStr    => outputStr,
                        value        => lasys.allow( capital ).dependent_allowances(2),
                        defaultValue => defaultSys.allow( capital ).dependent_allowances(2),
                        help         => "",
                        paramString  => getStr( params, "allow-capital-dependent_allowances2" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 100_000.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("allow-capital-dependent_allowances2",
                                 To_String (outputStr));


                exists := Exist(params, "allow-capital-dependent_allowances3");
                html_utils.makeOneInput
                       (varname      => "allow-capital-dependent_allowances3",
                        outputStr    => outputStr,
                        value        => lasys.allow( capital ).dependent_allowances(3),
                        defaultValue => defaultSys.allow( capital ).dependent_allowances(3),
                        help         => "",
                        paramString  => getStr( params, "allow-capital-dependent_allowances3" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 100_000.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("allow-capital-dependent_allowances3",
                                 To_String (outputStr));


                exists := Exist(params, "allow-capital-dependent_allowances4");
                html_utils.makeOneInput
                       (varname      => "allow-capital-dependent_allowances4",
                        outputStr    => outputStr,
                        value        => lasys.allow( capital ).dependent_allowances(4),
                        defaultValue => defaultSys.allow( capital ).dependent_allowances(4),
                        help         => "",
                        paramString  => getStr( params, "allow-capital-dependent_allowances4" ),
                        paramIsSet   => exists,
                        min => 0.0,
                        max => 100_000.0,
                        is_error => is_in_error );
                has_errors := has_errors or is_in_error;
                tablePos         := tablePos + 1;
                trans( tablePos ) :=
                        Templates_Parser.Assoc
                                ("allow-capital-dependent_allowances4",
                                 To_String (outputStr));

                --   ========= AUTOGENERATED ENDS =======
                --
                --   fill in remaining abwor/gf capital dependent's allowances
                --
                for i in 5..lasys.allow( capital ).dependent_allowances'Last loop
                        lasys.allow( capital ).dependent_allowances(i) := lasys.allow( capital ).dependent_allowances(4);
                end loop;

                Write (logger, "exiting make trans table; added " & tablePos'Img & " entries");
        end make_housing_translations_table;



        procedure make_main_translations_table
               (page       : String;
                lasys      : in out Legal_Aid_Sys;
                params     : AWS.Parameters.List;
                trans      : in out LA_Translate_Table;
                settings   : run_settings.Settings_Rec;
                has_errors : in out Boolean;
                use_if_exists : boolean )
        is
        begin
                Write (logger, "added uprate value OK");
                text_io.put( "page = " & getStr( params, "page" ));
                text_io.put( "make_main_translations_table entered " );
                if( ( page = "contributions" ) or Exist( params, "frm_contributions" )) then
                       text_io.put( "frm_contributions table started "  );
                       make_contributions_translations_table(
                        lasys, params, trans, settings, has_errors, use_if_exists );
                elsif( ( page = "income_limits" ) or Exist( params, "frm_incomes" ))then
                       text_io.put( "frm_incomes exists"  );

                      make_incomes_translations_table(
                        lasys, params, trans, settings, has_errors, use_if_exists );
                elsif( (page = "capital_disregards" ) or Exist( params, "frm_capital" ))then
                      make_capital_translations_table(
                        lasys, params, trans, settings, has_errors, use_if_exists );
                elsif( (page = "incomes_and_passporting" ) or Exist( params, "frm_benefits" ))then
                      make_benefits_translations_table(
                        lasys, params, trans, settings, has_errors, use_if_exists );
                elsif( (page = "allowable_expenses" ) or Exist( params, "frm_expenses" ))then
                      make_expenses_translations_table(
                        lasys, params, trans, settings, has_errors, use_if_exists );
                elsif( (page = "housing" ) or Exist( params, "frm_housing" )) then
                      make_housing_translations_table(
                        lasys, params, trans, settings, has_errors, use_if_exists );
                end if;

        end make_main_translations_table;

--        function make_default_translations return LA_Translate_Table is
--                trans : LA_Translate_Table;     --  ( LA_TABLE_SIZE ) := ( Others=>
--                                                --Templates_Parser.Null_Association );
--                lasys : Legal_Aid_Sys := Default_System;
--                params : AWS.Parameters.List;
--                has_error : Boolean := False;
--        begin
--                Write (logger, "make_default_translations: started ");
--                make_main_translations_table (page,
--                			      lasys,
--                                              params,
--                                              trans,
--                                              run_settings.DEFAULT_RUN_SETTINGS,
--                                              has_error, false );
--               return trans;
--        end make_default_translations;
--
        --
        --  Run our optimising routine & put a final table, a picture url and the final optimum pct
        --  into the session. The input system gets changed to the optimum one as a side-effect.
        --
        procedure run_optimise ( session_Id : AWS.Session.Id; settings : run_settings.Settings_Rec; laSys : in out Legal_Aid_Sys ) is
                extra_points     : legal_aid_optimiser.Points_Array;
                tables      : legal_aid_runner.Output_Tables;
                tmp_settings              : run_settings.Settings_Rec := settings;
                NUM_EXTRA_POINTS          : constant := 6;
                optim_output              : legal_aid_optimiser.Optimisation_Output;
                p : integer := 0;
        begin
                optim_output := legal_aid_optimiser.minimise ( laSys, settings ); -- , mult, error, points, num_points );
                write( logger, "run_optimise; got min as " & optim_output.multiplier'Img );
                text_io.put( "run_optimise; got min as " & optim_output.multiplier'Img );
                laSys := legal_aid_optimiser.change_limits_from_base ( optim_output.multiplier );
                tables := legal_aid_runner.doRun ( laSys, Image (session_ID), settings );
                --  FIXME: boundary checks on numpoints+i 6 to constant
                --  hack: extra pounts on the end so we can see a nice curve even if the
                --  optimiser doesn't need them.
                extra_points := legal_aid_optimiser.iterate ( laSys, tmp_settings, NUM_EXTRA_POINTS, 1.0, 1.0 );
                for i in 1 .. NUM_EXTRA_POINTS loop
                        p := optim_output.num_points+i;
                        text_io.put( "adding point " & p'Img );
                        optim_output.points(p) := extra_points(i);
                end loop;
                Table_Session_Data.set ( session_ID, "benefit_unit_table", tables( legal_aid_runner.benefit_unit ) );
                Table_Session_Data.set ( session_ID, "household_table", tables( legal_aid_runner.household ) );
                Table_Session_Data.set ( session_ID, "adult_table", tables( legal_aid_runner.adult ) );
                Table_Session_Data.set ( session_ID, "person_table", tables( legal_aid_runner.person ) );
                String_Session_Data.set( session_Id, "optimum_val", Session_String.to_bounded_string(format_utils.format(optim_output.multiplier*100.0)) );
                String_Session_Data.set ( session_Id, "url", Session_String.to_bounded_string (legal_aid_optimiser.data_To_URL ( optim_output.points, optim_output.num_points + NUM_EXTRA_POINTS )));
                Optimiser_Session_Data.set( session_Id, "optim_output", optim_output );
        end run_optimise;
        --
        -- this handles the inputs from any of the change parameter forms
        --
        function input_callback (request : in AWS.Status.Data) return AWS.Response.Data is
                --  pragma Unreferenced (Request);
                URI                      : constant String              :=
                        AWS.Status.URI (Request);
                username                 : constant String              :=
                        AWS.Status.Authorization_Name (Request);
                password                 : constant String              :=
                        AWS.Status.Authorization_Password (Request);
                this_user, existing_user : user.UserRec;

                params                   : constant AWS.Parameters.List :=
                        AWS.Status.Parameters (Request);
                null_params              : AWS.Parameters.List;
                session_ID               : constant AWS.Session.Id      :=
                        AWS.Status.Session (Request);
                laSys                    : Legal_Aid_Sys                  := Get_Default_System;
                translations             : LA_Translate_Table; --           :=
                      --  make_default_translations;
                output_translations      : LA_Translate_Table;

                --   Templates_Parser.Translate_Table( LA_TABLE_SIZE ) := ( Others=>
                --Templates_Parser.Null_Association );
                --   Templates_Parser.Translate_Table := Templates_Parser.No_translation; --
                --default_Templates_Parser.Translate_Table;
                has_errors : Boolean := False;
                change     : real;
                tables      : Legal_Aid_Runner.Output_Tables;
                settings   : run_settings.Settings_Rec;
                ctype      : Claim_Type := normalClaim;
                is_form_submission       : boolean  := Exist (params, "action"); -- FIXME 22/2 AND Action = 'Run' or 'Save'
                action : constant String := AWS.Parameters.Get (params, "action", 1);
                page   : constant String := AWS.Parameters.Get ( params, "page", 1 );

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


                Write (logger, "session ID is " & Image (session_ID));
                Write
                       (logger,
                        "initial value of lasys.allow( income ).child_age_limit( 1 ) " &
                        laSys.allow (income).child_age_limit (1)'Img);
                laSys := Parameters_Session_Data.Get (session_ID, "parameters");
                settings := Run_Settings_Session_Data.get ( session_ID, "run-settings" );
                --
                --  this is an ugly hack for when we've changed the base away for defaultNI on the intro page
                --
                if (( laSys = la_parameters.Get_Default_System )
                    and then ( settings /= run_settings.DEFAULT_RUN_SETTINGS )) then
			legal_aid_runner.getBaseSystem ( settings, laSys, ctype );
                end if;
                Write (logger, "got laSys from session ");
                -- translations := Translations_Session_Data.Get (session_ID, "translations");
                Write
                       (logger,
                        "value of lasys.allow( income ).child_age_limit( 1 ) after retrieval from session "
                        &
                        laSys.allow (income).child_age_limit (1)'Img);

                Write (logger, "got action as  " & action);
                if (action = "save") then
                        make_main_translations_table (page, laSys, params, translations, settings, has_errors, is_form_submission);
                elsif (action = "reset") then
                        laSys := Get_Default_System;
                        Write (logger, "resetting; to base ");
                        make_main_translations_table (page, laSys, null_params, translations, settings, has_errors, is_form_submission);
                elsif (action = "run") then
                        make_main_translations_table (page, laSys, params, translations, settings, has_errors, is_form_submission);
                        if (not has_errors) then
                                --
                                --  run the model and redirect to output page
                                --
                                settings := Run_Settings_Session_Data.get( session_ID, "run-settings" );
                                tables :=
                                    legal_aid_runner.doRun ( laSys, Image (session_ID), settings );
                                Table_Session_Data.set ( session_ID, "benefit_unit_table", tables( legal_aid_runner.benefit_unit ) );
                                Table_Session_Data.set ( session_ID, "household_table", tables( legal_aid_runner.household ) );
                                Table_Session_Data.set ( session_ID, "adult_table", tables( legal_aid_runner.adult ) );
                                Table_Session_Data.set ( session_ID, "person_table", tables( legal_aid_runner.person ) );
                                return AWS.Response.URL (Location => "/slab/output/?action=display&compare=totals");
                        end if;
                elsif (action = "optimise") then
                        make_main_translations_table (page, laSys, params, translations, settings, has_errors, is_form_submission);
                        if (not has_errors) then
                                --
                                --  run the model and redirect to output page
                                --
                                settings := Run_Settings_Session_Data.get ( session_ID, "run-settings" );

                                run_optimise ( session_Id, settings, laSys );
                                Parameters_Session_Data.Set (session_ID, "parameters", laSys);
                                return AWS.Response.URL (Location => "/slab/output/?action=optimise&compare=totals");
                        end if;
                --   run the model; redirect to main output page.
                elsif (action = "uprate") then
                        --  get pct uprate
                        --  uprate
                        -- call translations so everything is committed.
                        make_main_translations_table (page, laSys, params, translations, settings, has_errors, is_form_submission);
                        if (not has_errors) then
                                change := 1.0 + (uprate_amount / 100.0);
                                laSys  := uprate (laSys, change);
                                -- reset uprate so we don't uprate indefinitely
                                uprate_amount := 0.0;
                                is_form_submission := false;
                                make_main_translations_table
                                       (page,
                                        laSys,
                                        null_params,
                                        translations,
                                        settings,
                                        has_errors,
                                        is_form_submission );
                        end if;
                elsif (action = "english") then
                        --  get pct uprate
                        --  uprate
                        laSys := getEnglishSystem;
                        make_main_translations_table (page, laSys, null_params, translations, settings, has_errors, is_form_submission);
                else
                        make_main_translations_table (page, laSys, null_params, translations, settings, has_errors, is_form_submission );
                end if;
                -- Translations_Session_Data.set ( session_ID, "translations", translations );
                Parameters_Session_Data.Set (session_ID, "parameters", laSys);

                return buildInputPage( page, translations);
        end input_callback;

        procedure save_files ( settings : run_settings.Settings_Rec; laSys : Legal_Aid_Sys; username : String ) is
        begin
                if ( length (settings.save_file_name) > 0 )then
                        la_parameters.Binary_Write_Params ( file_lister.make_full_name( username, settings.save_file_name, "bpr"), laSys );
                        run_settings.Binary_Write_Settings( file_lister.make_full_name( username, settings.save_file_name, "set"), settings );
                end if;
        end save_files;

        procedure delete_files ( name : bounded_string; username : String ) is
        begin
                Ada.Directories.Delete_File ( file_lister.make_full_name( username, name, "bpr") );
                Ada.Directories.Delete_File( file_lister.make_full_name( username, name, "set") );
        end delete_files;


        procedure restore_files ( settings : in out run_settings.Settings_Rec; laSys : in out Legal_Aid_Sys; name : bounded_string; username : String ) is
        begin
                laSys := la_parameters.Binary_Read_Params ( file_lister.make_full_name( username, name, "bpr") );
                settings := run_settings.Binary_Read_Settings( file_lister.make_full_name( username, name, "set") );
        end restore_files;

        function intro_callback (request : in AWS.Status.Data) return AWS.Response.Data is
                params                   : constant AWS.Parameters.List :=
                        AWS.Status.Parameters (Request);
                URI                      : constant String         := AWS.Status.URI (request);
                username                 : constant String         :=
                        AWS.Status.Authorization_Name (request);
                password                 : constant String         :=
                        AWS.Status.Authorization_Password (request);
                this_user, existing_user : user.UserRec;
                translations             : LA_Translate_Table;
                session_ID               : constant AWS.Session.Id := AWS.Status.Session (request);
                settings,saved_settings  : run_settings.Settings_Rec;
                action                   : Unbounded_String;
                restore_target,delete_target      : Bounded_String;
                laSys                    : Legal_Aid_Sys;
                ctype                    : Claim_Type := normalClaim;
                has_errors               : boolean := false;
                is_form_submission       : constant boolean  := Exist (params, "action");
                --
                --  FIXME: there is a lot of redundancy here
                --
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
                action := To_Unbounded_String (AWS.Parameters.Get (params, "action", 1));

                settings := Run_Settings_Session_Data.get ( session_ID, "run-settings" );
                laSys := Parameters_Session_Data.get ( session_ID, "parameters" );

                restore_target := to_bounded_string (html_utils.reverse_table_lookup ( params, "restore" ));
                delete_target := to_bounded_string (html_utils.reverse_table_lookup ( params, "delete" ));
                text_io.put( "got restore target as " & to_string(restore_target) & " delete target as " & to_string(delete_target) );text_io.new_line;
                text_io.put( " got action as " & to_string(action) );text_io.new_line;
                saved_settings := settings;

                text_io.put ( "callback;; settings.split_benefit_units = " & settings.split_benefit_units'Img );
                text_io.new_line;

                make_intro_translations_table ( settings, params, translations, has_errors, username, is_form_submission );

                if ( action = "save" ) then
                        write( logger, "run type changed to " & settings.run_type'Img );
                        --
                        --  if we've changed anything in the run settings, we need to reload our parameters
                        --
			text_io.put( "save; exit; settings.split_benefit_units = "&settings.split_benefit_units'Img );
                        text_io.new_line;
                        Run_Settings_Session_Data.set ( session_ID, "run-settings", settings );
                elsif ( action = "store" ) then
	                text_io.put( "storing files under name " & to_string(settings.save_file_name ));text_io.new_line;
                        save_files ( settings, laSys, username );

                elsif ( restore_target /= "" ) then
                        restore_files ( settings, laSys, restore_target, username );
                        Run_Settings_Session_Data.set ( session_ID, "run-settings", settings );
                        Parameters_Session_Data.set ( session_ID, "parameters", laSys );

                elsif ( delete_target /= "" ) then
                        delete_files( delete_target, username );
                end if;
                --
                --   check if we've make enough changes to the settings to warrant
                --   reloading the parametes
                --
                if ( (saved_settings.uprate_to_current /= settings.uprate_to_current) or
                     (saved_settings.run_type  /= settings.run_type ) or
                      ( (( not saved_settings.uprate_to_current ) and
                         ( saved_settings.year /= settings.year )))
                   ) then
                                write( logger, "changing the base system to" & settings.run_type'Img );
                		legal_aid_runner.getBaseSystem ( settings, laSys, ctype );
                                Parameters_Session_Data.Set(session_ID, "parameters", laSys);
                                Run_Settings_Session_Data.set ( session_ID, "run-settings", settings );
                end if;
                --
                --   hack to run over 3 years for criminal cases
                --   This is particularly messy
                text_io.put( "intro_callback:: settings.run_type = " & settings.run_type'Img );
                if( settings.uprate_to_current ) then
                --   if( settings.run_type = magistrates_court_criminal ) then
                       text_io.put( "intro_callback:: setting years to 2002-2004 " );
                       settings.start_year := 2003;
                       settings.end_year := 2004;
                       Run_Settings_Session_Data.set ( session_ID, "run-settings", settings );
                       Parameters_Session_Data.Set(session_ID, "parameters", laSys);
                else
                       text_io.put( "intro_callback:: setting years to 2003-2003 " );
                       settings.start_year := settings.year;
                       settings.end_year := settings.year;
                end if;

                text_io.new_line;
                make_intro_translations_table ( settings, params, translations, has_errors, username, is_form_submission );
                return buildInputPage ("intro_page", translations);

        end intro_callback;

end legal_aid_callback;
