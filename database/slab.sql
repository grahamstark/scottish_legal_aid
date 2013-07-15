--  create database slab;
-- )  NOT LOGGED INITIALLY is db2 specific see: http://publib.boulder.ibm.com/infocenter/db2luw/v8/index.jsp?topic=/com.ibm.db2.udb.doc/admin/c0006079.htm
-- intended to stop logfiles building up on large csv imports
connect to slab;

drop table costs;
create table costs( 
        rate  decimal( 10,2 ) not null, 
        upper_lim  decimal( 10,2 ) not null, 
        num_benefit_units  decimal( 10, 2 ), 
        num_adults  decimal( 10, 2 ), 
        num_people  decimal( 10, 2 ), 
        total_costs decimal( 10, 2 ), 
        total_cases decimal( 10, 2 ),
        primary key( rate, upper_lim ))  NOT LOGGED INITIALLY;

        
drop table breakdown;
create table breakdown(
        rate  decimal(10,2) not null ,
        upper_lim     decimal(10,2) not null ,
        component     char(60) not null ,
        problem_type  char(60) not null ,
        value         decimal( 10, 2 ),
        primary key( rate, upper_lim, component, problem_type )) NOT LOGGED INITIALLY ;
        -- , constraint fk_1 foreign key( rate, upper_lim ) references costs( rate, upper_lim ));

        
drop table cases_by_income;
create table cases_by_income(
        rate  decimal(10,2) not null ,
        upper_lim     decimal(10,2) not null ,
        income_limit  integer not null ,
        value         decimal( 10, 2 ),
        primary key( rate, upper_lim, income_limit ))  NOT LOGGED INITIALLY;
        
        
create table flat_costs(
        rate  decimal( 10,2 ) not null, 
        upper_lim  decimal( 10,2 ) not null, 
        num_benefit_units  decimal( 10, 2 ), 
        num_adults  decimal( 10, 2 ), 
        num_people  decimal( 10, 2 ), 
        total_costs decimal( 10, 2 ), 
        total_cases decimal( 10, 2 ),
        
        cost_divorce decimal(10,2), 
        cost_relationships decimal(10,2), 
        cost_personal_injury decimal(10,2),
        cost_other_problem decimal(10,2), 
        cost_procedures decimal(10,2),
        
        count_divorce decimal(10,2), 
        count_relationships decimal(10,2), 
        count_personal_injury decimal(10,2),
        count_other_problem decimal(10,2), 
        count_procedures decimal(10,2),
        
        cost_b_1 decimal(10,2),
        cost_b_2 decimal(10,2),
        cost_b_3 decimal(10,2),
        cost_b_4 decimal(10,2),
        cost_b_5 decimal(10,2),
        cost_b_6 decimal(10,2),
        cost_b_7 decimal(10,2),
        cost_b_8 decimal(10,2),
        cost_b_9 decimal(10,2),
        cost_b_10 decimal(10,2),
        cost_b_11 decimal(10,2),
        cost_b_12 decimal(10,2),
        cost_b_13 decimal(10,2),
        cost_b_14 decimal(10,2),
        cost_b_15 decimal(10,2),
        cost_b_16 decimal(10,2),
        cost_b_17 decimal(10,2),
        cost_b_18 decimal(10,2),
        cost_b_19 decimal(10,2),
        cost_b_20 decimal(10,2),
        
        cnt_b_1 decimal(10,2),
        cnt_b_2 decimal(10,2),
        cnt_b_3 decimal(10,2),
        cnt_b_4 decimal(10,2),
        cnt_b_5 decimal(10,2),
        cnt_b_6 decimal(10,2),
        cnt_b_7 decimal(10,2),
        cnt_b_8 decimal(10,2),
        cnt_b_9 decimal(10,2),
        cnt_b_10 decimal(10,2),
        cnt_b_11 decimal(10,2),
        cnt_b_12 decimal(10,2),
        cnt_b_13 decimal(10,2),
        cnt_b_14 decimal(10,2),
        cnt_b_15 decimal(10,2),
        cnt_b_16 decimal(10,2),
        cnt_b_17 decimal(10,2),
        cnt_b_18 decimal(10,2),
        cnt_b_19 decimal(10,2),
        cnt_b_20 decimal(10,2),
        primary key( rate, upper_lim ) );
        
--        constraint fk_1 foreign key( rate, upper_lim ) references costs( rate, upper_lim ));
--
-- not sure we'd really need these given they are all parts of the PK
--
create index bd1 on breakdown( component );
create index bd2 on breakdown( problem_type );
create index cbi1 on cases_by_income( income_limit );
create index cp1 on costs( rate );        
create index cp2 on costs( upper_lim );        
create index bp1 on breakdown( rate );        
create index bp2 on breakdown( upper_lim );        
create index cb1 on cases_by_income( rate );        
create index cb2 on cases_by_income( upper_lim );        

select rate, upper_lim, total_costs, total_cases from costs where (total_costs > 248000) and (total_costs < 252000) order by total_cases desc; -- 218
select rate, upper_lim, total_costs, total_cases from costs where (total_costs > 490000) and (total_costs < 510000) order by total_cases desc; -- 467
select rate, upper_lim, total_costs, total_cases from costs where (total_costs > 740000) and (total_costs < 760000) order by total_cases desc; -- 763

(select max( total_cases )+20 from costs where (total_costs > 740000) and (total_costs < 760000))

select rate, upper_lim, total_costs, total_cases from costs where (total_cases > 210) and (total_cases < 226) order by total_costs desc;
select rate, upper_lim, total_costs, total_cases from costs where (total_cases > 460) and (total_cases < 472) order by total_costs desc;
select rate, upper_lim, total_costs, total_cases from costs where (total_cases > 758) and (total_cases < 770) order by total_costs desc;


select rate, upper_lim, total_costs, total_cases from costs where 
        (total_cases >
                (select max( total_cases )-20 from costs where (total_costs > 740000) and (total_costs < 760000))
        ) and 
          (total_cases < 
                (select max( total_cases )+20 from costs where (total_costs > 740000) and (total_costs < 760000))
          ) order by total_costs desc;

