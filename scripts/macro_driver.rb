#!/usr/bin/ruby
require 'mini_macro'
require 'pstore'
require 'utils'
## require 'data_constants'
#
#
# $revision$
# $author$
# $date$
# 
# unit tests of our simple macro ONS database
#
class MacroDriver
     ##
     # these are: employment stats, retail prices, economic trends
     ##
     DATABASES = [ 'EMP', 'MM23', 'UKEA' ]

     PATH = "";
     
     Wages = 'lnnk'; ## Unit Wage Costs : whole economy SA: Index 2002=100: UK royj';
     OtherIncome = 'ihxs' ## Gross national income per head at current market prices: SA 
     Capital = 'ihxs'  ## Gross national income per head at current market prices: SA
     StateBenefits = 'cbzw'; ## All items exc mortgage int payments and indirect taxes (RPIY) (Jan 1987=100)
     Rent = 'dobp' ## RPI: housing: rent (Jan 1987=100)   
     Mortgages = 'dobq' ## RPI: housing: mortgage interest payments (Jan 1987=100) 
     CT = 'dobr' ## RPI: housing: council tax & rates (Jan 1987=100)
     Charges = 'dobs' ##RPI: housing: water & other charges (Jan 1987=100)  
     Repairs = 'dobt' ## RPI: housing: repairs & maintenance charges (Jan 1987=100) 
     
     def printAdaDB
              [2002, 2003, 2004, 2005, 2006, 2007 ].each{
                      |year|
                      puts " on year #{year} ";
                      Range.new(1, 12).to_a.each{
                              |month|
                              ## puts " looking for month = #{month}"
                              date = Date::new( year, month, 1 );
                              wage = @macroDB.getByD( Wages, date );
                              other = @macroDB.getByD( OtherIncome, date );
                              
                              capital = @macroDB.getByD( Capital, date );
                              bens = @macroDB.getByD( StateBenefits, date );
                              rent = @macroDB.getByD( Rent, date ); 
                              mortgages = @macroDB.getByD( Mortgages, date );
                              ct = @macroDB.getByD( CT, date );
                              charges = @macroDB.getByD( Charges, date );
                              repairs = @macroDB.getByD( Repairs, date );
                              puts "macro( #{year}, #{month} ) := ( #{wage}, #{other}, #{capital}, #{bens}, #{rent}, #{mortgages}, #{ct}, #{charges}, #{repairs} )";
                      }
              }
     end;
 
     def loadMultipleDatabases
              _macroDB = MiniMacro.new;
              DATABASES.each{
                        |file|
                        _macroDB = loadFromONSData( PATH+file, _macroDB );
                        puts "loadMultipleDatabases; loaded #{file}: variables now ";
                        p _macroDB.variableList;
              }
              
              return _macroDB;
     end
      
      
     def initialize()
              @macroDB = loadMultipleDatabases;
              @latestDate = @macroDB.lastDate( 'cbzw' );
     end
end

driver = MacroDriver.new
driver.printAdaDB
