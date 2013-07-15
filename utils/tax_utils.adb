--
--   $Author: graham_s $
--   $Revision: 4531 $
--   $Date: 2008-01-04 12:58:00 +0000 (Fri, 04 Jan 2008) $
--

package body tax_utils is


   MAX_SAFE_VALUE : constant := 9999999999999999.9;   



   function uprate
     (x        : money;
      uprateBy : real;
      next     : money := 0.0)
      return     money
   is
      rx    : real;
      iadd  : modelint;
      add   : real;
      rnext : real;
   begin
      --
      -- zero or some jammed on upper limit? just leave alone
      --
      if x = 0.0 or x >= MAX_SAFE_VALUE or uprateBy = 0.0 then
         return x;
      end if;
      if (next = 0.0) then
         add :=real (x) * uprateBy;
      else
         rnext := real (next);
         rx    := real (x);
         iadd  := modelint ((rx * uprateBy) / real (next));
         add   := (rnext * real (iadd)) + rnext;
      end if;
      if( (MAX_SAFE_VALUE  - Money(add)) <= x  ) then
         return x; -- would overflow: probably indicates a max-something value anyway
      end if;
      return money (rx + add);
   end uprate;

   function uprateBands
     (bands    : Basic_Array;
      numBands : modelint;
      uprateBy : real; --  enter 1.1 for a 10% increase
      next     : money := 0.0)
      return     Basic_Array
   is
      gap      : money;
      width    : Basic_Array;
      igap     : modelint;
      outArray : Basic_Array;
   begin
      if (uprateBy = 0.0) then
         outArray := bands;
      elsif (next = 0.0) then
         for b in  1 .. numBands loop
            if (bands (b) = money'Last) then
               outArray (b) := bands (b);
            else
               outArray (b) := money (real (bands (b)) * uprateBy);
            end if;
         end loop;
      else
         width (1) := bands (1);
         igap      := modelint (real (width (1)) * (uprateBy - 1.0));
         gap       := money (igap) + next;
         width (1) := width (1) + gap;
         for i in  2 .. numBands loop
            width (i) := bands (i) - bands (i - 1);
            igap      := modelint ((real (width (i)) * (uprateBy - 1.0)));
            gap       := money (igap) + next;
            width (i) := width (i) + gap;
         end loop;
         outArray (1) := width (1);
         for i in  2 .. numBands loop
            -- overflow check
            if (MAX_SAFE_VALUE  - width(i) <= outArray(i-1) ) then 
               outArray (i) := MAX_SAFE_VALUE;
            else
               outArray (i) := outArray (i - 1) + width (i);
            end if;
         end loop;
      end if;
      return outArray;
   end uprateBands;

   --
   --   make a contribution of the p th element of rate
   --   when income is greater than or equal to the p th
   --   element of bands.
   --
   function calcSteppedContribution
     (taxable  : money;
      rates    : BasicRealArray;
      bands    : Basic_Array;
      numBands : modelint)
      return     TaxResult
   is
      taxr   : money;
      result : TaxResult;
   begin
      taxr := money'Min (taxable, bands (numBands));
      for p in  1 .. numBands loop
         if (taxr < bands (p)) then
            result.endBand := p;
            result.due     := money (rates (p));
         end if;
      end loop;
      return result;
   end calcSteppedContribution;

   --
   --  old style ni tax calculation: tax is band(p) * taxdue
   --  where p is the 1st band greater or equal to taxable.
   --
   function steppedTaxCalculation
     (taxable  : money;
      rates    : BasicRealArray;
      bands    : Basic_Array;
      numBands : modelint)
      return     TaxResult
   is
      m      : real := 0.0;
      taxr   : money;
      result : TaxResult;
   begin
      taxr := money'Min (taxable, bands (numBands));
      for p in  1 .. numBands loop
         if (taxr < bands (p)) then
            result.endBand := p;
            m              := real (taxr) * rates (p);
            result.due     := money (m);
         end if;
      end loop;
      return result;
   end steppedTaxCalculation;

   --
   --  standard banded income tax - style calculation
   --
   --
   function calcTaxDue
     (taxable  : money;
      rates    : BasicRealArray;
      bands    : Basic_Array;
      numBands : modelint)
      return     TaxResult
   is
      remaining, gap : money;
      i              : modelint;
      t              : real;
      result         : TaxResult;
   begin
      --
      --  calculate in floats then convert back to fixed on exit
      --
      remaining := taxable;
      i         := 0;
      gap       := bands (1);
      while remaining > 0.0 loop
         i := i + 1;
         if i > 1 then
            if i < numBands then
               gap := bands (i) - bands (i - 1);
            else
               gap := money'Last;
            end if;
         end if;
         t          := real (money'Min (remaining, gap));
         result.due := result.due + money (t * rates (i));
         remaining  := remaining - gap;
      end loop;
      result.endBand := i;
      return result;
   end calcTaxDue;

end tax_utils;
