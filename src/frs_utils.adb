package body FRS_Utils is

        function readSernum ( file : ada.text_io.FILE_TYPE ) return SernumString is
                serstr : SernumString := ( others => ' ');
                ch     : character;
        begin
                for p in SernumString'Range loop
         ada.text_io.get ( file, ch );
         if ( ch = ' ') then
           exit;
         end if;

                        serstr(p) := ch;
                end loop;
                return serstr;
        end readSernum;

        function real_to_money (r : real) return money is
        begin
                if (r = MISS_R) then
                        return 0.0;
                end if;
                return money (r);
        end real_to_money;

        function int_to_money (r : integer) return money is
        begin
                if (r = MISS) then
                        return 0.0;
                end if;
                return money (r);
        end int_to_money;

        function zero_or_missing ( r : money ) return boolean is
        begin
                return (( r = 0.0 ) or ( r = money(MISS_R) ));
        end zero_or_missing;

        function zero_or_missing ( r : real ) return boolean is
        begin
                return (( r = 0.0 ) or ( r = MISS_R ));
        end zero_or_missing;


end FRS_Utils;
