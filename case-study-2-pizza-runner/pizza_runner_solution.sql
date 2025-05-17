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

-- Cleaned version of runner_orders:
CREATE TEMPORARY TABLE runner_orders_cleaned AS
  SELECT 
    order_id,
    runner_id,
    CASE WHEN pickup_time = 'null' THEN NULL
    ELSE pickup_time
    END AS pickup_time_cleaned,
    CASE WHEN distance = 'null' THEN NULL
    ELSE distance
    END AS distance_cleaned,
    CASE WHEN duration = 'null' THEN NULL
    ELSE duration
    END AS duration_cleaned,
    CASE WHEN cancellation IN ('null', '', 'NaN' ) THEN NULL
    ELSE cancellation
    END AS cancellation_cleaned
  FROM runner_orders



/* --------------------
  A. Pizza Metrics
--------------------*/
-- 1. How many pizzas were ordered?


-- 2. How many unique customer orders were made?


-- 3. How many successful orders were delivered by each runner?
