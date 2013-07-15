--
--  $Author: graham_s $
--  $Date: 2010-02-15 13:23:15 +0000 (Mon, 15 Feb 2010) $
--  $Revision: 8643 $
--
--
--  crude user implementation with the users hard-wired in.
--
package body user is

   NUM_USERS : constant := 1;

   users : array (1 .. NUM_USERS) of UserRec := (others => INVALID_USER);

   --
   --  returns an INVALID_USER record if username/passwords don't match.
   --
   function validate (username : Bounded_String; password : Bounded_String) return UserRec is
   begin
      for i in  1 .. NUM_USERS loop
         if ((username = users (i).username) and then (password = users (i).password)) then
            return users (i);
         end if;
      end loop;
      return INVALID_USER;
   end validate;

   function validate (username : String; password : String) return UserRec is
   begin
      return validate (To_Bounded_String (username), To_Bounded_String (password));
   end validate;

   function isValid (user : UserRec) return Boolean is
   begin
      return user.username /= INVALID_USER.username;
   end isValid;

begin
   users (1) :=
     (username => To_Bounded_String ("user_x"),
      password => To_Bounded_String ("xxx"),
      title    => To_Bounded_String ("xxx"));

end user;
