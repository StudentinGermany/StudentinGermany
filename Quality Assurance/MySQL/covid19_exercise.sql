/* Covid19 */
USE mywork;

-- Country
CREATE TABLE covid19_country 
(
  countrycode                 VARCHAR(10) NOT NULL, 
  countryname                 VARCHAR(80) NOT NULL, 
  continent                   VARCHAR(50), 
  population                  DOUBLE,
  population_density          DOUBLE,
  median_age                  DOUBLE,
  aged_65_older               DOUBLE,
  aged_70_older               DOUBLE,
  hospital_beds_per_thousand  INT,
  PRIMARY KEY (countrycode)
);

-- Create the Covid data table
CREATE TABLE covid19_data 
(
  countrycode                 VARCHAR(10) NOT NULL, 
  issue_date                  DATE        NOT NULL,  
  cases                       INT, 
  new_cases_per_million       DOUBLE, 
  deaths                      INT, 
  icu_patients                INT, 
  hosp_patients               INT, 
  tests                       INT, 
  reproduction_rate           DOUBLE, 
  new_vaccinations            INT, 
  stringency_index            DOUBLE,
  PRIMARY KEY (countrycode, issue_date)
);

 
-- file -> open sql script -> Open 01.covid19_country_insert.sql -> Execute

-- file -> open sql script -> Open 02.covid19_data_insert.sql -> Execute


-- Check the number of records in each table.

  

-- 1. Data Cleaning
-- (1) Remove Unnecessary Data
-- The countrycode and countryname tables contain duplicate aggregated data for continents.
-- Identify (SELECT) and then delete (DELETE) rows from each table where the country code starts with 'OWID'.

select countrycode, countryname
 from covid19_country
 where countrycode like 'owid%'
 order by 1;

select countrycode
 from covid19_data
 where countrycode like 'owid%'
 order by 1;
 
 delete from covid19_country
 where countrycode like 'owid%';

delete from covid19_data
 where countrycode like 'owid%';

-- (2) Handle NULL Values in Numeric Columns
-- Some numeric columns contain NULL values.
-- Change these NULL values to 0.

-- option 1
/*
select count(*)
from covid19_country
where population is null;

update covid19_country
  set population = 0
where population is null;  

select count(*)
from covid19_country
where population_density is null;

update covid19_country
  set population_density = 0
where population_density is null;  


select count(*)
from covid19_country
where median_age is null;

update covid19_country
  set median_age = 0
where median_age is null;  


select count(*)
from covid19_country
where aged_65_older is null;

update covid19_country
  set aged_65_older = 0
where aged_65_older is null;  


select count(*)
from covid19_country
where aged_70_older is null;

update covid19_country
  set aged_70_older = 0
where aged_70_older is null;  



select count(*)
from covid19_country
where hospital_beds_per_thousand is null;

update covid19_country
  set hospital_beds_per_thousand = 0
where hospital_beds_per_thousand is null;  
*/
-- option 2
update covid19_country
  set population = ifnull(population, 0),
  population_density = ifnull(population_density, 0),
  median_age = ifnull(median_age, 0),
  aged_65_older = ifnull(aged_65_older, 0),
  aged_70_older = ifnull(aged_70_older, 0),
  hospital_beds_per_thousand = ifnull(hospital_beds_per_thousand, 0);
  
update covid19_data
  set cases = ifnull(cases,0),
  new_cases_per_million = ifnull(new_cases_per_million,0),
  deaths = ifnull(deaths,0),
  icu_patients = ifnull(icu_patients,0),
  hosp_patients = ifnull(hosp_patients,0),
  tests = ifnull(tests,0),
  reproduction_rate = ifnull(reproduction_rate,0),
  new_vaccinations = ifnull(new_vaccinations,0),
  stringency_index = ifnull(stringency_index,0);

  -- null check
  -- 1) covid19_country
with tmp1 as(
select population + population_density + median_age + aged_65_older + 
       aged_70_older + hospital_beds_per_thousand as plus_col
  from covid19_country
),
tmp2 as(
 select case when plus_col is null then "null" else "not null" 
	end chk
	from tmp1
)
select chk, count(*)
from tmp2
group by chk;
  
-- covid19_data
with null_check1 as (
select cases + new_cases_per_million + deaths + icu_patients + 
       hosp_patients + tests + reproduction_rate + new_vaccinations + stringency_index as plus_col
  from covid19_data
),
null_check2 as (
select case when plus_col is null then 'NULL' 
            ELSE 'NOT NULL'
       end chk
from null_check1
)
select chk, COUNT(*)
from null_check2
group by chk  
;


/* 2. Data Analysis */

-- (1) Retrieve the top 10 countries by number of deaths in 2020

select b.countryname, sum(a.deaths) death_num, sum(a.cases) case_num
from covid19_data a
join covid19_country b
on a.countrycode = b.countrycode
where year(a.issue_date) = 2020
group by b.countryname
order by 2 desc
limit 10;
   
-- option 2 (rank())
-- select b.countryname, sum(a.deaths) death_num, sum(a.cases) case_num,
-- rank() over (order by sum(a.deaths) desc) death_rank
-- from covid19_data a
-- join covid19_country bon a.countrycode = b.countrycode
-- where year(a.issue_date) = 2020
-- group by b.countryname
   -- order by 2 desc

-- (2) Calculate the ratio of confirmed cases and deaths to population in 2020
-- (2-1) Select the top 10 countries by the number of deaths in 2020.
	select b.countryname, sum(a.deaths) death_num, sum(a.cases) case_num
from covid19_data a
   join covid19_country b
     on a.countrycode = b.countrycode
   where year(a.issue_date) = 2020
   group by b.countryname
   order by 2 desc
   limit 10;

-- (2-2) For these countries, calculate and retrieve the ratio of confirmed cases to population.
select t.countryname, t.death_num, t.case_num, t.population,
 round(t.death_num/t.population * 100, 5) death_popul_rate,
 round(t.case_num/t.population * 100, 5) case_popul_rate
from (
select b.countryname, sum(a.deaths) death_num, sum(a.cases) case_num, b.population
  from covid19_data a
   join covid19_country b
     on a.countrycode = b.countrycode
   where year(a.issue_date) = 2020
   group by b.countryname
   order by 2 desc
   limit 10
)t
order by 5 desc;


-- (3) Retrieve monthly confirmed cases and deaths for South Korea
-- (3-1) Calculate the total number of confirmed cases and deaths by year and month for South Korea.
select extract(year_month from issue_date) months,
       sum(cases) case_num,
       sum(deaths) death_num
  from covid19_data
  where countrycode = "KOR"
  group by 1
  order by 1;
 
-- (3-2) Calculate the total sum of monthly confirmed cases and deaths (from the results of 3-1).
select extract(year_month from issue_date) months,
       sum(cases) case_num,
       sum(deaths) death_num
  from covid19_data
  where countrycode = "KOR"
  group by 1
union all
select "All", sum(cases), sum(deaths)
  from covid19_data
  where countrycode = "KOR";
 

-- (3-3) Based on the result from (3-1), display only the sum of confirmed cases for each year-month as columns.
-- Example output : 
-- 202002 202003 202004 202005 ...
-- 10	3139	6636	988	  729	1347	1486	5846	3707	2746	8017	27117	16739	11523

select case when months = 202001 then case_num else 0 end "202001",
       case when months = 202002 then case_num else 0 end "202002",
       case when months = 202003 then case_num else 0 end "202003",
       case when months = 202004 then case_num else 0 end "202004",
       case when months = 202005 then case_num else 0 end "202005",
       case when months = 202006 then case_num else 0 end "202006",
       case when months = 202007 then case_num else 0 end "202007",
       case when months = 202008 then case_num else 0 end "202008",
       case when months = 202009 then case_num else 0 end "202009",
       case when months = 202010 then case_num else 0 end "202010",
       case when months = 202011 then case_num else 0 end "202011",
       case when months = 202012 then case_num else 0 end "202012",
       case when months = 202101 then case_num else 0 end "202101",
       case when months = 202102 then case_num else 0 end "202102"
from (
  select extract(year_month from issue_date) months, sum(cases) case_num, sum(deaths) death_num
    from covid19_data
    where countrycode="kor"
  group by 1
)a
;
-- cte
with tmp as(
select extract(year_month from issue_date) months, sum(cases) case_num, sum(deaths) death_num
    from covid19_data
    where countrycode="kor"
  group by 1
 )
 select case when months = 202001 then case_num else 0 end "202001",
       case when months = 202002 then case_num else 0 end "202002",
       case when months = 202003 then case_num else 0 end "202003",
       case when months = 202004 then case_num else 0 end "202004",
       case when months = 202005 then case_num else 0 end "202005",
       case when months = 202006 then case_num else 0 end "202006",
       case when months = 202007 then case_num else 0 end "202007",
       case when months = 202008 then case_num else 0 end "202008",
       case when months = 202009 then case_num else 0 end "202009",
       case when months = 202010 then case_num else 0 end "202010",
       case when months = 202011 then case_num else 0 end "202011",
       case when months = 202012 then case_num else 0 end "202012",
       case when months = 202101 then case_num else 0 end "202101",
       case when months = 202102 then case_num else 0 end "202102"
from tmp;   

-- sum 적용    
with tmp as(
select extract(year_month from issue_date) months, sum(cases) case_num, sum(deaths) death_num
    from covid19_data
    where countrycode="kor"
  group by 1
 )
 select sum(case when months = 202001 then case_num else 0 end) "202001",
       sum(case when months = 202002 then case_num else 0 end) "202002",
       sum(case when months = 202003 then case_num else 0 end) "202003",
       sum(case when months = 202004 then case_num else 0 end) "202004",
       sum(case when months = 202005 then case_num else 0 end) "202005",
       sum(case when months = 202006 then case_num else 0 end) "202006",
       sum(case when months = 202007 then case_num else 0 end) "202007",
       sum(case when months = 202008 then case_num else 0 end) "202008",
       sum(case when months = 202009 then case_num else 0 end) "202009",
       sum(case when months = 202010 then case_num else 0 end) "202010",
       sum(case when months = 202011 then case_num else 0 end) "202011",
       sum(case when months = 202012 then case_num else 0 end) "202012",
       sum(case when months = 202101 then case_num else 0 end) "202101",
       sum(case when months = 202102 then case_num else 0 end) "202102"
from tmp;   

-- 사망자수까지 추가한다면...
with tmp as(
select extract(year_month from issue_date) months, sum(cases) case_num, sum(deaths) death_num
    from covid19_data
    where countrycode="kor"
  group by 1
 )
 select "확진" 종류, 
       sum(case when months = 202001 then case_num else 0 end) "202001",
       sum(case when months = 202002 then case_num else 0 end) "202002",
       sum(case when months = 202003 then case_num else 0 end) "202003",
       sum(case when months = 202004 then case_num else 0 end) "202004",
       sum(case when months = 202005 then case_num else 0 end) "202005",
       sum(case when months = 202006 then case_num else 0 end) "202006",
       sum(case when months = 202007 then case_num else 0 end) "202007",
       sum(case when months = 202008 then case_num else 0 end) "202008",
       sum(case when months = 202009 then case_num else 0 end) "202009",
       sum(case when months = 202010 then case_num else 0 end) "202010",
       sum(case when months = 202011 then case_num else 0 end) "202011",
       sum(case when months = 202012 then case_num else 0 end) "202012",
       sum(case when months = 202101 then case_num else 0 end) "202101",
       sum(case when months = 202102 then case_num else 0 end) "202102"
from tmp
union all
select "사망" 종류,
       sum(case when months = 202001 then death_num else 0 end) "202001",
       sum(case when months = 202002 then death_num else 0 end) "202002",
       sum(case when months = 202003 then death_num else 0 end) "202003",
       sum(case when months = 202004 then death_num else 0 end) "202004",
       sum(case when months = 202005 then death_num else 0 end) "202005",
       sum(case when months = 202006 then death_num else 0 end) "202006",
       sum(case when months = 202007 then death_num else 0 end) "202007",
       sum(case when months = 202008 then death_num else 0 end) "202008",
       sum(case when months = 202009 then death_num else 0 end) "202009",
       sum(case when months = 202010 then death_num else 0 end) "202010",
       sum(case when months = 202011 then death_num else 0 end) "202011",
       sum(case when months = 202012 then death_num else 0 end) "202012",
       sum(case when months = 202101 then death_num else 0 end) "202101",
       sum(case when months = 202102 then death_num else 0 end) "202102"
from tmp
;
;

-- (4) Retrieve monthly confirmed cases and deaths by country
-- (4-1) For each country, retrieve the monthly totals for confirmed cases and deaths, with months as columns.
-- Example output : 
-- countryname  type   202001  202002 202003 .....
-- Afghanistan	1.Cases	0	1	174	1952	13081	16299	5158	1494	1109	2157	4849	5252	3497	691
-- Afghanistan	2.Death	0	0	4	60	194	494	532	119	57	78	257	396	209	43
-- Albania	1.Cases	0	0	243	530	364	1398	2741	4237	4136	7226	17307	20134	19811	29040
-- Albania	2.Death	0	0	15	16	2	29	95	127	103	122	301	371	199	416
-- Algeria	1.Cases	0	1	715	3290	5388	4513	16487	14100	7036	6412	25257	16411	7729	5753
-- Algeria	2.Death	0	0	44	406	203	259	298	300	226	228	467	325	135	92
-- Andorra	1.Cases	0	0	376	369	19	91	70	251	874	2706	1989	1304	1888	929
-- Andorra	2.Death	0	0	12	30	9	1	0	1	0	22	1	8	17	9

with tmp1 as(
select b.countryname, extract(year_month from a.issue_date) months, sum(a.cases) case_num, sum(a.deaths) death_num
  from covid19_data a
  join covid19_country b
    on a.countrycode = b.countrycode
  group by 1, 2
)
select countryname, "확진" kind, 
       sum(case when months = 202001 then case_num else 0 end) "202001",
       sum(case when months = 202002 then case_num else 0 end) "202002",
       sum(case when months = 202003 then case_num else 0 end) "202003",
       sum(case when months = 202004 then case_num else 0 end) "202004",
       sum(case when months = 202005 then case_num else 0 end) "202005",
       sum(case when months = 202006 then case_num else 0 end) "202006",
       sum(case when months = 202007 then case_num else 0 end) "202007",
       sum(case when months = 202008 then case_num else 0 end) "202008",
       sum(case when months = 202009 then case_num else 0 end) "202009",
       sum(case when months = 202010 then case_num else 0 end) "202010",
       sum(case when months = 202011 then case_num else 0 end) "202011",
       sum(case when months = 202012 then case_num else 0 end) "202012",
       sum(case when months = 202101 then case_num else 0 end) "202101",
       sum(case when months = 202102 then case_num else 0 end) "202102"
from tmp1 
group by 1
union all
select countryname, "사망" kind,
       sum(case when months = 202001 then death_num else 0 end) "202001",
       sum(case when months = 202002 then death_num else 0 end) "202002",
       sum(case when months = 202003 then death_num else 0 end) "202003",
       sum(case when months = 202004 then death_num else 0 end) "202004",
       sum(case when months = 202005 then death_num else 0 end) "202005",
       sum(case when months = 202006 then death_num else 0 end) "202006",
       sum(case when months = 202007 then death_num else 0 end) "202007",
       sum(case when months = 202008 then death_num else 0 end) "202008",
       sum(case when months = 202009 then death_num else 0 end) "202009",
       sum(case when months = 202010 then death_num else 0 end) "202010",
       sum(case when months = 202011 then death_num else 0 end) "202011",
       sum(case when months = 202012 then death_num else 0 end) "202012",
       sum(case when months = 202101 then death_num else 0 end) "202101",
       sum(case when months = 202102 then death_num else 0 end) "202102"
from tmp1
group by 1, 2
order by 1;



-- (4-2) Create a view from the query in (4-1), and then retrieve the status (number of confirmed cases and deaths) for the United States.
-- (Hint: Use CREATE VIEW)

create or replace view covid19_summary_v as
with tmp1 as(
select b.countryname, extract(year_month from a.issue_date) months, sum(a.cases) case_num, sum(a.deaths) death_num
  from covid19_data a
  join covid19_country b
    on a.countrycode = b.countrycode
  group by 1, 2
)
select countryname, "확진" kind, 
       sum(case when months = 202001 then case_num else 0 end) "202001",
       sum(case when months = 202002 then case_num else 0 end) "202002",
       sum(case when months = 202003 then case_num else 0 end) "202003",
       sum(case when months = 202004 then case_num else 0 end) "202004",
       sum(case when months = 202005 then case_num else 0 end) "202005",
       sum(case when months = 202006 then case_num else 0 end) "202006",
       sum(case when months = 202007 then case_num else 0 end) "202007",
       sum(case when months = 202008 then case_num else 0 end) "202008",
       sum(case when months = 202009 then case_num else 0 end) "202009",
       sum(case when months = 202010 then case_num else 0 end) "202010",
       sum(case when months = 202011 then case_num else 0 end) "202011",
       sum(case when months = 202012 then case_num else 0 end) "202012",
       sum(case when months = 202101 then case_num else 0 end) "202101",
       sum(case when months = 202102 then case_num else 0 end) "202102"
from tmp1 
group by 1
union all
select countryname, "사망" kind,
       sum(case when months = 202001 then death_num else 0 end) "202001",
       sum(case when months = 202002 then death_num else 0 end) "202002",
       sum(case when months = 202003 then death_num else 0 end) "202003",
       sum(case when months = 202004 then death_num else 0 end) "202004",
       sum(case when months = 202005 then death_num else 0 end) "202005",
       sum(case when months = 202006 then death_num else 0 end) "202006",
       sum(case when months = 202007 then death_num else 0 end) "202007",
       sum(case when months = 202008 then death_num else 0 end) "202008",
       sum(case when months = 202009 then death_num else 0 end) "202009",
       sum(case when months = 202010 then death_num else 0 end) "202010",
       sum(case when months = 202011 then death_num else 0 end) "202011",
       sum(case when months = 202012 then death_num else 0 end) "202012",
       sum(case when months = 202101 then death_num else 0 end) "202101",
       sum(case when months = 202102 then death_num else 0 end) "202102"
from tmp1
group by 1, 2
order by 1;

select * from covid19_summary_v
  where countryname = "united states";
       

       
