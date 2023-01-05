Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

--Select The Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

--Looking at Total Cases VS Total Deaths
--Shows the likelihood of dying if you contract Covid in India (or Your Country)

Select Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%india%'
Order By 1, 2

--Looking at the Total Cases VS Population
--Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases / population) * 100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%india%'
Where continent is not null
Order By 1, 2

--Looking at countries with highest infection rate compared to the population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population) * 100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population
Order By PercentPopulationInfected DESC

--Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order By TotalDeathCount DESC


--LETS'S BREAK THINGS DOWN BY CONTINENT
--Showing the continents with highest death counts

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null and location not like '%income%' AND location not like '%International%' AND location not like '%union%' AND location not like '%world%'
Group By location
Order By TotalDeathCount DESC



--Global Numbers

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as bigint)) as TotalDeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%india%'
Where continent is not null
Group By date
Order By 1, 



--Looking at Total Population VS Total Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumulativeVaccinations
	--(CumulativeVaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order By 2, 3


--Using CTE

with PopVsVac (Continent, Location, Date, Population, NewVaccinations, CumulativeVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumulativeVaccinations
	--(CumulativeVaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null --AND dea.location like '%india%'
--Order By 2, 3
)

Select *, (CumulativeVaccinations/Population)*100 as PercentPopulationVaccinated
From PopVsVac
--The percentages go beyond 100% as there were two doses of vaccines and the dataset does not differentiate the vaccine doses


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativeVaccinations numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumulativeVaccinations
	--(CumulativeVaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null --AND dea.location like '%india%'
--Order By 2, 3

Select *, (CumulativeVaccinations/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated


--Creating Views to Store Data for Visualization Later

Create View 
PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumulativeVaccinations
	--(CumulativeVaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null --AND dea.location like '%india%'
--Order By 2, 3


Select *
From PercentPopulationVaccinated