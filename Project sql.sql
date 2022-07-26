SELECT *
FROM Project..CovidDeaths
ORDER BY 3,4	

--SELECT *
--FROM Project..CovidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Project..CovidDeaths
Order by 1,2

--Looking at Total Cases and Total Deaths
--Shows likelihood of dying if you contract covid  in your country

SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
FROM Project..CovidDeaths
WHERE location = 'Kazakhstan'
Order by 1,2

--Looking at total Cases vs Population
--Shows what percentage of population got Covid

SELECT location,date,population,total_cases,(total_cases/population)*100 as popvs 
FROM Project..CovidDeaths
--WHERE location = 'Kazakhstan'
Order by 1,2

 --Looking at countries with Infection Rate compared to Population

 SELECT location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM Project..CovidDeaths
--WHERE location = 'Kazakhstan'
GROUP BY Location,Population
Order by  PercentPopulationInfected desc

--Showing Countries with highest Death Count per Population

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Project..CovidDeaths
--WHERE location = 'Kazakhstan'
WHERE continent is not null
GROUP BY Location
Order by  TotalDeathsCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Project..CovidDeaths
--WHERE location = 'Kazakhstan'
WHERE continent is not null
GROUP BY continent
Order by  TotalDeathsCount desc



-- GLOBAL NUMBERS  

SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM Project..CovidDeaths
--WHERE location = 'Kazakhstan'
WHERE continent is not null
--GROUP BY date
Order by 1,2

--Looking st Total Population vs Vacccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccinations vac 
    ON dea.location= vac.location 
    and dea.date= vac.date
WHERE dea.continent is not null
order by 2,3 


-- USE CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccinations vac 
    ON dea.location= vac.location 
    and dea.date= vac.date
WHERE dea.continent is not null
--order by 2,3 
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccinations vac 
    ON dea.location= vac.location 
    and dea.date= vac.date
--WHERE dea.continent is not null
--order by 2,3 

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccinations vac 
    ON dea.location= vac.location 
    and dea.date= vac.date
WHERE dea.continent is not null
--order by 2,3 
)
DROP View PercentPopulationVaccinated

SELECT *
FROM PercentPopulationVaccinated