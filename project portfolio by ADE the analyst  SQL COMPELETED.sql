select * 
from [dbo].[Covid deaths]
where continent is not null
order by 3,4

-- select * 
-- from [dbo].[Covid Vaccination ]
-- order by 3,4

--Select data that we are going to be using 

select location, date,total_cases,new_cases,total_deaths,population
from [dbo].[Covid deaths]
where continent is not null
order by 1,2


-- looking at total cases vs total deaths 
-- shows liklihood of dying if you contract covid in your country

select [location],[date],[total_cases],[total_deaths],
(convert(float,total_deaths)/ nullif(convert(float,total_cases),0)) * 100 AS Deathpercentage
from [dbo].[Covid deaths]
where location like '%states%'
and continent is not null
order by 1,2


--looking at the total cases vs population 
-- shows what percentage of population has gotten covid 


select [continent],[date],total_cases,population,(total_cases/population )* 100 AS percentofpoupulationinfected 
from [dbo].[Covid deaths]
where continent is not null
and location like '%states%'
order by 1,2


-- looking at countries with highest infection rate compared to population

select  *
from[Portfolio project ]..[Covid deaths]

select [continent],population, MAX(total_cases) AS Higestinfectioncount, MAX((total_cases/population )) * 100 AS percentofpoupulationinfected
from [Portfolio project ]..[Covid deaths]
-- where location like '%states%'
where continent is not null
GROUP BY [continent],population
order by percentofpoupulationinfected DESC


--Showing countries with highest death count per population 


select [continent], MAX(CAST(TOTAL_DEATHS AS INT)) AS totaldeathcount
from [Portfolio project ]..[Covid deaths]
-- where location like '%states%'
where continent is not null
GROUP BY [continent]
order by totaldeathcount DESC


---LET'S BREAK THINGS DOWN BY CONTINENT 




-- Showing the continent with the highest deathcount 
select [continent], MAX(CAST(TOTAL_DEATHS AS INT)) AS totaldeathcount
from [Portfolio project ]..[Covid deaths]
-- where location like '%states%'
where continent is not null
GROUP BY [continent]
order by totaldeathcount DESC


--  Global Numbers 
select [date],sum([new_cases]),sum(cast(new_deaths as int)--[total_cases],[total_deaths],(total_deaths/total_cases)* 100 AS Deathpercentage
from [dbo].[Covid deaths]
--where location like '%states%'
Where [continent] is not null
Group by date
order by 1,2



--  Global Numbers 
select SUM([new_cases]) as Total_cases,SUM(cast(new_deaths as int))as Total_deaths, SUM(cast(new_deaths as int)) / SUM(New_cases)*100 AS Deathpercentage
from [Portfolio project ]..[Covid deaths]
--where location like '%states%'
Where [continent] is not null
--Group by date
order by 1,2


--Using covid Vaccination table

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, [new_vaccinations],
SUM(convert(int,[new_vaccinations])) OVER(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
,---(rollingpeoplevaccinated/population)*100 (you cant use a column that you just created to then use in the next one. we need to create a CTE or  TEMP table)
from [Portfolio project ]..[Covid Vaccination ] dea
join[Portfolio project ]..[Covid deaths] vac
     on dea.location =vac.location
	 and dea.date = vac. date
where dea.continent is not null
order by 2,3

-- USING CTE

with popvsvac (continent,location,date,population,[new_vaccinations], rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, [new_vaccinations],
SUM(convert(int,[new_vaccinations])) OVER(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio project ]..[Covid Vaccination ] dea
join[Portfolio project ]..[Covid deaths] vac
     on dea.location =vac.location
	 and dea.date = vac. date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac


---TEMP table
DROp table if exists #percentpopulationvacinated
create table #percentpopulationvacinated

(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

INSERT INTO #percentpopulationvacinated
select dea.continent, dea.location, dea.date, dea.population, [new_vaccinations],
SUM(convert(int,[new_vaccinations])) OVER(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio project ]..[Covid Vaccination ] dea
join[Portfolio project ]..[Covid deaths] vac
     on dea.location =vac.location
	 and dea.date = vac. date
--where dea.continent is not null
--order by 2,3
 
select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvacinated



--Creating vew to store data for later visualization 

Create view percentpopulationvacinated as
select dea.continent, dea.location, dea.date, dea.population, [new_vaccinations],
SUM(convert(int,[new_vaccinations])) OVER(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio project ]..[Covid Vaccination ] dea
join[Portfolio project ]..[Covid deaths] vac
     on dea.location =vac.location
	 and dea.date = vac. date
where dea.continent is not null
--order by 2,3


select *
from percentpopulationvacinated