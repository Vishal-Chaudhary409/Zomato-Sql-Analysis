CREATE DATABASE zomato;
use zomato;
select * from converted_table limit 5;
select * from dataset_table limit 5;
select * from food_items limit 5;
select * from menu limit 5;
select * from users limit 5;

-- Q1 What are the top 10 restaurants by total sales amount?
SELECT c.id, c.name, c.city, SUM(d.sales_amount) as total_sales FROM dataset_table d
JOIN
converted_table c on CAST(d.r_id as UNSIGNED) = c.id
GROUP BY c.id, c.name, c.city
ORDER BY total_sales DESC LIMIT 10;

-- Q2 What is the average rating and total rating count for restaurants in the top 20 cities?
WITH top_cities as(
SELECT city, COUNT(*) as restaurent_count FROM converted_table
GROUP BY city ORDER BY restaurent_count DESC limit 20
)
SELECT c.city, AVG(CAST(c.rating as DECIMAL(3,1))) AS avg_rating,
SUM(CAST(REGEXP_SUBSTR(c.rating_count, '[0-9]+') as UNSIGNED)) AS total_rating_count
FROM converted_table c
JOIN
top_cities t on t.city = c.city
WHERE c.rating REGEXP '^[0-9]'
GROUP BY city
ORDER BY t.restaurent_count DESC;

-- Q3 What are the monthly order trends based on order volume over time?
SELECT DATE_FORMAT(order_date, '%Y-%m') as order_month,
COUNT(*) as order_volume FROM dataset_table
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;

-- Q4 What are the top 5 most popular cuisines by order volume?
SELECT m.cuisine, COUNT(d.user_id) as order_vol FROM dataset_table d 
JOIN
menu m on m.r_id = d.r_id
GROUP BY cuisine ORDER BY order_vol DESC LIMIT 5;

-- Q5 What is the distribution of vegetarian vs non-vegetarian items ordered?
SELECT f.veg_or_non_veg, COUNT(d.user_id) as order_count FROM dataset_table d
JOIN
menu m on m.r_id = d.r_id
JOIN
food_items f on f.f_id = m.f_id
GROUP BY f.veg_or_non_veg;

-- Q6 What are the top 20 cities by the number of restaurants?
SELECT city, COUNT(*) as restaurent_count FROM converted_table GROUP BY city ORDER BY restaurent_count DESC LIMIT 20;

SELECT 
    CASE 
        WHEN city LIKE '%,%' 
        THEN TRIM(SUBSTRING_INDEX(city, ',', -1))
        ELSE TRIM(city)
    END AS city_name,
    COUNT(*) AS restaurant_count
FROM converted_table
GROUP BY city_name
ORDER BY restaurant_count DESC
LIMIT 20;

-- Q7 How do different user demographics correlate with average order value?

-- Q8 Who are the top 15 highest-spending users?
SELECT u.user_id, u.name, SUM(d.sales_amount) as user_spending FROM users u
JOIN 
dataset_table d on d.user_id = u.user_id
GROUP BY u.user_id, u.name ORDER BY user_spending DESC
LIMIT 15;

-- Q9 What are the top 15 cuisines with the highest average menu prices?
SELECT cuisine, AVG(price) as avg_price FROM menu 
GROUP BY cuisine ORDER BY avg_price DESC LIMIT 15;

-- Q10 Which restaurants offer the most diverse menu, based on the number of unique cuisines and dishes available?
SELECT 
    c.name,
    COUNT(DISTINCT m.cuisine) AS no_of_cuisines,
    COUNT(DISTINCT fi.item) AS no_of_dishes
FROM converted_table c
JOIN menu m ON m.r_id = c.id
JOIN food_items fi ON fi.f_id = m.f_id
GROUP BY c.name
ORDER BY no_of_cuisines DESC, no_of_dishes DESC
LIMIT 20;

-- Q11 What are the most ordered food items across all restaurants?
SELECT item, SUM(sales_qty) AS total_ordered FROM dataset_table d
JOIN
menu m on m.r_id = d.r_id
JOIN
food_items f on f.f_id = m.f_id
GROUP BY item ORDER BY total_ordered DESC;

-- Q12 How does spending behavior differ between genders?
SELECT gender, SUM(sales_amount) AS total_spending FROM users u
JOIN
dataset_table d on d.user_id = u.user_id
GROUP BY gender;

-- Q13 On which days of the week do restaurants experience peak order volumes?
SELECT 
    DAYNAME(order_date) AS day_of_week,
    COUNT(*) AS order_volume,
    SUM(sales_qty) AS total_qty_sold
FROM dataset_table
GROUP BY DAYNAME(order_date)
ORDER BY order_volume DESC;

-- Q14 How does order frequency vary across different income groups?
SELECT 
    u.`Monthly Income` AS income_group,
    COUNT(d.user_id) AS order_frequency
FROM users u
JOIN dataset_table d ON d.user_id = u.user_id
GROUP BY u.`Monthly Income`
ORDER BY order_frequency DESC;