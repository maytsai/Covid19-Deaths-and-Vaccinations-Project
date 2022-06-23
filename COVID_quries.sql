-- Update on the datatype on the date
update CovidDeaths SET date=str_to_date(date,'%m/%d/%Y');
update CovidVaccinations SET date=str_to_date(date,'%m/%d/%Y');

-- Select columns that are useful
Select Location, continent, date, total_cases,total_deaths, population
From CovidDeaths
Order by 3,4;

-- Looking at Total Cases vs Total Deaths
-- Looking at the Death rate based on the country
Select DISTINCT(Location), date, total_cases,total_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where Location Like '%states%'
Order by 1,2;

-- Looking at Total cases vs. Population, see the percentage of the Covid Case
-- Based on United States
Select DISTINCT(Location), date, total_cases,Population ,(total_cases/Population)*100 as CovidPercentage
From CovidDeaths
Where Location Like '%states%'
Order by 1,2 ;


-- Looking at Countries with highest infection rate compare to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentageofInfection
From CovidDeaths
Group by Location, Population
Order by PercentageofInfection desc;

-- Showing Countries with highest Death Count per Population
Select Location, MAX(Total_deaths) as HighestDeathCount 
From CovidDeaths
Where Location NOT IN (select continent from CovidDeaths)
Group by Location
Order by HighestDeathCount DESC;

-- Let's look at CONTINENT 
Select continent, MAX(Total_deaths) as HighestDeathCount
From CovidDeaths
Group by continent;

-- Global Numbers
Select Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, Sum(new_cases)/Sum(new_deaths) as DeathPercentage
From CovidDeaths
order by 1,2;


-- Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.location NOT IN (select continent from CovidDeaths)
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With table1 ( Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.location NOT IN (select continent from CovidDeaths)
-- order by 2,3 
)
Select *, (RollingPeopleVaccinated/population)*100
From table1;


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists PercentPopulationVaccinated ;

Create Table PercentPopulationVaccinated( 
Continent char(255),
Location char(255),
Date datetime,
Population char(255),
New_vaccinations char(255),
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,nchar)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date;


Select *, (RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated;

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated_view as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.location NOT IN (select continent from CovidDeaths);





