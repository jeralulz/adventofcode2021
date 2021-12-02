-- More of the same really compared to day 1
-- I bet there is nicer way for Part 2
-- I should really try to avoid using those inlined views but it's quite comfy
-- I use the regexp_substr but of course you could use a regular substring(row_value, len('forward')+1) or whatever
-- but this one felt a lot nicer to do
with day2 as (
    select  row_value, line_num
    from sa_split_list(<input>, char(10))
)

-- part 1
select  sum(case when row_value like 'forward%' then cast(regexp_substr(row_value, '\d+$') as decimal(19,0)) else 0 end)*
        sum(case when row_value like 'down%' then cast(regexp_substr(row_value, '\d+$') as decimal(19,0)) when row_value like 'up%' then cast(regexp_substr(row_value, '\d+$') as decimal(19,0))*-1 else 0 end) as pos
from day2

-- part 2
select sum(horizontal) * sum(depth) as result
from
(
    select  case when row_value like 'forward%' then cast(regexp_substr(row_value, '\d+$') as decimal(19,0)) else 0 end as horizontal,
            sum(case when row_value like 'down%' then cast(regexp_substr(row_value, '\d+$') as decimal(19,0)) when row_value like 'up%' then cast(regexp_substr(row_value, '\d+$') as decimal(19,0))*-1 else 0 end) over (order by line_num range between unbounded preceding and current row) as aim,
            horizontal*aim as depth
    from day2
) as base
