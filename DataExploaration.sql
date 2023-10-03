Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using 

--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths,
	CONVERT(decimal(15,3), total_deaths) AS deaths,
	CONVERT(decimal(15,3), total_cases) AS cases,
	CONVERT(decimal(15,3), CONVERT(decimal(15,3), total_deaths) / CONVERT (decimal(15,3), total_cases))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Kosovo%'
order by 1,2

--Looking at Total Cases vs Population

Select Location, date, total_cases, Population, (total_cases/population)*100 AS InfectionPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Kosovo%'
order by 1,2

-- Looking at Countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 AS HighestInfectedStates
From PortfolioProject..CovidDeaths
--Where location like '%Kosovo%'
Group by Location, Population
order by HighestInfectedStates desc

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 AS HighestInfectedStates
From PortfolioProject..CovidDeaths
--Where location like '%Kosovo%'
Group by Location, Population, date
order by HighestInfectedStates desc

--Showing Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Kosovo%'
Where continent is not null
Group by Location, Population
order by TotalDeathCount desc

-- Break by continent


-- Show continents with most deaths

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Kosovo%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Stats
SET ANSI_WARNINGS OFF;
GO
Select date, SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group By date
order by 1,2
 

Select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group By date
order by 1,2

--Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location , dea.Date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location , dea.Date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (PeopleVaccinated/Population)*100
From PopvsVac
Where location like '%States%'
order by PeopleVaccinated desc


-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location , dea.Date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location , dea.Date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income' )
Group by location
order by TotalDeathCount desc
