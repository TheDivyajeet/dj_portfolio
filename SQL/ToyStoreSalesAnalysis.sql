/*                       Toys Company Sales Analysis Using SQL          

In this project we have data of a fictitious company which have toys stores all around Mexico area.
We will do analysis on this data to gather key insights about the sales of the company.

*/







---------- 1. Total Revenue of the Company ----------

WITH t1 AS 
(
SELECT product_id, SUBSTRING(product_cost, 2,5) AS cost, SUBSTRING(product_price, 2,5) AS price
FROM products
),

t2 AS 
(
SELECT product_id, (CAST(t1.price AS FLOAT) - CAST(t1.cost AS FLOAT)) AS profit_from_product
FROM t1 

),

t3 AS 
(
SELECT t2.product_id, t2.profit_from_product * sales.units AS revenue
FROM t2
JOIN sales
ON t2.product_id = sales.product_id
)

SELECT SUM(revenue) AS total_revenue
FROM t3 








-------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 2. Total Toys Sold ----------

SELECT *
FROM sales

SELECT SUM(CAST(units AS INT)) AS total_toys_sold
FROM sales








---------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 3. Total Stores ----------

SELECT COUNT(store_id) AS total_stores
FROM stores








--------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 4. How many product categories do we have? ----------

SELECT COUNT(DISTINCT product_category) AS product_categories_count
FROM products








--------------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 5. How many different products are we selling? ----------

SELECT COUNT(product_id) AS total_toys
FROM products








----------------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 6. Total Revenue by Year ----------

WITH t1 AS 
(
SELECT product_id, SUBSTRING(product_cost, 2,5) AS cost, SUBSTRING(product_price, 2,5) AS price
FROM products
),

t2 AS 
(
SELECT product_id, (CAST(t1.price AS FLOAT) - CAST(t1.cost AS FLOAT)) AS profit_from_product
FROM t1 

),

t3 AS 
(
SELECT t2.product_id, t2.profit_from_product * sales.units AS revenue, SUBSTRING(sales.date,1,4) AS Year
FROM t2
JOIN sales
ON t2.product_id = sales.product_id
)

SELECT SUM(revenue) AS total_revenue,Year
FROM t3 
GROUP BY Year
ORDER BY Year








---------------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 7. Revenue By Store Locations ----------

WITH t1 AS 
(
SELECT product_id, SUBSTRING(product_cost, 2,5) AS cost, SUBSTRING(product_price, 2,5) AS price
FROM products
),

t2 AS 
(
SELECT product_id, (CAST(t1.price AS FLOAT) - CAST(t1.cost AS FLOAT)) AS profit_from_product
FROM t1 

),

t3 AS 
(
SELECT sales.store_id, t2.product_id, t2.profit_from_product * sales.units AS revenue
FROM t2
JOIN sales
ON t2.product_id = sales.product_id
)


SELECT TOP 5 stores.Store_Location, SUM(revenue) AS total_revenue_from_store
FROM t3
JOIN stores
ON t3.store_id = stores.store_id
GROUP BY stores.Store_Location
ORDER BY total_revenue_from_store DESC








-------------------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 8. Revenue by product category ----------

WITH t1 AS 
(
SELECT product_category, product_id, SUBSTRING(product_cost, 2,5) AS cost, SUBSTRING(product_price, 2,5) AS price
FROM products
),

t2 AS 
(
SELECT product_category, product_id, (CAST(t1.price AS FLOAT) - CAST(t1.cost AS FLOAT)) AS profit_from_product
FROM t1 

),

t3 AS 
(
SELECT t2.Product_Category,t2.product_id, t2.profit_from_product * sales.units AS revenue
FROM t2
JOIN sales
ON t2.product_id = sales.product_id
)

SELECT t3.Product_Category,SUM(revenue) AS total_revenue
FROM t3 
GROUP BY t3.Product_Category
ORDER BY total_revenue DESC








-----------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 9. Most Selling Products (Top 10 Products) ----------

WITH t1 AS 
(
SELECT product_name, product_id, SUBSTRING(product_cost, 2,5) AS cost, SUBSTRING(product_price, 2,5) AS price
FROM products
),

t2 AS 
(
SELECT product_name,product_id, (CAST(t1.price AS FLOAT) - CAST(t1.cost AS FLOAT)) AS profit_from_product
FROM t1 

),


t3 AS
(
SELECT t2.product_name, t2.profit_from_product * sales.units AS revenue
FROM t2
JOIN sales
ON t2.product_id = sales.product_id
)


SELECT TOP 10 t3.product_name, SUM(revenue) AS total_revenue
FROM t3
GROUP BY t3.Product_Name
ORDER BY total_revenue DESC 








--------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 10. Least Selling Products ----------

WITH t1 AS 
(
SELECT product_name, product_id, SUBSTRING(product_cost, 2,5) AS cost, SUBSTRING(product_price, 2,5) AS price
FROM products
),

t2 AS 
(
SELECT product_name,product_id, (CAST(t1.price AS FLOAT) - CAST(t1.cost AS FLOAT)) AS profit_from_product
FROM t1 

),


t3 AS
(
SELECT t2.product_name, t2.profit_from_product * sales.units AS revenue
FROM t2
JOIN sales
ON t2.product_id = sales.product_id
)


SELECT TOP 10 t3.product_name, SUM(revenue) AS total_revenue
FROM t3
GROUP BY t3.Product_Name
ORDER BY total_revenue








----------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 11. Flagship Stores ----------

WITH t1 AS 
(
SELECT product_id, SUBSTRING(product_cost, 2,5) AS cost, SUBSTRING(product_price, 2,5) AS price
FROM products
),

t2 AS 
(
SELECT product_id, (CAST(t1.price AS FLOAT) - CAST(t1.cost AS FLOAT)) AS profit_from_product
FROM t1 

),

t3 AS 
(
SELECT sales.store_id, t2.product_id, t2.profit_from_product * sales.units AS revenue
FROM t2
JOIN sales
ON t2.product_id = sales.product_id
)


SELECT TOP 5 stores.store_name, SUM(revenue) AS total_revenue_from_store
FROM t3
JOIN stores
ON t3.store_id = stores.store_id
GROUP BY stores.store_name
ORDER BY total_revenue_from_store DESC








-----------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 12. How much money is currently tied up in inventory at the toy stores? ----------

WITH t1 AS 
(
SELECT i.store_id, i.product_id, i.stock_on_hand, SUBSTRING(p.product_cost,2,5) AS cost
FROM inventory i
JOIN products p
ON i.Product_ID = p.Product_ID
),

t2 AS 
(
SELECT t1.stock_on_hand * CAST(cost AS FLOAT) AS money
FROM t1
)

SELECT SUM(money) AS money_in_inventory
FROM t2








--------------------------------------------------------------------------------------------------------------------------------------------------------------


---------- 13. Which are the top 3 stores in each location? ----------

WITH t1 AS 
(
SELECT product_id, SUBSTRING(product_cost, 2,5) AS cost, SUBSTRING(product_price, 2,5) AS price
FROM products
),

t2 AS 
(
SELECT product_id, (CAST(t1.price AS FLOAT) - CAST(t1.cost AS FLOAT)) AS profit_from_product
FROM t1 

),

t3 AS 
(
SELECT sales.store_id, t2.product_id, t2.profit_from_product * sales.units AS revenue
FROM t2
JOIN sales
ON t2.product_id = sales.product_id
),

t4 AS 
(
SELECT  stores.store_name,stores.Store_Location, SUM(revenue) AS total_revenue_from_store
FROM t3
JOIN stores
ON t3.store_id = stores.store_id
GROUP BY stores.store_name, stores.Store_Location
),

t5 AS 
(
SELECT *,ROW_NUMBER() OVER (PARTITION BY store_location ORDER BY total_revenue_from_store DESC) AS rn
FROM t4
)

SELECT store_location,
         MAX(CASE WHEN rn = 1 THEN store_name END) + ' - ' +
         CAST(MAX(CASE WHEN rn = 1
                  THEN total_revenue_from_store END) AS varchar(10)) AS First,
	     MAX(CASE WHEN rn = 2 THEN store_name END) + ' - ' +
         CAST(MAX(CASE WHEN rn = 2
                  THEN total_revenue_from_store END) AS varchar(10)) AS Second,
		 MAX(CASE WHEN rn = 3 THEN store_name END) + ' - ' +
         CAST(MAX(CASE WHEN rn = 3
                  THEN total_revenue_from_store END) AS varchar(10)) AS Third

FROM t5
GROUP BY store_location




