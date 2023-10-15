select *
from CovidDeaths
where continent is not null AND continent <> '';

-- Change the data type of total_deaths to FLOAT
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT;

-- Change data types 
ALTER TABLE CovidDeaths
ALTER COLUMN population FLOAT;

ALTER TABLE CovidDeaths
ALTER COLUMN new_cases FLOAT;

ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths FLOAT;

ALTER TABLE CovidDeaths
ALTER COLUMN date date;

--select *
--from CovidVaccinations

--Select Data that I am going to use

select location, date, total_cases, new_cases,total_deaths, population
from CovidDeaths
where continent is not null AND continent <> '';



--total cases vs total deaths
--Shows the chances of death if you got infected in your country
SELECT location, date, total_cases, total_deaths,
       CASE
           WHEN total_cases = 0 THEN NULL  -- Handle division by zero
           ELSE CAST(total_deaths AS FLOAT) / total_cases *100
       END AS death_rate
FROM CovidDeaths
where location like '%Egypt%' And
continent is not null AND continent <> '';


-- Total cases vs Population
-- Percentage of population got covid
SELECT location, date, population,total_cases,
       CASE
           WHEN total_cases = 0 THEN NULL  -- Handle division by zero
           ELSE CAST(total_cases AS FLOAT) / population *100
       END AS infection_rate
FROM CovidDeaths
where location like '%Egypt%' And
continent is not null AND continent <> ''


--Highest infection rate to Population

SELECT location, population, Max(total_cases) as HighestInfectionCount,
       CASE
           WHEN Max(total_cases) = 0 THEN NULL  -- Handle division by zero
           ELSE (CAST(Max(total_cases) AS FLOAT) / population *100)
       END AS infection_rate
FROM CovidDeaths
where continent is not null AND continent <> ''
GROUP BY
    location,
    population
order by infection_rate Desc


--Highest Mortality Rate / Population / Location

SELECT location, population, Max(total_deaths) as TotalDeathCount,
CASE
           WHEN Max(total_deaths) = 0 THEN NULL  -- Handle division by zero
           ELSE (CAST(Max(total_deaths) AS FLOAT) / population *100)
       END AS Death_rate
FROM CovidDeaths
where continent is not null AND continent <> ''
GROUP BY
    location,
    population
order by TotalDeathCount Desc

--BY continent/location

SELECT continent, Max(total_deaths) as TotalDeathCount
FROM CovidDeaths
where continent is not null AND continent <> '' 
GROUP BY continent
order by TotalDeathCount Desc

--Global DeathPercentage
SELECT sum(new_cases) as TotalNewCases, sum(new_deaths) as TotalNewDeaths,
CASE
        WHEN SUM(new_cases) = 0 THEN NULL  -- Handle division by zero
        ELSE SUM(new_deaths) * 100.0 / SUM(new_cases)
    END AS DeathPercentage
FROM CovidDeaths
where continent is not null AND continent <> '' 
--group by Date
order by 1
--location like '%Egypt%'

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by Dea.location order by dea.location, dea.date) AccumaltiveVaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null AND dea.continent <> '' 



--ALTER TABLE CovidVaccinations
--ALTER COLUMN date date;

--ALTER TABLE CovidVaccinations
--ALTER COLUMN population FLOAT;


--ALTER TABLE CovidVaccinations
--ALTER COLUMN new_vaccinations FLOAT;

--Use CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by Dea.location order by dea.location, dea.date) AccumaltiveVaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null AND dea.continent <> '' )
select *, (RollingPeopleVaccinated/Population)*100 RollingPeopleVaccinatedPercentage
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated2
Create Table #PercentPopulationVaccinated2
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric)

Insert into #PercentPopulationVaccinated2
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by Dea.location order by dea.location, dea.date) AccumaltiveVaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null AND dea.continent <> '' 
 select *, (RollingPeopleVaccinated/Population)*100 RollingPeopleVaccinatedPercentage
From #PercentPopulationVaccinated2

--Creating View for storage and Visulaizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by Dea.location order by dea.location, dea.date) AccumaltiveVaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null AND dea.continent <> '' 

