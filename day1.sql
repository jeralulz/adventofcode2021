-- I did all of this in a SQL Anywhere 17 T-SQL Dialect
-- Hence I use sa_split_list() instead of inserting into a temp table or reading a file
-- I personally split on a line feed so I can just paste the input in there

-- Day 1
-- All you need is window functions and a sum for aggregation

-- Part 1 requires one to get the diff from the previous value a first_value or last_value window function is perfect for this case
select sum(case when diffs > 0 then 1 else 0 end) as incs
from
(
    select  row_value-first_value(row_value) over (order by line_num range between 1 preceding and current row) as diffs
    from sa_split_list(<input>, char(10))
) as werte

-- Part 2 adds a sliding window on top that, yet again a perfect job for a window function
-- not much to add here
select sum(case when diffs > 0 then 1 else 0 end) as incs
from
(
    select  summe-first_value(summe) over (order by line_num range between 1 preceding and current row) as diffs
from
(
    select  cast(row_value as decimal(19,0)) as row_value,
            line_num,
            last_value(row_value) over (order by line_num range between current row and 1 following) as naechste_zeile,
            last_value(line_num) over (order by line_num range between current row and 1 following) as naechste_zeile_line,
            last_value(row_value) over (order by line_num range between current row and 2 following) as uebernaechste_zeile,
            last_value(line_num) over (order by line_num range between current row and 2 following) as uebernaechste_zeile_line,
            row_value+naechste_zeile+uebernaechste_zeile as summe
    from sa_split_list(<input>, char(10))
) as sliding
where line_num <> naechste_zeile_line
        and naechste_zeile_line <> uebernaechste_zeile_line
) as werte
