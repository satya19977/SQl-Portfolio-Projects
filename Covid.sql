select * from PortfolioProject..CovidDeaths
order by 3,4


select  location, date, new_cases, total_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 3,4

-- Death Percentage

select  location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Total case vs Population

select  location, date, total_cases, total_deaths,population, (total_cases/population) * 100 as  percent_population
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- highest percentage of cases per population

select  location, date, max(total_cases), total_deaths,population, max((total_cases/population)) * 100 as  percent_population
from PortfolioProject..CovidDeaths
group by location, date, total_cases, total_deaths,population
order by percent_population desc


-- highest percentage of deaths

select  location, date, max(total_cases)as infection, total_deaths,population, max((total_deaths/population)) * 100 as  percent_population_d
from PortfolioProject..CovidDeaths
where continent is not null
group by location, date, total_cases, total_deaths,population
order by percent_population_d desc

-- toal deaths by continent

select  continent , max(cast(total_deaths as int)) as deathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by deathcount desc


-- new cases
select   sum(new_cases) as new_cases , sum(cast(new_deaths  as int)) as new_deaths,   sum(cast(new_deaths  as int)) / sum(new_cases) * 100 as deathpercentage 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



--vaccination vs population

with popvsvac (continent,location,date,population,new_vaccinations, rollingcount)
as
(
select cd.date,cd.location,cd.continent,cd.population, cv.new_vaccinations, sum(convert(int,new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as rollingcount --(rollingcount/population) * 100
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent  is not null
--order by 3,2
)
select *,(rollingcount/population) * 100 from popvsvac

-- temp table 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location  nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingcount  numeric
)

insert into #PercentPopulationVaccinated
select cd.date,cd.location,cd.continent,cd.population, cv.new_vaccinations, sum(convert(int,new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as rollingcount --(rollingcount/population) * 100
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
--where cd.continent  is not null
--order by 3,2

select *,(rollingcount/population) * 100 from #PercentPopulationVaccinated

-- Views
create view PercentPopulationVaccinated as 
select cd.date,cd.location,cd.continent,cd.population, cv.new_vaccinations, sum(convert(int,new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as rollingcount --(rollingcount/population) * 100
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent  is not null
--order by 3,2
