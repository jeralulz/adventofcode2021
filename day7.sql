-- part 2 yet again brought forth the amazing off by one
-- the reason? i did cast(avg_travel as int) before getting my dest in part2 resulting in an unwanted rounding
with day7 as
(
    select  line_num as idx,
            cast(row_value as int) as pos
    from sa_split_list(<input>)
), part1 as
(
    select  distinct top 1
            avgs.pos,
            avg(abs(day7.pos-avgs.pos)) over (partition by avgs.idx order by avgs.idx) as avg_travel,
            avg_travel*count(*) over (partition by avgs.idx) as total_travel
    from day7
    cross join day7 as avgs
    order by avg_travel
), long_avg_travel as
(
    select  distinct top 1
            avgs.pos,
            avg(abs(day7.pos-avgs.pos)) over (partition by avgs.idx order by avgs.idx) as avg_travel,
            avg_travel*count(*) over (partition by avgs.idx) as total_travel
    from day7
    cross join day7 as avgs
    order by avg_travel desc
), part2 as
(
    select  long_avg_travel.pos as long_pos,
            day7.*,
            avg_travel as avg_travel,
            cast(abs(long_pos-avg_travel) as int) as dest,
            abs(day7.pos-dest) as travel_dist_dest,
            (select sum(row_num) from sa_rowgenerator(0, travel_dist_dest)) as travel_dist
    from long_avg_travel
    cross apply day7
)

select * from part1
select sum(travel_dist) from part2
