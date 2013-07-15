--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with la_parameters;         use la_parameters;
with legal_aid_web_commons; use legal_aid_web_commons;

--
--  FIXME: this is misnamed: it really generates a list of our parameters in
--  AWS Templates_Parser.Tag. format. The original version just generated the differences from base,
--  hence the name, but the current version can produce all of them, plus the params in CSV.
--
package differences_generator is

        --
        --  produce a LA_Translate_Table with elements for each of our paramerers
        --  under the names TITLE, PRE-VALUE and POST-VALUE. Each element is a
        --  Templates_Parser.Tag; these can be iterated over in the output template
        --  pages.
        --
        procedure make_differences_translations_table
               (defaultSys, laSys : Legal_Aid_Sys;
                trans             : in out LA_Translate_Table;
                ctype             : Claim_Type;
                insert_Start_Position : integer;
                print_all             : boolean := false );

        --  Write out all the parameters in comma- seperated values.
        --  lines need to be separated by DOS cr/lfs see: http://www.rfc-editor.org/rfc/rfc4180.txt
        --  And we have "s round the parameter labels.
        --
        function convert_parameters_to_csv ( defaultSys, laSys : Legal_Aid_Sys;
                                             ctype             : Claim_Type ) return String;


end differences_generator;
