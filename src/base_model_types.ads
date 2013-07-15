--
--  $Author: graham_s $
--  $Date: 2007-11-13 19:16:54 +0000 (Tue, 13 Nov 2007) $
--  $Revision: 4321 $
--
--  basic types for our model;
--
with Ada.Text_IO; use Ada.Text_IO;

with Ada.Strings.Bounded; use Ada.Strings.Bounded;

package base_model_types is
   --
   --  standard types we use everywhere
   --
   type money is delta 0.01 digits 18;

   type real is new Long_Float;
   type SReal is new Float;
   
   subtype modelint is Integer;

   MISS   : constant := -12345;
   MISS_R : constant real := -12345.0;

   --
   --  some standard io packages typed for the above
   --
   package fix_io is new Ada.Text_IO.Decimal_IO (money);
   package int_io is new Ada.Text_IO.Integer_IO (modelint);
   package real_io is new Ada.Text_IO.Float_IO (real);
   package std_io is new Ada.Text_IO.Integer_IO (Integer);
   package string_io renames Ada.Text_IO;

   package Str80 is new Ada.Strings.Bounded.Generic_Bounded_Length (80);

   type Model_Array is array (Positive range <>) of real;

   function safe_add (a, b : real; c, d, e, f, g, h : real := 0.0) return money;
   function safe_add (a, b : modelint) return modelint;
   function safe_add (a, b : money) return money;
   function safe_add (a : money; b : real) return money;
   function safe_mult (a, b : real) return money;


end base_model_types;
