-- Sadly I didn't get around to it yesterday
-- Part 2 will follow along with day 6 today
--create temporary procedure proc_apply_found_vents (in minx int, in maxx int, in miny int, in maxy int)
--begin
--    execute immediate
--    'update #vent_field
--    set vents = vents +1
--    where depth >= ' ||minx||'
--        and depth <= ' ||maxx||'
--        and width >= ' ||miny||'
--        and width <= ' ||maxy
--end

with day5 as
(
select  *,
        cast(regexp_substr(row_value, '\d+',0, 1) as integer) as x1,
        cast(regexp_substr(row_value, '\d+',len(x1)+1, 1) as integer) as y1,
        cast(regexp_substr(row_value, '\d+',len(x1)+len(y1)+len(' -> ')+1, 1) as integer) as x2,
        cast(regexp_substr(row_value, '\d+',len(x1)+len(y1)+len(' -> ')+len(x2)+2, 1) as integer) as y2
from sa_split_list(
<input>, char(10))
),
generate_field as
(
    select depth.row_num as depth, width.row_num as width, width.vents
    from sa_rowgenerator((select case when min(x1) >= min(x2) then min(x1) else min(x2) end as min_x from day5), (select case when max(x1) >= max(x2) then max(x1) else max(x2) end as max_x from day5)) as depth
    cross apply (select row_num, 0 as vents from sa_rowgenerator((select case when min(y1) >= min(y2) then min(y1) else min(y2) end as min_y from day5), (select case when max(y1) >= max(y2) then max(y1) else max(y2) end as max_y from day5))) as width
),
find_vents as
(
    select  case when x1 <= x2 then x1 else x2 end as minx,
            case when x1 >= x2 then x1 else x2 end as maxx,
            case when y1 <= y2 then y1 else y2 end as miny,
            case when y1 >= y2 then y1 else y2 end as maxy
    from day5
    where minx = maxx or miny = maxy
)

-- part 1
select * into #vent_field from generate_field
select proc_apply_found_vents(minx, maxx, miny, maxy) from find_vents
select count(*) from #vent_field where vents >= 2
