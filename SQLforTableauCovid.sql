-- SQL for Tableau vizualization

----------------1---------------
-- Global Death Pearcent per Case

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)*1.0/SUM(new_cases)*100 AS Death_percentage
FROM Covid19..CovidDeaths
WHERE continent IS NOT NULL

----------------2---------------
-- Continents death count

SELECT location, MAX(total_deaths) AS max_total_deaths
FROM Covid19..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income%' AND location NOT IN ('World', 'European Union')
GROUP BY location
ORDER BY max_total_deaths DESC

----------------3---------------
-- Countries with highest Percent of Population Infected

SELECT location, MAX(total_cases) as max_total_cases, population, MAX(total_cases/population)*100 AS Infection_rate
FROM Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX(total_cases) IS NOT NULL -- filter out countries without data
ORDER BY 4 DESC

----------------4---------------
-- Countries with highest Percent of Population Infected timeseries

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Infection_rate
FROM Covid19..CovidDeaths
ORDER BY 5 DESC