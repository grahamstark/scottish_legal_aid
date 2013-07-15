--
--  $Author: graham_s $
--  $Date: 2007-03-20 16:12:17 +0000 (Tue, 20 Mar 2007) $
--  $Revision: 2397 $
--
with base_model_types; use base_model_types;

with Ada.Calendar; use Ada.Calendar;

package model_uprate is

-- to autogenerate this file with new data
--
-- download  'EMP', 'MM23', 'UKEA' from http://www.statistics.gov.uk/statbase/tsdlistfiles.asp
-- find the file ../scripts/macrotests.rb
-- run and capture the bottom part of the screen dump.
-- Paste this in below

  -- Wages = 'lnnk'; ## Unit Wage Costs : whole economy SA: Index 2002=100: UK royj';
  -- OtherIncome = 'ihxs' ## Gross national income per head at current market prices: SA 
  -- Capital = 'ihxs'  ## Gross national income per head at current market prices: SA
  -- StateBenefits = 'cbzw'; ## All items exc mortgage int payments and indirect taxes (RPIY) (Jan 1987=100)
  -- Rent = 'dobp' ## RPI: housing: rent (Jan 1987=100)   
  -- Mortgages = 'dobq' ## RPI: housing: mortgage interest payments (Jan 1987=100) 
  -- CT = 'dobr' ## RPI: housing: council tax & rates (Jan 1987=100)
  -- Charges = 'dobs' ##RPI: housing: water & other charges (Jan 1987=100)  
  -- Repairs = 'dobt' ## RPI: housing: repairs & maintenance charges (Jan 1987=100) 



        subtype DataYears is integer range 2002 .. 2007;

        subtype NW_House_Price_Years is integer range 1952 .. 2007;

        subtype Quarter is integer range 1..4;

        type NW_House_Price_Index is array( NW_House_Price_Years, Quarter ) of real;


        LAST_DATE  : constant Time         := Time_Of (Year => 2007, Month => 1, Day => 1);
        LAST_YEAR  : constant DataYears    := DataYears (Year (LAST_DATE));
        LAST_MONTH : constant Month_Number := Month (LAST_DATE);

        --
        --  FIXME : we need this updated
        LAST_NW_HOUSE_PRICE_YEAR : constant NW_House_Price_Years := 2005 ;
        LAST_NW_HOUSE_PRICE_QUARTER : constant Quarter := 4;

        --
        --
        --
        type UprateTypes is ( 
            wages, 
            other_income, 
            capital, 
            stateBenefits, -- rpi xmip  CBZW
            rent,          -- 
            mortgages, 
            localTaxes, 
            charges, 
            repairs );
        type MacroArray is array (UprateTypes) of real;

        --
        --  price change between the latest date available and the given date,
        --  for the given type. Only Y/M are used in Time.
        --
        function priceChange( date : Time; utype : UprateTypes ) return real;
        --
        --  ditto for Nationwide House price index
        --
        function housePriceChange( year : NW_House_Price_Years; month :  Month_Number ) return real;

        function changes ( date : Time ) return MacroArray;

end model_uprate;
