--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--

with raw_frs_conversions_0304;
with raw_frs_conversions_0405;

procedure write_frs_datasets is
begin

   raw_frs_conversions_0304.write_everything_in_binary;
   raw_frs_conversions_0405.write_everything_in_binary;

end write_frs_datasets;
