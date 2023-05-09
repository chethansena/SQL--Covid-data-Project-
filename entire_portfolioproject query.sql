select * 
from portfolioproject..CovidDeaths$
where continent is not null 
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeaths$
order by 1,2;

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country


select location, date, total_cases, total_deaths,(total_deaths/total_cases) *100 As DeathPercentage
from portfolioproject..CovidDeaths$
where location like '%india%'
order by 1,2 

-- looking at total cases vs population
--shows what percentage of p
select  location, date, population, total_cases,(total_cases/population) *100 As casePercentage
from portfolioproject..CovidDeaths$
where location like '%india%'
order by 1,2 

---- finding highest infection rate compared to population 
select  location, population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population) )*100 As PopulationInfected
from portfolioproject..CovidDeaths$
--where location like '%india%'
GROUP BY location, population
order by PopulationInfected desc


-- LETS BREAK THIS DOWN BY CONTINENT 
select  location,MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths$
--where location like '%india%'
where continent is not null 
GROUP BY location
order by TotalDeathCount desc


-- showing countries with highest deathcount per population

select  continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths$
--where location like '%india%'
where continent is  not null 
GROUP BY continent
order by TotalDeathCount desc

----showing the continent with highest death count per population
select continent, MAX (cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


----- global numbers 
create view  global_numbers as
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as 
DeathPercentage
from portfolioproject..CovidDeaths$
where continent is not null
--group by date
--order by 1,2

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as 
DeathPercentage
from portfolioproject..CovidDeaths$
where continent is not null
group by date
order by 1,2


-- looking at total population vs vaccinations 

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as rolling_ppl_vac

from portfolioproject..CovidDeaths$ dea
join portfolioproject..Covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null
order by 2,3


-- use cte
WITH PopvsVac(continent, location, date, population, New_vaccinations, rolling_ppl_vac)
as
(
	select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as rolling_ppl_vac

	from portfolioproject..CovidDeaths$ dea
	join portfolioproject..Covidvaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date

	where dea.continent is not null
--order by 2,3
)
select *,(rolling_ppl_vac/population)*100
from PopvsVac


--temp table
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
rolling_ppl_vac numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as rolling_ppl_vac

from portfolioproject..CovidDeaths$ dea
join portfolioproject..Covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null
--order by 2,3


select *,(rolling_ppl_vac/population)*100
from #PercentPopulationVaccinated




--creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as rolling_ppl_vac

from portfolioproject..CovidDeaths$ dea
join portfolioproject..Covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null
--order by 2,3
