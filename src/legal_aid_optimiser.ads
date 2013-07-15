--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with base_model_types; use base_model_types;
with la_parameters;    use la_parameters;
with legal_aid_runner; use legal_aid_runner;    --  FIXME: we only need the run_settings.Settings_Rec, which
with run_settings;
with data_constants;   use data_constants;
with brent;
--
--  FIXME: make this generic on MAX_NUM_POINTS ...
--
--  Optimisation and iteration routines for Legal Aid,
--  and a definition of an output point.
---
package legal_aid_optimiser is

        type Point_Rec is
                record
                        x, y : money;
                end record;

        type Points_Array is array (1 .. brent.MAX_ITERATIONS) of Point_Rec;

	type Optimisation_Output is record
                multiplier, error : Money := 0.0;
                intermediates     : run_settings.Target_Array := (others => 0.0);
                num_points        : integer := 0;
                points            : Points_Array := (others=>(x=>0.0,y=>0.0));
                num_iterations    : integer := 0;
        end record;

        BLANK_OPTIMISATION_OUTPUT : constant Optimisation_Output :=
          ( multiplier=>0.0, error=>0.0, intermediates=>(others=>0.0),num_points=>0,num_iterations=>0,points=>(Others=>(x=>0.0,y=>0.0)));

        --
        --  Minimise our Legal Aid model targets with the
        --  given new parameter sysyetm and run settings.
        -- 
        function minimise
               (params         : Legal_Aid_Sys;
                sets           : run_settings.Settings_Rec ) return Optimisation_Output;
        --
        --  Used for graphics, mainly.
        --  Just call the minimand routine for a fixed set of x-values and 
        --  return the results as an array of pounts.
        --
        function iterate
               (params         : Legal_Aid_Sys;
                sets           : run_settings.Settings_Rec;
                num_iterations : Integer;
                start_Point    : real := 0.5;
                width          : real := 1.0 )
                return           Points_Array;

        function data_To_URL ( points : Points_Array; num_points : integer ) return String;
	function change_limits_from_base ( mult : Money ) return Legal_Aid_Sys;

end legal_aid_optimiser;
