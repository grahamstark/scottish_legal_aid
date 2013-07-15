with text_io;
package body local is
function f ( i : integer ) return String is
begin
   if ( i = 1 ) then
      return "hello mum";
   elsif ( i = 2 ) then
      return "12345";
   end if;
   return "??";
end f;
end local;


