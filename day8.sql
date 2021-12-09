-- I reused my proc_splitToChar from day3 to get each part of the number out
-- Part 2 took me a good nights sleep until I realized I could sum the occurences of each segment
-- Beforehand I had a sheet of paper where I was writing down and counting the occurences by hand
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
    select  "input".line_num as idx,
            substr("input".row_value, locate("input".row_value,'| ')+2) as digits,
            digit.line_num as ordering,
            digit.row_value as digit,
            (select list(sort.row_value, '' order by sort.row_value asc) from proc_splitToChar(digit) as sort) as sorted_digit
    from "input"
    cross apply sa_split_list(digits, ' ') as digit
), patterns as
(
    select  "input".line_num as idx,
            substr("input".row_value, 1, locate("input".row_value,' |')-1) as patterns,
            pattern.line_num as num_idx,
            pattern.row_value as pattern
    from "input"
    cross apply sa_split_list(patterns, ' ') as pattern
), segments as
(
    select * from sa_split_list('a,b,c,d,e,f,g')
), part2base as
(
    select patterns.*, segments.*
    from patterns
    cross apply proc_splitToChar(pattern) as num_part
    join segments on num_part.row_value = segments.row_value
), ciphers as
(
    select  distinct
            part2base.idx,
            part2base.num_idx,
            part2base.pattern,
            sum(occurences.occ) over (partition by part2base.idx, part2base.num_idx) as cipher,
            (select list(sort.row_value, '' order by sort.row_value asc) from proc_splitToChar(pattern) as sort) as sorted_pattern,
            case
                when cipher = 17 then 1
                when cipher = 25 then 7
                when cipher = 30 then 4
                when cipher = 34 then 2
                when cipher = 37 then 5
                when cipher = 39 then 3
                when cipher = 41 then 6
                when cipher = 42 then 0
                when cipher = 45 then 9
                when cipher = 49 then 8
            end as num
    from part2base
    join
    (
        select idx, line_num, row_value, count(*) as occ
        from part2base
        group by idx, line_num, row_value
    ) as occurences on part2base.idx = occurences.idx
        and part2base.line_num = occurences.line_num
), displayed_numbers as
(
    select part1.idx, list(num, '' order by ordering) as number
    from part1
    join ciphers on part1.idx = ciphers.idx
        and part1.sorted_digit = ciphers.sorted_pattern
    group by part1.idx
)

select count(*), 'part1'
from part1
where len(digit) in (2, 3, 4, 7)

union all

select sum(cast(number as integer)) as number, 'part2'
from displayed_numbers
