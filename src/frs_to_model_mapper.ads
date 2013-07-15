--
--
--
--
with base_model_types; use base_model_types;
with raw_frs; use raw_frs;
with model_household; use model_household;
with data_constants;  use data_constants;

package frs_to_model_mapper is

        function map( hh : raw_household; dyear : DataYears ) return Model_Household_Rec;

end frs_to_model_mapper;
