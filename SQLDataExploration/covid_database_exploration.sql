-- create covid_deaths table
create table covid_deaths(
iso_code varchar(50) not null,
continent varchar(200),
location varchar (200) not null,
date timestamp not null,
total_cases	integer,
new_cases integer,
new_cases_smoothed float,
total_deaths integer,
new_deaths integer,
new_deaths_smoothed	float,
total_cases_per_million	float,
new_cases_per_million float,
new_cases_smoothed_per_million float,
total_deaths_per_million float,
new_deaths_per_million float,
new_deaths_smoothed_per_million	float,
reproduction_rate float,
icu_patients integer,
icu_patients_per_million float,	
hosp_patients integer,
hosp_patients_per_million float,
weekly_icu_admissions integer,
weekly_icu_admissions_per_million float,
weekly_hosp_admissions float,
weekly_hosp_admissions_per_million float,
new_tests integer,
total_tests	integer,
total_tests_per_thousand float,
new_tests_per_thousand float,
new_tests_smoothed integer,
new_tests_smoothed_per_thousand	float,
positive_rate float,
tests_per_case float,
tests_units	varchar(250),
total_vaccinations integer,
people_vaccinated integer,	
people_fully_vaccinated	integer,
new_vaccinations integer,
new_vaccinations_smoothed integer,	
total_vaccinations_per_hundred float,
people_vaccinated_per_hundred float,
people_fully_vaccinated_per_hundred	float,
new_vaccinations_smoothed_per_million float,
stringency_index float,
population float,
population_density float,
median_age float,
aged_65_older float,
aged_70_older float,
gdp_per_capita float,
extreme_poverty float,
cardiovasc_death_rate float,
diabetes_prevalence float,
female_smokers float,
male_smokers float,
handwashing_facilities float,
hospital_beds_per_thousand float,
life_expectancy float,
human_development_index float
);

--Import Database for covid_deaths table
COPY covid_deaths(iso_code,continent,location,date,total_cases,new_cases,new_cases_smoothed,total_deaths,new_deaths,new_deaths_smoothed,total_cases_per_million,new_cases_per_million,new_cases_smoothed_per_million,total_deaths_per_million,new_deaths_per_million,new_deaths_smoothed_per_million,reproduction_rate,icu_patients,icu_patients_per_million,hosp_patients,hosp_patients_per_million,weekly_icu_admissions,weekly_icu_admissions_per_million,weekly_hosp_admissions,weekly_hosp_admissions_per_million,new_tests,total_tests,total_tests_per_thousand,new_tests_per_thousand,new_tests_smoothed,new_tests_smoothed_per_thousand,positive_rate,tests_per_case,tests_units,total_vaccinations,people_vaccinated,people_fully_vaccinated,new_vaccinations,new_vaccinations_smoothed,total_vaccinations_per_hundred,people_vaccinated_per_hundred,people_fully_vaccinated_per_hundred,new_vaccinations_smoothed_per_million,stringency_index,population,population_density,median_age,aged_65_older,aged_70_older,gdp_per_capita,extreme_poverty,cardiovasc_death_rate,diabetes_prevalence,female_smokers,male_smokers,handwashing_facilities,hospital_beds_per_thousand,life_expectancy,human_development_index
)
FROM 'D:\DataAanlysis\Databases\portfolio-databases\CovidDeaths.csv' 
DELIMITER ',' CSV HEADER;

-- change type for weekly_icu_admissions column in covid_deaths table
ALTER TABLE covid_deaths
ALTER COLUMN weekly_icu_admissions TYPE float
USING weekly_icu_admissions::float;

-- create covid_vaccinations table
create table covid_vaccinations(
iso_code varchar(50) not null,
continent varchar(200),
location varchar (200) not null,
date timestamp not null,
new_tests integer,
total_tests integer,
total_tests_per_thousand float,
new_tests_per_thousand float,
new_tests_smoothed integer,
new_tests_smoothed_per_thousand float,
positive_rate float,
tests_per_case float,
tests_units varchar(250),
total_vaccinations integer,
people_vaccinated integer,
people_fully_vaccinated integer,
new_vaccinations integer,
new_vaccinations_smoothed integer,
total_vaccinations_per_hundred float,
people_vaccinated_per_hundred float,
people_fully_vaccinated_per_hundred float,
new_vaccinations_smoothed_per_million float,
stringency_index float,
population_density float,
median_age float,
aged_65_older float,
aged_70_older float,
gdp_per_capita float,
extreme_poverty float,
cardiovasc_death_rate float,
diabetes_prevalence float,
female_smokers float,
male_smokers float,
handwashing_facilities float,
hospital_beds_per_thousand float,
life_expectancy float,
human_development_index float
);

--Import Database for covid_deaths table
COPY covid_deaths(iso_code,continent,location,date,new_tests,total_tests,total_tests_per_thousand,new_tests_per_thousand,new_tests_smoothed,new_tests_smoothed_per_thousand,positive_rate,tests_per_case,tests_units,total_vaccinations,people_vaccinated,people_fully_vaccinated,new_vaccinations,new_vaccinations_smoothed,total_vaccinations_per_hundred,people_vaccinated_per_hundred,people_fully_vaccinated_per_hundred,new_vaccinations_smoothed_per_million,stringency_index,population_density,median_age,aged_65_older,aged_70_older,gdp_per_capita,extreme_poverty,cardiovasc_death_rate,diabetes_prevalence,female_smokers,male_smokers,handwashing_facilities,hospital_beds_per_thousand,life_expectancy,human_development_index
)
FROM 'D:\DataAanlysis\Databases\portfolio-databases\CovidVaccinations.csv' 
DELIMITER ',' CSV HEADER;

-- show covid_deaths table
select * from covid_deaths;

-- show covid_vaccinations table
select * from covid_vaccinations;

-- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population 
from covid_deaths
order by location, date;

-- Looking total cases with total deaths
-- How many cases are there in this country?
-- and then how many deaths they have for their entire cases?
select location, date, total_cases, total_deaths, 
(cast(total_deaths as float))/(cast(total_cases as float))*100 as death_percent
from covid_deaths
order by location, date;

-- Looking total cases with total deaths
-- Show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, 
(cast(total_deaths as float))/(cast(total_cases as float))*100 as death_percent
from covid_deaths
where location ilike '%states%'
order by location, date;

-- Looking total cases with population
-- Shows what percentage of population got Covid
select location, date, population, total_cases, 
(cast(total_cases as float))/(cast(population as float))*100 as gotCovid_percent
from covid_deaths
order by location, date;

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as highest_infection_count, 
max((cast(total_cases as float))/(cast(population as float)))*100 as percent_population_infected
from covid_deaths
group by location, population
order by percent_population_infected desc;

-- Let's break things down by continent 
-- Showing continents with the highest death count per population
select continent, max(total_deaths) as total_deaths_count
from covid_deaths
where continent is not null
group by continent
order by total_deaths_count desc;

-- Global Numbers
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as death_percent
from covid_deaths
where continent is not null
group by date
order by date, total_cases;

-- 
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as death_percent
from covid_deaths
where continent is not null
order by total_cases;

-- Looking at Total Population vs Vaccinations
select d.continent, d.location, d.date, population, v.new_vaccinations
from covid_deaths as d
inner join covid_vaccinations as v
on d.location = v.location and d.date = v.date
order by d.continent, d.location, d.date;

--
select d.continent, d.location, d.date, population, v.new_vaccinations,
sum(cast(v.new_vaccinations as integer)) over (partition by d.location order by d.location, d.date)
as rolling_people_vaccinated, 
from covid_deaths as d
inner join covid_vaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by d.location, d.date;

-- use cte
with pop_and_vac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as (
select d.continent, d.location, d.date, population, v.new_vaccinations,
sum(cast(v.new_vaccinations as integer)) over (partition by d.location order by d.location, d.date)
as rolling_people_vaccinated
from covid_deaths as d
inner join covid_vaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null
)
select *, (rolling_people_vaccinated/population)*100
from pop_and_vac

-- TEMP TABLE
drop table if exists percent_population_vaccinated

create table percent_population_vaccinated(
continent varchar(200),
location varchar (200) not null,
date timestamp not null,
population float,
new_vaccinations float,
rolling_people_vaccinated float
)

insert into percent_population_vaccinated
select d.continent, d.location, d.date, population, v.new_vaccinations,
sum(cast(v.new_vaccinations as integer)) over (partition by d.location order by d.location, d.date)
as rolling_people_vaccinated
from covid_deaths as d
inner join covid_vaccinations as v
on d.location = v.location and d.date = v.date

select *
from percent_population_vaccinated

-- Creating view to store data for later visualizations
create view percent_population_vaccinated_view as
select d.continent, d.location, d.date, population, v.new_vaccinations,
sum(cast(v.new_vaccinations as integer)) over (partition by d.location order by d.location, d.date)
as rolling_people_vaccinated
from covid_deaths as d
inner join covid_vaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null