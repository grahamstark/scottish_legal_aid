
with Ada.Characters.Latin_1;
with Ada.Strings.Unbounded;
with Ada.Strings.Bounded;

package Text_Utils is

   INDENT : constant String := "        ";

   package ustr renames Ada.Strings.Unbounded;
   package stda renames Ada.Characters.Latin_1;
   DOS_NEW_LINE  : constant String (1 .. 2) := (stda.CR, stda.LF);
   UNIX_NEW_LINE : constant String (1 .. 1) := (1 => stda.LF);
   package String80 is new Ada.Strings.Bounded.Generic_Bounded_Length (80);
   package StdBoundedString is new Ada.Strings.Bounded.Generic_Bounded_Length (2048);

end Text_Utils;
