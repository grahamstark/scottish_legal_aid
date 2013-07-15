with base_model_types;            
with Legal_Aid_Output_Types;
with la_parameters; 
package optimal_rate_searcher_hacked_for_jo is

   use base_model_types;
   use legal_aid_output_types;
   use la_parameters;
   
   NUM_INCOME_DIVISIONS : constant integer := 20;
   NUM_RATES  : constant integer := 1; -- 78;
   NUM_LIMITS : constant integer := 6;
   
   subtype Rate_Counter is integer range 1 .. NUM_RATES;
   subtype Limit_Counter is integer range 1 .. NUM_LIMITS;
   subtype Income_Counter is integer range 1 .. NUM_INCOME_DIVISIONS;
 
   type Count_Array is array ( Income_Counter ) of SReal;
   
   type Takeup_Array is array( LA_Costs_Component, LA_Problem_Type ) of sreal; 
   
   type Problem_Array is array( LA_Problem_Type ) of sreal;
   
   type Flat_Cell is record
      Rate              : Real;
      upper_limit       : Money;
      num_benefit_units : SReal := 0.0;
      num_adults        : SReal := 0.0;
      num_people        : SReal := 0.0;
      total_num_cases   : SReal := 0.0;
      total_cost        : SReal := 0.0;
      cost_by_problem   : Problem_Array;  
      cases_by_problem  : Problem_Array;  
      cost_by_income    : Count_Array;  
      cases_by_income   : Count_Array;  
   end record;
   
   type Cell is record
      Rate              : Real;
      upper_limit       : Money;
      num_benefit_units : SReal := 0.0;
      num_adults        : SReal := 0.0;
      num_people        : SReal := 0.0;
      total_num_cases   : SReal := 0.0;
      total_cost        : SReal := 0.0;
      costs_breakdown   : Takeup_Array := ( Others => (others=>0.0 ));
      cases_by_income   : Count_Array := ( Others => 0.0 ); 
   end record;
   
   type Cell_Array is array( Rate_Counter, Limit_Counter ) of Cell;
   
   type Flat_Cell_Array is array( Rate_Counter, Limit_Counter ) of Flat_Cell;
   
   type Control_Record is record
   
      rate_increment : Real := 0.0;
      rate_start : Real; 
      rate_end : Real := 0.0;
      
      limit_increment : Money := 0.0;
      limit_start : Money := 0.0;
      limit_end   : Money := 0.0;
   end record;
   
   function generate_searches( sys : Legal_Aid_Sys; control : Control_Record; equivalise : boolean ) return Cell_Array;
   procedure print_searches( file_name : String; cells : Cell_Array );
   procedure calibrate_settings( control : in out Control_Record );

end optimal_rate_searcher_hacked_for_jo;
