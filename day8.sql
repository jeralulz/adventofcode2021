with "input" as
(
select *
from sa_split_list(
(
replace(
<input>
, ' |'||char(10), ' | ')
), char(10))
), part1 as
(
    select  "input".line_num,
            substr("input".row_value, locate("input".row_value,'| ')+2) as digits,
            digit.row_value as digit
    from "input"
    cross apply sa_split_list(digits, ' ') as digit
)

select count(*)
from part1
where len(digit) in (2, 3, 4, 7)
