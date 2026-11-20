use coffee

---- -- Q.1
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in 2023?
SELECT 
sum(total)
FROM sales
where DATEPART(year,sale_date)=2023

-- Q.2
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?
SELECT p.product_id,count(s.product_id) 
from sales s left join products p on s.product_id=p.product_id
group by p.product_id order by p.product_id

-- Q.3
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?
select co.city_id,AVG(CAST(s.total AS DECIMAL(10,2))) avg
from sales as s left join customers co on s.customer_id=co.customer_id
group by co.city_id order by co.city_id


-- -- Q.4
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.

with cte as(
select co.customer_id,cy.city_name,cast(cy.population*0.25 as int) popu 
from city cy
left join customers co on cy.city_id=co.city_id)
select ct.city_name,ct.popu,count(distinct(s.customer_id)) countt
from cte ct  left join sales s on ct.customer_id=s.customer_id
group by ct.city_name,ct.popu2

-- -- Q5
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
 WITH cte AS (
    SELECT
        cy.city_name,
        s.product_id,
        RANK() OVER (
            PARTITION BY cy.city_id
            ORDER BY SUM(s.total) DESC
        ) AS rn
    FROM city cy
    JOIN customers co ON cy.city_id = co.city_id
    JOIN sales s ON co.customer_id = s.customer_id
    GROUP BY cy.city_id, cy.city_name, s.product_id
)

SELECT
    city_name,
    STRING_AGG(CAST(product_id AS VARCHAR(20)), ',') AS pro
FROM cte
WHERE rn <= 3
GROUP BY city_name
ORDER BY city_name
------------------------------------------------------------
-- Q.6
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

WITH cte AS(
select cy.city_name,count(distinct(s.customer_id))  total_customer from 
city cy left join customers cu on cy.city_id=cu.city_id
        left join sales s on cu.customer_id=s.customer_id
        group by cy.city_name)
        select * from cte order by city_name

-- -- Q.7
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
WITH cte AS (
    select cy.city_name,
           cast(sum(s.total)/count(distinct(s.customer_id)) as decimal(10,2)) AVGG,
           max(cy.estimated_rent)/nullif(count(distinct(s.customer_id)),0) SS
    from city cy
    left join customers cu
        on cy.city_id=cu.city_id
    left join sales s
        on cu.customer_id=s.customer_id
    group by cy.city_name
)
select *
from cte
order by city_name
-- Q.8
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

WITH CTE AS(
select datepart(YEAR,sale_date) as year ,datepart(month,sale_date)  as month ,sum(total) tot 
from sales
group by datepart(month,sale_date),datepart(YEAR,sale_date) )

select year,month,cast(((tot-lagi)*100/lagi) as decimal(10,2))  as growth
from(
select *,lag(tot)over (order by month) lagi 
from cte )t  order by year,month

-- Q.9
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers.

WITH cte AS (
    select cy.city_name,
           sum(s.total) tot,
           max(cy.estimated_rent) ER,
           COUNT(DISTINCT(S.customer_id)) as N_customers
    from city cy
    left join customers cu
        on cy.city_id=cu.city_id
    left join sales s
        on cu.customer_id=s.customer_id
    group by cy.city_name)

    SELECT * FROM(
    select *,rank()over(order by tot desc) as Rn
    from cte )T 
    where rn<=3