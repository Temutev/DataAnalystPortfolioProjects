select * from `DA.CovidDeaths`order by 3,4;

--select the data that we are going to be using
select Location,date,total_cases,new_cases,total_deaths,population from  `DA.CovidDeaths` order by 1,2;



--- Looking at the total cases vs total deaths 
-- shows likelihood of dying if you contract covid
select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from  `DA.CovidDeaths`
 where location like '%Kenya%'
 order by 1,2;


 -- looking at the total cases vs population
 -- shows what percentage of population got covid
select Location,date,total_cases,population, (total_deaths/population)*100 as DeathPercentage
 from  `DA.CovidDeaths`
 where location like '%Kenya%'
 order by 1,2;



--looking at countries with highest infection rate compared to population

select Location,population,MAX(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as PercentPopulationInfected
from  `DA.CovidDeaths`
group by Location,population
order by  PercentPopulationInfected desc;



 -- showing  countries with the highest death count per population
select Location,MAX(cast (total_deaths as int)) as TotalDeathCount
from  `DA.CovidDeaths`
where continent is not null
group by Location
order by  TotalDeathCount desc;


-- LET'S BREAK THINGS DOWN BY CONTINENT
select Location,MAX(cast (total_deaths as int)) as TotalDeathCount
from  `DA.CovidDeaths`
where continent is null
group by Location
order by  TotalDeathCount desc;


--- showing continents with the highest death count per population
select continent,MAX(cast (total_deaths as int)) as TotalDeathCount
from  `DA.CovidDeaths`
where continent is not  null
group by continent
order by  TotalDeathCount desc;




--GLOBAL NUMBERS

select date, sum(new_cases) as total_cases ,sum( cast (new_deaths as int)) as total_deaths, sum(new_deaths)/sum(cast(new_cases as int))*100 as DeathPercentage
 from  `DA.CovidDeaths`
 --where location like '%Kenya%'
 where continent is not null
 group by date
 order by 1,2;



-- Looking at total population vs vaccination
select * from `DA.CovidVaccinations` dea
join `DA.CovidDeaths` vac 
on dea.location = vac.location 
and dea.date = vac.date;



select
dea.continent,dea.location,
dea.date,vac.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
,
from `DA.CovidVaccinations` dea
join `DA.CovidDeaths` vac 
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3;




--USE CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From `DA.CovidDeaths` dea
Join `DA.CovidVaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
