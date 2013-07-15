--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--

with raw_frs;
with frs_binary_reads;
with model_household;
with frs_to_model_mapper;
with text_io;

procedure write_model_datasets is
      hh           : raw_frs.Raw_Household;
      sz           : Integer := 0;
      mhh          : model_household.Model_Household_Rec;
      outputFile   : model_household.hh_io.File_Type;
      dump_File : Text_IO.File_Type;
begin
   Text_IO.Create ( dump_File, Text_IO.Out_File, "model_dump.txt");

   for year in  2003 .. 2004 loop
      model_household.initialise (outputFile, year, sz, True);
      sz := frs_binary_reads.openFiles (year);
      for href in  1 .. sz loop
         hh  := frs_binary_reads.getHousehold (href);
         mhh := frs_to_model_mapper.map (hh, year);
         model_household.hh_io.Write (outputFile, mhh);
         if( href < 20 ) then
            text_io.put (dump_file, model_household.toString (mhh ));
         end if;
      end loop;
      model_household.hh_io.close ( outputFile );
      frs_binary_reads.CloseFiles;
   end loop;

   Text_IO.close ( dump_file );

end write_model_datasets;
