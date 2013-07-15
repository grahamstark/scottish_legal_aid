--
--  $Author:$
--  $Date:$
--  $Revision:$
--
with optimal_rate_searcher;
with base_model_types; 
with la_parameters; 

procedure optimal_rate_driver is
   
   use optimal_rate_searcher;
   use base_model_types;
   use la_parameters; 

   ctl : Control_Record;
   sys : Legal_Aid_Sys := Get_Default_System;
   
begin

   sys.contributions (income).contribution_proportion := ( 1=>One_Third, 2=>One_Third, others=>0.0 );
   sys.contributions (income).numContributions := 2;

   ctl.rate_start := 1.0; -- sys.contributions (income).contribution_proportion(2);
   ctl.rate_end := 1.0;
   ctl.limit_start := sys.upper_limit( income, normalClaim );
   sys.contributions (income).contribution_band := ( 1 => 6785.00, 2  => money'Last, others=> 0.0 );
   ctl.limit_end := 15_000.0;
   calibrate_settings( ctl );
   generate_searches( sys, ctl );
   print_searches( "test.txt" );

end optimal_rate_driver;
