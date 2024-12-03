select *
from Covid..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from Covid..CovidVaccinations$
--order by 3,4


select location,date, total_cases,new_cases,total_deaths,population
from Covid..CovidDeaths$
order by 1,2

--total cases vs total deaths
select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid..CovidDeaths$
where location like '%states%'
order by 1,2

-- total cases vs population
select location,date, total_cases,population, (total_cases/ population)*100 as DeathPercentage
from Covid..CovidDeaths$
--where location like '%india%'
order by 1,2


--looking at countries with highest infection
select location,MAX( total_cases) as highestInfectionCount, population, MAX((total_cases/ population)*100) as PercentageOFpopulationinfected
from Covid..CovidDeaths$
--where location like '%india%'
group by population, location
order by PercentageOFpopulationinfected desc

--countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeath_counts
from Covid..CovidDeaths$
--where location like '%india%'
where continent is not null
group by location
order by TotalDeath_counts desc

--by continent
select continent, MAX(cast(total_deaths as int)) as TotalDeath_counts
from Covid..CovidDeaths$
--where location like '%india%'
where continent is null
group by continent
order by TotalDeath_counts desc

--by location again
select location, MAX(cast(total_deaths as int)) as TotalDeath_counts
from Covid..CovidDeaths$
--where location like '%india%'
where continent is null
group by location
order by TotalDeath_counts desc


--continents with highest deathcount
select continent, MAX(cast(total_deaths as int)) as TotalDeath_counts
from Covid..CovidDeaths$
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeath_counts desc

--global numbers

select sum(new_cases) as total_cases , sum(CAST(new_deaths as int)) as total_deaths, sum(CAST(new_deaths as int ))/ sum(new_cases)*100 as DeathPercentage
from Covid..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

select* 
from Covid..CovidDeaths$ dea
join Covid..CovidVaccinations$ vac
    on dea.location = dea.location 
    and dea.date=vac.date

	--population vs vaccination
select dea.continent,dea.location,dea.date,dea.population, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location)
from Covid..CovidDeaths$ dea
join Covid..CovidVaccinations$ vac
    on dea.location = dea.location 
    and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Using  CTE's
with PopvsVac (continent, location, date, population, new_vaccinations,rollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location,dea.date) as rollingPeopleVaccinated
from Covid..CovidDeaths$ dea
Join Covid..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *, (rollingPeopleVaccinated/Population)*100
from PopvsVac

--With Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location,dea.date) as rollingPeopleVaccinated
from Covid..CovidDeaths$ dea
Join Covid..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date

Select *, (rollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location,dea.date) as rollingPeopleVaccinated
from Covid..CovidDeaths$ dea
Join Covid..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select * 
from PercentPopulationVaccinated