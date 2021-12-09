-- Well Part 1 was basically a freebie in SQL
-- Now for Part 2
with day8 as
(
select  "input".line_num as hm_row,
        "input".row_value as hm,
        cast(hm_cols.line_num as integer) as hm_col,
        cast(hm_cols.row_value as integer) as hm_val
from sa_split_list(
<input>, char(10)) as "input"
cross apply proc_splitToChar(hm) as hm_cols
), part1 as
(
    select  day8.*,
            case when hm_row = count(*) over (partition by hm_col) then null else last_value(hm_val respect nulls) over (partition by hm_col order by hm_row asc range between current row and 1 following) end as below,
            case when hm_row = 1 then null else first_value(hm_val respect nulls) over (partition by hm_col order by hm_row asc range between 1 preceding and current row) end as above,
            case when hm_col = 1 then null else first_value(hm_val respect nulls) over (partition by hm_row order by hm_col asc range between 1 preceding and current row) end as leftside,
            case when hm_col = count(*) over (partition by hm_row) then null else last_value(hm_val respect nulls) over (partition by hm_row order by hm_col asc range between current row and 1 following) end as rightside,
            case when hm_val < coalesce(below, hm_val+1) and hm_val < coalesce(above, hm_val+1) and hm_val < coalesce(leftside, hm_val+1) and hm_val < coalesce(rightside, hm_val+1) then hm_val+1 else null end as low_point
    from day8
)

select 'part 1', sum(low_point) as result
from part1
where low_point is not null
