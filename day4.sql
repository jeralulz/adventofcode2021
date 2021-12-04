-- This required some regex magic to get those bingo sheets into a table format
-- proc_playGame() for Part 1
-- proc_playGame2() for Part 2
-- I went straight for the procedures since its the path of least resistance
-- compared to day 3 this one's been a blessing :D
create or replace table sheets
(
    sheet integer,
    sheet_row integer,
    col1 integer,
    col2 integer,
    col3 integer,
    col4 integer,
    col5 integer,
    c1 bit default 0,
    c2 bit default 0,
    c3 bit default 0,
    c4 bit default 0,
    c5 bit default 0,
    won_on integer default 0
)

create or replace view day4 as
(
    select * from sa_split_list(<input>)
)
create or replace view sheet_checks as
(
    select  distinct
            sheet,
            sheet_row,
            sum(c1) over (partition by sheet) as col1_matches,
            sum(c2) over (partition by sheet) as col2_matches,
            sum(c3) over (partition by sheet) as col3_matches,
            sum(c4) over (partition by sheet) as col4_matches,
            sum(c5) over (partition by sheet) as col5_matches,
            sum(c1+c2+c3+c4+c5) over (partition by sheet, sheet_row) as row_matches
    from sheets
)

create or replace view sheet_matches as
(
    select *
    from sheet_checks
    where row_matches = 5
        or col1_matches = 5
        or col2_matches = 5
        or col3_matches = 5
        or col4_matches = 5
        or col5_matches = 5
 )

-- part 1
create or replace procedure proc_playGame()
result (sheet int, num_played int)
begin
    declare i integer = 1;
    while (i <= (select count(*) from day4)) and ((select count(*) from sheet_matches) = 0) loop
        update sheets
        set
            c1 = case when col1 = (select cast(row_value as integer) from day4 where line_num = i) then 1 else c1 end,
            c2 = case when col2 = (select cast(row_value as integer) from day4 where line_num = i) then 1 else c2 end,
            c3 = case when col3 = (select cast(row_value as integer) from day4 where line_num = i) then 1 else c3 end,
            c4 = case when col4 = (select cast(row_value as integer) from day4 where line_num = i) then 1 else c4 end,
            c5 = case when col5 = (select cast(row_value as integer) from day4 where line_num = i) then 1 else c5 end;
        set i = i + 1
    end loop;
    select distinct sheet, (select row_value from day4 where line_num = i-1) from sheet_matches;
end

-- part2
create or replace procedure proc_playGame2()
result (sheet int, num_played int)
begin
    declare i integer = 1;
    while (i <= (select count(*) from day4) and (select count(*) from sheets where won_on = 0) > 0) loop
        update sheets
        set
            c1 = case when col1 = (select cast(row_value as integer) from day4 where line_num = i) then 1 else c1 end,
            c2 = case when col2 = (select cast(row_value as integer) from day4 where line_num = i) then 1 else c2 end,
            c3 = case when col3 = (select cast(row_value as integer) from day4 where line_num = i) then 1 else c3 end,
            c4 = case when col4 = (select cast(row_value as integer) from day4 where line_num = i) then 1 else c4 end,
            c5 = case when col5 = (select cast(row_value as integer) from day4 where line_num = i) then 1 else c5 end;
        update sheets
        set won_on = (select cast(line_num as integer) from day4 where line_num = i)
        where sheet in (select distinct sheet from sheet_matches)
            and won_on = 0;
        set i = i + 1
    end loop;
    select top 1 sheet, (select row_value from day4 where line_num = won_on) from sheets order by won_on desc;
end

select  (select sum((case when c1 = 1 then 0 else col1 end)+
                    (case when c2 = 1 then 0 else col2 end)+
                    (case when c3 = 1 then 0 else col3 end)+
                    (case when c4 = 1 then 0 else col4 end)+
                    (case when c5 = 1 then 0 else col5 end))
        from sheets
        where sheet = game.sheet)*num_played as score
from proc_playGame() as game

select  (select sum((case when c1 = 1 then 0 else col1 end)+
                    (case when c2 = 1 then 0 else col2 end)+
                    (case when c3 = 1 then 0 else col3 end)+
                    (case when c4 = 1 then 0 else col4 end)+
                    (case when c5 = 1 then 0 else col5 end))
        from sheets
        where sheet = game.sheet)*num_played as score
from proc_playGame2() as game
