--
--   $Author: graham_s $
--   $Revision: 2378 $
--   $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--

with base_model_types; use base_model_types;

package tax_utils is
   BASIC_ARRAY_SIZE : constant modelint := 20;

   type Basic_Array is array (1 .. BASIC_ARRAY_SIZE) of money;
   type Basic_Int_Array is array (1 .. BASIC_ARRAY_SIZE) of modelint;
   type BasicRealArray is array (1 .. BASIC_ARRAY_SIZE) of real;

   type TaxResult is
      record
         due     : money    := 0.0;
         endBand : modelint := 0;
      end record;

   --
   --  standard banded income tax - style calculation
   --
   --
   function calcTaxDue
     (taxable  : money;
      rates    : BasicRealArray;
      bands    : Basic_Array;
      numBands : modelint)
      return     TaxResult;
   --
   --  old style ni tax calculation: tax is band(p) * taxdue
   --  where p is the 1st band greater or equal to taxable.
   --
   function steppedTaxCalculation
     (taxable  : money;
      rates    : BasicRealArray;
      bands    : Basic_Array;
      numBands : modelint)
      return     TaxResult;
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
      return     TaxResult;
   --
   --  uprate the money value x by uprate by, rounding to next
   --  using Rooker Wise rules
   --
   function uprate
     (x        : money;
      uprateBy : real;
      next     : money := 0.0)
      return     money;
   --
   --  uprate some bands, using rooker wise 'uprate the gaps'
   --  rules if next is greater than 0
   --
   function uprateBands
     (bands    : Basic_Array;
      numBands : modelint;
      uprateBy : real;
      next     : money := 0.0)
      return     Basic_Array;
end tax_utils;
