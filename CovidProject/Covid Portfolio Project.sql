--- show the data we will use 

select location , date ,total_cases ,new_cases , total_deaths ,population 
from CovidDeaths
where continent is not null
order by 1,2


-- looking at percentage of deaths (total cases vs total deaths )
select location , date ,total_cases  , total_deaths , convert(varchar , ROUND( (total_deaths / total_cases) * 100  , 2) )+ ' %' as DeathsPercentage 
from CovidDeaths
where location = 'Egypt' and 
continent is not null
order by 1,2




-- show what percentage of population got covid 
select location , date , population , total_cases  , convert(varchar , ROUND( (total_cases / population) * 100  , 2) )+ ' %' as PopulationPercentage 
from CovidDeaths
--where location = 'Egypt'
where continent is not null
order by 1,2



-- what countries with heighest infection rate compared to population 
select location ,  population , max(total_cases) as heighest_Infection_Count  , 
ROUND( max((total_cases / population) * 100 ) , 2)  as Population_infected_percentage ,
RANK() OVER(ORDER BY ROUND( max((total_cases / population) * 100 ) , 2) DESC) rank
from CovidDeaths
where continent is not null
group by location , population
order by Population_infected_percentage desc



-- brak them by continent
-- looking at heighest death count per population 
select continent , MAX(cast(total_deaths as int))  total_Death_Count
from CovidDeaths
where continent is not null
group by continent
order by total_Death_Count desc 



-- global numbers  (total cases over world vs total deaths over world and their percentage )
select  SUM(new_cases) total_World_cases_ , SUM(cast(new_deaths as int ))  total_World_deaths, 
ROUND(( SUM(cast(new_deaths as int )) / SUM(new_cases) ) *100 , 2) WorldDeathPercentage
from CovidDeaths
where continent is not null 
order by 1,2 


 


-- looking at total population vs vaccinations
select cd.continent ,  cd.location , cd.date , cd.population , cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as int )) over (partition by cd.location order by cd.location , cd.date) as RollingVaccinated
from CovidVaccinations cv
join CovidDeaths cd 
	on cv.location = cd.location
	and cv.date = cd.date
where cd.continent is not null 
order by 2,3
 


-- with cte 
with PopVsVac (continent , location , date , population , new_vaccinations , RollingVaccinated)
as 
(
	select cd.continent ,  cd.location , cd.date , cd.population , cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations as int )) over (partition by cd.location order by cd.location , cd.date) as RollingVaccinated
	from CovidVaccinations cv
	join CovidDeaths cd 
	on cv.location = cd.location
	and cv.date = cd.date
	where cd.continent is not null 
)
-- percentage of vaccinated peopel 
select *  , (RollingVaccinated / population) * 100
from PopVsVac






-- with temp table 
drop table if exists #PopVsVac
create Table #PopVsVac 
(
continent nvarchar(255),
location nvarchar(255),
date datetime ,
population numeric ,
new_vaccinations numeric ,
RollingVaccinated numeric 
)

insert into #PopVsVac 
select cd.continent ,  cd.location , cd.date , cd.population , cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations as int )) over (partition by cd.location order by cd.location , cd.date) as RollingVaccinated
	from CovidVaccinations cv
	join CovidDeaths cd 
	on cv.location = cd.location
	and cv.date = cd.date
where cd.continent is not null 

-- percentage of vaccinated peopel 
select *  , (RollingVaccinated / population) * 100
from #PopVsVac



-- creating view to store data for visualization later
create view percentPopulationVaccinated as 
select cd.continent ,  cd.location , cd.date , cd.population , cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations as int )) over (partition by cd.location order by cd.location , cd.date) as RollingVaccinated
	from CovidVaccinations cv
	join CovidDeaths cd 
	on cv.location = cd.location
	and cv.date = cd.date
where cd.continent is not null 
