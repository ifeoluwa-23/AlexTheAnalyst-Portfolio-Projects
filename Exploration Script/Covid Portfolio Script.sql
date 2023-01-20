/*
Covid 19 Data Exploration 
Skills used: Joins, Casting Data Types, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select 
	*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;



-- Select Data that we are going to be starting with

Select
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

/* Activity 1
Total Cases Vs Total Deaths Per country
To show likelihood of dying after contracting Covid
*/

Select
	Location, 
	date, 
	total_cases, 
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2;

/* Activity 2
Total Cases Vs Population
To show the percentage of population infected with Covid
*/

Select
	Location, 
	date, 
	population,
	total_cases, 
	(total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

/* Activity 3
shows countries with highest infection rate per location
*/

Select
	Location, 
	population,
	max(total_cases) as HighestInfectionCount, 
	max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by
	Location, Population
order by
	4 desc;

/* Activity 4
shows countries with highest death count per population
*/

Select
	Location, 
	max(cast(total_deaths as int)) as HighestDeathCount
	-- (total_deaths/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by
	Location
order by
	2 desc;

/* Activity 5
shows the breakdown of activity 4 by continent
*/

Select
	continent, 
	max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by
	continent
order by
	2 desc;


/* Activity 6
Global figures
*/

Select
	--date, 
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_death,
	(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

/* Activity 7
shows the join of both tables
*/

select 
	*
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidsVaccinations cv
	on cd.location=cv.location
		and cd.date = cv.date;


/* Activity 8
Total Population by vaccinations
Shows Percentage of Population that has recieved at least one Covid Vaccine
*/

select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidsVaccinations cv
	on cd.location=cv.location
		and cd.date = cv.date
where 
	cd.continent is not null
order by
	2,3;

/* Activity 9
Total Population by vaccinations roll over
*/

select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidsVaccinations cv
	on cd.location=cv.location
		and	cd.date = cv.date
where 
	cd.continent is not null
order by
	2,3;

/* Activity 10
Using CTE to perform Calculation on Partition By in activity 9
*/


with PopvsVac (continent, location, date, population, new_vaccnations, RollingPeopleVaccinated) as
(
select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date)  as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidsVaccinations cv
	on cd.location=cv.location
		and	cd.date = cv.date
where 
	cd.continent is not null
)
select
	*,
	(RollingPeopleVaccinated/population)*100
from PopvsVac;


/* Activity 11
creating a temp table for percent of population vaccinated
*/

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
populaton numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date)  as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidsVaccinations cv
	on cd.location=cv.location
		and	cd.date = cv.date
where 
	cd.continent is not null

select
	*,
	(RollingPeopleVaccinated/populaton)*100
from
	#PercentPopulationVaccinated;

/* Activity 12
creating a view to store data for visualizations
*/
create view PercentPopulationVaccinated as
(select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date)  as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidsVaccinations cv
	on cd.location=cv.location
		and	cd.date = cv.date
where 
	cd.continent is not null
);

