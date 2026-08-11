-- 1. SELECT / WHERE
-- Restaurants located in a specific city (Mumbai)
SELECT restaurant_id, name, cuisine, city
FROM restaurants
WHERE city = 'Mumbai';

-- 2. DISTINCT
-- Every distinct cuisine listed on the platform
SELECT DISTINCT cuisine
FROM restaurants;

-- 3. ORDER BY + LIMIT
-- The 5 highest-value orders by amount_inr
SELECT order_id, customer_id, restaurant_id, order_date, amount_inr, status
FROM orders
ORDER BY amount_inr DESC
LIMIT 5;

-- 4. LIKE with %
-- Find restaurants whose name contains the keyword 'House'
SELECT restaurant_id, name, cuisine, city
FROM restaurants
WHERE name LIKE '%House%';

-- 5. IN
-- Customers whose city is in a 2-city list (Mumbai, Delhi)
SELECT customer_id, name, city
FROM customers
WHERE city IN ('Mumbai', 'Delhi');

-- 6. BETWEEN
-- Orders with amount_inr in the range 500 to 1000 (inclusive)
SELECT order_id, amount_inr, status
FROM orders
WHERE amount_inr BETWEEN 500 AND 1000;

-- 6b. NOT BETWEEN
-- Orders with amount_inr outside the range 500 to 1000
SELECT order_id, amount_inr, status
FROM orders
WHERE amount_inr NOT BETWEEN 500 AND 1000;

-- 7. IS NULL
-- Orders with no rating recorded (these are exactly the
-- Cancelled/Pending orders, which never receive a rating)
SELECT order_id, status, rating
FROM orders
WHERE rating IS NULL;

