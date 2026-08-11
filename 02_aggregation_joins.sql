-- (a) INNER JOIN of orders to restaurants, grouped by cuisine,
-- Delivered orders only, with HAVING total_revenue > 40000
SELECT
    r.cuisine,
    COUNT(o.order_id)          AS order_count,
    SUM(o.amount_inr)          AS total_revenue,
    AVG(o.amount_inr)          AS avg_revenue
FROM orders o
INNER JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.status = 'Delivered'
GROUP BY r.cuisine
HAVING total_revenue > 40000
ORDER BY total_revenue DESC;

-- (b) LEFT JOIN of restaurants to orders, grouped by restaurant,
-- counting ALL orders (any status). A restaurant with zero
-- matching orders still appears, with a count of 0.
-- Ordered ascending to surface the least-active restaurants.
SELECT
    r.restaurant_id,
    r.name,
    r.cuisine,
    COUNT(o.order_id) AS total_orders
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.name, r.cuisine
ORDER BY total_orders ASC;