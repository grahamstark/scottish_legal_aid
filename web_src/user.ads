--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with Text_Utils; use Text_Utils;

package user is

        use String80;

        type UserRec is
                record
                        username : Bounded_String;
                        password : Bounded_String;
                        title    : Bounded_String;
                end record;

        INVALID_USER : constant UserRec :=
               (username => To_Bounded_String ("INVALID"),
                password => To_Bounded_String ("INVALID"),
                title    => To_Bounded_String ("INVALID"));
        --
        --  returns an INVALID_USER record if username/passwords don't match.
        --
        function validate (username : Bounded_String; password : Bounded_String) return UserRec;
        function validate (username : String; password : String) return UserRec;
        function isValid( user : UserRec ) return boolean;

end user;
