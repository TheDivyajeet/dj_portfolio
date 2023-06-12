 /*                          Exploratory Data Analysis Of Suicide Dataset(1985-2016) 

In this project we will do analysis on the data which contains the records of number of suicides that have taken place
in each country from year 1985-2016. 

*/







---------- 1. First of all we will analyse the columns that are present in the suicide table.

EXEC sp_help  suicide








-----------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 2. Mention the total number of nations whose data is present in this table.

SELECT COUNT(DISTINCT country) AS total_countries
FROM suicide


SELECT DISTINCT country 
FROM suicide








------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 3..What are the total number of suicides commited from year 1985-2016? 
----------    How many males are there and how many females?

SELECT SUM(suicides_no) AS total_suicides
FROM suicide 


SELECT SUM(suicides_no) AS male_suicides
FROM suicide
WHERE sex = 'male'

SELECT SUM(suicides_no) AS female_suicides
FROM suicide
WHERE sex = 'female'








-----------------------------------------------------------------------------------------------------------------------------------


---------- 4.List the top 10 countries with the highest number of suicides.

WITH t1 AS 
( 
SELECT country,SUM(suicides_no) AS total_suicides
FROM suicide
GROUP BY country 
),

t2 AS 
(
SELECT country, total_suicides, RANK() OVER (ORDER BY total_suicides DESC ) AS rnk
FROM t1
)

SELECT country,total_suicides
FROM t2
WHERE rnk <=10








-----------------------------------------------------------------------------------------------------------------------------------


---------- 5.Which age group committed the most number of suicides?

SELECT age,SUM(suicides_no) AS total_suicides
FROM suicide
GROUP BY age
ORDER BY total_suicides DESC








-----------------------------------------------------------------------------------------------------------------------------------


---------- 6.Which generation committed the most number of suicides?

SELECT generation,SUM(suicides_no) AS total_suicides
FROM suicide
GROUP BY generation
ORDER BY total_suicides DESC








------------------------------------------------------------------------------------------------------------------------------------


---------- 7.Which year saw the highest and lowest number of suicides?

WITH t1 AS 
(
SELECT year,SUM(suicides_no) AS total_suicides
FROM suicide
GROUP BY year
)

SELECT TOP 1 FIRST_VALUE(CONCAT(year,' = ',total_suicides)) OVER (ORDER BY total_suicides) AS lowest_year,
       FIRST_VALUE(CONCAT(year,' = ',total_suicides)) OVER (ORDER BY total_suicides DESC) AS highest_year
FROM t1








-------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 8.What was the GDP per capita of the countries with the highest suicides?

SELECT TOP 10  country,ROUND(AVG([gdp_per_capita ($)]),2) AS avg_gdp
FROM suicide
GROUP BY country
ORDER BY SUM(suicides_no) DESC








----------------------------------------------------------------------------------------------------------------------------------------------------


---------- 9.Which countries has the highest suicide rate?

SELECT TOP 10 country,SUM(suicides_no) /SUM(population/100000) AS suicide_rate
FROM suicide
GROUP BY country
ORDER BY SUM(suicides_no) /SUM(population/100000) DESC








------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 10.List the top 3 countries with the highest suicides for each year.

WITH t1 AS 
(
SELECT year,country,SUM(suicides_no) AS total_suicides
FROM suicide
GROUP BY year,country

),

t2 AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY year
                                 ORDER BY total_suicides DESC) rn
    FROM t1
)

SELECT
    year,
    MAX(CASE WHEN rn = 1 THEN country END) + ' - ' +
    CAST(MAX(CASE WHEN rn = 1
                  THEN total_suicides END) AS varchar(10)) AS First,
    MAX(CASE WHEN rn = 2 THEN country END) + ' - ' +
    CAST(MAX(CASE WHEN rn = 2
                  THEN total_suicides END) AS varchar(10)) AS Second,
    MAX(CASE WHEN rn = 3 THEN country END) + ' - ' +
    CAST(MAX(CASE WHEN rn = 3
                  THEN total_suicides END) AS varchar(10)) AS Third
FROM t2
GROUP BY year
ORDER BY year;








----------------------------------------------------------------------------------------------------------------------------------------------------


---------- 11. List the top 3 countries with the highest suicide rate for each year.

WITH t1 AS 
(
SELECT year,country,SUM(suicides_no) /SUM(population/100000) AS suicide_rate
FROM suicide
GROUP BY year,country

),

t2 AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY year
                                 ORDER BY suicide_rate DESC) rn
    FROM t1
)

SELECT
    year,
    MAX(CASE WHEN rn = 1 THEN country END) + ' - ' +
    CAST(MAX(CASE WHEN rn = 1
                  THEN suicide_rate END) AS varchar(10)) AS First,
    MAX(CASE WHEN rn = 2 THEN country END) + ' - ' +
    CAST(MAX(CASE WHEN rn = 2
                  THEN suicide_rate END) AS varchar(10)) AS Second,
    MAX(CASE WHEN rn = 3 THEN country END) + ' - ' +
    CAST(MAX(CASE WHEN rn = 3
                  THEN suicide_rate END) AS varchar(10)) AS Third
FROM t2
GROUP BY year
ORDER BY year;








---------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 12. List the countries with the lowest suicide rate.

SELECT TOP 10 country,SUM(suicides_no) /SUM(population/100000) AS suicide_rate
FROM suicide
GROUP BY country
ORDER BY SUM(suicides_no) /SUM(population/100000) 








------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 13. What is the male to female suicide ratio?

WITH t1 AS
(
SELECT sex,SUM(suicides_no) AS male_suicides
FROM suicide
WHERE sex = 'male'
GROUP BY sex
),

t2 AS
(
SELECT sex,SUM(suicides_no) AS female_suicides
FROM suicide
WHERE sex = 'female'
GROUP BY sex
)

SELECT male_suicides/female_suicides AS ratio
FROM t1,t2








-------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 14. In which countries are old people committing the most suicides?

SELECT TOP 10 country,age,SUM(suicides_no) AS total_suicides
FROM suicide
WHERE age = '55-74 years' OR age = '75+ years'
GROUP BY country,age
ORDER BY SUM(suicides_no) DESC








---------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 15. In which countries are the young people committing the most suicides?

SELECT TOP 10 country,age,SUM(suicides_no) AS total_suicides
FROM suicide
WHERE age = '15-24 years' OR age = '25-34 years'
GROUP BY country,age
ORDER BY SUM(suicides_no) DESC








