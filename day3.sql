-- Needed 2 Helpers
-- Part 2 will follow, this getting quite involved in sql :D
-- Jesus christ, I spend way too much time to find an elegent solution to part 2 in SQL
-- in the end I decided to use two additional procedure
-- It really boiled down to me really trying to force a solution without those procedure
-- but a recursive CTE is out the window due splicing or concatenating the values
-- and just wrapping everything in max 12 Subselect seemed ridiculous
-- Well let's see what Day 4 will bring
create temporary function func_bitToDec(in abit bit, in pos int)
returns decimal(19,0)
begin
    return (abit*power(2,pos-1))
end

create temporary procedure proc_splitToChar(in varfield varchar(255 char))
result (num int, field varchar(255 char))
begin
    declare i integer = 1;
    create table #var_split(num int not null default autoincrement, field char(1));
    while (i <= len(varfield)) loop
        insert into #var_split (field) select substring(varfield, i, 1);
        set i = i + 1
    end loop;
    select * from #var_split
end

-- Part 2
create temporary procedure proc_getOxygen(in candidates long varchar, in bitlen integer)
result (oxygen varchar(255 char))
begin
    create table #candidates(line_num int not null, row_value varchar(255 char));
    insert into #candidates select line_num, cast(row_value as varchar(255 char)) from sa_split_list(candidates);
    while (((select count(*) from #candidates) >= 2) and bitlen > 1) loop
        delete from #candidates where line_num not in (
            select  case
                        when cast(count(*) over (partition by field) as decimal(19,2))/cast(count(*) over () as decimal(19,2)) = 0.5 and field = 1
                        then line_num
                        when cast(count(*) over (partition by field) as decimal(19,2))/cast(count(*) over () as decimal(19,2)) >= 0.5
                        then line_num
                        else -1 end
            from #candidates
            cross apply proc_splitToChar(reverse(row_value)) as sign
            where num = bitlen
        );
        set bitlen = bitlen - 1;
    end loop;
    select top 1 row_value
    from #candidates
    cross apply proc_splitToChar(reverse(row_value)) as sign
    where num = bitlen
    order by field desc
end

create temporary procedure proc_getCO2(in candidates long varchar, in bitlen integer)
result (co2 varchar(255 char))
begin
    create table #candidates(line_num int not null, row_value varchar(255 char));
    insert into #candidates select line_num, cast(row_value as varchar(255 char)) from sa_split_list(candidates);
    while (((select count(*) from #candidates) >= 2) and bitlen > 1) loop
        delete from #candidates where line_num not in (
            select  case
                        when cast(count(*) over (partition by field) as decimal(19,2))/cast(count(*) over () as decimal(19,2)) = 0.5 and field = 0
                        then line_num
                        when cast(count(*) over (partition by field) as decimal(19,2))/cast(count(*) over () as decimal(19,2)) < 0.5
                        then line_num
                        else -1 end
            from #candidates
            cross apply proc_splitToChar(reverse(row_value)) as sign
            where num = bitlen
        );
        set bitlen = bitlen - 1;
    end loop;
    select top 1 row_value
    from #candidates
    cross apply proc_splitToChar(reverse(row_value)) as sign
    where num = bitlen
    order by field asc
end

with day3 as
(
select *
from sa_split_list(<input>, char(10))
)
-- PART 1
select  sum(func_bitToDec(epsi, num))*sum(func_bitToDec(gamma, num))
from
(
    select  distinct
            num,
            first_value(field) over (partition by num order by bitcount range between unbounded preceding and unbounded following) as epsi,
            last_value(field) over (partition by num order by bitcount range between unbounded preceding and unbounded following) as gamma
    from
    (
        select  distinct
                num,
                field,
                count(field) over (partition by num, field) as bitcount
        from day3
        cross apply proc_splitToChar(reverse(row_value))
    ) as base
) step2

-- PART 2
select sum(func_bitToDec(oxy.field, oxy.num))*sum(func_bitToDec(co2.field, co2.num))
from
(
    select (select * from proc_getOxygen(poss_oxy, num-1)) as oxygen, (select * from proc_getCO2(poss_co2, num-1)) as co2
    from
    (
        select  list(case when field = 1 then row_value else '' end) as poss_oxy, list(case when field = 0 then row_value else '' end) as poss_co2, num
        from day3
        cross apply proc_splitToChar(reverse(row_value)) as bit1
        where num = len(row_value)
        group by num
    ) as readings
) as n
cross apply proc_splitToChar(reverse(oxygen)) as oxy
join proc_splitToChar(reverse(co2)) as co2 on oxy.num = co2.num
