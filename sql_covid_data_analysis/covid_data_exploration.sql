/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From coviddeaths
Where continent is not null 
order by 3,4;

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From coviddeaths
Where location like '%states%'
and continent is not null 
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From coviddeaths
-- Where location like '%states%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as unsigned)) as TotalDeathCount
From coviddeaths
-- Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as unsigned)) as TotalDeathCount
From coviddeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as unsigned)) as total_deaths, SUM(cast(new_deaths as unsigned))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.location, dea.date;
    
-- Using CTE to perform Calculation on Partition By in previous query


WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
            OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM coviddeaths dea
    JOIN covidvaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentVaccinated
FROM PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated (
  Continent VARCHAR(255),
  Location VARCHAR(255),
  Date DATETIME,
  Population BIGINT,
  New_vaccinations BIGINT,
  RollingPeopleVaccinated BIGINT
);

INSERT INTO PercentPopulationVaccinated (
  Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated
)
SELECT
  t.continent,
  t.location,
  t.safe_date,
  t.population,
  t.new_vax,
  SUM(t.new_vax) OVER (
    PARTITION BY t.location
    ORDER BY t.safe_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS RollingPeopleVaccinated
FROM (
  SELECT
    dea.continent,
    dea.location,
    -- read date as string once
    TRIM(CAST(dea.date AS CHAR)) AS raw_date,
    dea.population,
    -- sanitize new_vaccinations to unsigned integer (tolerates commas)
    CASE
      WHEN vac.new_vaccinations IS NULL OR TRIM(vac.new_vaccinations) = '' THEN 0
      WHEN TRIM(REPLACE(vac.new_vaccinations, ',', '')) REGEXP '^[0-9]+$'
        THEN CAST(REPLACE(vac.new_vaccinations, ',', '') AS UNSIGNED)
      ELSE 0
    END AS new_vax,
    -- only call STR_TO_DATE when the raw_date matches a known pattern
    CASE
      WHEN TRIM(CAST(dea.date AS CHAR)) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
        THEN STR_TO_DATE(TRIM(CAST(dea.date AS CHAR)), '%Y-%m-%d %H:%i:%s')
      WHEN TRIM(CAST(dea.date AS CHAR)) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        THEN STR_TO_DATE(TRIM(CAST(dea.date AS CHAR)), '%Y-%m-%d')
      WHEN TRIM(CAST(dea.date AS CHAR)) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
        THEN STR_TO_DATE(TRIM(CAST(dea.date AS CHAR)), '%d/%m/%Y')
      ELSE NULL
    END AS safe_date
  FROM portfolio_project.coviddeaths dea
  JOIN portfolio_project.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
) AS t
-- skip rows whose date couldn't be parsed (remove this filter if you want NULL dates)
WHERE t.safe_date IS NOT NULL
ORDER BY t.location, t.safe_date;

-- Final output with percentage
SELECT 
  Continent,
  Location,
  Date,
  Population,
  New_vaccinations,
  RollingPeopleVaccinated,
  ROUND((RollingPeopleVaccinated / NULLIF(Population, 0)) * 100, 2) AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated
ORDER BY Location, Date;

-- Creating View to store data for later visualizations

CREATE OR REPLACE VIEW PercentPopulationVaccinated AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
    OVER (
      PARTITION BY dea.location
      ORDER BY dea.date
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeaths AS dea
JOIN portfolio_project.covidvaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL; 
