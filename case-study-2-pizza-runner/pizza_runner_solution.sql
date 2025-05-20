/* --------------------
  Cleaned Dataset:
--------------------*/

-- Cleaned version of customer_orders:
CREATE TEMPORARY TABLE customer_orders AS
  SELECT 
    order_id,
    customer_id,
    pizza_id,
    CASE WHEN exclusions IN ('', 'null') THEN NULL
    ELSE exclusions
    END AS exclusions_cleaned,
    CASE WHEN extras IN('', 'null', 'NaN') THEN NULL
    ELSE extras
    END AS extras_cleaned,
    order_time
  FROM customer_orders;

-- Cleaned version of runner_orders:
CREATE TEMPORARY TABLE runner_orders_cleaned AS
  SELECT 
    order_id,
    runner_id,
    CASE 
      WHEN pickup_time = 'null' THEN NULL
      ELSE pickup_time
    END AS pickup_time_cleaned,
    
    CASE 
      WHEN distance = 'null' THEN NULL
      ELSE CAST(regexp_replace(distance, '(km|\\s+)', '', 'gi') AS DECIMAL(5,2))
    END AS distance_cleaned,
    
    CASE 
      WHEN duration = 'null' THEN NULL
      ELSE CAST(regexp_replace(duration, '(minutes|minute|mins|min|\\s+)', '', 'gi') AS DECIMAL(5,2))
    END AS duration_cleaned,
    
    CASE 
      WHEN cancellation IN ('null', '', 'NaN') THEN NULL
      ELSE cancellation
    END AS cancellation_cleaned
  FROM runner_orders;


/* --------------------
  A. Pizza Metrics
--------------------*/
-- 1. How many pizzas were ordered?
SELECT COUNT(*) AS pizzas_ordered
FROM customer_orders;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) as unique_orders_made
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(*) AS successful_orders
FROM runner_orders_cleaned
WHERE pickup_time_cleaned IS NOT NULL AND cancellation_cleaned IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT coc.pizza_id, COUNT(*) AS pizza_delivered
FROM customer_orders_cleaned coc
INNER JOIN runner_orders_cleaned roc USING(order_id)
WHERE roc.pickup_time_cleaned IS NOT NULL AND roc.cancellation_cleaned IS NULL
GROUP BY coc.pizza_id;

-- 5. How many Vegetarian and Meatloaves were ordered by each customer?
SELECT 
  customer_id,
  COUNT(CASE WHEN pizza_id = 1 THEN 1 END) AS meatlovers_ordered,
  COUNT(CASE WHEN pizza_id = 2 THEN 1 END) AS vegetarian_ordered
FROM customer_orders_cleaned
GROUP BY customer_id
ORDER BY customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
WITH pizzas_per_order AS (
  SELECT COUNT(*) AS pizza_count
  FROM customer_orders
  GROUP BY order_id
) 
SELECT MAX(pizza_count) AS max_pizzas_in_single_order
FROM pizzas_per_order;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
  customer_id, 
  COUNT(CASE WHEN coc.exclusions_cleaned IS NOT NULL OR coc.extras_cleaned IS NOT NULL THEN 1 END) as total_pizzas_with_changes,
  COUNT(CASE WHEN coc.exclusions_cleaned IS NULL AND coc.extras_cleaned IS NULL THEN 1 END) as total_pizzas_no_changes
FROM customer_orders_cleaned coc
INNER JOIN runner_orders_cleaned roc USING(order_id)
WHERE roc.cancellation_cleaned IS NULL
GROUP BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
 COUNT(CASE WHEN coc.exclusions_cleaned IS NOT NULL AND coc.extras_cleaned IS NOT NULL THEN 1 END) as total_pizzas_both_exclusions_extras
FROM customer_orders_cleaned coc
INNER JOIN runner_orders_cleaned roc USING(order_id)
WHERE roc.cancellation_cleaned IS NULL

-- 9. What was the total volume of pizzas ordered for each hour of the day?
WITH RECURSIVE cte AS (
  SELECT 0 AS hour
  UNION ALL
  SELECT hour + 1
  FROM cte
  WHERE hour < 23
)

SELECT cte.hour as hour,  COUNT(CASE WHEN co.order_id IS NOT NULL THEN 1 END) as total_ordered
FROM cte
LEFT JOIN customer_orders co ON EXTRACT(HOUR FROM co.order_time) = cte.hour
GROUP BY  cte.hour
ORDER BY cte.hour

-- 10. What was the volume of orders for each day of the week?
WITH RECURSIVE cte AS (
  SELECT 0 AS day
  UNION ALL
  SELECT day + 1
  FROM cte
  WHERE day < 6
)

SELECT cte.day as day,  COUNT(CASE WHEN co.order_id IS NOT NULL THEN 1 END) as total_ordered
FROM cte
LEFT JOIN customer_orders co ON EXTRACT(DOW FROM order_time) = cte.day
GROUP BY  cte.day
ORDER BY cte.day

/* --------------------
  B. Runner and Customer Experience
--------------------*/
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
WITH RECURSIVE cte AS (
    SELECT 
        DATE '2021-01-01' AS start_date, 
        DATE '2021-01-01' + INTERVAL '6 days' AS end_date
    UNION ALL
    SELECT 
        (end_date + INTERVAL '1 day')::DATE, 
        (end_date + INTERVAL '7 days')::DATE
    FROM cte 
    WHERE end_date < DATE '2021-01-31'
)

SELECT
  ROW_NUMBER() OVER(ORDER BY start_date) AS week,
  start_date,
  end_date,
  SUM(CASE WHEN r.registration_date IS NOT NULL THEN 1 ELSE 0 END) as total_runners_signed_up
FROM cte
LEFT JOIN runners r ON r.registration_date BETWEEN start_date AND end_date
GROUP BY start_date, end_date

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
  r.runner_id, 
  ROUND(AVG(EXTRACT(EPOCH FROM (r.pickup_time_cleaned::timestamp - c.order_time)) / 60)::numeric ,2) AS avg_minutes_diff
FROM customer_orders_cleaned c
LEFT JOIN runner_orders_cleaned r USING(order_id)
WHERE r.pickup_time_cleaned  IS NOT NULL AND r.cancellation_cleaned IS NULL
GROUP BY r.runner_id

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH cte AS (
  SELECT 
    order_id, 
    COUNT(pizza_id) as total_pizzas, 
    r.pickup_time_cleaned, c.order_time,
    EXTRACT(EPOCH FROM (r.pickup_time_cleaned::timestamp - c.order_time)) / 60 AS minutes_diff
  FROM customer_orders c
  INNER JOIN runner_orders_cleaned r USING (order_id)
  WHERE r.pickup_time_cleaned IS NOT NULL
  GROUP BY order_id, r.pickup_time_cleaned, c.order_time
  ORDER BY order_id
)

SELECT total_pizzas, ROUND(AVG(minutes_diff), 2)
FROM cte
GROUP BY total_pizzas

-- 4. What was the average distance traveled for each customer?
SELECT 
  customer_id,
  ROUND(AVG(distance_cleaned), 2) AS ave_distance_traveled
FROM customer_orders c
INNER JOIN runner_orders_cleaned r USING (order_id)
WHERE r.pickup_time_cleaned IS NOT NULL
GROUP BY customer_id
ORDER BY customer_id

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration_cleaned) - MIN(duration_cleaned) AS delivery_time_diff
FROM runner_orders_cleaned

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH cte AS (
  SELECT 
    order_id, 
    runner_id, 
    distance_cleaned,
    duration_cleaned,
    distance_cleaned / duration_cleaned  AS speed
  FROM runner_orders_cleaned r
  WHERE pickup_time_cleaned IS NOT NULL
)

SELECT runner_id, ROUND(AVG(speed), 2) average_speed
FROM cte
GROUP BY runner_id
ORDER BY runner_id