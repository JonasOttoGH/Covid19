--Checking data from both datasets to see if anymore cleaning needs to be done
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Afghanistan'

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations

SELECT  *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, Population
FROM PortfolioProject.dbo.CovidDeaths
ORDER by 1,2

SELECT DISTINCT Location
FROM PortfolioProject.dbo.CovidDeaths

--Looking at total cases VS total deaths 
--Likilyhood of dying in America if you contrated covid as a %

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%States%'
ORDER by 1,2

-- Likilyhood of dying in New Zealand if you contrated Covid19 as a %

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'New Zealand'
ORDER by 1,2

-- Looking at total cases VS Population (showing percentage cases according to population as a %)

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'New Zealand'
ORDER by 1,2

SELECT Location, date, total_cases, total_deaths, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%States%'
ORDER by 1,2

--Looking at countries with highest infection rates compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--Where location like %states%
GROUP BY Location, population
ORDER by PercentPopulationInfected desc

--Showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER by TotalDeathCount desc

-- Showing the continent with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not  null
GROUP BY continent
ORDER by TotalDeathCount desc

-- Showing global numbers per day

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage -- (total_deaths/total_cases)*100 AS Deathpercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER by 1,2

-- Showing global numbers total average

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage-- (total_deaths/total_cases)*100 AS Deathpercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER by 1,2

--Joining two tables together

SELECT  *
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date

--looking at total population vs vaccinations

SELECT  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
Order by 1,2,3

-- Using CTE to make  a rolling population count column
With PopulationVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
( 
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT * , (RollingPeopleVaccinated/population)*100
From PopulationVaccination

-- Using Temp Table to make a rolling population count column

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
  Continent nvarchar (255),
  Location nvarchar (255),
  Date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated 
Select dea.continent, dea.location,dea.Date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as PopulationPercent_RollingPopVac
From #PercentPopulationVaccinated

--Creating Views to store data for later visualizations

USE PortfolioProject;
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.Date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null 


USE PortfolioProject;
GO
Create View CountiresDeathCountsPerPopulation as
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location


USE PortfolioProject;
GO
Create View LikilyhoodofDyinginNZ as
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'New Zealand'

