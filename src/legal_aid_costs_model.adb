with model_household;use model_household;
with la_parameters; use la_parameters;
with model_output; use model_output;
with raw_frs;
with base_model_types; use base_model_types;
with text_io;
with criminal_legal_aid_costs_model;


package body legal_aid_costs_model is

        function getAgeRange ( age : integer ) return LA_Age_Range is
                arange : LA_Age_Range;
        begin
                if age < 16 then
                        arange := age_0_15;
                elsif age < 20 then
                        arange := age_16_19;
                elsif age < 30 then
                        arange := age_20_29;
                elsif age < 45 then
                        arange := age_30_44;
                elsif age < 60 then
                        arange := age_45_59;
                else
                        arange := age_60_plus;
                end if;
                return arange;
        end  getAgeRange;



        function Calculate_Costs ( takeup : raw_frs.Takeup_Estimates_Rec;
                                   latype : LA_Costs_System_Type ) return LA_Takeup_Array is
                costs : LA_Takeup_Array := ( others=>(others=>(others=>0.0)));
        begin
                case latype is
                when civil =>
                        costs ( latype, expected_takeup, divorce ) :=
                        	takeup.pdiv * ( takeup.cladivr /1000.0 ) ;
                        costs ( latype, expected_bills, divorce ) :=
                        	costs ( latype, expected_takeup, divorce ) * takeup.cladivt;
                        costs ( latype, expected_gross_costs, divorce ) :=
                        	costs ( latype, expected_bills, divorce ) * takeup.cladivb;

                        costs ( latype, expected_takeup, relationships ) :=
                        	takeup.pfam * ( takeup.clafamr /1000.0 ) ;
                        costs ( latype, expected_bills, relationships ) :=
                                costs( latype, expected_takeup, relationships ) * takeup.clafamt ;
                        costs ( latype, expected_gross_costs, relationships ) :=
                                costs ( latype, expected_bills, relationships )* takeup.clafamb ;
                                
                        costs ( latype, expected_takeup, other_problem ) :=
                                takeup.poth * ( takeup.claothr /1000.0 ) ;
                        costs ( latype, expected_bills, other_problem ) :=
                                costs ( latype, expected_takeup, other_problem ) * takeup.claotht ;
                        costs ( latype, expected_gross_costs, other_problem ) :=
                                costs ( latype, expected_bills, other_problem ) * takeup.claothb ;

                        costs ( latype, expected_takeup, criminal_justice ) :=
                                takeup.pcri * ( takeup.clacrir /1000.0 ) ;
                        costs ( latype, expected_bills, criminal_justice ) :=
                                costs ( latype, expected_takeup, criminal_justice ) * takeup.clacrit ;
                        costs ( latype, expected_gross_costs, criminal_justice ) :=
                                costs ( latype, expected_bills, criminal_justice ) * takeup.clacrib ;
                        costs ( latype, expected_takeup, misc_problems ) :=
                                takeup.pmisc * ( takeup.clamisr /1000.0 ) ;
                        costs ( latype, expected_bills, misc_problems ) :=
                                costs ( latype, expected_takeup, misc_problems ) * takeup.clamist ;
                        costs ( latype, expected_gross_costs, misc_problems ) :=
                                costs ( latype, expected_bills, misc_problems ) * takeup.clamisb ;

                when civil_pi =>
                        costs ( latype, expected_takeup, personal_injury ) :=  takeup.ppin  * ( takeup.clapinr /1000.0 ) ;
                        costs ( latype, expected_bills, personal_injury ) :=   costs ( latype, expected_takeup, personal_injury ) * takeup.clapint ;
                        costs ( latype, expected_gross_costs, personal_injury ) :=  costs ( latype, expected_bills, personal_injury ) * takeup.clapinb ;
                when ABWOR =>
                        costs ( latype, expected_takeup, divorce ) :=  takeup.pdiv  * ( takeup.abwdivr /1000.0 ) ;
                        costs ( latype, expected_bills, divorce ) :=   costs ( latype, expected_takeup, divorce ) * takeup.abwdivt ;
                        costs ( latype, expected_gross_costs, divorce ) :=  costs ( latype, expected_bills, divorce ) * takeup.abwdivb ;

                        costs ( latype, expected_takeup, relationships ) :=  takeup.pfam  * ( takeup.abwfamr /1000.0 ) ;
                        costs ( latype, expected_bills, relationships ) :=   costs ( latype, expected_takeup, relationships ) * takeup.abwfamt ;
                        costs ( latype, expected_gross_costs, relationships ) :=  costs ( latype, expected_bills, relationships ) * takeup.abwfamb ;

                        costs ( latype, expected_takeup, other_problem ) :=  takeup.poth  * ( takeup.abwothr /1000.0 ) ;
                        costs ( latype, expected_bills, other_problem ) :=   costs ( latype, expected_takeup, other_problem ) * takeup.abwotht ;
                        costs ( latype, expected_gross_costs, other_problem ) :=  costs ( latype, expected_bills, other_problem ) * takeup.abwothb ;

                        costs ( latype, expected_takeup, criminal_justice ) :=  takeup.pcri * ( takeup.abwcrir /1000.0 ) ;
                        costs ( latype, expected_bills, criminal_justice ) :=  costs ( latype, expected_takeup, criminal_justice ) * takeup.abwcrit ;
                        costs ( latype, expected_gross_costs, criminal_justice ) :=  costs ( latype, expected_bills, criminal_justice ) * takeup.abwcrib ;

                        costs ( latype, expected_takeup, misc_problems ) :=  takeup.pmisc * ( takeup.abwmisr /1000.0 ) ;
                        costs ( latype, expected_bills, misc_problems ) :=   costs ( latype, expected_takeup, misc_problems ) * takeup.abwmist ;
                        costs ( latype, expected_gross_costs, misc_problems ) :=  costs ( latype, expected_bills, misc_problems ) * takeup.abwmisb ;
                when green_form =>
                        costs ( latype, expected_takeup, divorce ) :=  takeup.pdiv * ( takeup.laadivr /1000.0 ) ;
                        costs ( latype, expected_bills, divorce ) :=   costs ( latype, expected_takeup, divorce ) * takeup.laadivt ;
                        costs ( latype, expected_gross_costs, divorce ) :=  costs ( latype, expected_bills, divorce ) * takeup.laadivb ;

                        costs ( latype, expected_takeup, relationships ) :=  takeup.pfam  * ( takeup.laafamr /1000.0 ) ;
                        costs ( latype, expected_bills, relationships ) :=  costs ( latype, expected_takeup, relationships ) * takeup.laafamt ;
                        costs ( latype, expected_gross_costs, relationships ) :=  costs ( latype, expected_bills, relationships ) * takeup.laafamb ;

                        costs ( latype, expected_takeup, other_problem ) :=  takeup.poth * ( takeup.laaothr /1000.0 ) ;
                        costs ( latype, expected_bills, other_problem ) :=   costs ( latype, expected_takeup, other_problem ) * takeup.laaotht ;
                        costs ( latype, expected_gross_costs, other_problem ) :=  costs ( latype, expected_bills, other_problem ) * takeup.laaothb ;

                        costs ( latype, expected_takeup, criminal_justice ) :=  takeup.pcri * ( takeup.laacrir /1000.0 ) ;
                        costs ( latype, expected_bills, criminal_justice ) :=   costs ( latype, expected_takeup, criminal_justice ) * takeup.laacrit ;
                        costs ( latype, expected_gross_costs, criminal_justice ) :=  costs ( latype, expected_bills, criminal_justice ) * takeup.laacrib ;

                        costs ( latype, expected_takeup, misc_problems ) :=  takeup.pmisc  * ( takeup.laamisr /1000.0 ) ;
                        costs ( latype, expected_bills, misc_problems ) :=  costs ( latype, expected_takeup, misc_problems ) * takeup.laamist ;
                        costs ( latype, expected_gross_costs, misc_problems ) :=  costs ( latype, expected_bills, misc_problems ) * takeup.abwmisb ;

                        costs ( latype, expected_takeup, personal_injury ) :=  takeup.ppin  * ( takeup.laapinr /1000.0 ) ;
                        costs ( latype, expected_bills, personal_injury ) :=  costs ( latype, expected_takeup, personal_injury ) * takeup.laapint ;
                        costs ( latype, expected_gross_costs, personal_injury ) :=  costs ( latype, expected_bills, personal_injury ) * takeup.laapinb ;
                when magistrates_court_criminal =>

                        costs ( latype, expected_takeup, divorce ) :=  takeup.pdiv * ( takeup.laadivr /1000.0 ) ;
                        costs ( latype, expected_bills, divorce ) :=   costs ( latype, expected_takeup, divorce ) * takeup.laadivt ;
                        costs ( latype, expected_gross_costs, divorce ) :=  costs ( latype, expected_bills, divorce ) * takeup.laadivb ;

                        costs ( latype, expected_takeup, relationships ) :=  takeup.pfam  * ( takeup.laafamr /1000.0 ) ;
                        costs ( latype, expected_bills, relationships ) :=  costs ( latype, expected_takeup, relationships ) * takeup.laafamt ;
                        costs ( latype, expected_gross_costs, relationships ) :=  costs ( latype, expected_bills, relationships ) * takeup.laafamb ;

                        costs ( latype, expected_takeup, other_problem ) :=  takeup.poth * ( takeup.laaothr /1000.0 ) ;
                        costs ( latype, expected_bills, other_problem ) :=   costs ( latype, expected_takeup, other_problem ) * takeup.laaotht ;
                        costs ( latype, expected_gross_costs, other_problem ) :=  costs ( latype, expected_bills, other_problem ) * takeup.laaothb ;

                        costs ( latype, expected_takeup, criminal_justice ) :=  takeup.pcri * ( takeup.laacrir /1000.0 ) ;
                        costs ( latype, expected_bills, criminal_justice ) :=   costs ( latype, expected_takeup, criminal_justice ) * takeup.laacrit ;
                        costs ( latype, expected_gross_costs, criminal_justice ) :=  costs ( latype, expected_bills, criminal_justice ) * takeup.laacrib ;

                        costs ( latype, expected_takeup, misc_problems ) :=  takeup.pmisc  * ( takeup.laamisr /1000.0 ) ;
                        costs ( latype, expected_bills, misc_problems ) :=  costs ( latype, expected_takeup, misc_problems ) * takeup.laamist ;
                        costs ( latype, expected_gross_costs, misc_problems ) :=  costs ( latype, expected_bills, misc_problems ) * takeup.abwmisb ;

                        costs ( latype, expected_takeup, personal_injury ) :=  takeup.ppin  * ( takeup.laapinr /1000.0 ) ;
                        costs ( latype, expected_bills, personal_injury ) :=  costs ( latype, expected_takeup, personal_injury ) * takeup.laapint ;
                        costs ( latype, expected_gross_costs, personal_injury ) :=  costs ( latype, expected_bills, personal_injury ) * takeup.laapinb ;
                end case;
                --
                --  total costs and claims
                --
                for cmp in LA_Costs_Component loop
                        for pt in divorce .. misc_problems loop
                                costs( latype, cmp, all_problems ) := costs( latype, cmp, all_problems ) +
                                        costs( latype, cmp, pt );
                        end loop;
                end loop;
                text_io.put ( "CalculateCosts; costs ( latype, expected_takeup, all_problems ) = " &
                             costs ( latype, expected_takeup, all_problems )'Img );
                text_io.put ( "costs ( latype, expected_gross_costs, all_problems ) = " &
                             costs ( latype, expected_gross_costs, all_problems )'Img );
                text_io.new_line;

                return costs;
        end Calculate_Costs;

        --  type LA_Costs_Component is ( expected_takeup, expected_bills, expected_gross_costs );
        --  LA_Costs_System_Type, LA_Costs_Component, LA_Problem_Type
        function add_to_costs( totals : LA_Takeup_Array; add_to : LA_Takeup_Array ) return LA_Takeup_Array is
        outt :  LA_Takeup_Array := ( others=>(others=>(others=>0.0)));
        begin
                 for ct in LA_Costs_System_Type loop
                        for cmp in LA_Costs_Component loop
                                for pt in LA_Problem_Type loop
                                        --  text_io.put( "add_to_costs "&add_to( ct, cmp, pt )'Img &" added to "& totals( ct, cmp, pt )'Img );

                                        --  text_io.new_line;
                                        outt( ct, cmp, pt ) := totals( ct, cmp, pt ) +
                                                add_to( ct, cmp, pt );
                                        --  text_io.put( "giving " & outt( ct, cmp, pt )'Img );
                                end loop;
                        end loop;
                end loop;
                return outt;
        end add_to_costs;

        function get_costs_type_from_param_types(
                sys : System_Type;
                ctype : Claim_Type ) return LA_Costs_System_Type is
              latype : LA_Costs_System_Type;
        begin
                case sys is
                      when defaultNI|defaultEnglish|ni_personal_injury =>
                        if ctype = personalInjuryClaim then
                                latype := civil_pi;
                        else
                                latype := civil;
                        end if;
                       when ABWOR => latype := abwor;
                       when green_form => latype := green_form;
                       when magistrates_court_criminal => latype := magistrates_court_criminal;
                end case;
                return latype;
        end get_costs_type_from_param_types;

        function Calculate_Costs( bu : Model_Benefit_Unit;
                                  results : model_output.One_LA_Output;
                                  sys : System_Type;
                                  ctype   : Claim_Type;
                                  indexed : boolean ) return LA_Takeup_Array is
                working_costs, costs : LA_Takeup_Array := ( others=>(others=>(others=>0.0)));

                latype : LA_Costs_System_Type := get_costs_type_from_param_types( sys, ctype );
        begin
                 text_io.put ( " Calculate_Cost start: initialised working_costs ( latype, expected_gross_costs, all_problems ) to " &
                                        working_costs ( latype, expected_gross_costs, all_problems )'Img );
                                text_io.new_line;

                if( results.la_State /= disqualified ) and ( results.la_State /= na ) then
                        for chno in 1 .. bu.numChildren loop
                                if( indexed ) then
                                        working_costs :=  Calculate_Costs ( bu.children ( chno ).takeup_indexed, latype );
                                else
                                        working_costs :=  Calculate_Costs ( bu.children ( chno ).takeup_non_indexed , latype );
                                end if;
                                text_io.put ( "child calc working_costs ( latype, expected_gross_costs, all_problems ) = " &
                                        working_costs ( latype, expected_gross_costs, all_problems )'Img );
                                text_io.new_line;

                                costs := add_to_costs( costs, working_costs );
                                text_io.put ( "full_costs afterwards ( latype, expected_gross_costs, all_problems ) = " &
                                        costs ( latype, expected_gross_costs, all_problems )'Img );
                                text_io.new_line;
                        end loop;
                        for adno in head .. bu.last_adult loop
                                if( indexed ) then
                                        working_costs :=  Calculate_Costs ( bu.adults ( adno ).takeup_indexed, latype );
                                else
                                        working_costs :=  Calculate_Costs ( bu.adults ( adno ).takeup_non_indexed, latype );
                                end if;
                                text_io.put ( "ad calc working_costs ( latype, expected_gross_costs, all_problems ) = " &
                                        working_costs ( latype, expected_gross_costs, all_problems )'Img );
                                text_io.new_line;
                                text_io.put ( "full_costs before( latype, expected_gross_costs, all_problems ) = " &
                                        costs ( latype, expected_gross_costs, all_problems )'Img );
                                text_io.new_line;
                                costs := add_to_costs( costs, working_costs );
                                text_io.put ( "full_costs after( latype, expected_gross_costs, all_problems ) = " &
                                        costs ( latype, expected_gross_costs, all_problems )'Img );
                                text_io.new_line;
                        end loop;
                end if;
                return costs;
        end Calculate_Costs ;

end legal_aid_costs_model;
