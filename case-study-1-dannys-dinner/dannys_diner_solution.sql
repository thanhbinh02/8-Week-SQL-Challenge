/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) AS total_amount
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id

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

SELECT customer_id, SUM(total_items * price) AS total_amount
FROM cte
JOIN menu USING(product_id)
GROUP BY customer_id
ORDER BY customer_id

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH item_counts AS (
	SELECT
  		customer_id, 
		product_id, 
		COUNT(*) AS total_items
	FROM sales
  	GROUP BY customer_id, product_id
),
customer_points AS (
	SELECT 
		customer_id,
		CASE 
			WHEN product_name = 'sushi' THEN total_items * price * 20
			ELSE total_items * price * 10
		END AS points
	FROM item_counts
	JOIN menu USING(product_id)
)
SELECT 
	customer_id, 
	SUM(points) AS total_points
FROM customer_points
GROUP BY customer_id
ORDER BY customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
	-- JOIN members m USING(customer_id)
	-- WHERE m.join_date IS NOT NULL AND s.order_date >= m.join_date
WITH memberships AS (
	SELECT *
	FROM sales s
	JOIN members m USING(customer_id)
	WHERE m.join_date IS NOT NULL AND s.order_date >= m.join_date
),
memberships_order_in_promotion AS (
	SELECT
  		customer_id, 
		product_id, 
		COUNT(*) AS total_items
	FROM memberships
	WHERE order_date BETWEEN join_date AND join_date + INTERVAL '6 DAY' 
	  AND order_date < '2021-02-01'
	GROUP BY customer_id, product_id
),
memberships_order_not_in_promotion AS (
	SELECT
  		customer_id, 
		product_id, 
		COUNT(*) AS total_items
	FROM memberships
	WHERE order_date NOT BETWEEN join_date AND join_date + INTERVAL '6 DAY'  
	  AND order_date < '2021-02-01'
	GROUP BY customer_id, product_id
),
memberships_points AS (
	SELECT 
		customer_id,
		product_id,
		total_items * price * 20 AS points  
	FROM memberships_order_in_promotion
	JOIN menu USING(product_id)

	UNION ALL

	SELECT 
		customer_id,
		product_id,
		CASE 
			WHEN product_name = 'sushi' THEN total_items * price * 20
			ELSE total_items * price * 10
		END AS points
	FROM memberships_order_not_in_promotion
	JOIN menu USING(product_id)
)

SELECT 
	customer_id, 
	SUM(points) AS total_points
FROM memberships_points
GROUP BY customer_id
ORDER BY customer_id;

/* --------------------
   Bonus Questions
   --------------------*/
-- 1. Join All The Things
SELECT s.customer_id, s.order_date, m.product_name, m.price,
CASE
    WHEN order_date >= join_date THEN 'Y'
    ELSE 'N'
END AS member
FROM sales s
INNER JOIN menu m USING(product_id)
INNER JOIN members mb USING(customer_id)
ORDER BY s.customer_id, s.order_date

-- 2. Rank All The Things
WITH cte AS (
  SELECT 
    s.customer_id, 
    s.order_date, 
    me.product_name, 
    me.price,
    CASE
      WHEN s.order_date < m.join_date OR m.join_date IS NULL THEN 'N'
      ELSE 'Y'
    END AS member
  FROM sales s
  LEFT JOIN menu me USING (product_id)
  LEFT JOIN members m USING (customer_id)
)

SELECT *,
  CASE
    WHEN member = 'Y' THEN DENSE_RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date)
    WHEN member = 'N' THEN NULL
  END AS ranking
FROM cte;
