select * from dbo.CovidDeaths order by 3,4 

select * from dbo.CovidVaccinations order by 3,4 

select Location, date, total_cases, new_cases, total_deaths, population from PersonalProject..CovidDeaths order by 1,2

--checking for death percentage using total cases and total death

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from PersonalProject..CovidDeaths order by 1,2

--trying to sort deathpercentage in USA alone

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from PersonalProject..CovidDeaths where location like '%states%' order by 1,2

--relating data to total cases against the ppopulation in percentage.

select Location, date, total_cases, population, (total_cases/population)*100 as casesPopulationPercent 
from PersonalProject..CovidDeaths 
--where location like '%states%' 
order by 1,2

-- working on data for countried with highest infection rate compare to population

select location, population, MAX(total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as percentageoOfPopulationInfected
from PersonalProject..CovidDeaths
Group by Location, Population
Order by percentageoOfPopulationInfected desc

-- instead of highest infection, trying out countries with highest death rate per population

select Location, MAX(cast(total_deaths as int))as TotalDeathNumber 
from PersonalProject..CovidDeaths
where continent is not null
Group by Location
Order by TotalDeathNumber desc

--Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PersonalProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

select covdea.continent, covdea.location, covdea.date, covdea.population, covac.new_vaccinations,
SUM(CONVERT(int, covac.new_vaccinations)) 
OVER (Partition by covdea.Location Order by covdea.location, covdea.date)
as AddedVaccinatedPeople
from PersonalProject..CovidDeaths covdea 
join PersonalProject..CovidVaccinations covac
	on covdea.location = covac.location
	and covdea.date = covac.date
where covdea.continent is not null
order by 2,3

--Using CTE to actualize the calculation for the addedvaccinatedpeople

With PopOverVac (Continent, Location, Date, Population, New_Vaccinations, AddedVaccinatedPeople) as
(
select covdea.continent, covdea.location, covdea.date, covdea.population, covac.new_vaccinations,
SUM(CONVERT(int, covac.new_vaccinations)) 
OVER (Partition by covdea.Location Order by covdea.location, covdea.date)
as AddedVaccinatedPeople
from PersonalProject..CovidDeaths covdea 
join PersonalProject..CovidVaccinations covac
	on covdea.location = covac.location
	and covdea.date = covac.date
where covdea.continent is not null
--order by 2,3
)
Select *, (AddedVaccinatedPeople/Population) * 100 as PercentVaccinated
from PopOverVac

--Solving the above using new table method

Drop Table if exists #percentPopulationVacccinated

Create Table #percentPopulationVacccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
AddedVaccinatedPeople numeric)

Insert into #percentPopulationVacccinated
select covdea.continent, covdea.location, covdea.date, covdea.population, covac.new_vaccinations,
SUM(CONVERT(int, covac.new_vaccinations)) 
OVER (Partition by covdea.Location Order by covdea.location, covdea.Date)
as AddedVaccinatedPeople
from PersonalProject..CovidDeaths covdea 
join PersonalProject..CovidVaccinations covac
	on covdea.location = covac.location
	and covdea.date = covac.date
--where covdea.continent is not null
--order by 2,3

Select *, (AddedVaccinatedPeople/Population) * 100 as PercentVaccinated
from #percentPopulationVacccinated

--Creating view for visualization from the above


Create View PercentPopulationVacccinated as 
select covdea.continent, covdea.location, covdea.date, covdea.population, covac.new_vaccinations,
SUM(CONVERT(int, covac.new_vaccinations)) 
OVER (Partition by covdea.Location Order by covdea.location, covdea.Date)
as AddedVaccinatedPeople
from PersonalProject..CovidDeaths covdea 
join PersonalProject..CovidVaccinations covac
	on covdea.location = covac.location
	and covdea.date = covac.date
where covdea.continent is not null
--order by 2,3
