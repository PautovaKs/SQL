-------------------- DATA EXPLORATION -----------------------------------

-- Check the highest level of data groups: continent
SELECT DISTINCT continent
FROM Covid19..CovidDeaths

-- Since there are 7 continents in the world and data has 6 and NULL, let's check if Null is the last continent
SELECT DISTINCT location
FROM Covid19..CovidDeaths
WHERE continent IS NULL

-- Looks like it's actually pregrouped data by again continent (the same 6), and income data (4 groups) and European Union and World
-- Let's check correctnes of those (let's call them pre-groups) and use number of death, for example
-- Start with World

SELECT location, MAX(total_deaths) AS total_deaths
FROM Covid19..CovidDeaths
WHERE continent IS NULL AND location = 'World'
GROUP BY location

-- And now calculate this number from diffrent angle
-- Going to create Temp Table with detailed data, which we will use later

DROP TABLE IF EXISTS #Continents -- just in case we need to modify our temp table
CREATE TABLE #Continents
(continent varchar(50),
location varchar(50),
max_total_deaths numeric
)

INSERT INTO #Continents
SELECT continent, location, MAX(total_deaths) AS max_total_deaths
FROM Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location


SELECT SUM(max_total_deaths) AS total_deaths
FROM #Continents

-- The diffrence between two numbers = 2, which could be neglected,  (considering the scale of tragedy)
-- Let's now check the continent scale and start with pre-groups, where continent IS NULL

SELECT location, MAX(total_deaths) AS total_deaths
FROM Covid19..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income%' AND location NOT IN ('World', 'European Union')
GROUP BY location
ORDER BY total_deaths DESC

-- Calculate the numbers from diffrent perspective

SELECT continent, SUM(max_total_deaths) AS total_deaths
FROM #Continents
GROUP BY continent
ORDER BY 2 DESC

-- Again with slight deviation (not more than 5), numbers can be considered identical

-- Moving on more detailed look
-- Let's see the percent of Population infected over time in Italy, for example
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Infection_rate
FROM Covid19..CovidDeaths
WHERE location = 'Italy'
ORDER BY 1,2

-- Countries with highest Infection rate
-- I don't have access to the full version of Tableau, but if I did, I would need to create a view for future visualization
-- Let's do that for the sake of example
CREATE VIEW PopulationInfectionRate AS
SELECT location, MAX(total_cases) AS max_total_cases, population, MAX(total_cases)/population*100 AS Infection_rate
FROM Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX(total_cases) IS NOT NULL -- filter out countries without data


-- Death percent per day
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
	COALESCE(SUM(new_deaths) * 1.0 / NULLIF(SUM(new_cases),0)*100, 0) AS Death_percentage -- NULLIF takes care of devision by zero error and COALESCE turns NULL into 0
FROM Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- Total population vs Vaccination
WITH ContinentsVac (continent, location, date, population, new_vaccitations, cumulative_vaccination)
AS (
	SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
		SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumulative_vaccination
	FROM Covid19..CovidDeaths AS dea
	JOIN Covid19..CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)

SELECT *, (cumulative_vaccination / population)*100 AS percent_vaccinated
FROM ContinentsVac
ORDER BY 2, 3

