/* --------------------
  Cleaned Dataset:
--------------------*/

-- Cleaned version of customer_orders:
CREATE TEMPORARY TABLE customer_orders_cleaned AS
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

SELECT * FROM runner_orders_cleaned;




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

/* --------------------
  B. Runner and Customer Experience
--------------------*/
-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration_cleaned) - MIN(duration_cleaned) AS delivery_time_diff
FROM runner_orders_cleaned
