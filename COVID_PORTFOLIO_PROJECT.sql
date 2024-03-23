SELECT * FROM CovidDeaths
order by 3,4


-- SELECT * FROM CovidVaccinations
-- order by 3,4


SELECT [location], date, total_cases, new_cases, total_deaths, population FROM CovidDeaths
ORDER BY 1,2


-- Looking at total Cases vrs Total Deaths
-- show likelihood of dying if you contract covid in your country
SELECT [location], date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM CovidDeaths
WHERE [location] LIKE '%DURAS%'
ORDER BY 1,2

-- Looking at total cases vrs population
-- shows what percentage of population got covid
SELECT [location], date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS ProbabilityCovid
FROM CovidDeaths
WHERE [location] LIKE '%DURAS%'
ORDER BY 1,2

-- Get Information until the last date reported '2021-04-30' per country
SELECT [location], total_cases, population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS ProbabilityCovid,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM CovidDeaths
WHERE [date] = '2021-04-30'

-- Looking at countries with highest infection rate compared to population
SELECT [location], population, MAX(total_cases) as HighestInfectionCount, 
MAX(CONVERT(float, total_cases) / population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
-- WHERE [location] LIKE '%DURAS%'
GROUP BY [location], population
ORDER BY 4 DESC

-- Showing countries with highest death count per population
SELECT [location], population, MAX(total_deaths) as HighestDeathCount, 
MAX(CONVERT(float, total_deaths) / population) * 100 AS PercentPopulationDeath
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location], population
ORDER BY 3 DESC


-- lET'S BREAK THINGS DOWN BY CONTINENT
SELECT [location], MAX(total_deaths) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY [location]
ORDER BY 2 DESC

-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT
SELECT [continent], MAX(total_deaths) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [continent]
ORDER BY 2 DESC

-- Global Numbers

SELECT SUM(new_cases) as Total_cases, SUM(new_deaths) as total_deaths, SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 as Deathpercentage
FROM CovidDeaths
WHERE continent is not null
-- GROUP BY [date]
ORDER BY 1,2


-- Looking at total population vs vaccinations
Select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated,
 RollingPeopleVaccinated/population*100
from CovidDeaths dea
join CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
order by 2,3

-- USE CTE

With PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--  RollingPeopleVaccinated/population*100
from CovidDeaths dea
join CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac
where [location] like '%duras%'


-- Looking at total population vs vaccinations BY CONTINENT
Select dea.[location],population, SUM(vac.new_vaccinations) as TotalVccinated, SUM(CAST(vac.new_vaccinations AS float))/SUM(dea.population) * 100 as PercentageVaccinated
from CovidDeaths dea
join CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.date
WHERE dea.continent is null
GROUP BY dea.[location], population

-- Looking at total population vs vaccinations BY Country
Select dea.[location],population, SUM(vac.new_vaccinations) as TotalVccinated, SUM(CAST(vac.new_vaccinations AS float))/SUM(dea.population) * 100 as PercentageVaccinated
from CovidDeaths dea
join CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.date
WHERE dea.continent is not null
GROUP BY dea.[location], population
order by 1

-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--  RollingPeopleVaccinated/population*100
from CovidDeaths dea
join CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
-- order by 2,3

SELECT * FROM PercentPopulationVaccinated