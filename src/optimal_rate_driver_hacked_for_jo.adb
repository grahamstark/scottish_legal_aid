--
--  $Author:$
--  $Date:$
--  $Revision:$
--
with optimal_rate_searcher_hacked_for_jo;
with base_model_types; 
with la_parameters; 

procedure optimal_rate_driver_hacked_for_jo is
   
   use optimal_rate_searcher_hacked_for_jo;
   use base_model_types;
   use la_parameters; 

   ctl : Control_Record;
   sys : Legal_Aid_Sys := Get_Default_System;
   cells : Cell_Array;
begin

   sys.contributions (income).contribution_proportion := ( 1=>One_Third, 2=>One_Third, others=>0.0 );
   sys.contributions (income).numContributions := 2;

   sys.contributions (income).contribution_band := ( 1 => 6785.00, 2  => money'Last, others=> 0.0 );
   calibrate_settings( ctl );
   cells := generate_searches( sys, ctl, false );
   print_searches( "output_hacked_for_jo.sql", cells );
   cells := generate_searches( sys, ctl, true );
   print_searches( "output_hacked_for_jo_equivalised.sql", cells );

end optimal_rate_driver_hacked_for_jo;
