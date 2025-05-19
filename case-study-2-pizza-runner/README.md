# Case Study #2 - Pizza Runner
## **Table 1: runners**
The `runners` table shows the registration_date for each new runner

| runner_id | registration_date |
|-----------|-------------------|
| 1         | 2021-01-01        |
| 2         | 2021-01-03        |
| 3         | 2021-01-08        |
| 4         | 2021-01-15        |


## **Table 2: customer_orders**
The `customer_orders` table records pizza orders from customers, with each row representing an individual pizza in the order.

- The `pizza_id` column indicates the type of pizza ordered.
- The `exclusions` column lists the IDs of ingredients to be removed from the pizza (if any).
- The `extras` column lists the IDs of ingredients to be added to the pizza (if any).
- A single order (`order_id`) can include multiple pizzas, even of the same type, but with different topping customizations.
- The `exclusions` and `extras` columns may contain inconsistent data (e.g., `null`, `NaN`, or strings with multiple IDs separated by commas) and need to be cleaned before processing.

| order_id | customer_id | pizza_id | exclusions | extras  | order_time           |
|----------|-------------|----------|------------|---------|----------------------|
| 1        | 101         | 1        |            |         | 2021-01-01 18:05:02  |
| 2        | 101         | 1        |            |         | 2021-01-01 19:00:52  |
| 3        | 102         | 1        |            |         | 2021-01-02 23:51:23  |
| 3        | 102         | 2        |            | NaN     | 2021-01-02 23:51:23  |
| 4        | 103         | 1        | 4          |         | 2021-01-04 13:23:46  |
| 4        | 103         | 1        | 4          |         | 2021-01-04 13:23:46  |
| 4        | 103         | 2        | 4          |         | 2021-01-04 13:23:46  |
| 5        | 104         | 1        | null       | 1       | 2021-01-08 21:00:29  |
| 6        | 101         | 2        | null       | null    | 2021-01-08 21:03:13  |
| 7        | 105         | 2        | null       | 1       | 2021-01-08 21:20:29  |
| 8        | 102         | 1        | null       | null    | 2021-01-09 23:54:33  |
| 9        | 103         | 1        | 4          | 1, 5    | 2021-01-10 11:22:59  |
| 10       | 104         | 1        | null       | null    | 2021-01-11 18:34:49  |
| 10       | 104         | 1        | 2, 6       | 1, 4    | 2021-01-11 18:34:49  |

## **Table 3: runner_orders**
The `runner_orders` table tracks how orders are assigned to runners. Not all orders are completed—some may be cancelled by either the restaurant or the customer.
- pickup_time records when the runner picks up the pizzas.
- distance and duration represent how far and how long the delivery took.
- There are known data quality issues in this table, so always check column data types before querying.

| order_id | runner_id | pickup_time           | distance  | duration     | cancellation            |
|----------|-----------|------------------------|-----------|--------------|--------------------------|
| 1        | 1         | 2021-01-01 18:15:34    | 20km      | 32 minutes   |                          |
| 2        | 1         | 2021-01-01 19:10:54    | 20km      | 27 minutes   |                          |
| 3        | 1         | 2021-01-03 00:12:37    | 13.4km    | 20 mins      | NaN                      |
| 4        | 2         | 2021-01-04 13:53:03    | 23.4      | 40           | NaN                      |
| 5        | 3         | 2021-01-08 21:10:57    | 10        | 15           | NaN                      |
| 6        | 3         | null                   | null      | null         | Restaurant Cancellation  |
| 7        | 2         | 2020-01-08 21:30:45    | 25km      | 25mins       | null                     |
| 8        | 2         | 2020-01-10 00:15:02    | 23.4 km   | 15 minute    | null                     |
| 9        | 2         | null                   | null      | null         | Customer Cancellation    |
| 10       | 1         | 2020-01-11 18:50:20    | 10km      | 10minutes    | null                     |

## **Table 4: pizza_names**
At the moment - Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!
| pizza_id | pizza_name  |
|----------|-------------|
| 1        | Meat Lovers |
| 2        | Vegetarian  |

## **Table 5: pizza_recipes**
Each `pizza_id` has a standard set of toppings which are used as part of the pizza recipe.
| pizza_id | toppings                |
|----------|-------------------------|
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 |
| 2        | 4, 6, 7, 9, 11, 12      |

## **Table 6: pizza_toppings**
This table contains all of the `topping_name` values with their corresponding `topping_id` value

| topping_id | topping_name |
|------------|--------------|
| 1          | Bacon        |
| 2          | BBQ Sauce    |
| 3          | Beef         |
| 4          | Cheese       |
| 5          | Chicken      |
| 6          | Mushrooms    |
| 7          | Onions       |
| 8          | Pepperoni    |
| 9          | Peppers      |
| 10         | Salami       |
| 11         | Tomatoes     |
| 12         | Tomato Sauce |

# Cleaned Dataset
I remove all the blank spaces and replace all stringed (null/NaN) values as a NULL value for consistency
## **customer_orders table**
```sql
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
```

| order_id | customer_id | pizza_id | exclusions_cleaned | extras_cleaned | order_time           |
|----------|-------------|----------|--------------------|----------------|----------------------|
| 1        | 101         | 1        | null               | null           | 2020-01-01 18:05:02  |
| 2        | 101         | 1        | null               | null           | 2020-01-01 19:00:52  |
| 3        | 102         | 1        | null               | null           | 2020-01-02 23:51:23  |
| 3        | 102         | 2        | null               | null           | 2020-01-02 23:51:23  |
| 4        | 103         | 1        | 4                  | null           | 2020-01-04 13:23:46  |
| 4        | 103         | 1        | 4                  | null           | 2020-01-04 13:23:46  |
| 4        | 103         | 2        | 4                  | null           | 2020-01-04 13:23:46  |
| 5        | 104         | 1        | null               | 1              | 2020-01-08 21:00:29  |
| 6        | 101         | 2        | null               | null           | 2020-01-08 21:03:13  |
| 7        | 105         | 2        | null               | 1              | 2020-01-08 21:20:29  |
| 8        | 102         | 1        | null               | null           | 2020-01-09 23:54:33  |
| 9        | 103         | 1        | 4                  | 1, 5           | 2020-01-10 11:22:59  |
| 10       | 104         | 1        | null               | null           | 2020-01-11 18:34:49  |
| 10       | 104         | 1        | 2, 6               | 1, 4           | 2020-01-11 18:34:49  |

## **runner_orders table**
```sql
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
```

| order_id | runner_id | pickup_time_cleaned   | distance_cleaned | duration_cleaned | cancellation_cleaned       |
|----------|-----------|------------------------|------------------|------------------|-----------------------------|
| 1        | 1         | 2020-01-01 18:15:34    | 20.00            | 32.00            | null                        |
| 2        | 1         | 2020-01-01 19:10:54    | 20.00            | 27.00            | null                        |
| 3        | 1         | 2020-01-03 00:12:37    | 13.40            | 20.00            | null                        |
| 4        | 2         | 2020-01-04 13:53:03    | 23.40            | 40.00            | null                        |
| 5        | 3         | 2020-01-08 21:10:57    | 10.00            | 15.00            | null                        |
| 6        | 3         | null                   | null             | null             | Restaurant Cancellation     |
| 7        | 2         | 2020-01-08 21:30:45    | 25.00            | 25.00            | null                        |
| 8        | 2         | 2020-01-10 00:15:02    | 23.40            | 15.00            | null                        |
| 9        | 2         | null                   | null             | null             | Customer Cancellation       |
| 10       | 1         | 2020-01-11 18:50:20    | 10.00            | 10.00            | null                        |


# A. Pizza Metrics
## **1. How many pizzas were ordered?**
```sql
SELECT COUNT(*) AS pizzas_ordered
FROM customer_orders;
```
| pizzas_ordered |
|-------------   |
| 14             | 

## **2. How many unique customer orders were made?**
```sql
SELECT COUNT(DISTINCT order_id) as unique_orders_made
FROM customer_orders;
```
| unique_orders_made |
|-------------       |
| 10                 | 

## **3. How many successful orders were delivered by each runner?**
```sql
SELECT runner_id, COUNT(*) AS successful_orders_each_runner
FROM runner_orders_cleaned
WHERE pickup_time_cleaned IS NOT NULL AND cancellation_cleaned IS NULL
GROUP BY runner_id;
```
| runner_id | successful_orders |
|-----------|-------------------|
| 1         | 4                 |
| 2         | 3                 |
| 3         | 1                 |

## **4. How many of each type of pizza was delivered?**
```sql
SELECT coc.pizza_id, COUNT(*) AS pizza_delivered
FROM customer_orders_cleaned coc
INNER JOIN runner_orders_cleaned roc USING(order_id)
WHERE roc.pickup_time_cleaned IS NOT NULL AND roc.cancellation_cleaned IS NULL
GROUP BY coc.pizza_id;
```
| pizza_id | pizza_delivered   |
|----------|-------------------|
| 1        | 9                 |
| 2        | 3                 |

## **5. How many Vegetarian and Meatloaves were ordered by each customer?**
```sql
SELECT 
  customer_id,
  COUNT(CASE WHEN pizza_id = 1 THEN 1 END) AS meatlovers_ordered,
  COUNT(CASE WHEN pizza_id = 2 THEN 1 END) AS vegetarian_ordered
FROM customer_orders_cleaned
GROUP BY customer_id
ORDER BY customer_id;
```
| customer_id | meatlovers_ordered | vegetarian_ordered |
|-------------|--------------------|---------------------|
| 101         | 2                  | 1                   |
| 102         | 2                  | 1                   |
| 103         | 3                  | 1                   |
| 104         | 3                  | 0                   |
| 105         | 0                  | 1                   |

## **6. What was the maximum number of pizzas delivered in a single order?**
```sql
WITH pizzas_per_order AS (
  SELECT COUNT(*) AS pizza_count
  FROM customer_orders
  GROUP BY order_id
) 
SELECT MAX(pizza_count) AS max_pizzas_in_single_order
FROM pizzas_per_order;

```
| max_pizzas_in_single_order |
|-------------------------   |
| 3                          | 

## **7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```sql
SELECT 
  customer_id, 
  COUNT(CASE WHEN coc.exclusions_cleaned IS NOT NULL OR coc.extras_cleaned IS NOT NULL THEN 1 END) as total_pizzas_with_changes,
  COUNT(CASE WHEN coc.exclusions_cleaned IS NULL AND coc.extras_cleaned IS NULL THEN 1 END) as total_pizzas_no_changes
FROM customer_orders_cleaned coc
INNER JOIN runner_orders_cleaned roc USING(order_id)
WHERE roc.cancellation_cleaned IS NULL
GROUP BY customer_id;
```
| customer_id | total_pizzas_with_changes | total_pizzas_no_changes |
|-------------|---------------------------|-------------------------|
| 101         | 0                         | 2                       |
| 102         | 0                         | 3                       |
| 103         | 3                         | 0                       |
| 104         | 2                         | 1                       |
| 105         | 1                         | 0                       |

## **8. How many pizzas were delivered that had both exclusions and extras?**
```sql
SELECT 
 COUNT(CASE WHEN coc.exclusions_cleaned IS NOT NULL AND coc.extras_cleaned IS NOT NULL THEN 1 END) as total_pizzas_both_exclusions_extras
FROM customer_orders_cleaned coc
INNER JOIN runner_orders_cleaned roc USING(order_id)
WHERE roc.cancellation_cleaned IS NULL
```
| total_pizzas_both_exclusions_extras |
|-------------------------            |
| 1                                   | 

## **9. What was the total volume of pizzas ordered for each hour of the day?**
```sql
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
```
| hour | total_ordered |
|------|----------------|
| 0    | 0              |
| 1    | 0              |
| 2    | 0              |
| 3    | 0              |
| 4    | 0              |
| 5    | 0              |
| 6    | 0              |
| 7    | 0              |
| 8    | 0              |
| 9    | 0              |
| 10   | 0              |
| 11   | 1              |
| 12   | 0              |
| 13   | 3              |
| 14   | 0              |
| 15   | 0              |
| 16   | 0              |
| 17   | 0              |
| 18   | 3              |
| 19   | 1              |
| 20   | 0              |
| 21   | 3              |
| 22   | 0              |
| 23   | 3              |

## **10. What was the volume of orders for each day of the week?**
```sql
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
```
| day | total_ordered |
|-----|----------------|
| 0   | 0              |
| 1   | 0              |
| 2   | 0              |
| 3   | 5              |
| 4   | 3              |
| 5   | 1              |
| 6   | 5              |

# B. Runner and Customer Experience
## **5. What was the difference between the longest and shortest delivery times for all orders?**
```sql
SELECT MAX(duration) - MIN(duration) AS delivery_time_diff
FROM runner_orders_cleaned
```
| delivery_time_diff|
|-------------------|
| 30.00             |

## **1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**
```sql
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
```
| week | start_date          | end_date            | total_runners_signed_up |
|------|---------------------|---------------------|--------------------------|
| 1    | 2021-01-01          | 2021-01-07 00:00:00 | 2                        |
| 2    | 2021-01-08          | 2021-01-14 00:00:00 | 1                        |
| 3    | 2021-01-15          | 2021-01-21 00:00:00 | 1                        |
| 4    | 2021-01-22          | 2021-01-28 00:00:00 | 0                        |
| 5    | 2021-01-29          | 2021-02-04 00:00:00 | 0                        |

## **2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```sql
SELECT
  r.runner_id, 
  ROUND(AVG(EXTRACT(EPOCH FROM (r.pickup_time_cleaned::timestamp - c.order_time)) / 60)::numeric ,2) AS avg_minutes_diff
FROM customer_orders_cleaned c
LEFT JOIN runner_orders_cleaned r USING(order_id)
WHERE r.pickup_time_cleaned  IS NOT NULL AND r.cancellation_cleaned IS NULL
GROUP BY r.runner_id
```
| runner_id | avg_minutes_diff |
|-----------|------------------|
| 1         | 15.68            |
| 2         | 23.72            |
| 3         | 10.47            |






