-- Needed 2 Helpers
-- Part 2 will follow, this getting quite involved in sql :D
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
