--
--  $Author:$
--  $Date:$
--  $Revision:$
--
with la_statistics_functions;

procedure generate_la_statistics is
begin

   la_statistics_functions.generate_costs_tests;
   la_statistics_functions.generate_upper_limits;
   la_statistics_functions.generate_model_statistics;
   la_statistics_functions.generate_counts_in_each_state;

end generate_la_statistics;
