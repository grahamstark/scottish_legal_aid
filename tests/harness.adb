with model_hh_suite;
with AUnit.Run;
with AUnit.Reporter.Text;

procedure Harness is

        procedure Run is new AUnit.RUn.Test_Runner (model_hh_suite);
        reporter : AUnit.Reporter.Text.Text_Reporter;
begin
        Run( reporter );
end Harness;
