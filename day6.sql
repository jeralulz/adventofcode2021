-- to be fair I don't even want to admit, how long I looked at the sequence before it finally clicked
-- 80 days were wirst done with a very stupid approach, inserting a new row
-- this one is quite a bit faster and is far as i can tell as functional of an approach as sql can be?
create or replace view "days"
as
    select row_num as day
    from sa_rowgenerator(0, 8)

create temporary procedure proc_SimulateDays(in initial_state long varchar, in "days" int)
result (squid_count unsigned bigint)
begin
    select "days".day, coalesce(observation.squids, 0) as squids into #observations
    from "days"
    left join (select row_value as day, cast(count(*) as unsigned bigint) as squids from sa_split_list(initial_state) group by day) as observation on "days".day = observation.day;
    while ("days" >= 1) loop
        update #observations
        join
        (
            select  day,
                    case
                        when day = 8 then (select squids from #observations where day = 0)
                        when day = 6 then (select squids from #observations where day = 0)+last_value(squids) over (order by day asc range between current row and 1 following)
                        else last_value(squids) over (order by day asc range between current row and 1 following)
                    end as next_squids
            from #observations
        ) as m on #observations.day = m.day
        set squids = next_squids;
        set "days" = "days" - 1;
    end loop;
    select sum(squids) from #observations;
end

select '80 days' as days, squid_count
from proc_SimulateDays(<input>, 80)

union all

select '256 days', squid_count
from proc_SimulateDays(<input>, 256)
