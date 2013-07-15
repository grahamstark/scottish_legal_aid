import MySQLdb
import csv;

def getCostsCloseToTarget( ll, ul ):
        data_by_band = {}
        try:
                conn = MySQLdb.connect (host = "localhost",
                                        user = "root",
                                        passwd = "iainkath",
                                        db = "slab")
                cursor = conn.cursor ()
                cursor.execute ("select rate, upper_lim, total_costs, total_cases, num_benefit_units, num_people from costs where (total_costs > %s) and (total_costs < %s) order by total_cases desc;" % ( ll, ul ))
                p = 0
                while( 1 ):
                        row = cursor.fetchone ()
                        if( p == 0 ):
                                # 1st row is optimum
                                optimum = row
                        if row == None:
                                break
                        band = row[1];
                        #
                        # kill duplicate bands, leaving the one with the highest cost
                        # (i.e. the lowest rate).
                        #
                        if data_by_band.has_key( band ):
                            if( row[3] > data_by_band[ band ][ 3 ] ):
                                    data_by_band[ band ] = row
                        else:
                            data_by_band[ band ] = row
                        p += 1
                cursor.close ()
                conn.close ()
        except MySQLdb.Error, e:
                print "Error %d: %s" % (e.args[0], e.args[1])
                sys.exit (1)
        # print "SORT By BAND";
        #
        # delete duplicate rates, picking the rate/band dup with the highest case count (col 3)
        #
        keys = data_by_band.keys()
        keys.sort()
        data_by_rate = {}
        for r in data_by_band.keys():
                row = data_by_band[ r ]
                rate = row[0];
                if data_by_rate.has_key( rate ):
                    if( row[3] > data_by_rate[ rate ][ 3 ] ):
                            data_by_rate[ rate ] = row
                else:
                    data_by_rate[ rate ] = row
        # print "FINAL SORT"       
        keys = data_by_rate.keys()
        keys.sort()
        final_rows = []
        for r in keys:
                row = data_by_rate[ r ]
                final_rows.append( row );
        return { 'optimum': optimum, 'final_rows': final_rows }

rows = getCostsCloseToTarget( 249000.00, 251000.00 )
print ",rate, upper_lim, total_costs, total_cases, num_benefit_units, num_people" 
print "250_000=== optimum, %s,%s,%s,%s,%s,%s " % (rows['optimum'][0], rows['optimum'][1], rows['optimum'][2], rows['optimum'][3], rows['optimum'][4], rows['optimum'][5] );
print 
for row in rows['final_rows']:
        print ",%s,%s,%s,%s,%s,%s " % (row[0], row[1], row[2], row[3], row[4], row[5] )
print 
rows = getCostsCloseToTarget( 499000.00, 501000.00 )
print ",rate, upper_lim, total_costs, total_cases, num_benefit_units, num_people" 
print "500_000  === optimum, %s,%s,%s,%s,%s,%s " % (rows['optimum'][0], rows['optimum'][1], rows['optimum'][2], rows['optimum'][3], rows['optimum'][4], rows['optimum'][5] );
for row in rows['final_rows']:
        print ",%s,%s,%s,%s,%s,%s " % (row[0], row[1], row[2], row[3], row[4], row[5] )
print 
rows = getCostsCloseToTarget( 749000.00, 751000.00 )
print "750_000  === optimum, %s,%s,%s,%s,%s,%s " % (rows['optimum'][0], rows['optimum'][1], rows['optimum'][2], rows['optimum'][3], rows['optimum'][4], rows['optimum'][5] );
print ",rate, upper_lim, total_costs, total_cases, num_benefit_units, num_people" 
for row in rows['final_rows']:
        print ",%s,%s,%s,%s,%s,%s " % (row[0], row[1], row[2], row[3], row[4], row[5] )
print 
