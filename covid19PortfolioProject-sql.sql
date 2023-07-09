/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions,  Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM covidDeath
ORDER BY 3,4

SELECT *
FROM covidVaccination
ORDER BY 3,4


-- Selecting the data that I am going to be starting with 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covidDeath
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths 
--SELECT location, date, total_cases, total_deaths, ((cast (total_deaths as int)) /(cast (total_cases as int))) 
SELECT location, date, total_cases, total_deaths, (CONVERT (float,total_deaths)/ (total_cases))*100 as DeathPercentage
FROM covidDeath
WHERE location like '%Nigeria%'
ORDER BY 1,2
-- This shows the likelihood of dying if you contract covid in my country 


-- Looking at Total Cases vs Population
SELECT location, date, population, total_cases,(CONVERT (float,total_cases)/ (population)) * 100 as percentPopulationInfected
FROM covidDeath
WHERE location like '%Nigeria%'
ORDER BY 1,2
-- This shows the percentage of population with covid in my country 


-- Looking at countries with highest infection rate compared to population 
SELECT location, population, MAX(total_cases) as  HighestInfectionCount,MAX((CONVERT (float,total_cases)/ (population))) * 100 as percentPopulationInfected
FROM covidDeath
GROUP BY location, population
ORDER BY percentPopulationInfected DESC


-- Looking at countries with highest death count by population 
SELECT location, population, MAX((CONVERT(float,total_deaths))) as HighestdeathCount,MAX((CONVERT (float,total_deaths)/ (population))) * 100 as HighestdeathCountPercentage
FROM covidDeath
--WHERE location like '%Nigeria%'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY HighestdeathCount DESC


-- Looking at continent with highest death count 
SELECT continent, MAX((CONVERT(float,total_deaths))) as TotaldeathCount
FROM covidDeath
--WHERE location like '%Nigeria%'
WHERE continent is not NULL 
GROUP BY continent
ORDER BY TotaldeathCount DESC



-- Looking at Total Population vs vaccinations in the each continent
SELECT dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated)*100 We can't use a column that we just created and then use it in the next one, so we will have to use a cte or temp table.
FROM covidDeath as dea
JOIN covidVaccination as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2,3


--Using CTE to performcalculation on partiton by in previous query 
with PopvsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM covidDeath as dea
JOIN covidVaccination as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Using a Temp Table to perform calculation on partition By in previous query  

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar,
date  datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM covidDeath as dea
JOIN covidVaccination as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *--,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations 
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM covidDeath as dea
JOIN covidVaccination as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3


