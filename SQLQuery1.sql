Select*
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, total_deaths, new_cases, population
From PortfolioProject..CovidDeaths
order by 3,4

--Looking at Total Cases VS Total Deaths
--Probability of death if you contract Covid in India

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like 'India'
order by 3,4

--Looking at Total Cases VS Population

Select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
where location like 'India'
order by 1,2

--Countries with highest infection rates compared to population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected Desc

--showing countries with Highest Death count per Population

Select location, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--showing Continents with Highest Death count per Population

Select continent, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers date wise

Select date, Sum(new_cases) as totalnewcases, Sum(new_deaths) as totalnewdeaths, (Sum(new_deaths)/nullif(Sum(new_cases),0))*100 as TotalDeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
having (Sum(new_deaths)/nullif(Sum(new_cases),0))*100 is not null
order by 1,2 

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as 'Cumulative Count of Vaccinations'
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
  on dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not NULL
  Order by 2,3

  --Percentage of Population vaccinated
  --Using CTE
 

  With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccincated)
  as 
  (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccincated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
  on dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not NULL
  --Order by 2,3
  )
  Select* , (RollingPeopleVaccincated/population *100) as PercentPopulationVaccinated
  from PopvsVac


-- Using TEMP tables

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
  on dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not NULL
  --Order by 2,3

    Select* , (RollingPeopleVaccinated/population *100) as PercentPopulationVaccinated
  from #PercentPopulationVaccinated


  --Creating view for visualisations

 Create View PercentPopulationVaccinated as
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
  on dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not NULL
  --Order by 2,3

  