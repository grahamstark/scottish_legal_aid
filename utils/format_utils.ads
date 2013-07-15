--
-- $Revision $
-- $Author $
-- $Date $
--

with base_model_types;    use base_model_types;
with Ada.Strings.Bounded;
with Text_Utils;          use Text_Utils;
--
--
--
--
package format_utils is

   use StdBoundedString;

   function format_with_commas (m : money) return String;
   function format_with_commas (r : real) return String;
   function format_with_commas (i : Integer) return String;
   function format (m : money) return String;
   function format (r : real) return String;
   function format (r : sreal) return String;
   function format (i : Integer) return String;
   function format_counts (m : money) return String;

   procedure validate
     (inputStr : String;
      val      : in out money;
      message  : in out Bounded_String;
      min      : money := money'First;
      max      : money := money'Last);

   procedure validate
     (inputStr : String;
      val      : in out real;
      message  : in out Bounded_String;
      min      : real := real'First;
      max      : real := real'Last);

   procedure validate
     (inputStr : String;
      val      : in out Integer;
      message  : in out Bounded_String;
      min      : Integer := Integer'First;
      max      : Integer := Integer'Last);

   --          procedure validate
   --                 (inputStr : String;
   --                  val      : in out modelint;
   --                  message  : in out Bounded_String;
   --                  min      : modelint := modelint'First;
   --                  max      : modelint := modelint'Last);

end format_utils;
