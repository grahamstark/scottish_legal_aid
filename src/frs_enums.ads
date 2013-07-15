--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--

with Templates_Parser;

package FRS_Enums is

      type Acorn is (
      missing,
      no_population_data_available,
      thriving_wealthy_suburbs_large_detached_houses,
      thriving_villages_with_wealthy_commuters,
      thriving_mature_affluent_home_owning_areas,
      thriving_affluent_suburbs_older_families,
      thriving_mature_well_off_suburbs,
      thriving_agricultural_villages_home_based_workers,
      thriving_hol_retreats_oldr_people_home_based_workers,
      thriving_home_owning_areas_well_off_older_residents,
      thriving_private_flats_elderly_people,
      expanding_affluent_working_families_with_mortgages,
      expanding_affluent_wrkng_cpls_with_mortgs_new_homes,
      expanding_transient_wrkfrcs_livng_at_their_place_of_wrk,
      expanding_home_owning_family_areas,
      expanding_home_owning_family_areas_older_children,
      expanding_families_with_mortgages_younger_children,
      rising_well_off_town_and_city_areas,
      rising_flats_and_mortgs_singles_and_young_wrkng_couples,
      rising_furnshed_flats_and_bedsits_ynger_single_people,
      rising_aprtmnts_yng_professional_singles_and_couples,
      rising_gentrified_multi_ethnic_areas,
      rising_prosperous_enclaves_highly_qualified_exectivs,
      rising_academic_cntrs_studnts_and_young_professionals,
      rising_affluent_city_centre_areas_tenements_and_flats,
      rising_partially_gentrified_multi_ethnic_areas,
      rising_converted_flats_and_bedsits_single_people,
      settling_mature_established_home_owning_areas,
      settling_rural_areas_mixed_occupations,
      settling_established_home_owning_areas,
      settling_hme_owng_areas_council_tenants_retired_pple,
      settling_estblshd_home_owning_areas_skilled_workers,
      settling_home_owners_in_oldr_proprts_younger_wrkrs,
      settling_home_owning_areas_with_skilled_workers,
      aspiring_council_areas_some_new_home_owners,
      aspiring_mature_home_owning_areas_skilled_workers,
      aspiring_low_rise_estates_oldr_wrkrs_new_home_ownrs,
      aspiring_home_ownng_multi_ethnic_areas_young_famils,
      aspiring_multi_occupied_town_cntrs_mixed_occupations,
      aspiring_multi_ethnic_areas_white_collar_workers,
      striving_home_ownrs_small_councl_flats_singl_pensnrs,
      striving_council_areas_older_people_health_problems,
      striving_better_off_council_areas_new_home_owners,
      striving_concil_areas_yng_famles_sme_new_hme_oners,
      striving_council_areas_yng_famls_many_lone_parents,
      striving_multi_occupied_terraces_multi_ethnic_areas,
      striving_low_rise_council_housing_less_well_off_famls,
      striving_council_areas_residents_with_health_problems,
      striving_estates_with_high_unemployment,
      striving_council_flats_elderly_people_health_problems,
      striving_council_flats_very_high_unemploymnt_singles,
      striving_council_areas_high_unemploymnt_one_parents,
      striving_council_flats_greatst_hrdshp_many_lone_parnts,
      striving_multi_ethnic_large_families_overcrowding,
      striving_multi_ethnic_severe_unemplymnt_lone_parents,
      striving_multi_ethnic_high_unemploymnt_overcrowding,
      area_where_code_not_yet_assigned
   );

   function pretty_print( i : Acorn ) return String;
   function convert_acorn( i : integer ) return Acorn;
   function get_acorn_template return  Templates_Parser.Tag;


   type Adult_Employment_Status is (
      missing,
      self_employed,
      full_time_employee,
      part_time_employee,
      ft_employee_temporarily_sick,
      pt_employee_temporarily_sick,
      industrial_action,
      unemployed,
      work_related_govt_training,
      retired,
      unoccupied_under_retirement_age,
      temporarily_sick,
      long_term_sick,
      students_in_non_advanced_fe,
      unpaid_family_workers
   );

   function pretty_print( i : Adult_Employment_Status ) return String;
   function convert_adult_employment_status( i : integer ) return Adult_Employment_Status;
   function get_adult_employment_status_template return  Templates_Parser.Tag;


   type Age_Group is (
      missing,
      vage_16_to_24,
      vage_25_to_34,
      vage_35_to_44,
      vage_45_to_54,
      vage_55_to_59,
      vage_60_to_64,
      vage_65_to_74,
      vage_75_to_84,
      vage_85_or_over
   );

   function pretty_print( i : Age_Group ) return String;
   function convert_age_group( i : integer ) return Age_Group;
   function get_age_group_template return  Templates_Parser.Tag;


   type Aggregated_Ethnic_Group is (
      missing,
      white,
      mixed,
      asian_or_asian_british,
      black_or_black_british,
      chinese_or_other_ethnic_group
   );

   function pretty_print( i : Aggregated_Ethnic_Group ) return String;
   function convert_aggregated_ethnic_group( i : integer ) return Aggregated_Ethnic_Group;
   function get_aggregated_ethnic_group_template return  Templates_Parser.Tag;


   type Benefit_Types is (
      missing,
      dla_self_care,
      dla_mobility,
      child_benefit,
      pension_credit,
      retirement_pension_opp,
      widows_pension_bereavement_allowance,
      widowed_mothers_widowed_parents_allowance,
      war_disablement_pension,
      war_widows_widowers_pension,
      severe_disability_allowance,
      disabled_persons_tax_credit,
      attendence_allowance,
      invalid_care_allowance,
      jobseekers_allowance,
      industrial_injury_disablement_benefit,
      incapacity_benefit,
      working_families_tax_credit,
      income_support,
      new_deal,
      maternity_allowance,
      maternity_grant_from_social_fund,
      funeral_grant_from_social_fund,
      community_care_grant_from_social_fund,
      back_to_work_bonus_received,
      back_to_work_bonus_accrued,
      any_other_ni_or_state_benefit,
      trade_union_sick_strike_pay,
      friendly_society_benefits,
      private_sickness_scheme_benefits,
      accident_insurance_scheme_benefits,
      hospital_savings_scheme_benefits,
      government_training_allowances,
      guardians_allowance,
      social_fund_loan_budgeting,
      social_fund_loan_crisis,
      working_families_tax_credit_lump_sum,
      future_dla_self_care,
      future_dla_mobility,
      future_attendance_allowance,
      disabled_persons_tax_credit_lump_sum,
      child_maintenance_bonus,
      lone_parent_benefit_run_on,
      widows_payment,
      unemployment_redundancy_insurance,
      winter_fuel_payments,
      dwp_direct_payments_isa,
      dwp_direct_payments_jsa,
      hb_only_or_separately,
      ctb_only_or_separately,
      hb_ctb_paid_together,
      permanent_health_insurance,
      any_other_sickness_insurance,
      critical_illness_cover,
      working_tax_credit,
      child_tax_credit,
      working_tax_credit_lump_sum,
      child_tax_credit_lump_sum
   );

   function pretty_print( i : Benefit_Types ) return String;
   function convert_benefit_types( i : integer ) return Benefit_Types;
   function get_benefit_types_template return  Templates_Parser.Tag;


   type Benefit_Unit_Economic_Status is (
      missing,
      self_employed,
      v1_or_2_adults_in_f_t_employed_work,
      v2_adults_one_in_f_t_other_p_t,
      v2_adults_one_f_t_as_employee_other_not,
      v1_or_2_adults_at_least_1_in_p_t_work,
      v1_or_2_adults_head_or_spouse_aged_60plus,
      v1_or_2_adults_hd_or_sp_unemployed,
      v1_or_2_adults_hd_or_sp_sick_lt_pen_age,
      any_other_category
   );

   function pretty_print( i : Benefit_Unit_Economic_Status ) return String;
   function convert_benefit_unit_economic_status( i : integer ) return Benefit_Unit_Economic_Status;
   function get_benefit_unit_economic_status_template return  Templates_Parser.Tag;


   type Benefit_Unit_Type is (
      missing,
      any_other_category,
      pensioner_couple,
      pensioner_single,
      couple_with_children,
      couple_without_children,
      lone_parent,
      single_without_children
   );

   function pretty_print( i : Benefit_Unit_Type ) return String;
   function convert_benefit_unit_type( i : integer ) return Benefit_Unit_Type;
   function get_benefit_unit_type_template return  Templates_Parser.Tag;


   type BU_Disabled_Indicator is (
      missing,
      v1_person_in_bu_blind,
      v2_people_in_bu_blind,
      v1_person_in_bu_disabled,
      v2_people_in_bu_disabled,
      v1_person_blind_and_1_person_disabled,
      no_one_blind_or_disabled
   );

   function pretty_print( i : BU_Disabled_Indicator ) return String;
   function convert_bu_disabled_indicator( i : integer ) return BU_Disabled_Indicator;
   function get_bu_disabled_indicator_template return  Templates_Parser.Tag;


   type Employment_Status is (
      missing,
      self_employed,
      full_time_employee,
      part_time_employee,
      ft_employee_temporarily_sick,
      pt_employee_temporarily_sick,
      industrial_action,
      unemployed,
      work_related_govt_training,
      retired,
      unoccupied_under_retirement_age,
      temporarily_sick,
      long_term_sick,
      students_in_non_advanced_fe,
      unpaid_family_workers
   );

   function pretty_print( i : Employment_Status ) return String;
   function convert_employment_status( i : integer ) return Employment_Status;
   function get_employment_status_template return  Templates_Parser.Tag;


   type Ethnic_Group is (
      missing,
      white_british,
      any_other_white_background,
      mixed_white_and_black_caribbean,
      mixed_white_and_black_african,
      mixed_white_and_asian,
      any_other_mixed_background,
      asian_or_asian_british_indian,
      asian_or_asian_british_pakistani,
      asian_or_asian_british_bangladeshi,
      any_other_asian_asian_british_background,
      black_or_black_british_caribbean,
      black_or_black_british_african,
      any_other_black_black_british_background,
      chinese,
      any_other
   );

   function pretty_print( i : Ethnic_Group ) return String;
   function convert_ethnic_group( i : integer ) return Ethnic_Group;
   function get_ethnic_group_template return  Templates_Parser.Tag;


   type HBAI_Benefit_Unit_Type is (
      missing,
      any_other_category,
      pensioner_couple,
      pensioner_single,
      couple_with_children,
      couple_without_children,
      lone_parent,
      single_without_children
   );

   function pretty_print( i : HBAI_Benefit_Unit_Type ) return String;
   function convert_hbai_benefit_unit_type( i : integer ) return HBAI_Benefit_Unit_Type;
   function get_hbai_benefit_unit_type_template return  Templates_Parser.Tag;


   type Household_Composition is (
      missing,
      one_male_adult_no_children_over_pension_age,
      one_female_adult_no_children_over_pension_age,
      one_male_adult_no_children_under_pension_age,
      one_female_adult_no_children_under_pension_age,
      two_adults_no_children_both_over_pension_age,
      two_adults_no_children_one_over_pension_age,
      two_adults_no_children_both_under_pension_age,
      three_or_more_adults_no_children,
      one_adult_one_child,
      one_adult_two_children,
      one_adult_three_or_more_children,
      two_adults_one_child,
      two_adults_two_children,
      two_adults_three_or_more_children,
      three_or_more_adults_one_child,
      three_or_more_adults_two_children,
      three_or_more_adults_three_or_more_chidren
   );

   function pretty_print( i : Household_Composition ) return String;
   function convert_household_composition( i : integer ) return Household_Composition;
   function get_household_composition_template return  Templates_Parser.Tag;


   type Household_Income_Band is (
      missing,
      vunder_100_a_week,
      v100_and_less_than_200,
      v200_and_less_than_300,
      v300_and_less_than_400,
      v400_and_less_than_500,
      v500_and_less_than_600,
      v600_and_less_than_700,
      v700_and_less_than_800,
      v800_and_less_than_900,
      v900_and_less_than_1000,
      vabove_1000
   );

   function pretty_print( i : Household_Income_Band ) return String;
   function convert_household_income_band( i : integer ) return Household_Income_Band;
   function get_household_income_band_template return  Templates_Parser.Tag;


   type ILO_Employment_Status is (
      missing,
      full_time_employee,
      part_time_employee,
      full_time_self_employed,
      part_time_self_employed,
      unemployed,
      retired,
      student,
      looking_after_family_home,
      permanently_sick_disabled,
      temporarily_sick_injured,
      other_inactive
   );

   function pretty_print( i : ILO_Employment_Status ) return String;
   function convert_ilo_employment_status( i : integer ) return ILO_Employment_Status;
   function get_ilo_employment_status_template return  Templates_Parser.Tag;


   type Marital_Status is (
      missing,
      married,
      cohabiting,
      single,
      widowed,
      separated,
      divorced,
      same_sex_couple
   );

   function pretty_print( i : Marital_Status ) return String;
   function convert_marital_status( i : integer ) return Marital_Status;
   function get_marital_status_template return  Templates_Parser.Tag;


   type Non_Dependency_Class is (
      missing,
      boarder,
      lodger,
      vaged_18plus_working_full_time,
      vaged_18plus_on_yts_jobskills,
      vaged_18_24_on_is,
      vaged_25plus_on_is,
      student,
      vothers_18plus,
      vaged_16_17
   );

   function pretty_print( i : Non_Dependency_Class ) return String;
   function convert_non_dependency_class( i : integer ) return Non_Dependency_Class;
   function get_non_dependency_class_template return  Templates_Parser.Tag;


   type Old_Region is (
      missing,
      north_east,
      north_west,
      merseyside,
      yorks_and_humberside,
      east_midlands,
      west_midlands,
      eastern,
      london,
      south_east,
      south_west,
      wales,
      scotland,
      northern_ireland
   );

   function pretty_print( i : Old_Region ) return String;
   function convert_old_region( i : integer ) return Old_Region;
   function get_old_region_template return  Templates_Parser.Tag;


   type Pension_Types is (
      missing,
      basic_pension,
      basic_increment,
      graduated_pension,
      age_addition,
      increase_of_pension_for_an_adult,
      increase_of_pension_for_children,
      invalidity_addition,
      attendance_allowance,
      additonl_pension_before_contracted_out_dedct,
      contracted_out_deduction,
      add_pension_after_contracted_out_deduct,
      additional_pension_increments,
      upgrading_of_contracted_out_increments,
      care_component_high,
      care_component_middle,
      care_component_low,
      mobility_component_high,
      mobility_component_low,
      pension_credit_guaranteed_element_amt,
      pension_credit_savings_element_amt
   );

   function pretty_print( i : Pension_Types ) return String;
   function convert_pension_types( i : integer ) return Pension_Types;
   function get_pension_types_template return  Templates_Parser.Tag;


   type Regional_Stratifier is (
      missing,
      north_east_met,
      north_east_non_met,
      north_west_met,
      north_west_non_met,
      merseyside,
      yorks_and_humberside_met,
      yorks_and_humberside_non_met,
      east_midlands,
      west_midlands_met,
      west_midlands_non_met,
      eastern_outer_metropolitan,
      eastern_other,
      london_north_east,
      london_north_west,
      london_south_east,
      london_south_west,
      south_east_outer_met,
      south_east_other,
      south_west,
      glamorgan_gwent,
      clwyd_gwynedd_dyfed_powys,
      highland_grampian_tayside,
      fife_central_lothian,
      glasgow,
      strathclyde_ex_glasgow,
      borders_dumfries_and_galloway,
      north_of_the_caledonian_canal,
      northern_ireland
   );

   function pretty_print( i : Regional_Stratifier ) return String;
   function convert_regional_stratifier( i : integer ) return Regional_Stratifier;
   function get_regional_stratifier_template return  Templates_Parser.Tag;


   type Relationship_To_Head_Of_Household is (
      missing,
      spouse,
      cohabitee,
      son_daughter_incl_adopted,
      step_son_daughter,
      foster_child,
      son_in_law_daughter_in_law,
      parent,
      step_parent,
      foster_parent,
      parent_in_law,
      brother_sister_incl_adopted,
      step_brother_sister,
      foster_brother_sister,
      brother_sister_in_law,
      grand_child,
      grand_parent,
      other_relative,
      other_non_relative
   );

   function pretty_print( i : Relationship_To_Head_Of_Household ) return String;
   function convert_relationship_to_head_of_household( i : integer ) return Relationship_To_Head_Of_Household;
   function get_relationship_to_head_of_household_template return  Templates_Parser.Tag;


   type Standard_Region is (
      missing,
      north_east,
      north_west_and_merseyside,
      yorks_and_humberside,
      east_midlands,
      west_midlands,
      eastern,
      london,
      south_east,
      south_west,
      wales,
      scotland,
      northern_ireland
   );

   function pretty_print( i : Standard_Region ) return String;
   function convert_standard_region( i : integer ) return Standard_Region;
   function get_standard_region_template return  Templates_Parser.Tag;


   type Tenure_Type is (
      missing,
      owns_it_outright,
      buying_with_the_help_of_a_mortgage,
      part_own_part_rent,
      rents,
      rent_free,
      squatting
   );

   function pretty_print( i : Tenure_Type ) return String;
   function convert_tenure_type( i : integer ) return Tenure_Type;
   function get_tenure_type_template return  Templates_Parser.Tag;

   type Gender is (
      missing,
      male,
      female
   );

   function pretty_print( i : Gender ) return String;
   function convert_gender( i : integer ) return Gender;
   function get_gender_template return  Templates_Parser.Tag;

end FRS_Enums;
