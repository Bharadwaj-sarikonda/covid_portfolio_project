  -- total deaths vs total cases
select LOCATION,DATE_,TOTAL_CASES, TOTAL_DEATHS, (TOTAL_DEATHS/TOTAL_CASES)*100 AS DEATH_PERCENTAGE from coviddeaths
WHERE LOCATION LIKE '%Australia%'
ORDER BY 1,2 ;

-- total cases vs population
select location, date_,population, total_cases, (total_cases/population)*100 as affected_population
from coviddeaths

--WHERE LOCATION LIKE '%Australia%'
where (total_cases/population)*100 is NOT NULL
order by affected_population desc;

--looking at courntries highest infection rate compared to population
select location, population, max(total_cases) as highest_total, max((total_Cases/population))*100 as max_affected_population
from coviddeaths 
group by location , population
order by max_affected_population  desc  ;

--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count 
from coviddeaths
where continent is not null 
group by location
order by total_death_count desc ;

--showing Continent with highest death count per population 

select continent, max(cast(total_deaths as int)) as total_death_count 
from coviddeaths
where continent is not null 
group by continent
order by total_death_count desc ;

--global numbers

select date_, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death , (sum(total_deaths)/sum(new_cases))*100 as death_percentage
from coviddeaths
where continent is not null
group by date_
order by 1,2 

--using CTE

with popvsvac (continent,location,date_,population,new_vaccinations,rolling_people_vaccinated)
as
(
    select dea.continent, dea.location,dea.date_,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date_) as rolling_people_vaccinated
    from coviddeaths  dea 
    join covidvaccinations vac
       on dea.location = vac.location
       and dea.date_ = vac.date_ 
    where dea.continent is not null
--order by  2,3;
)
select continent,location,date_,population,new_vaccinations,rolling_people_vaccinated ,(rolling_people_vaccinated/population)*100 as count_
from popvsvac;

--creating view to store data for later visualization

CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date_, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_) AS rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date_ = vac.date_
WHERE dea.continent IS NOT NULL;

select *
from percent_population_vaccinated


