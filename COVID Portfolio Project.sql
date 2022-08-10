--THIS IS A COVID-19 RELATED PROJECT 

--THESE QUERIES SHOW SOME OF THE ANALYSIS I CAN DO USING SQL 
--I USED 4 OF THESE QUERIES TO CREATE VISUALIZATIONS ON TABLEAU (I HAVE INDICATED WHICH)
--HERE IS THE LINK TO MY TABLEAU PUBLIC: 

SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4
--IF YOU EXPLORE THE DATA, IF CONTINENT IS NULL, THEN LOCATION IS THE CONTINENT
-- SO WE HAVE WEIRD VALUES FOR LOCATION SUCH AS WORLD, EUROPE, ASIA... SO THERE'S A GROUPING ISSUE AT HAND
-- TO ADDRESS THIS ISSUE, WE SHOULD SPECIFY FOR ALL OUR QUERIES, WHERE CONTINENT IS NOT NULL 

SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3, 4


SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4


-- Select Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths 
-- Shows the likelihood of dying if you contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL 
ORDER BY 1, 2 


-- Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL 
ORDER BY 1, 2


-- Looking at countries with highest infection rate compared to population 

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' AND continent IS NOT NULL 
GROUP BY location, population
ORDER BY InfectedPercentage DESC


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC
--WE ARE CASTING IT TO INT BECAUSE WE WERE GETTING WEIRD VALUES AT FIRST, THEN WE CHECKED THE TYPE OF TOTAL_DEATHS AND WE REALIZED IT WAS VARCHAR
-- TOTAL_DEATHS SHOULD BE NUMERIC SO WE CAST IT TO INT
--AS YOU CAN SEE, THE US IS NUMBER 1


-- LET'S BREAK THINGS DOWN BY CONTINENT 

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent IS NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS 

SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
ORDER BY 1, 2 

--This shows total number of new cases by day in the whole world
SELECT date, SUM(new_cases)
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1, 2 

--This shows total number of new cases and new deaths in the whole world. We are casting new_deaths to int because it was initially an nvarchar
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int))
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1, 2 

SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1, 2 
--This one is grouped by date 



--We can remove the date to see the total global numbers 
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
ORDER BY 1, 2 
--USED FOR TABLEAU VISUALIZATION AS TABLE 1


SELECT location, SUM(cast(new_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NULL 
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC
--USED FOR TABLEAU VISUALIZATION AS TABLE 2


SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population) *100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
--USED FOR TABLEAU VISUALIZATION AS TABLE 3


SELECT Location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' AND continent IS NOT NULL 
GROUP BY location, population, date
ORDER BY InfectedPercentage DESC
--USED FOR TABLEAU VISUALIZATION AS TABLE 4



--Looking at data from the other dataset (vaccinations) or table 
SELECT *
FROM PortfolioProject..CovidVaccinations

SELECT * 
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, population, new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3
--When you order by multiple columns, it's because there's a tie in some records, so you can order by a 2nd or even 3rd column 
-- In our case we don't really need to order by the third column because all the locations have different dates
 
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2
--This shows that you do not need the 3rd column of date (as we get the same output as above)

SELECT dea.continent, dea.location, dea.date, population, new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2
--This ordering so we can look at Afghanistan first (we are ordering by location)

SELECT dea.continent, dea.location, dea.date, population, new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location)
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2
--We want to do a rolling count 
--However, we want to partition it by location so that once it gets to another country, the sum stops and starts over
--The problem with this partitioning is that the partition column would have the same value for a location in every single row (it would be the total number of vaccinations)
--ALSO... Notice how we casted the new_vaccinations into int by using the CONVERT 

SELECT dea.continent, dea.location, dea.date, population, new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2
--To fix the issue encountered in the previous query, we need to order inside the partition by location and date
--If we take a look at this output, you can see the rolling count works, and it ignores the NULL values

 
--Now we want to use the max value of RollingPeopleVaccinated for each location and compare it to its population 
--This will give us the percentage of people that are vaccinated in each country 
--However, you cannot use a column that you just created in the same query 
--So you have 2 solutions: Use CTE or create a Temp Table


--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac


--WITH TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
