SELECT * 
FROM portfolioproject..[covid-deaths]
order by 3,4
		
SELECT * 
FROM portfolioproject..[covid-vaccinations]
order by 3,4  

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..[covid-deaths]
order by 1,2

--looking at total cases vs total deaths)
-- show likelihood of death if you contct covid in your country


select 
    location, date, total_cases, total_deaths, 
    CONVERT(DECIMAL(18, 8), (CONVERT(DECIMAL(18, 8), total_deaths) / CONVERT(DECIMAL(18, 8), total_cases)))*100 as death_percentage
from portfolioproject..[covid-deaths]
order by 1,2

select 
    location, date, total_cases, total_deaths, 
    CONVERT(DECIMAL(18, 8), (CONVERT(DECIMAL(18, 8), total_deaths) / CONVERT(DECIMAL(18, 8), total_cases)))*100 as death_percentage
from portfolioproject..[covid-deaths]
WHERE location = 'India'
order by 1,2

--looking at the total cases vs population
--shows what percentage of population got covid



select 
    location,date, population, total_cases, (total_cases/population)*100 as covid_percentage_population 
    from portfolioproject..[covid-deaths]
order by 1,2



--looking at countries with highest infection rate vs population

select 
    location, population, MAX(total_cases) AS Highest_casescount , MAX(total_cases)/MAX(population)*100 as covid_percentage_population 
    from portfolioproject..[covid-deaths]
group by location, population
order by covid_percentage_population DESC

--looking for countries with highest death count per population

select 
    location, population, MAX(CAST(total_deaths as int)) as total_death_count
    from portfolioproject..[covid-deaths]
WHERE continent is not null
group by location, population
order by total_death_count DESC

-- looking for continents with total deaths

select location, MAX(CAST(total_deaths as int)) as total_death_count
    from portfolioproject..[covid-deaths]
WHERE continent is null
group by location
order by total_death_count DESC

-- daily cases count across the world

select date, SUM(new_cases) as total_cases, SUM(total_deaths as int) as total_deaths, 
SUM(cast (new_deaths as int)) /SUM(new_cases)*100 as death percentage
from [portfolioproject]..[covid-deaths]
where continent is not null
group by date
order by 1,2

--looking at the total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [portfolioproject]..[covid-deaths] dea
join [portfolioproject]..[covid-vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations))
 over (partition by dea.location,dea.date) as rollingpeoplevaccinated 
from [portfolioproject]..[covid-deaths] dea
join [portfolioproject]..[covid-vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using cte

with popvsvac(continent, date, loaction, population,new_vaccinations,rollingpeoplevaccinated)
as
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations))
 over (partition by dea.location,dea.date) as rollingpeoplevaccinated 
from [portfolioproject]..[covid-deaths] dea
join [portfolioproject]..[covid-vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (rollingpeoplevaccinated/population)*100 as vaccinated_percentage from popvsvac

--temp table


drop table if exists #percentpopulatedvaccinated
create table #percentpopulatedvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,)

INSERT INTO #percentpopulatedvaccinated
 SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations))
 over (partition by dea.location,dea.date) as rollingpeoplevaccinated 
from [portfolioproject]..[covid-deaths] dea
join [portfolioproject]..[covid-vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
select * , (rollingpeoplevaccinated/population)*100 as vaccinated_percentage from #percentpopulatedvaccinated


--creating view to store data for later visualization

create view percentpopulatedvaccinated as
 SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations))
 over (partition by dea.location,dea.date) as rollingpeoplevaccinated 
from [portfolioproject]..[covid-deaths] dea
join [portfolioproject]..[covid-vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null



select * from percentpopulatedvaccinated