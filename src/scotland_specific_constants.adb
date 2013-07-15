package body scotland_specific_constants is

    use type Templates_Parser.Vector_Tag;

    function get_scottish_regional_stratifier_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Highland Grampian, Tayside";
       tag := tag & "Fife, Central, Lothian";
       tag := tag & "Glasgow";
       tag := tag & "Strathclyde ex Glasgow";
       tag := tag & "Borders, Dumfries & Galloway";
       tag := tag & "North of the Caledonian Canal";
       return tag;
    end get_scottish_regional_stratifier_template;

   --
   --  recode the stratifier to Grampian is 1
   --
   function get_int_value_of_stratifier( strat : Regional_Stratifier ) return integer is
   begin
      if ( strat < highland_grampian_tayside ) or ( strat = northern_ireland ) then
         return 0;
      end if;
      return 1 + Regional_Stratifier'Pos( strat ) - ( Regional_Stratifier'Pos( highland_grampian_tayside ));
   end get_int_value_of_stratifier;


end scotland_specific_constants;
