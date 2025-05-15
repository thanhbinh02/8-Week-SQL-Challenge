/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) AS total_amount
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS visited_days
FROM sales
GROUP BY customer_id

-- 3/ What was the first item from the menu purchased by each customer?
WITH cte AS (
	SELECT *,
 	DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) as rank
  	FROM sales
  	INNER JOIN menu USING(product_id)
)
SELECT customer_id, product_name
FROM cte
WHERE rank = 1
ORDER BY customer_id ASC, product_name ASC

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- Get customer and number by item most purchased
WITH cte1 AS (
	SELECT product_id, COUNT(*) as number_of_orders
  	FROM sales
  	GROUP BY product_id
),

cte2 AS (
	SELECT product_id, DENSE_RANK() OVER (ORDER BY number_of_orders DESC) AS rn
  	FROM cte1
)

SELECT customer_id, COUNT(*) top_item_order_count
FROM sales
WHERE product_id IN (SELECT product_id FROM cte2 WHERE rn = 1)
GROUP BY customer_id

-- The most purchased and how many times was it purchased by all customers
WITH cte AS (
	SELECT product_id, COUNT(*) AS orders_count
  	FROM sales
  	GROUP BY product_id
),
rank AS (
	SELECT product_id, orders_count,  DENSE_RANK() OVER (ORDER BY orders_count DESC) AS rn
  	FROM cte
)

SELECT m.product_name, rank.orders_count
FROM menu m
JOIN rank USING(product_id)
WHERE rank.rn = 1

-- 5. Which item was the most popular for each customer?
WITH cte AS (
	SELECT 
		customer_id, 
		product_id, 
		COUNT(*) AS total_purchases
	FROM sales
	GROUP BY customer_id, product_id
),

ranked AS (
	SELECT 
		customer_id, 
		product_id, 
		total_purchases,
		DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY total_purchases) AS rn
	FROM cte
)

SELECT ranked.customer_id, menu.product_name
FROM ranked
JOIN menu USING(product_id)
WHERE ranked.rn = 1
ORDER BY ranked.customer_id

-- 6. Which item was purchased first by the customer after they became a member? 
WITH cte AS (
	SELECT *
	FROM sales s
	JOIN members m USING(customer_id)
	WHERE m.join_date IS NOT NULL AND s.order_date >= m.join_date
),
rank AS (
	SELECT * , DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
  	FROM cte
)

SELECT customer_id, product_name
FROM rank
JOIN menu USING(product_id)
WHERE rn = 1
ORDER BY customer_id, product_name


-- 7. Which item was purchased just before the customer became a member?
WITH cte AS (
	SELECT *
	FROM sales s
	JOIN members m USING(customer_id)
	WHERE m.join_date IS NOT NULL AND s.order_date < m.join_date
),
rank AS (
	SELECT * , DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rn
  	FROM cte
)

SELECT customer_id, product_name
FROM rank
JOIN menu USING(product_id)
WHERE rn = 1
ORDER BY customer_id, product_name

-- 8. What is the total items and amount spent for each member before they became a member?
WITH cte AS (
	SELECT
  		customer_id, 
		product_id, 
		COUNT(*) AS total_items
	FROM sales s
	JOIN members m USING(customer_id)
	WHERE m.join_date IS NOT NULL AND s.order_date < m.join_date
  	GROUP BY customer_id, product_id
)

SELECT customer_id, product_name, total_items, (total_items * price) AS total_amount
FROM cte
JOIN menu USING(product_id)
ORDER BY customer_id, product_name

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?