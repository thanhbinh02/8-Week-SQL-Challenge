/* --------------------
  A. Pizza Metrics
--------------------*/
-- 1. How many pizzas were ordered?
SELECT COUNT(*)
FROM customer_orders

-- 2. How many unique customer orders were made?
SELECT DISTINCT customer_id
FROM customer_orders
ORDER BY customer_id

-- 3. How many successful orders were delivered by each runner?
UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation = 'NaN' OR cancellation = '';

SELECT runner_id, COUNT(order_id) AS successful_deliveries
FROM runner_orders
WHERE pickup_time IS NOT NULL
  AND cancellation IS NULL
GROUP BY runner_id
ORDER BY runner_id;