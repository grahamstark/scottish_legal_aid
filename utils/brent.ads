--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
--  implements brent's method for finding a miminum of an arbtrary function
--  from Numerical Recipies (Pascal) ch 10.,
--  from Numerical Recipies (Pascal) ch 9.3,
--
--  FIXME: we should really make this generic, with the Brent just being a
--  plugin algorithm a la the Jakarta maths package. We should move the control record somewhere
--  else
--  in case I need the Budget constraint algorithm or something.
--
with base_model_types; use base_model_types;


package brent is

   MAX_ITERATIONS  : constant := 100;
   GOLDEN_RATIO    : constant := 0.3819660;
   NEARLY_ZERO     : constant := 1.0E-10;
   STD_TOLERANCE   : constant := 0.01;
   STD_INCREMEMENT : constant := 0.01;

   type Error_Conditions is (NoError, TooManyIterations, RootNotBracketed, OtherOptimumProblem);

   type Point_Rec is
      record
         x, y : real;
      end record;

   type Point_Array is array (1 .. MAX_ITERATIONS + 1) of Point_Rec;

   --
   --  general thing to control an optimisation. Start and stop bracket the search
   --  options1..6 can be used to pass arbitrary controls to the callback func
   --
   type Control_Rec is
      record
         start   : real;
         stop    : real;
         tol     : real    := STD_TOLERANCE;
         incr    : real    := STD_INCREMEMENT;
         option1 : Integer := 0;
         option2 : Integer := 0;
         option3 : Integer := 0;
         option4 : Integer := 0;
         option5 : Integer := 0;
         option6 : Integer := 0;
      end record;

   --
   --  this just allows us to gather up any interesting other things that the
   --  optimisation is throwning out. FIMXE Maybe we should make this Generic somehow?
   --
   MAX_NUM_INTERMEDIATES : constant := 20;
   type Intermediate_Data_Array is array (1 .. MAX_NUM_INTERMEDIATES) of real;

   type Optimisation_Output is
      record
         minimum           : real;
         intermediate_data : Intermediate_Data_Array;
      end record;

   --
   --  defines the function. We can pass in tolerances, bracketing information
   --  and anything else we want via the control record
   --
   type Minimand is access function (control : Control_Rec; m : real) return Optimisation_Output;

   --
   --
   --  returns:
   --
   procedure Optimise
     (control           : in out Control_Rec;
      calc              : Minimand;
      optimum_x         : in out real;
      optimum_y         : in out real;
      stored_points     : in out Point_Array;
      intermediate_data : in out Intermediate_Data_Array;
      num_iterations    : in out Integer;
      err               : in out Error_Conditions);

end brent;
