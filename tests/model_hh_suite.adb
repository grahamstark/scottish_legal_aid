with AUnit.Test_Suites; use AUnit.Test_Suites;

with Hh_Test_1;
with Hh_Test_raw;
with optimum_tests;
with hh_dumper;
-- with hh_convert_takeup;

function model_hh_suite return Access_Test_Suite is
        Result : Access_Test_Suite := new Test_Suite;
begin
        -- Add_Test (Result, new hh_test_raw.Test_Case);
        Add_Test (Result, new Hh_Test_1.Test_Case);
        -- Add_Test (Result, new optimum_tests.Test_Case);
        --  Add_Test (Result, new hh_convert_takeup.Test_Case);
        -- Add_Test (Result, new hh_dumper.Test_Case);
        return Result;
end model_hh_suite;
