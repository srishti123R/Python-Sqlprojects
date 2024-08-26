/* ANALYSIS 1 - find top 10 highest revenue generating products.
 ANALYSIS 2 - find top 5 highest selling products in each region.
ANALYSIS 3 - find month over month growth comparison for 2022 and 2023 sales. eg. jan 2022 to jan 2023.
 ANALYSIS 4 - for each category which month had highest sales.
ANALYSIS 5- which sub category had highest growth by percentage of profit in 2023 compare to 2022.*/




create database customer_segment;
use customer_segment;
show tables;		
select* from orders;
-- drop table orders;

CREATE TABLE orders (
    order_id INT,
    order_date DATE,
    ship_mode VARCHAR(255),
    segment VARCHAR(255),
    country VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    postal_code INT,
    region VARCHAR(255),
    category VARCHAR(255),
    sub_category VARCHAR(255),
    product_id VARCHAR(255),
    quantity INT,
    discount FLOAT,
    sale_price FLOAT,
    total_revenue FLOAT,
    total_cost INT,
    profit FLOAT
);

-- (1)find top 10 highest revenue generating products.
SELECT
    product_id,
    SUM(total_revenue) AS total_revenue_generated
FROM 
    orders
GROUP BY 
    product_id
ORDER BY 
    total_revenue_generated DESC
LIMIT 10;

-- (2) 	 find top 5 highest selling products in each region.
select distinct region from orders;
select region,product_id, sum(total_revenue) as sales
from orders
group by region,product_id
order by region,sales desc
limit 5; -- it will only give top 5 selling products across all the resons not across each regions.

--  for top 5 selling product across each region we have to use sub query
SELECT *
FROM (
    SELECT 
        region,
        product_id,
         sales,
        RANK() OVER (PARTITION BY region ORDER BY sales DESC) AS `rank`
    FROM (
        SELECT 
            region,
            product_id,
            SUM(total_revenue) AS sales
        FROM 
            orders
        GROUP BY 
            region, product_id
    ) AS aggregated -- Subquery to calculate sales
) AS ranked -- Subquery to apply the RANK function
WHERE `rank` <= 5
ORDER BY region, `rank`;
-- (3) find month over month growth comparison for 2022 and 2023 sales. eg. jan 2022 to jan 2023

 Select
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(total_revenue) AS sales
    FROM 
        orders
    GROUP BY 
        YEAR(order_date), MONTH(order_date)
) AS sales_data
GROUP BY 
    order_month
ORDER BY 
    order_month;


SELECT 
    month,
   round( SUM(CASE WHEN order_year = 2022 THEN total_revenue ELSE 0 END),2) AS sales_2022,
   round( SUM(CASE WHEN order_year = 2023 THEN total_revenue ELSE 0 END),2) AS sales_2023
FROM (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS month,
        total_revenue
    FROM 
        orders
    WHERE 
        YEAR(order_date) IN (2022, 2023)
) AS sales_data
GROUP BY 
    month
ORDER BY 
    month;
    -- (4) for each category which month had highest sales
SELECT * 
FROM (
    SELECT 
        category, 
        DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
        ROUND(SUM(total_revenue), 2) AS sales,  -- Rounding sales to 2 decimal places
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY ROUND(SUM(total_revenue), 2) DESC) AS `rank`
    FROM 
        orders
    GROUP BY 
        category, 
        DATE_FORMAT(order_date, '%Y%m')
) a
WHERE `rank` = 1;
-- which sub category had highest growth by percentage of profit in 2023 compare to 2022

SELECT 
    sub_category,
    profit_2022,
    profit_2023,
    ROUND(((profit_2023 - profit_2022) / profit_2022) * 100, 2) AS profit_growth_percentage
FROM (
    SELECT 
        sub_category,
        round(SUM(CASE WHEN YEAR(order_date) = 2022 THEN profit ELSE 0 END),2) AS profit_2022,
        round(SUM(CASE WHEN YEAR(order_date) = 2023 THEN profit ELSE 0 END),2) AS profit_2023
    FROM 
        orders
    GROUP BY 
        sub_category
) AS profit_summary
ORDER BY 
    profit_growth_percentage DESC
LIMIT 1;
