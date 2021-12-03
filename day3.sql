-- Needed 2 Helpers
-- Part 2 will follow, this getting quite involved in sql :D

--create temporary function func_getBit(in bin varchar(32 char),  in pos int)
--returns char
--begin
--    return substring(bin, pos, 1)
--end

--create temporary function func_bitToDec(in abit bit, in pos int)
--returns decimal(19,0)
--begin
--    return (abit*power(2,pos-1))
--end

with day3 as
(
select *
from sa_split_list(<input>, char(10))
)
-- PART 1
select  distinct
            (
                func_bitToDec(first_value("12th") over (order by "12th_bitcount" range between unbounded preceding and unbounded following), 12)+
                func_bitToDec(first_value("11th") over (order by "11th_bitcount" range between unbounded preceding and unbounded following), 11)+
                func_bitToDec(first_value("10th") over (order by "10th_bitcount" range between unbounded preceding and unbounded following), 10)+
                func_bitToDec(first_value("9th") over (order by "9th_bitcount" range between unbounded preceding and unbounded following), 9)+
                func_bitToDec(first_value("8th") over (order by "8th_bitcount" range between unbounded preceding and unbounded following), 8)+
                func_bitToDec(first_value("7th") over (order by "7th_bitcount" range between unbounded preceding and unbounded following), 7)+
                func_bitToDec(first_value("6th") over (order by "6th_bitcount" range between unbounded preceding and unbounded following), 6)+
                func_bitToDec(first_value("5th") over (order by "5th_bitcount" range between unbounded preceding and unbounded following), 5)+
                func_bitToDec(first_value("4th") over (order by "4th_bitcount" range between unbounded preceding and unbounded following), 4)+
                func_bitToDec(first_value("3rd") over (order by "3rd_bitcount" range between unbounded preceding and unbounded following), 3)+
                func_bitToDec(first_value("2nd") over (order by "2nd_bitcount" range between unbounded preceding and unbounded following), 2)+
                func_bitToDec(first_value("1st") over (order by "1st_bitcount" range between unbounded preceding and unbounded following), 1)
            ) 
            *
            (
                func_bitToDec(last_value("12th") over (order by "12th_bitcount" range between unbounded preceding and unbounded following), 12)+
                func_bitToDec(last_value("11th") over (order by "11th_bitcount" range between unbounded preceding and unbounded following), 11)+
                func_bitToDec(last_value("10th") over (order by "10th_bitcount" range between unbounded preceding and unbounded following), 10)+
                func_bitToDec(last_value("9th") over (order by "9th_bitcount" range between unbounded preceding and unbounded following), 9)+
                func_bitToDec(last_value("8th") over (order by "8th_bitcount" range between unbounded preceding and unbounded following), 8)+
                func_bitToDec(last_value("7th") over (order by "7th_bitcount" range between unbounded preceding and unbounded following), 7)+
                func_bitToDec(last_value("6th") over (order by "6th_bitcount" range between unbounded preceding and unbounded following), 6)+
                func_bitToDec(last_value("5th") over (order by "5th_bitcount" range between unbounded preceding and unbounded following), 5)+
                func_bitToDec(last_value("4th") over (order by "4th_bitcount" range between unbounded preceding and unbounded following), 4)+
                func_bitToDec(last_value("3rd") over (order by "3rd_bitcount" range between unbounded preceding and unbounded following), 3)+
                func_bitToDec(last_value("2nd") over (order by "2nd_bitcount" range between unbounded preceding and unbounded following), 2)+
                func_bitToDec(last_value("1st") over (order by "1st_bitcount" range between unbounded preceding and unbounded following), 1)
            ) as result
from
(
    select  distinct
            func_getBit(row_value, 1) as "12th",
            func_getBit(row_value, 2) as "11th",
            func_getBit(row_value, 3) as "10th",
            func_getBit(row_value, 4) as "9th",
            func_getBit(row_value, 5) as "8th",
            func_getBit(row_value, 6) as "7th",
            func_getBit(row_value, 7) as "6th",
            func_getBit(row_value, 8) as "5th",
            func_getBit(row_value, 9) as "4th",
            func_getBit(row_value, 10) as "3rd",
            func_getBit(row_value, 11) as "2nd",
            func_getBit(row_value, 12) as "1st",
            count(func_getBit(row_value, 1)) over (partition by "12th" order by line_num range between unbounded preceding and unbounded following) as "12th_bitcount",
            count(func_getBit(row_value, 2)) over (partition by "11th" order by line_num range between unbounded preceding and unbounded following) as "11th_bitcount",
            count(func_getBit(row_value, 3)) over (partition by "10th" order by line_num range between unbounded preceding and unbounded following) as "10th_bitcount",
            count(func_getBit(row_value, 4)) over (partition by "9th" order by line_num range between unbounded preceding and unbounded following) as "9th_bitcount",
            count(func_getBit(row_value, 5)) over (partition by "8th" order by line_num range between unbounded preceding and unbounded following) as "8th_bitcount",
            count(func_getBit(row_value, 6)) over (partition by "7th" order by line_num range between unbounded preceding and unbounded following) as "7th_bitcount",
            count(func_getBit(row_value, 7)) over (partition by "6th" order by line_num range between unbounded preceding and unbounded following) as "6th_bitcount",
            count(func_getBit(row_value, 8)) over (partition by "5th" order by line_num range between unbounded preceding and unbounded following) as "5th_bitcount",
            count(func_getBit(row_value, 9)) over (partition by "4th" order by line_num range between unbounded preceding and unbounded following) as "4th_bitcount",
            count(func_getBit(row_value, 10)) over (partition by "3rd" order by line_num range between unbounded preceding and unbounded following) as "3rd_bitcount",
            count(func_getBit(row_value, 11)) over (partition by "2nd" order by line_num range between unbounded preceding and unbounded following) as "2nd_bitcount",
            count(func_getBit(row_value, 12)) over (partition by "1st" order by line_num range between unbounded preceding and unbounded following) as "1st_bitcount"
    from day3
) as base
