package body FRS_Enums is

   use type Templates_Parser.Vector_Tag;


    function pretty_print( i : Acorn ) return String is
    begin
         case i is
             when no_population_data_available => return "No population data available";
             when thriving_wealthy_suburbs_large_detached_houses => return "Thriving-Wealthy suburbs, large detached houses";
             when thriving_villages_with_wealthy_commuters => return "Thriving-Villages with wealthy commuters";
             when thriving_mature_affluent_home_owning_areas => return "Thriving-Mature affluent home owning areas";
             when thriving_affluent_suburbs_older_families => return "Thriving-Affluent suburbs, older families";
             when thriving_mature_well_off_suburbs => return "Thriving-Mature, well-off suburbs";
             when thriving_agricultural_villages_home_based_workers => return "Thriving-Agricultural villages, home-based workers";
             when thriving_hol_retreats_oldr_people_home_based_workers => return "Thriving-Hol retreats,oldr people, home based workers";
             when thriving_home_owning_areas_well_off_older_residents => return "Thriving-Home owning areas, well-off older residents";
             when thriving_private_flats_elderly_people => return "Thriving-Private flats, elderly people";
             when expanding_affluent_working_families_with_mortgages => return "Expanding-Affluent working families with mortgages";
             when expanding_affluent_wrkng_cpls_with_mortgs_new_homes => return "Expanding-Affluent wrkng cpls with mortgs,new homes";
             when expanding_transient_wrkfrcs_livng_at_their_place_of_wrk => return "Expanding-Transient wrkfrcs,livng at their place of wrk";
             when expanding_home_owning_family_areas => return "Expanding-Home owning family areas";
             when expanding_home_owning_family_areas_older_children => return "Expanding-Home owning family areas, older children";
             when expanding_families_with_mortgages_younger_children => return "Expanding-Families with mortgages, younger children";
             when rising_well_off_town_and_city_areas => return "Rising-Well off town and city areas";
             when rising_flats_and_mortgs_singles_and_young_wrkng_couples => return "Rising-Flats and mortgs, singles and young wrkng couples";
             when rising_furnshed_flats_and_bedsits_ynger_single_people => return "Rising-Furnshed flats and bedsits, ynger single people";
             when rising_aprtmnts_yng_professional_singles_and_couples => return "Rising-Aprtmnts, yng professional singles and couples";
             when rising_gentrified_multi_ethnic_areas => return "Rising-Gentrified multi-ethnic areas";
             when rising_prosperous_enclaves_highly_qualified_exectivs => return "Rising-Prosperous enclaves, highly qualified exectivs";
             when rising_academic_cntrs_studnts_and_young_professionals => return "Rising-Academic cntrs, studnts and young professionals";
             when rising_affluent_city_centre_areas_tenements_and_flats => return "Rising-Affluent city centre areas, tenements and flats";
             when rising_partially_gentrified_multi_ethnic_areas => return "Rising-Partially gentrified multi-ethnic areas";
             when rising_converted_flats_and_bedsits_single_people => return "Rising-Converted flats and bedsits, single people";
             when settling_mature_established_home_owning_areas => return "Settling-Mature established home owning areas";
             when settling_rural_areas_mixed_occupations => return "Settling-Rural areas, mixed occupations";
             when settling_established_home_owning_areas => return "Settling-Established home owning areas";
             when settling_hme_owng_areas_council_tenants_retired_pple => return "Settling-Hme owng areas, council tenants, retired pple";
             when settling_estblshd_home_owning_areas_skilled_workers => return "Settling-Estblshd home owning areas, skilled workers";
             when settling_home_owners_in_oldr_proprts_younger_wrkrs => return "Settling-Home owners in oldr proprts, younger wrkrs";
             when settling_home_owning_areas_with_skilled_workers => return "Settling-Home owning areas with skilled workers";
             when aspiring_council_areas_some_new_home_owners => return "Aspiring-Council areas, some new home owners";
             when aspiring_mature_home_owning_areas_skilled_workers => return "Aspiring-Mature home owning areas, skilled workers";
             when aspiring_low_rise_estates_oldr_wrkrs_new_home_ownrs => return "Aspiring-Low rise estates,oldr wrkrs,new home ownrs";
             when aspiring_home_ownng_multi_ethnic_areas_young_famils => return "Aspiring-Home ownng multi-ethnic areas,young famils";
             when aspiring_multi_occupied_town_cntrs_mixed_occupations => return "Aspiring-Multi-occupied town cntrs, mixed occupations";
             when aspiring_multi_ethnic_areas_white_collar_workers => return "Aspiring-Multi-ethnic areas, white collar workers";
             when striving_home_ownrs_small_councl_flats_singl_pensnrs => return "Striving-Home ownrs, small councl flats,singl pensnrs";
             when striving_council_areas_older_people_health_problems => return "Striving-Council areas, older people, health problems";
             when striving_better_off_council_areas_new_home_owners => return "Striving-Better-off council areas, new home owners";
             when striving_concil_areas_yng_famles_sme_new_hme_oners => return "Striving-Concil areas,yng famles,sme new hme oners";
             when striving_council_areas_yng_famls_many_lone_parents => return "Striving-Council areas, yng famls, many lone parents";
             when striving_multi_occupied_terraces_multi_ethnic_areas => return "Striving-Multi-occupied terraces, multi-ethnic areas";
             when striving_low_rise_council_housing_less_well_off_famls => return "Striving-Low rise council housing, less well-off famls";
             when striving_council_areas_residents_with_health_problems => return "Striving-Council areas, residents with health problems";
             when striving_estates_with_high_unemployment => return "Striving-Estates with high unemployment";
             when striving_council_flats_elderly_people_health_problems => return "Striving-Council flats, elderly people, health problems";
             when striving_council_flats_very_high_unemploymnt_singles => return "Striving-Council flats, very high unemploymnt,singles";
             when striving_council_areas_high_unemploymnt_one_parents => return "Striving-Council areas,high unemploymnt, one parents";
             when striving_council_flats_greatst_hrdshp_many_lone_parnts => return "Striving-Council flats,greatst hrdshp,many lone parnts";
             when striving_multi_ethnic_large_families_overcrowding => return "Striving-Multi-ethnic, large families, overcrowding";
             when striving_multi_ethnic_severe_unemplymnt_lone_parents => return "Striving-Multi-ethnic, severe unemplymnt,lone parents";
             when striving_multi_ethnic_high_unemploymnt_overcrowding => return "Striving-Multi-ethnic, high unemploymnt, overcrowding";
             when area_where_code_not_yet_assigned => return "Area where code not yet assigned";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_acorn( i : integer ) return Acorn is
    begin
        case i is
            when 0 => return no_population_data_available;
            when 1 => return thriving_wealthy_suburbs_large_detached_houses;
            when 2 => return thriving_villages_with_wealthy_commuters;
            when 3 => return thriving_mature_affluent_home_owning_areas;
            when 4 => return thriving_affluent_suburbs_older_families;
            when 5 => return thriving_mature_well_off_suburbs;
            when 6 => return thriving_agricultural_villages_home_based_workers;
            when 7 => return thriving_hol_retreats_oldr_people_home_based_workers;
            when 8 => return thriving_home_owning_areas_well_off_older_residents;
            when 9 => return thriving_private_flats_elderly_people;
            when 10 => return expanding_affluent_working_families_with_mortgages;
            when 11 => return expanding_affluent_wrkng_cpls_with_mortgs_new_homes;
            when 12 => return expanding_transient_wrkfrcs_livng_at_their_place_of_wrk;
            when 13 => return expanding_home_owning_family_areas;
            when 14 => return expanding_home_owning_family_areas_older_children;
            when 15 => return expanding_families_with_mortgages_younger_children;
            when 16 => return rising_well_off_town_and_city_areas;
            when 17 => return rising_flats_and_mortgs_singles_and_young_wrkng_couples;
            when 18 => return rising_furnshed_flats_and_bedsits_ynger_single_people;
            when 19 => return rising_aprtmnts_yng_professional_singles_and_couples;
            when 20 => return rising_gentrified_multi_ethnic_areas;
            when 21 => return rising_prosperous_enclaves_highly_qualified_exectivs;
            when 22 => return rising_academic_cntrs_studnts_and_young_professionals;
            when 23 => return rising_affluent_city_centre_areas_tenements_and_flats;
            when 24 => return rising_partially_gentrified_multi_ethnic_areas;
            when 25 => return rising_converted_flats_and_bedsits_single_people;
            when 26 => return settling_mature_established_home_owning_areas;
            when 27 => return settling_rural_areas_mixed_occupations;
            when 28 => return settling_established_home_owning_areas;
            when 29 => return settling_hme_owng_areas_council_tenants_retired_pple;
            when 30 => return settling_estblshd_home_owning_areas_skilled_workers;
            when 31 => return settling_home_owners_in_oldr_proprts_younger_wrkrs;
            when 32 => return settling_home_owning_areas_with_skilled_workers;
            when 33 => return aspiring_council_areas_some_new_home_owners;
            when 34 => return aspiring_mature_home_owning_areas_skilled_workers;
            when 35 => return aspiring_low_rise_estates_oldr_wrkrs_new_home_ownrs;
            when 36 => return aspiring_home_ownng_multi_ethnic_areas_young_famils;
            when 37 => return aspiring_multi_occupied_town_cntrs_mixed_occupations;
            when 38 => return aspiring_multi_ethnic_areas_white_collar_workers;
            when 39 => return striving_home_ownrs_small_councl_flats_singl_pensnrs;
            when 40 => return striving_council_areas_older_people_health_problems;
            when 41 => return striving_better_off_council_areas_new_home_owners;
            when 42 => return striving_concil_areas_yng_famles_sme_new_hme_oners;
            when 43 => return striving_council_areas_yng_famls_many_lone_parents;
            when 44 => return striving_multi_occupied_terraces_multi_ethnic_areas;
            when 45 => return striving_low_rise_council_housing_less_well_off_famls;
            when 46 => return striving_council_areas_residents_with_health_problems;
            when 47 => return striving_estates_with_high_unemployment;
            when 48 => return striving_council_flats_elderly_people_health_problems;
            when 49 => return striving_council_flats_very_high_unemploymnt_singles;
            when 50 => return striving_council_areas_high_unemploymnt_one_parents;
            when 51 => return striving_council_flats_greatst_hrdshp_many_lone_parnts;
            when 52 => return striving_multi_ethnic_large_families_overcrowding;
            when 53 => return striving_multi_ethnic_severe_unemplymnt_lone_parents;
            when 54 => return striving_multi_ethnic_high_unemploymnt_overcrowding;
            when 55 => return area_where_code_not_yet_assigned;
            when others => return missing;
        end case;
    end convert_acorn;


    function get_acorn_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "No population data available";
       tag := tag & "Thriving-Wealthy suburbs, large detached houses";
       tag := tag & "Thriving-Villages with wealthy commuters";
       tag := tag & "Thriving-Mature affluent home owning areas";
       tag := tag & "Thriving-Affluent suburbs, older families";
       tag := tag & "Thriving-Mature, well-off suburbs";
       tag := tag & "Thriving-Agricultural villages, home-based workers";
       tag := tag & "Thriving-Hol retreats,oldr people, home based workers";
       tag := tag & "Thriving-Home owning areas, well-off older residents";
       tag := tag & "Thriving-Private flats, elderly people";
       tag := tag & "Expanding-Affluent working families with mortgages";
       tag := tag & "Expanding-Affluent wrkng cpls with mortgs,new homes";
       tag := tag & "Expanding-Transient wrkfrcs,livng at their place of wrk";
       tag := tag & "Expanding-Home owning family areas";
       tag := tag & "Expanding-Home owning family areas, older children";
       tag := tag & "Expanding-Families with mortgages, younger children";
       tag := tag & "Rising-Well off town and city areas";
       tag := tag & "Rising-Flats and mortgs, singles and young wrkng couples";
       tag := tag & "Rising-Furnshed flats and bedsits, ynger single people";
       tag := tag & "Rising-Aprtmnts, yng professional singles and couples";
       tag := tag & "Rising-Gentrified multi-ethnic areas";
       tag := tag & "Rising-Prosperous enclaves, highly qualified exectivs";
       tag := tag & "Rising-Academic cntrs, studnts and young professionals";
       tag := tag & "Rising-Affluent city centre areas, tenements and flats";
       tag := tag & "Rising-Partially gentrified multi-ethnic areas";
       tag := tag & "Rising-Converted flats and bedsits, single people";
       tag := tag & "Settling-Mature established home owning areas";
       tag := tag & "Settling-Rural areas, mixed occupations";
       tag := tag & "Settling-Established home owning areas";
       tag := tag & "Settling-Hme owng areas, council tenants, retired pple";
       tag := tag & "Settling-Estblshd home owning areas, skilled workers";
       tag := tag & "Settling-Home owners in oldr proprts, younger wrkrs";
       tag := tag & "Settling-Home owning areas with skilled workers";
       tag := tag & "Aspiring-Council areas, some new home owners";
       tag := tag & "Aspiring-Mature home owning areas, skilled workers";
       tag := tag & "Aspiring-Low rise estates,oldr wrkrs,new home ownrs";
       tag := tag & "Aspiring-Home ownng multi-ethnic areas,young famils";
       tag := tag & "Aspiring-Multi-occupied town cntrs, mixed occupations";
       tag := tag & "Aspiring-Multi-ethnic areas, white collar workers";
       tag := tag & "Striving-Home ownrs, small councl flats,singl pensnrs";
       tag := tag & "Striving-Council areas, older people, health problems";
       tag := tag & "Striving-Better-off council areas, new home owners";
       tag := tag & "Striving-Concil areas,yng famles,sme new hme oners";
       tag := tag & "Striving-Council areas, yng famls, many lone parents";
       tag := tag & "Striving-Multi-occupied terraces, multi-ethnic areas";
       tag := tag & "Striving-Low rise council housing, less well-off famls";
       tag := tag & "Striving-Council areas, residents with health problems";
       tag := tag & "Striving-Estates with high unemployment";
       tag := tag & "Striving-Council flats, elderly people, health problems";
       tag := tag & "Striving-Council flats, very high unemploymnt,singles";
       tag := tag & "Striving-Council areas,high unemploymnt, one parents";
       tag := tag & "Striving-Council flats,greatst hrdshp,many lone parnts";
       tag := tag & "Striving-Multi-ethnic, large families, overcrowding";
       tag := tag & "Striving-Multi-ethnic, severe unemplymnt,lone parents";
       tag := tag & "Striving-Multi-ethnic, high unemploymnt, overcrowding";
       tag := tag & "Area where code not yet assigned";
       return tag;
    end get_acorn_template;

    function pretty_print( i : Adult_Employment_Status ) return String is
    begin
         case i is
             when self_employed => return "Self-Employed";
             when full_time_employee => return "Full Time Employee";
             when part_time_employee => return "Part Time Employee";
             when ft_employee_temporarily_sick => return "FT Employee temporarily Sick";
             when pt_employee_temporarily_sick => return "PT Employee temporarily Sick";
             when industrial_action => return "Industrial Action";
             when unemployed => return "Unemployed";
             when work_related_govt_training => return "Work related Govt training";
             when retired => return "Retired";
             when unoccupied_under_retirement_age => return "Unoccupied under retirement age";
             when temporarily_sick => return "temporarily sick";
             when long_term_sick => return "Long term sick";
             when students_in_non_advanced_fe => return "Students in non advanced FE";
             when unpaid_family_workers => return "Unpaid Family Workers";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_adult_employment_status( i : integer ) return Adult_Employment_Status is
    begin
        case i is
            when 1 => return self_employed;
            when 2 => return full_time_employee;
            when 3 => return part_time_employee;
            when 4 => return ft_employee_temporarily_sick;
            when 5 => return pt_employee_temporarily_sick;
            when 6 => return industrial_action;
            when 7 => return unemployed;
            when 8 => return work_related_govt_training;
            when 9 => return retired;
            when 10 => return unoccupied_under_retirement_age;
            when 11 => return temporarily_sick;
            when 12 => return long_term_sick;
            when 13 => return students_in_non_advanced_fe;
            when 14 => return unpaid_family_workers;
            when others => return missing;
        end case;
    end convert_adult_employment_status;


    function get_adult_employment_status_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Self-Employed";
       tag := tag & "Full Time Employee";
       tag := tag & "Part Time Employee";
       tag := tag & "FT Employee temporarily Sick";
       tag := tag & "PT Employee temporarily Sick";
       tag := tag & "Industrial Action";
       tag := tag & "Unemployed";
       tag := tag & "Work related Govt training";
       tag := tag & "Retired";
       tag := tag & "Unoccupied under retirement age";
       tag := tag & "temporarily sick";
       tag := tag & "Long term sick";
       tag := tag & "Students in non advanced FE";
       tag := tag & "Unpaid Family Workers";
       return tag;
    end get_adult_employment_status_template;

    function pretty_print( i : Age_Group ) return String is
    begin
         case i is
             when vage_16_to_24 => return "Age 16 to 24";
             when vage_25_to_34 => return "Age 25 to 34";
             when vage_35_to_44 => return "Age 35 to 44";
             when vage_45_to_54 => return "Age 45 to 54";
             when vage_55_to_59 => return "Age 55 to 59";
             when vage_60_to_64 => return "Age 60 to 64";
             when vage_65_to_74 => return "Age 65 to 74";
             when vage_75_to_84 => return "Age 75 to 84";
             when vage_85_or_over => return "Age 85 or over";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_age_group( i : integer ) return Age_Group is
    begin
        case i is
            when 1 => return vage_16_to_24;
            when 2 => return vage_25_to_34;
            when 3 => return vage_35_to_44;
            when 4 => return vage_45_to_54;
            when 5 => return vage_55_to_59;
            when 6 => return vage_60_to_64;
            when 7 => return vage_65_to_74;
            when 8 => return vage_75_to_84;
            when 9 => return vage_85_or_over;
            when others => return missing;
        end case;
    end convert_age_group;


    function get_age_group_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Age 16 to 24";
       tag := tag & "Age 25 to 34";
       tag := tag & "Age 35 to 44";
       tag := tag & "Age 45 to 54";
       tag := tag & "Age 55 to 59";
       tag := tag & "Age 60 to 64";
       tag := tag & "Age 65 to 74";
       tag := tag & "Age 75 to 84";
       tag := tag & "Age 85 or over";
       return tag;
    end get_age_group_template;

    function pretty_print( i : Aggregated_Ethnic_Group ) return String is
    begin
         case i is
             when white => return "White";
             when mixed => return "Mixed";
             when asian_or_asian_british => return "Asian or Asian British";
             when black_or_black_british => return "Black or Black British";
             when chinese_or_other_ethnic_group => return "Chinese or Other Ethnic group";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_aggregated_ethnic_group( i : integer ) return Aggregated_Ethnic_Group is
    begin
        case i is
            when 1 => return white;
            when 2 => return mixed;
            when 3 => return asian_or_asian_british;
            when 4 => return black_or_black_british;
            when 5 => return chinese_or_other_ethnic_group;
            when others => return missing;
        end case;
    end convert_aggregated_ethnic_group;


    function get_aggregated_ethnic_group_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "White";
       tag := tag & "Mixed";
       tag := tag & "Asian or Asian British";
       tag := tag & "Black or Black British";
       tag := tag & "Chinese or Other Ethnic group";
       return tag;
    end get_aggregated_ethnic_group_template;

    function pretty_print( i : Benefit_Types ) return String is
    begin
         case i is
             when dla_self_care => return "DLA(self care)";
             when dla_mobility => return "DLA(mobility)";
             when child_benefit => return "Child Benefit";
             when pension_credit => return "Pension credit";
             when retirement_pension_opp => return "Retirement Pension /OPP";
             when widows_pension_bereavement_allowance => return "Widow's Pension/Bereavement Allowance";
             when widowed_mothers_widowed_parents_allowance => return "Widowed Mothers/Widowed Parents Allowance";
             when war_disablement_pension => return "War Disablement Pension";
             when war_widows_widowers_pension => return "War Widow's/Widower's Pension";
             when severe_disability_allowance => return "Severe Disability Allowance";
             when disabled_persons_tax_credit => return "Disabled Person's Tax Credit";
             when attendence_allowance => return "Attendence Allowance";
             when invalid_care_allowance => return "Invalid Care Allowance";
             when jobseekers_allowance => return "Jobseeker's Allowance";
             when industrial_injury_disablement_benefit => return "Industrial Injury Disablement Benefit";
             when incapacity_benefit => return "Incapacity Benefit";
             when working_families_tax_credit => return "Working Families' Tax Credit";
             when income_support => return "Income Support";
             when new_deal => return "New Deal";
             when maternity_allowance => return "Maternity Allowance";
             when maternity_grant_from_social_fund => return "Maternity Grant from Social Fund";
             when funeral_grant_from_social_fund => return "Funeral Grant from Social Fund";
             when community_care_grant_from_social_fund => return "Community Care grant from Social Fund";
             when back_to_work_bonus_received => return "Back to Work Bonus (received)";
             when back_to_work_bonus_accrued => return "Back to Work Bonus (accrued)";
             when any_other_ni_or_state_benefit => return "Any other NI or State benefit";
             when trade_union_sick_strike_pay => return "Trade Union sick/strike pay";
             when friendly_society_benefits => return "Friendly Society Benefits";
             when private_sickness_scheme_benefits => return "Private sickness scheme benefits";
             when accident_insurance_scheme_benefits => return "Accident insurance scheme benefits";
             when hospital_savings_scheme_benefits => return "Hospital savings scheme benefits";
             when government_training_allowances => return "Government training allowances";
             when guardians_allowance => return "Guardians Allowance";
             when social_fund_loan_budgeting => return "Social Fund Loan:Budgeting";
             when social_fund_loan_crisis => return "Social Fund Loan:Crisis";
             when working_families_tax_credit_lump_sum => return "Working Families' Tax Credit - Lump Sum";
             when future_dla_self_care => return "Future: DLA Self Care";
             when future_dla_mobility => return "Future: DLA Mobility";
             when future_attendance_allowance => return "Future: Attendance Allowance";
             when disabled_persons_tax_credit_lump_sum => return "Disabled Person's Tax Credit - Lump Sum";
             when child_maintenance_bonus => return "Child Maintenance Bonus";
             when lone_parent_benefit_run_on => return "Lone Parent Benefit run-on";
             when widows_payment => return "Widow's Payment";
             when unemployment_redundancy_insurance => return "Unemployment/Redundancy Insurance";
             when winter_fuel_payments => return "Winter Fuel Payments";
             when dwp_direct_payments_isa => return "DWP direct payments - ISA";
             when dwp_direct_payments_jsa => return "DWP direct payments - JSA";
             when hb_only_or_separately => return "HB only or separately";
             when ctb_only_or_separately => return "CTB only or separately";
             when hb_ctb_paid_together => return "HB/CTB paid together";
             when permanent_health_insurance => return "Permanent health insurance";
             when any_other_sickness_insurance => return "Any other sickness insurance";
             when critical_illness_cover => return "Critical Illness Cover";
             when working_tax_credit => return "Working Tax Credit";
             when child_tax_credit => return "Child Tax Credit";
             when working_tax_credit_lump_sum => return "Working Tax Credit Lump Sum";
             when child_tax_credit_lump_sum => return "Child Tax Credit Lump Sum";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_benefit_types( i : integer ) return Benefit_Types is
    begin
        case i is
            when 1 => return dla_self_care;
            when 2 => return dla_mobility;
            when 3 => return child_benefit;
            when 4 => return pension_credit;
            when 5 => return retirement_pension_opp;
            when 6 => return widows_pension_bereavement_allowance;
            when 7 => return widowed_mothers_widowed_parents_allowance;
            when 8 => return war_disablement_pension;
            when 9 => return war_widows_widowers_pension;
            when 10 => return severe_disability_allowance;
            when 11 => return disabled_persons_tax_credit;
            when 12 => return attendence_allowance;
            when 13 => return invalid_care_allowance;
            when 14 => return jobseekers_allowance;
            when 15 => return industrial_injury_disablement_benefit;
            when 17 => return incapacity_benefit;
            when 18 => return working_families_tax_credit;
            when 19 => return income_support;
            when 20 => return new_deal;
            when 21 => return maternity_allowance;
            when 22 => return maternity_grant_from_social_fund;
            when 24 => return funeral_grant_from_social_fund;
            when 25 => return community_care_grant_from_social_fund;
            when 26 => return back_to_work_bonus_received;
            when 27 => return back_to_work_bonus_accrued;
            when 30 => return any_other_ni_or_state_benefit;
            when 31 => return trade_union_sick_strike_pay;
            when 32 => return friendly_society_benefits;
            when 33 => return private_sickness_scheme_benefits;
            when 34 => return accident_insurance_scheme_benefits;
            when 35 => return hospital_savings_scheme_benefits;
            when 36 => return government_training_allowances;
            when 37 => return guardians_allowance;
            when 39 => return social_fund_loan_budgeting;
            when 40 => return social_fund_loan_crisis;
            when 41 => return working_families_tax_credit_lump_sum;
            when 42 => return future_dla_self_care;
            when 43 => return future_dla_mobility;
            when 44 => return future_attendance_allowance;
            when 50 => return disabled_persons_tax_credit_lump_sum;
            when 51 => return child_maintenance_bonus;
            when 52 => return lone_parent_benefit_run_on;
            when 60 => return widows_payment;
            when 61 => return unemployment_redundancy_insurance;
            when 62 => return winter_fuel_payments;
            when 65 => return dwp_direct_payments_isa;
            when 66 => return dwp_direct_payments_jsa;
            when 78 => return hb_only_or_separately;
            when 79 => return ctb_only_or_separately;
            when 80 => return hb_ctb_paid_together;
            when 81 => return permanent_health_insurance;
            when 82 => return any_other_sickness_insurance;
            when 83 => return critical_illness_cover;
            when 90 => return working_tax_credit;
            when 91 => return child_tax_credit;
            when 92 => return working_tax_credit_lump_sum;
            when 93 => return child_tax_credit_lump_sum;
            when others => return missing;
        end case;
    end convert_benefit_types;


    function get_benefit_types_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "DLA(self care)";
       tag := tag & "DLA(mobility)";
       tag := tag & "Child Benefit";
       tag := tag & "Pension credit";
       tag := tag & "Retirement Pension /OPP";
       tag := tag & "Widow's Pension/Bereavement Allowance";
       tag := tag & "Widowed Mothers/Widowed Parents Allowance";
       tag := tag & "War Disablement Pension";
       tag := tag & "War Widow's/Widower's Pension";
       tag := tag & "Severe Disability Allowance";
       tag := tag & "Disabled Person's Tax Credit";
       tag := tag & "Attendence Allowance";
       tag := tag & "Invalid Care Allowance";
       tag := tag & "Jobseeker's Allowance";
       tag := tag & "Industrial Injury Disablement Benefit";
       tag := tag & "Incapacity Benefit";
       tag := tag & "Working Families' Tax Credit";
       tag := tag & "Income Support";
       tag := tag & "New Deal";
       tag := tag & "Maternity Allowance";
       tag := tag & "Maternity Grant from Social Fund";
       tag := tag & "Funeral Grant from Social Fund";
       tag := tag & "Community Care grant from Social Fund";
       tag := tag & "Back to Work Bonus (received)";
       tag := tag & "Back to Work Bonus (accrued)";
       tag := tag & "Any other NI or State benefit";
       tag := tag & "Trade Union sick/strike pay";
       tag := tag & "Friendly Society Benefits";
       tag := tag & "Private sickness scheme benefits";
       tag := tag & "Accident insurance scheme benefits";
       tag := tag & "Hospital savings scheme benefits";
       tag := tag & "Government training allowances";
       tag := tag & "Guardians Allowance";
       tag := tag & "Social Fund Loan:Budgeting";
       tag := tag & "Social Fund Loan:Crisis";
       tag := tag & "Working Families' Tax Credit - Lump Sum";
       tag := tag & "Future: DLA Self Care";
       tag := tag & "Future: DLA Mobility";
       tag := tag & "Future: Attendance Allowance";
       tag := tag & "Disabled Person's Tax Credit - Lump Sum";
       tag := tag & "Child Maintenance Bonus";
       tag := tag & "Lone Parent Benefit run-on";
       tag := tag & "Widow's Payment";
       tag := tag & "Unemployment/Redundancy Insurance";
       tag := tag & "Winter Fuel Payments";
       tag := tag & "DWP direct payments - ISA";
       tag := tag & "DWP direct payments - JSA";
       tag := tag & "HB only or separately";
       tag := tag & "CTB only or separately";
       tag := tag & "HB/CTB paid together";
       tag := tag & "Permanent health insurance";
       tag := tag & "Any other sickness insurance";
       tag := tag & "Critical Illness Cover";
       tag := tag & "Working Tax Credit";
       tag := tag & "Child Tax Credit";
       tag := tag & "Working Tax Credit Lump Sum";
       tag := tag & "Child Tax Credit Lump Sum";
       return tag;
    end get_benefit_types_template;

    function pretty_print( i : Benefit_Unit_Economic_Status ) return String is
    begin
         case i is
             when self_employed => return "Self-employed";
             when v1_or_2_adults_in_f_t_employed_work => return "1 or 2 adults in f/t employed work";
             when v2_adults_one_in_f_t_other_p_t => return "2 adults, one in f/t, other p/t";
             when v2_adults_one_f_t_as_employee_other_not => return "2 adults, one f/t as employee, other not";
             when v1_or_2_adults_at_least_1_in_p_t_work => return "1 or 2 adults, at least 1 in p/t work";
             when v1_or_2_adults_head_or_spouse_aged_60plus => return "1 or 2 adults, head or spouse aged 60+";
             when v1_or_2_adults_hd_or_sp_unemployed => return "1 or 2 adults, hd or sp unemployed";
             when v1_or_2_adults_hd_or_sp_sick_lt_pen_age => return "1 or 2 adults, hd or sp sick, < pen age";
             when any_other_category => return "Any other category";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_benefit_unit_economic_status( i : integer ) return Benefit_Unit_Economic_Status is
    begin
        case i is
            when 1 => return self_employed;
            when 2 => return v1_or_2_adults_in_f_t_employed_work;
            when 3 => return v2_adults_one_in_f_t_other_p_t;
            when 4 => return v2_adults_one_f_t_as_employee_other_not;
            when 5 => return v1_or_2_adults_at_least_1_in_p_t_work;
            when 6 => return v1_or_2_adults_head_or_spouse_aged_60plus;
            when 7 => return v1_or_2_adults_hd_or_sp_unemployed;
            when 8 => return v1_or_2_adults_hd_or_sp_sick_lt_pen_age;
            when 9 => return any_other_category;
            when others => return missing;
        end case;
    end convert_benefit_unit_economic_status;


    function get_benefit_unit_economic_status_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Self-employed";
       tag := tag & "1 or 2 adults in f/t employed work";
       tag := tag & "2 adults, one in f/t, other p/t";
       tag := tag & "2 adults, one f/t as employee, other not";
       tag := tag & "1 or 2 adults, at least 1 in p/t work";
       tag := tag & "1 or 2 adults, head or spouse aged 60+";
       tag := tag & "1 or 2 adults, hd or sp unemployed";
       tag := tag & "1 or 2 adults, hd or sp sick, < pen age";
       tag := tag & "Any other category";
       return tag;
    end get_benefit_unit_economic_status_template;

    function pretty_print( i : Benefit_Unit_Type ) return String is
    begin
         case i is
             when any_other_category => return "Any other category";
             when pensioner_couple => return "Pensioner couple";
             when pensioner_single => return "Pensioner single";
             when couple_with_children => return "Couple with children";
             when couple_without_children => return "Couple without children";
             when lone_parent => return "Lone parent";
             when single_without_children => return "Single without children";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_benefit_unit_type( i : integer ) return Benefit_Unit_Type is
    begin
        case i is
            when 0 => return any_other_category;
            when 1 => return pensioner_couple;
            when 2 => return pensioner_single;
            when 3 => return couple_with_children;
            when 4 => return couple_without_children;
            when 5 => return lone_parent;
            when 6 => return single_without_children;
            when others => return missing;
        end case;
    end convert_benefit_unit_type;


    function get_benefit_unit_type_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Any other category";
       tag := tag & "Pensioner couple";
       tag := tag & "Pensioner single";
       tag := tag & "Couple with children";
       tag := tag & "Couple without children";
       tag := tag & "Lone parent";
       tag := tag & "Single without children";
       return tag;
    end get_benefit_unit_type_template;

    function pretty_print( i : BU_Disabled_Indicator ) return String is
    begin
         case i is
             when v1_person_in_bu_blind => return "1 Person in BU blind";
             when v2_people_in_bu_blind => return "2 People in BU blind";
             when v1_person_in_bu_disabled => return "1 person in BU disabled";
             when v2_people_in_bu_disabled => return "2 People in BU disabled";
             when v1_person_blind_and_1_person_disabled => return "1 Person blind and 1 Person disabled";
             when no_one_blind_or_disabled => return "No one blind or disabled";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_bu_disabled_indicator( i : integer ) return BU_Disabled_Indicator is
    begin
        case i is
            when 1 => return v1_person_in_bu_blind;
            when 2 => return v2_people_in_bu_blind;
            when 3 => return v1_person_in_bu_disabled;
            when 4 => return v2_people_in_bu_disabled;
            when 5 => return v1_person_blind_and_1_person_disabled;
            when 6 => return no_one_blind_or_disabled;
            when others => return missing;
        end case;
    end convert_bu_disabled_indicator;


    function get_bu_disabled_indicator_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "1 Person in BU blind";
       tag := tag & "2 People in BU blind";
       tag := tag & "1 person in BU disabled";
       tag := tag & "2 People in BU disabled";
       tag := tag & "1 Person blind and 1 Person disabled";
       tag := tag & "No one blind or disabled";
       return tag;
    end get_bu_disabled_indicator_template;

    function pretty_print( i : Employment_Status ) return String is
    begin
         case i is
             when self_employed => return "Self-Employed";
             when full_time_employee => return "Full Time Employee";
             when part_time_employee => return "Part Time Employee";
             when ft_employee_temporarily_sick => return "FT Employee temporarily Sick";
             when pt_employee_temporarily_sick => return "PT Employee temporarily Sick";
             when industrial_action => return "Industrial Action";
             when unemployed => return "Unemployed";
             when work_related_govt_training => return "Work related Govt training";
             when retired => return "Retired";
             when unoccupied_under_retirement_age => return "Unoccupied under retirement age";
             when temporarily_sick => return "temporarily sick";
             when long_term_sick => return "Long term sick";
             when students_in_non_advanced_fe => return "Students in non advanced FE";
             when unpaid_family_workers => return "Unpaid Family Workers";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_employment_status( i : integer ) return Employment_Status is
    begin
        case i is
            when 1 => return self_employed;
            when 2 => return full_time_employee;
            when 3 => return part_time_employee;
            when 4 => return ft_employee_temporarily_sick;
            when 5 => return pt_employee_temporarily_sick;
            when 6 => return industrial_action;
            when 7 => return unemployed;
            when 8 => return work_related_govt_training;
            when 9 => return retired;
            when 10 => return unoccupied_under_retirement_age;
            when 11 => return temporarily_sick;
            when 12 => return long_term_sick;
            when 13 => return students_in_non_advanced_fe;
            when 14 => return unpaid_family_workers;
            when others => return missing;
        end case;
    end convert_employment_status;


    function get_employment_status_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Self-Employed";
       tag := tag & "Full Time Employee";
       tag := tag & "Part Time Employee";
       tag := tag & "FT Employee temporarily Sick";
       tag := tag & "PT Employee temporarily Sick";
       tag := tag & "Industrial Action";
       tag := tag & "Unemployed";
       tag := tag & "Work related Govt training";
       tag := tag & "Retired";
       tag := tag & "Unoccupied under retirement age";
       tag := tag & "temporarily sick";
       tag := tag & "Long term sick";
       tag := tag & "Students in non advanced FE";
       tag := tag & "Unpaid Family Workers";
       return tag;
    end get_employment_status_template;

    function pretty_print( i : Ethnic_Group ) return String is
    begin
         case i is
             when white_british => return "White - British";
             when any_other_white_background => return "Any other white background";
             when mixed_white_and_black_caribbean => return "Mixed - White and Black Caribbean";
             when mixed_white_and_black_african => return "Mixed - White and Black African";
             when mixed_white_and_asian => return "Mixed - White and Asian";
             when any_other_mixed_background => return "Any other mixed background";
             when asian_or_asian_british_indian => return "Asian or Asian British - Indian";
             when asian_or_asian_british_pakistani => return "Asian or Asian British - Pakistani";
             when asian_or_asian_british_bangladeshi => return "Asian or Asian British - Bangladeshi";
             when any_other_asian_asian_british_background => return "Any other Asian/Asian British background";
             when black_or_black_british_caribbean => return "Black or Black British - Caribbean";
             when black_or_black_british_african => return "Black or Black British - African";
             when any_other_black_black_british_background => return "Any other Black/Black British background";
             when chinese => return "Chinese";
             when any_other => return "Any other";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_ethnic_group( i : integer ) return Ethnic_Group is
    begin
        case i is
            when 1 => return white_british;
            when 2 => return any_other_white_background;
            when 3 => return mixed_white_and_black_caribbean;
            when 4 => return mixed_white_and_black_african;
            when 5 => return mixed_white_and_asian;
            when 6 => return any_other_mixed_background;
            when 7 => return asian_or_asian_british_indian;
            when 8 => return asian_or_asian_british_pakistani;
            when 9 => return asian_or_asian_british_bangladeshi;
            when 10 => return any_other_asian_asian_british_background;
            when 11 => return black_or_black_british_caribbean;
            when 12 => return black_or_black_british_african;
            when 13 => return any_other_black_black_british_background;
            when 14 => return chinese;
            when 15 => return any_other;
            when others => return missing;
        end case;
    end convert_ethnic_group;


    function get_ethnic_group_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "White - British";
       tag := tag & "Any other white background";
       tag := tag & "Mixed - White and Black Caribbean";
       tag := tag & "Mixed - White and Black African";
       tag := tag & "Mixed - White and Asian";
       tag := tag & "Any other mixed background";
       tag := tag & "Asian or Asian British - Indian";
       tag := tag & "Asian or Asian British - Pakistani";
       tag := tag & "Asian or Asian British - Bangladeshi";
       tag := tag & "Any other Asian/Asian British background";
       tag := tag & "Black or Black British - Caribbean";
       tag := tag & "Black or Black British - African";
       tag := tag & "Any other Black/Black British background";
       tag := tag & "Chinese";
       tag := tag & "Any other";
       return tag;
    end get_ethnic_group_template;

    function pretty_print( i : HBAI_Benefit_Unit_Type ) return String is
    begin
         case i is
             when any_other_category => return "Any other category";
             when pensioner_couple => return "Pensioner couple";
             when pensioner_single => return "Pensioner single";
             when couple_with_children => return "Couple with children";
             when couple_without_children => return "Couple without children";
             when lone_parent => return "Lone parent";
             when single_without_children => return "Single without children";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_hbai_benefit_unit_type( i : integer ) return HBAI_Benefit_Unit_Type is
    begin
        case i is
            when 0 => return any_other_category;
            when 1 => return pensioner_couple;
            when 2 => return pensioner_single;
            when 3 => return couple_with_children;
            when 4 => return couple_without_children;
            when 5 => return lone_parent;
            when 6 => return single_without_children;
            when others => return missing;
        end case;
    end convert_hbai_benefit_unit_type;


    function get_hbai_benefit_unit_type_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Any other category";
       tag := tag & "Pensioner couple";
       tag := tag & "Pensioner single";
       tag := tag & "Couple with children";
       tag := tag & "Couple without children";
       tag := tag & "Lone parent";
       tag := tag & "Single without children";
       return tag;
    end get_hbai_benefit_unit_type_template;

    function pretty_print( i : Household_Composition ) return String is
    begin
         case i is
             when one_male_adult_no_children_over_pension_age => return "One male adult, no children over pension age";
             when one_female_adult_no_children_over_pension_age => return "One female adult, no children over pension age";
             when one_male_adult_no_children_under_pension_age => return "One male adult, no children, under pension age";
             when one_female_adult_no_children_under_pension_age => return "One female adult, no children, under pension age";
             when two_adults_no_children_both_over_pension_age => return "Two adults, no children, both over pension age";
             when two_adults_no_children_one_over_pension_age => return "Two adults, no children, one over pension age";
             when two_adults_no_children_both_under_pension_age => return "Two adults, no children, both under pension age";
             when three_or_more_adults_no_children => return "Three or more adults, no children";
             when one_adult_one_child => return "One adult, one child";
             when one_adult_two_children => return "One adult, two children";
             when one_adult_three_or_more_children => return "One adult, three or more children";
             when two_adults_one_child => return "Two adults, one child";
             when two_adults_two_children => return "Two adults, two children";
             when two_adults_three_or_more_children => return "Two adults, three or more children";
             when three_or_more_adults_one_child => return "Three or more adults, one child";
             when three_or_more_adults_two_children => return "Three or more adults, two children";
             when three_or_more_adults_three_or_more_chidren => return "Three or more adults, three or more chidren";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_household_composition( i : integer ) return Household_Composition is
    begin
        case i is
            when 1 => return one_male_adult_no_children_over_pension_age;
            when 2 => return one_female_adult_no_children_over_pension_age;
            when 3 => return one_male_adult_no_children_under_pension_age;
            when 4 => return one_female_adult_no_children_under_pension_age;
            when 5 => return two_adults_no_children_both_over_pension_age;
            when 6 => return two_adults_no_children_one_over_pension_age;
            when 7 => return two_adults_no_children_both_under_pension_age;
            when 8 => return three_or_more_adults_no_children;
            when 9 => return one_adult_one_child;
            when 10 => return one_adult_two_children;
            when 11 => return one_adult_three_or_more_children;
            when 12 => return two_adults_one_child;
            when 13 => return two_adults_two_children;
            when 14 => return two_adults_three_or_more_children;
            when 15 => return three_or_more_adults_one_child;
            when 16 => return three_or_more_adults_two_children;
            when 17 => return three_or_more_adults_three_or_more_chidren;
            when others => return missing;
        end case;
    end convert_household_composition;


    function get_household_composition_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "One male adult, no children over pension age";
       tag := tag & "One female adult, no children over pension age";
       tag := tag & "One male adult, no children, under pension age";
       tag := tag & "One female adult, no children, under pension age";
       tag := tag & "Two adults, no children, both over pension age";
       tag := tag & "Two adults, no children, one over pension age";
       tag := tag & "Two adults, no children, both under pension age";
       tag := tag & "Three or more adults, no children";
       tag := tag & "One adult, one child";
       tag := tag & "One adult, two children";
       tag := tag & "One adult, three or more children";
       tag := tag & "Two adults, one child";
       tag := tag & "Two adults, two children";
       tag := tag & "Two adults, three or more children";
       tag := tag & "Three or more adults, one child";
       tag := tag & "Three or more adults, two children";
       tag := tag & "Three or more adults, three or more chidren";
       return tag;
    end get_household_composition_template;

    function pretty_print( i : Household_Income_Band ) return String is
    begin
         case i is
             when vunder_100_a_week => return "Under £100 a week";
             when v100_and_less_than_200 => return "£100 and less than £200";
             when v200_and_less_than_300 => return "£200 and less than £300";
             when v300_and_less_than_400 => return "£300 and less than £400";
             when v400_and_less_than_500 => return "£400 and less than £500";
             when v500_and_less_than_600 => return "£500 and less than £600";
             when v600_and_less_than_700 => return "£600 and less than £700";
             when v700_and_less_than_800 => return "£700 and less than £800";
             when v800_and_less_than_900 => return "£800 and less than £900";
             when v900_and_less_than_1000 => return "£900 and less than £1000";
             when vabove_1000 => return "Above £1000";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_household_income_band( i : integer ) return Household_Income_Band is
    begin
        case i is
            when 1 => return vunder_100_a_week;
            when 2 => return v100_and_less_than_200;
            when 3 => return v200_and_less_than_300;
            when 4 => return v300_and_less_than_400;
            when 5 => return v400_and_less_than_500;
            when 6 => return v500_and_less_than_600;
            when 7 => return v600_and_less_than_700;
            when 8 => return v700_and_less_than_800;
            when 9 => return v800_and_less_than_900;
            when 10 => return v900_and_less_than_1000;
            when 11 => return vabove_1000;
            when others => return missing;
        end case;
    end convert_household_income_band;


    function get_household_income_band_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Under &#163;100 a week";
       tag := tag & "&#163;100 and less than &#163;200";
       tag := tag & "&#163;200 and less than &#163;300";
       tag := tag & "&#163;300 and less than &#163;400";
       tag := tag & "&#163;400 and less than &#163;500";
       tag := tag & "&#163;500 and less than &#163;600";
       tag := tag & "&#163;600 and less than &#163;700";
       tag := tag & "&#163;700 and less than &#163;800";
       tag := tag & "&#163;800 and less than &#163;900";
       tag := tag & "&#163;900 and less than &#163;1000";
       tag := tag & "Above &#163;1000";
       return tag;
    end get_household_income_band_template;

    function pretty_print( i : ILO_Employment_Status ) return String is
    begin
         case i is
             when full_time_employee => return "Full-time Employee";
             when part_time_employee => return "Part-time Employee";
             when full_time_self_employed => return "Full-time Self-Employed";
             when part_time_self_employed => return "Part-time Self-Employed";
             when unemployed => return "Unemployed";
             when retired => return "Retired";
             when student => return "Student";
             when looking_after_family_home => return "Looking after family/home";
             when permanently_sick_disabled => return "Permanently sick/disabled";
             when temporarily_sick_injured => return "Temporarily sick/injured";
             when other_inactive => return "Other Inactive";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_ilo_employment_status( i : integer ) return ILO_Employment_Status is
    begin
        case i is
            when 1 => return full_time_employee;
            when 2 => return part_time_employee;
            when 3 => return full_time_self_employed;
            when 4 => return part_time_self_employed;
            when 5 => return unemployed;
            when 6 => return retired;
            when 7 => return student;
            when 8 => return looking_after_family_home;
            when 9 => return permanently_sick_disabled;
            when 10 => return temporarily_sick_injured;
            when 11 => return other_inactive;
            when others => return missing;
        end case;
    end convert_ilo_employment_status;


    function get_ilo_employment_status_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Full-time Employee";
       tag := tag & "Part-time Employee";
       tag := tag & "Full-time Self-Employed";
       tag := tag & "Part-time Self-Employed";
       tag := tag & "Unemployed";
       tag := tag & "Retired";
       tag := tag & "Student";
       tag := tag & "Looking after family/home";
       tag := tag & "Permanently sick/disabled";
       tag := tag & "Temporarily sick/injured";
       tag := tag & "Other Inactive";
       return tag;
    end get_ilo_employment_status_template;

    function pretty_print( i : Marital_Status ) return String is
    begin
         case i is
             when married => return "Married";
             when cohabiting => return "Cohabiting";
             when single => return "Single";
             when widowed => return "Widowed";
             when separated => return "Separated";
             when divorced => return "Divorced";
             when missing => return "Null or Missing";
             when same_sex_couple => return "Same Sex Couple";
         end case;
         return "?";
    end pretty_print;


     function convert_marital_status( i : integer ) return Marital_Status is
    begin
        case i is
            when 1 => return married;
            when 2 => return cohabiting;
            when 3 => return single;
            when 4 => return widowed;
            when 5 => return separated;
            when 6 => return divorced;
            when 7 => return same_sex_couple;
            when others => return missing;
        end case;
    end convert_marital_status;


    function get_marital_status_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Married";
       tag := tag & "Cohabiting";
       tag := tag & "Single";
       tag := tag & "Widowed";
       tag := tag & "Separated";
       tag := tag & "Divorced";
       return tag;
    end get_marital_status_template;

    function pretty_print( i : Non_Dependency_Class ) return String is
    begin
         case i is
             when boarder => return "Boarder";
             when lodger => return "Lodger";
             when vaged_18plus_working_full_time => return "Aged 18+ Working Full Time";
             when vaged_18plus_on_yts_jobskills => return "Aged 18+ on YTS/Jobskills";
             when vaged_18_24_on_is => return "Aged 18-24 on IS";
             when vaged_25plus_on_is => return "Aged 25+ on IS";
             when student => return "Student";
             when vothers_18plus => return "Others 18+";
             when vaged_16_17 => return "Aged 16-17";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_non_dependency_class( i : integer ) return Non_Dependency_Class is
    begin
        case i is
            when 1 => return boarder;
            when 2 => return lodger;
            when 3 => return vaged_18plus_working_full_time;
            when 4 => return vaged_18plus_on_yts_jobskills;
            when 5 => return vaged_18_24_on_is;
            when 6 => return vaged_25plus_on_is;
            when 7 => return student;
            when 8 => return vothers_18plus;
            when 9 => return vaged_16_17;
            when others => return missing;
        end case;
    end convert_non_dependency_class;


    function get_non_dependency_class_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Boarder";
       tag := tag & "Lodger";
       tag := tag & "Aged 18+ Working Full Time";
       tag := tag & "Aged 18+ on YTS/Jobskills";
       tag := tag & "Aged 18-24 on IS";
       tag := tag & "Aged 25+ on IS";
       tag := tag & "Student";
       tag := tag & "Others 18+";
       tag := tag & "Aged 16-17";
       return tag;
    end get_non_dependency_class_template;

    function pretty_print( i : Old_Region ) return String is
    begin
         case i is
             when north_east => return "North East";
             when north_west => return "North West";
             when merseyside => return "Merseyside";
             when yorks_and_humberside => return "Yorks and Humberside";
             when east_midlands => return "East Midlands";
             when west_midlands => return "West Midlands";
             when eastern => return "Eastern";
             when london => return "London";
             when south_east => return "South East";
             when south_west => return "South West";
             when wales => return "Wales";
             when scotland => return "Scotland";
             when northern_ireland => return "Northern Ireland";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_old_region( i : integer ) return Old_Region is
    begin
        case i is
            when 1 => return north_east;
            when 2 => return north_west;
            when 3 => return merseyside;
            when 4 => return yorks_and_humberside;
            when 5 => return east_midlands;
            when 6 => return west_midlands;
            when 7 => return eastern;
            when 8 => return london;
            when 9 => return south_east;
            when 10 => return south_west;
            when 11 => return wales;
            when 12 => return scotland;
            when 13 => return northern_ireland;
            when others => return missing;
        end case;
    end convert_old_region;


    function get_old_region_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "North East";
       tag := tag & "North West";
       tag := tag & "Merseyside";
       tag := tag & "Yorks and Humberside";
       tag := tag & "East Midlands";
       tag := tag & "West Midlands";
       tag := tag & "Eastern";
       tag := tag & "London";
       tag := tag & "South East";
       tag := tag & "South West";
       tag := tag & "Wales";
       tag := tag & "Scotland";
       tag := tag & "Northern Ireland";
       return tag;
    end get_old_region_template;

    function pretty_print( i : Pension_Types ) return String is
    begin
         case i is
             when basic_pension => return "Basic pension";
             when basic_increment => return "Basic increment";
             when graduated_pension => return "Graduated pension";
             when age_addition => return "Age Addition";
             when increase_of_pension_for_an_adult => return "Increase of Pension for an Adult";
             when increase_of_pension_for_children => return "Increase of Pension for Children";
             when invalidity_addition => return "Invalidity addition";
             when attendance_allowance => return "Attendance allowance";
             when additonl_pension_before_contracted_out_dedct => return "Additonl pension before contracted out dedct";
             when contracted_out_deduction => return "Contracted out deduction";
             when add_pension_after_contracted_out_deduct => return "Add pension: after contracted out deduct";
             when additional_pension_increments => return "Additional pension increments";
             when upgrading_of_contracted_out_increments => return "Upgrading of contracted out increments";
             when care_component_high => return "Care Component - High";
             when care_component_middle => return "Care Component - Middle";
             when care_component_low => return "Care Component - Low";
             when mobility_component_high => return "Mobility Component - High";
             when mobility_component_low => return "Mobility Component - Low";
             when pension_credit_guaranteed_element_amt => return "Pension Credit Guaranteed Element Amt";
             when pension_credit_savings_element_amt => return "Pension Credit Savings Element Amt";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_pension_types( i : integer ) return Pension_Types is
    begin
        case i is
            when 1 => return basic_pension;
            when 2 => return basic_increment;
            when 3 => return graduated_pension;
            when 4 => return age_addition;
            when 5 => return increase_of_pension_for_an_adult;
            when 6 => return increase_of_pension_for_children;
            when 7 => return invalidity_addition;
            when 8 => return attendance_allowance;
            when 9 => return additonl_pension_before_contracted_out_dedct;
            when 10 => return contracted_out_deduction;
            when 11 => return add_pension_after_contracted_out_deduct;
            when 12 => return additional_pension_increments;
            when 13 => return upgrading_of_contracted_out_increments;
            when 14 => return care_component_high;
            when 15 => return care_component_middle;
            when 16 => return care_component_low;
            when 17 => return mobility_component_high;
            when 18 => return mobility_component_low;
            when 19 => return pension_credit_guaranteed_element_amt;
            when 20 => return pension_credit_savings_element_amt;
            when others => return missing;
        end case;
    end convert_pension_types;


    function get_pension_types_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Basic pension";
       tag := tag & "Basic increment";
       tag := tag & "Graduated pension";
       tag := tag & "Age Addition";
       tag := tag & "Increase of Pension for an Adult";
       tag := tag & "Increase of Pension for Children";
       tag := tag & "Invalidity addition";
       tag := tag & "Attendance allowance";
       tag := tag & "Additonl pension before contracted out dedct";
       tag := tag & "Contracted out deduction";
       tag := tag & "Add pension: after contracted out deduct";
       tag := tag & "Additional pension increments";
       tag := tag & "Upgrading of contracted out increments";
       tag := tag & "Care Component - High";
       tag := tag & "Care Component - Middle";
       tag := tag & "Care Component - Low";
       tag := tag & "Mobility Component - High";
       tag := tag & "Mobility Component - Low";
       tag := tag & "Pension Credit Guaranteed Element Amt";
       tag := tag & "Pension Credit Savings Element Amt";
       return tag;
    end get_pension_types_template;

    function pretty_print( i : Regional_Stratifier ) return String is
    begin
         case i is
             when north_east_met => return "North East Met";
             when north_east_non_met => return "North East Non Met";
             when north_west_met => return "North West Met";
             when north_west_non_met => return "North West Non Met";
             when merseyside => return "Merseyside";
             when yorks_and_humberside_met => return "Yorks and Humberside Met";
             when yorks_and_humberside_non_met => return "Yorks and Humberside Non Met";
             when east_midlands => return "East Midlands";
             when west_midlands_met => return "West Midlands Met";
             when west_midlands_non_met => return "West Midlands Non Met";
             when eastern_outer_metropolitan => return "Eastern Outer Metropolitan";
             when eastern_other => return "Eastern Other";
             when london_north_east => return "London - North East";
             when london_north_west => return "London - North West";
             when london_south_east => return "London - South East";
             when london_south_west => return "London - South West";
             when south_east_outer_met => return "South East Outer Met";
             when south_east_other => return "South East Other";
             when south_west => return "South West";
             when glamorgan_gwent => return "Glamorgan, Gwent";
             when clwyd_gwynedd_dyfed_powys => return "Clwyd, Gwynedd, Dyfed, Powys";
             when highland_grampian_tayside => return "Highland Grampian, Tayside";
             when fife_central_lothian => return "Fife, Central, Lothian";
             when glasgow => return "Glasgow";
             when strathclyde_ex_glasgow => return "Strathclyde ex Glasgow";
             when borders_dumfries_and_galloway => return "Borders, Dumfries and Galloway";
             when north_of_the_caledonian_canal => return "North of the Caledonian Canal";
             when northern_ireland => return "Northern Ireland";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_regional_stratifier( i : integer ) return Regional_Stratifier is
    begin
        case i is
            when 1 => return north_east_met;
            when 2 => return north_east_non_met;
            when 3 => return north_west_met;
            when 4 => return north_west_non_met;
            when 5 => return merseyside;
            when 6 => return yorks_and_humberside_met;
            when 7 => return yorks_and_humberside_non_met;
            when 8 => return east_midlands;
            when 9 => return west_midlands_met;
            when 10 => return west_midlands_non_met;
            when 11 => return eastern_outer_metropolitan;
            when 12 => return eastern_other;
            when 13 => return london_north_east;
            when 14 => return london_north_west;
            when 15 => return london_south_east;
            when 16 => return london_south_west;
            when 17 => return south_east_outer_met;
            when 18 => return south_east_other;
            when 19 => return south_west;
            when 20 => return glamorgan_gwent;
            when 21 => return clwyd_gwynedd_dyfed_powys;
            when 22 => return highland_grampian_tayside;
            when 23 => return fife_central_lothian;
            when 24 => return glasgow;
            when 25 => return strathclyde_ex_glasgow;
            when 26 => return borders_dumfries_and_galloway;
            when 27 => return north_of_the_caledonian_canal;
            when 30 => return northern_ireland;
            when others => return missing;
        end case;
    end convert_regional_stratifier;


    function get_regional_stratifier_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "North East Met";
       tag := tag & "North East Non Met";
       tag := tag & "North West Met";
       tag := tag & "North West Non Met";
       tag := tag & "Merseyside";
       tag := tag & "Yorks and Humberside Met";
       tag := tag & "Yorks and Humberside Non Met";
       tag := tag & "East Midlands";
       tag := tag & "West Midlands Met";
       tag := tag & "West Midlands Non Met";
       tag := tag & "Eastern Outer Metropolitan";
       tag := tag & "Eastern Other";
       tag := tag & "London - North East";
       tag := tag & "London - North West";
       tag := tag & "London - South East";
       tag := tag & "London - South West";
       tag := tag & "South East Outer Met";
       tag := tag & "South East Other";
       tag := tag & "South West";
       tag := tag & "Glamorgan, Gwent";
       tag := tag & "Clwyd, Gwynedd, Dyfed, Powys";
       tag := tag & "Highland Grampian, Tayside";
       tag := tag & "Fife, Central, Lothian";
       tag := tag & "Glasgow";
       tag := tag & "Strathclyde ex Glasgow";
       tag := tag & "Borders, Dumfries and Galloway";
       tag := tag & "North of the Caledonian Canal";
       tag := tag & "Northern Ireland";
       return tag;
    end get_regional_stratifier_template;

    function pretty_print( i : Relationship_To_Head_Of_Household ) return String is
    begin
         case i is
             when spouse => return "Spouse";
             when cohabitee => return "Cohabitee";
             when son_daughter_incl_adopted => return "Son/daughter (incl. adopted)";
             when step_son_daughter => return "Step-son/daughter";
             when foster_child => return "Foster child";
             when son_in_law_daughter_in_law => return "Son-in-law/daughter-in-law";
             when parent => return "Parent";
             when step_parent => return "Step-parent";
             when foster_parent => return "Foster parent";
             when parent_in_law => return "Parent-in-law";
             when brother_sister_incl_adopted => return "Brother/sister (incl. adopted)";
             when step_brother_sister => return "Step-brother/sister";
             when foster_brother_sister => return "Foster brother/sister";
             when brother_sister_in_law => return "Brother/sister-in-law";
             when grand_child => return "Grand-child";
             when grand_parent => return "Grand-parent";
             when other_relative => return "Other relative";
             when other_non_relative => return "Other non-relative";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_relationship_to_head_of_household( i : integer ) return Relationship_To_Head_Of_Household is
    begin
        case i is
            when 1 => return spouse;
            when 2 => return cohabitee;
            when 3 => return son_daughter_incl_adopted;
            when 4 => return step_son_daughter;
            when 5 => return foster_child;
            when 6 => return son_in_law_daughter_in_law;
            when 7 => return parent;
            when 8 => return step_parent;
            when 9 => return foster_parent;
            when 10 => return parent_in_law;
            when 11 => return brother_sister_incl_adopted;
            when 12 => return step_brother_sister;
            when 13 => return foster_brother_sister;
            when 14 => return brother_sister_in_law;
            when 15 => return grand_child;
            when 16 => return grand_parent;
            when 17 => return other_relative;
            when 18 => return other_non_relative;
            when others => return missing;
        end case;
    end convert_relationship_to_head_of_household;


    function get_relationship_to_head_of_household_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Spouse";
       tag := tag & "Cohabitee";
       tag := tag & "Son/daughter (incl. adopted)";
       tag := tag & "Step-son/daughter";
       tag := tag & "Foster child";
       tag := tag & "Son-in-law/daughter-in-law";
       tag := tag & "Parent";
       tag := tag & "Step-parent";
       tag := tag & "Foster parent";
       tag := tag & "Parent-in-law";
       tag := tag & "Brother/sister (incl. adopted)";
       tag := tag & "Step-brother/sister";
       tag := tag & "Foster brother/sister";
       tag := tag & "Brother/sister-in-law";
       tag := tag & "Grand-child";
       tag := tag & "Grand-parent";
       tag := tag & "Other relative";
       tag := tag & "Other non-relative";
       return tag;
    end get_relationship_to_head_of_household_template;

    function pretty_print( i : Standard_Region ) return String is
    begin
         case i is
             when north_east => return "North East";
             when north_west_and_merseyside => return "North West and Merseyside";
             when yorks_and_humberside => return "Yorks and Humberside";
             when east_midlands => return "East Midlands";
             when west_midlands => return "West Midlands";
             when eastern => return "Eastern";
             when london => return "London";
             when south_east => return "South East";
             when south_west => return "South West";
             when wales => return "Wales";
             when scotland => return "Scotland";
             when northern_ireland => return "Northern Ireland";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_standard_region( i : integer ) return Standard_Region is
    begin
        case i is
            when 1 => return north_east;
            when 2 => return north_west_and_merseyside;
            when 4 => return yorks_and_humberside;
            when 5 => return east_midlands;
            when 6 => return west_midlands;
            when 7 => return eastern;
            when 8 => return london;
            when 9 => return south_east;
            when 10 => return south_west;
            when 11 => return wales;
            when 12 => return scotland;
            when 13 => return northern_ireland;
            when others => return missing;
        end case;
    end convert_standard_region;


    function get_standard_region_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "North East";
       tag := tag & "North West and Merseyside";
       tag := tag & "Yorks and Humberside";
       tag := tag & "East Midlands";
       tag := tag & "West Midlands";
       tag := tag & "Eastern";
       tag := tag & "London";
       tag := tag & "South East";
       tag := tag & "South West";
       tag := tag & "Wales";
       tag := tag & "Scotland";
       tag := tag & "Northern Ireland";
       return tag;
    end get_standard_region_template;

    function pretty_print( i : Tenure_Type ) return String is
    begin
         case i is
             when owns_it_outright => return "Owns it outright";
             when buying_with_the_help_of_a_mortgage => return "Buying with the help of a mortgage";
             when part_own_part_rent => return "Part own, part rent";
             when rents => return "Rents";
             when rent_free => return "Rent-free";
             when squatting => return "Squatting";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


     function convert_tenure_type( i : integer ) return Tenure_Type is
    begin
        case i is
            when 1 => return owns_it_outright;
            when 2 => return buying_with_the_help_of_a_mortgage;
            when 3 => return part_own_part_rent;
            when 4 => return rents;
            when 5 => return rent_free;
            when 6 => return squatting;
            when others => return missing;
        end case;
    end convert_tenure_type;


    function get_tenure_type_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Owns it outright";
       tag := tag & "Buying with the help of a mortgage";
       tag := tag & "Part own, part rent";
       tag := tag & "Rents";
       tag := tag & "Rent-free";
       tag := tag & "Squatting";
       return tag;
    end get_tenure_type_template;
    
    function pretty_print( i : Gender ) return String is
    begin
         case i is
             when male => return "Male";
             when female => return "Female";
             when missing => return "Null or Missing";
         end case;
         return "?";
    end pretty_print;


    function convert_gender( i : integer ) return Gender is
    begin
        case i is
            when 1 => return male;
            when 2 => return female;
            when others => return missing;
        end case;
    end convert_gender;

    function get_gender_template return  Templates_Parser.Tag is
       tag : Templates_Parser.Tag;
    begin
       tag := tag & "Null or Missing";
       tag := tag & "Male";
       tag := tag & "Female";
       return tag;
    end get_gender_template;


    

end FRS_Enums;
