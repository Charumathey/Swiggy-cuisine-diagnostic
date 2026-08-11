-- (a) Tier every restaurant by its total Delivered revenue
SELECT
    r.restaurant_id,
    r.name,
    r.cuisine,
    SUM(o.amount_inr) AS total_revenue,
    CASE
        WHEN SUM(o.amount_inr) >= 50000 THEN 'High'
        WHEN SUM(o.amount_inr) >= 20000 THEN 'Medium'
        ELSE 'Low'
    END AS revenue_tier
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
WHERE o.status = 'Delivered'
GROUP BY r.restaurant_id, r.name, r.cuisine
ORDER BY total_revenue DESC;

-- (b) Monthly-by-cuisine business report (Delivered orders only)
-- This is the exact query exported to monthly_cuisine_revenue.csv
SELECT
    r.cuisine                                  AS cuisine,
    strftime('%Y-%m', o.order_date)            AS month,
    COUNT(o.order_id)                          AS order_count,
    SUM(o.amount_inr)                          AS total_revenue,
    AVG(o.amount_inr)                          AS avg_revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.status = 'Delivered'
GROUP BY r.cuisine, strftime('%Y-%m', o.order_date)
ORDER BY r.cuisine, month;

-- (c) Derived fields: cuisine-level revenue vs. target,
-- variance and percentage_variance, with status tags.
-- Note: total_revenue and target_revenue_inr are both INTEGER,
-- so we force floating-point division by multiplying by 100.0
-- BEFORE dividing, to avoid SQLite's integer-division truncation.
SELECT
    cr.cuisine,
    cr.total_revenue,
    ct.target_revenue_inr,
    (ct.target_revenue_inr - cr.total_revenue) AS variance,
    ((cr.total_revenue - ct.target_revenue_inr) * 100.0) / ct.target_revenue_inr
        AS percentage_variance,
    CASE
        WHEN cr.total_revenue >= ct.target_revenue_inr
            THEN 'Above Target'
        WHEN ((ct.target_revenue_inr - cr.total_revenue) * 100.0) / ct.target_revenue_inr <= 15
            THEN 'Below Target - Watch'
        ELSE 'Below Target - Critical'
    END AS target_status
FROM (
    SELECT r.cuisine, SUM(o.amount_inr) AS total_revenue
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE o.status = 'Delivered'
    GROUP BY r.cuisine
) cr
JOIN cuisine_targets ct ON cr.cuisine = ct.cuisine
ORDER BY percentage_variance ASC;