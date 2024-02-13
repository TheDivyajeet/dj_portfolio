/*                                Famous Paintings Analysis Using SQL

The dataset we use is the famous paintings dataset taken from Kaggle.
In this Dataset we have data of famous paintings and their artists from all around the world.
We will use SQL queries to answer problems related to the famous paintings dataset. 

*/








-- 1. Fetch all the paintings which are not displayed in any museum.

SELECT *
FROM work
WHERE museum_id IS NULL










-- 2. Are there any museums without any paintings?

SELECT *
FROM museum 
WHERE museum_id NOT IN (SELECT DISTINCT museum_id FROM WORK WHERE museum_id IS NOT NULL)










-- 3. How many paintings have an asking price of more than their regular price? 

SELECT *
FROM product_size
WHERE sale_price>regular_price










-- 4. Identify the paintings whose asking price is less than 50% of its regular price.

SELECT *
FROM product_size
WHERE sale_price< (regular_price)*1/2










-- 5.Which canva size costs the most?

SELECT label, sale_price
FROM
(SELECT ca.label, pr.sale_price, RANK() OVER (ORDER BY pr.sale_price DESC) AS RNK
FROM canvas_size ca
JOIN product_size pr
ON ca.size_id = pr.size_id) x
WHERE x.RNK = 1










-- 6. Delete duplicate records from work, product_size, subject and image_link tables.

-- In order to delete the duplicate records. 

WITH t1 AS 
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY work_id ORDER BY work_id) AS RowNumber 
FROM image_link
)

DELETE 
FROM t1
WHERE RowNumber >1










-- 7. Fetch the top 10 most famous painting subject.

SELECT subject, Total_Paintings
FROM
(SELECT subject, COUNT(work_id) AS Total_Paintings, RANK() OVER (ORDER BY COUNT(work_id) DESC) AS RNK
FROM subject
GROUP BY subject) x
WHERE x.RNK <=10










-- 8. Identify the museums which are open on both Sunday and Monday. Display museum name, city.

WITH t1 AS 
(
SELECT museum_id,COUNT(day) AS TotalDays
FROM museum_hours
WHERE day IN ('Sunday','Monday')
GROUP BY museum_id
)

SELECT m.name, m.city
FROM t1
JOIN museum m
ON t1.museum_id = m.museum_id
WHERE TotalDays = 2










-- 9. How many museums are open every single day?

WITH t1 AS 
(
SELECT museum_id, COUNT(day) AS TotalDays
FROM museum_hours
GROUP BY museum_id
HAVING COUNT(day) = 7
)

SELECT m.name, m.city
FROM t1
JOIN museum m
ON t1.museum_id = m.museum_id










-- 10. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum).

WITH t1 AS 
(
SELECT museum_id, COUNT(work_id) AS TotalPaintings
FROM work
WHERE museum_id IS NOT NULL
GROUP BY museum_id
)


SELECT TOP 5 m.name, m.city, t1.TotalPaintings
FROM t1
JOIN museum m 
ON t1.museum_id = m.museum_id
ORDER BY TotalPaintings DESC 










-- 11. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist).

WITH t1 AS 
(
SELECT TOP 5 artist_id, COUNT(work_id) AS TotalPaintings
FROM work
GROUP BY artist_id
ORDER BY TotalPaintings DESC
)

SELECT artist.full_name, t1.TotalPaintings
FROM t1
JOIN artist
ON t1.artist_id = artist.artist_id










--12. Display the 3 least popular canvas sizes.

-- ANSWER USING CTE 

WITH t1 AS 
(
SELECT size_id, COUNT(work_id) AS TotalPaintings, DENSE_RANK() OVER (ORDER BY COUNT(work_id) ASC) AS RNK
FROM product_size
GROUP BY size_id
)

SELECT *
FROM t1
WHERE RNK <=3



-- ANSWER USING SUBQUERY 

SELECT label, TotalPaintings, RNK
FROM
(SELECT size_id, COUNT(work_id) AS TotalPaintings, DENSE_RANK() OVER (ORDER BY COUNT(work_id) ASC) AS RNK
FROM product_size
GROUP BY size_id) x
JOIN canvas_size c
ON x.size_id = c.size_id
WHERE x.RNK <=3
ORDER BY RNK ASC










-- 13. Which museum has the most no. of most popular painting style?


WITH t1 AS
(
SELECT *
FROM
(SELECT style, COUNT(*) AS TotalPaintings, RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM work
GROUP BY style) x
WHERE x.rnk = 1
),

t2 AS 
(
SELECT w.name, w.style, w.museum_id
FROM t1
JOIN work w
ON t1.style = w.style
),

t3 AS 
(
SELECT *
FROM 
(SELECT t2.museum_id, COUNT(*) AS TotalPaintings, RANK() OVER (ORDER BY COUNT(*) DESC ) AS RNK
FROM t2
GROUP BY t2.museum_id) y
WHERE y.RNK = 2
)

SELECT name, TotalPaintings
FROM t3
JOIN museum m
ON t3.museum_id = m.museum_id










-- 14. Identify the artists whose paintings are displayed in multiple countries.

WITH t1 AS 
(
SELECT *
FROM
(SELECT w.artist_id, COUNT(DISTINCT country) AS NoOfCountries
FROM work w
JOIN museum m
ON w.museum_id = m.museum_id
GROUP BY w.artist_id) x
WHERE x.NoOfCountries >1
)

SELECT artist.full_name, t1.NoOfCountries
FROM t1
JOIN artist
ON t1.artist_id = artist.artist_id
ORDER BY NoOfCountries DESC










-- 15.  Display the country and the city with most no of museums. 
--      Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.


WITH t1 AS 
(
SELECT city, COUNT(*) AS TotalMuseumsInCity, RANK() OVER (ORDER BY COUNT(*) DESC) AS RNK
FROM museum
GROUP BY city 
),

t2 AS 
(
SELECT country, COUNT(*) AS TotalMuseumsInCountry, RANK() OVER (ORDER BY COUNT(*) DESC) AS RNK
FROM museum
GROUP BY country
)

SELECT string_agg(country,',') AS Country, string_agg(city, ',') AS City
FROM t1,t2
WHERE t1.RNK = 1 AND t2.RNK = 1
















-- 16. Identify the artist and the museum where the most expensive and least expensive painting is placed. 

WITH t1 AS 
(
SELECT work_id, sale_price
FROM
(SELECT *, RANK() OVER (ORDER BY sale_price DESC) AS RNK
FROM product_size) x
WHERE x.RNK = 1

UNION 

SELECT DISTINCT work_id, sale_price
FROM
(SELECT *, RANK() OVER (ORDER BY sale_price) AS RNK
FROM product_size) x
WHERE x.RNK = 1
),

t2 AS 
(
SELECT t1.work_id,t1.sale_price, work.artist_id, work.museum_id
FROM t1
JOIN work 
ON t1.work_id = work.work_id
)


SELECT full_name AS artist_name, sale_price AS painting_price, museum.name AS museum_name
FROM t2
JOIN artist
ON t2.artist_id = artist.artist_id
JOIN museum 
ON t2.museum_id = museum.museum_id










-- 17. Which country has the 5th highest no of paintings?

WITH t1 AS
(
SELECT w.work_id, m.country
FROM work w
JOIN museum m
ON w.museum_id = m.museum_id
)

SELECT *
FROM
(SELECT country, COUNT(work_id) AS TotalPaintings, RANK() OVER (ORDER BY COUNT(work_id) DESC) AS RNK
FROM t1
GROUP BY country) x
WHERE RNK = 5










-- 18. Which are the 3 most popular and 3 least popular painting styles?

WITH CTE AS
(SELECT style, COUNT(1) AS cnt, RANK() OVER(ORDER BY COUNT(1) DESC) rnk, COUNT(1) OVER() AS no_of_records
FROM work
WHERE style IS NOT NULL
GROUP BY style)
SELECT style
,CASE WHEN rnk <=3 THEN 'Most Popular' ELSE 'Least Popular' END AS remarks 
FROM CTE
WHERE rnk <=3 OR rnk > no_of_records - 3










-- 19. Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.

WITH t1 AS 
(
SELECT w.work_id, a.full_name, a.nationality, w.museum_id, m.country
FROM work w
JOIN artist a
ON w.artist_id = a.artist_id
JOIN museum m 
ON w.museum_id = m.museum_id
JOIN subject s
ON w.work_id = s.work_id
WHERE NOT country = 'USA' AND subject = 'Portraits'
)

SELECT full_name, nationality,Total_Paintings
FROM 
(SELECT full_name, nationality, COUNT(work_id) AS Total_Paintings, RANK() OVER (ORDER BY COUNT(work_id) DESC) AS RNK
FROM t1
GROUP BY full_name, nationality) x
WHERE x.RNK = 1






	










































