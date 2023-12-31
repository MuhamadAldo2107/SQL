-- In terms of the supply of item, 
-- which product category that have the most variety of SKU that being 
-- input to the system in the year 2019

SELECT product_category,
       COUNT(product_category) as total_product,
  FROM `sql-project-376612.thelook_ecommerce.inventory_items`
 WHERE EXTRACT(YEAR FROM created_at) = 2019
 GROUP BY product_category
 ORDER BY total_product DESC

--  Considering completed orders and focusing on the month of shipment, 
--  which month in the year 2021 
--  had the lowest total order performance 
--  for the Jeans category?

SELECT COUNT(o.product_id) AS total_order,
       DATE_TRUNC(o.shipped_at, MONTH) AS shipped_date
  FROM `sql-project-376612.thelook_ecommerce.order_items` AS o 
 INNER JOIN `sql-project-376612.thelook_ecommerce.products` AS p
    ON o.product_id = p.id
 WHERE EXTRACT(YEAR FROM created_at) = 2021
   AND p.category = 'Jeans'
   AND o.status = "Complete"
 GROUP BY shipped_date
 ORDER BY shipped_date ASC


-- To retrieve the location with the highest number of buyers (use unique user) 
-- who made purchases on our platform during the year 2022
 
SELECT t2.country,
       COUNT(DISTINCT t1.user_id) total_user
  FROM `sql-project-376612.thelook_ecommerce.orders` t1
  LEFT JOIN `sql-project-376612.thelook_ecommerce.users` t2
    ON t1.user_id = t2.id
 WHERE t1.status = 'Complete'
   AND DATE(t1.shipped_at) >= '2022-01-01'
   AND DATE(t1.shipped_at) < '2023-01-01'
 GROUP BY 1
 ORDER BY 2 DESC

-- Considering the completed orders that were shipped in the year 2022, 
-- which distribution center to which country destination had the highest total number of items sold?


 
WITH shipping_date AS( 
SELECT t1.user_id,
       t1.product_id,
       t1.status,
       t2.country AS customer_country,
       DATE(t1.shipped_at) shipped_date
  FROM `sql-project-376612.thelook_ecommerce.order_items` t1
  LEFT JOIN `sql-project-376612.thelook_ecommerce.users` t2
    ON t1.user_id = t2.id
 WHERE EXTRACT(YEAR FROM shipped_at) = 2022
   AND status = 'Complete'
 ORDER BY shipped_date
),

product_data AS(
SELECT t1.distribution_center_id,
       t1.id AS product_id,
       t2.name AS distribution_center_name
  FROM `sql-project-376612.thelook_ecommerce.products` t1
  LEFT JOIN `sql-project-376612.thelook_ecommerce.distribution_centers` t2
    ON t1.distribution_center_id = t2.id
),

distribution_data AS(
SELECT COUNT(DISTINCT t1.product_id) as total_item_sold,
       t2.distribution_center_name,
       t1.customer_country
 FROM shipping_date t1
 LEFT JOIN product_data t2
   ON t1.product_id = t2.product_id
 GROUP BY customer_country, distribution_center_name
 ORDER BY total_item_sold DESC
)

SELECT total_item_sold,
       CONCAT(distribution_center_name,' to ',customer_country) as distribution_center_to_country
  FROM distribution_data
ORDER BY total_item_sold DESC;


   -----------------------------------------------------------

WITH shipping_date AS( 
SELECT t1.user_id,
       t1.product_id,
       t1.status,
       t2.country AS customer_country,
       DATE(t1.shipped_at) shipped_date
  FROM `sql-project-376612.thelook_ecommerce.order_items` t1
  LEFT JOIN `sql-project-376612.thelook_ecommerce.users` t2
    ON t1.user_id = t2.id
 WHERE EXTRACT(YEAR FROM shipped_at) = 2022
   AND status = 'Complete'
 ORDER BY shipped_date
),

product_data AS(
SELECT t1.distribution_center_id,
       t1.id AS product_id,
       t2.name AS distribution_center_name
  FROM `sql-project-376612.thelook_ecommerce.products` t1
  LEFT JOIN `sql-project-376612.thelook_ecommerce.distribution_centers` t2
    ON t1.distribution_center_id = t2.id
),

distribution_data AS(
SELECT COUNT(DISTINCT t1.product_id) as total_item_sold,
       t2.distribution_center_name,
       t1.customer_country
 FROM shipping_date t1
 LEFT JOIN product_data t2
   ON t1.product_id = t2.product_id
 GROUP BY customer_country, distribution_center_name
 ORDER BY total_item_sold DESC
)

SELECT total_item_sold,
       CONCAT(distribution_center_name,' to ',customer_country) as distribution_center_to_country
  FROM distribution_data
ORDER BY total_item_sold DESC;


-- Using the completed orders that were shipped in the year 2021 and considering the following age group standards:
-- 17 and below
-- 18 to 24
-- 25 to 34
-- 35 to 54
-- 55 and above
-- Can you identify the top 1 combination of 
-- age group, 
-- gender, 
-- and country 
-- that contributed the highest number of buyers in 2021? 
-- How much percentage contribute to all buyers?



WITH user_data AS(
SELECT id,
       gender,
       country,
       age,
       CASE
       WHEN age <= 17 THEN '17 and below'
       WHEN age BETWEEN 18 AND 24 THEN '18 to 24'
       WHEN age BETWEEN 35 AND 54 THEN '35 to 52'
       ELSE '55 and above'
       END AS age_group_standards
  FROM `sql-project-376612.thelook_ecommerce.users`
),

order_data AS(
SELECT id,
       user_id,
       status,
       DATE(shipped_at) shipped_date,
  FROM `sql-project-376612.thelook_ecommerce.order_items`
 WHERE EXTRACT(YEAR FROM shipped_at) = 2021
   AND status = 'Complete'
 ORDER BY shipped_date
),
final_stage_data AS(
SELECT t2.age_group_standards,
       t2.gender,
       t2.country,
       COUNT(DISTINCT t1.user_id) total_buyer
  FROM order_data t1
  LEFT JOIN user_data t2
    ON t1.user_id = t2.id
  GROUP BY t2.age_group_standards, t2.gender, t2.country
)

SELECT *,
       total_buyer/SUM(total_buyer)*100 OVER(ORDER BY age_group_standards )
FROM final_stage_data
   



-------------------

WITH user_data AS (
SELECT id,
       gender,
       country,
       age,
       CASE
       WHEN age <= 17 THEN '17 and below'
       WHEN age BETWEEN 18 AND 24 THEN '18 to 24'
       WHEN age BETWEEN 35 AND 54 THEN '35 to 54'
       ELSE '55 and above'
       END AS age_group_standards
  FROM `sql-project-376612.thelook_ecommerce.users`
),

order_data AS (
SELECT id,
       user_id,
       status,
       DATE(shipped_at) shipped_date
  FROM `sql-project-376612.thelook_ecommerce.order_items`
 WHERE EXTRACT(YEAR FROM shipped_at) = 2021
   AND status = 'Complete'
 ORDER BY shipped_date
),

final_stage_data AS (
SELECT t2.age_group_standards,
       t2.gender,
       t2.country,
       COUNT(DISTINCT t1.user_id) AS total_buyer
  FROM order_data t1
  LEFT JOIN user_data t2
    ON t1.user_id = t2.id
  GROUP BY t2.age_group_standards, t2.gender, t2.country
)

SELECT *,
       (total_buyer / SUM(total_buyer) OVER ()) * 100 AS percentage
FROM final_stage_data
ORDER BY total_buyer DESC




