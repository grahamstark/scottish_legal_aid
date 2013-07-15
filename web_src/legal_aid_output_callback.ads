--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with AWS.Response;
with AWS.Status;

package legal_aid_output_callback is

        function output_callback (Request : in AWS.Status.Data) return AWS.Response.Data;

end legal_aid_output_callback;
