with ada.text_io;
with base_model_types; use base_model_types;
package FRS_Utils is

        subtype SernumString is String (1 .. 10);

        function readSernum ( file : ada.text_io.FILE_TYPE ) return SernumString;

   function real_to_money (r : real) return money;
           function int_to_money (r : integer) return money;


        function zero_or_missing ( r : money ) return boolean;

        function zero_or_missing ( r : real ) return boolean;

end FRS_Utils;
