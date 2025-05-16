# Case Study #1- Danny's Diner
## **1. What is the total amount each customer spent at the restaurant?**

```sql
SELECT s.customer_id, SUM(m.price) AS total_amount
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
```
| customer_id | amount |
|-------------|--------|
| A           | 76     |
| B           | 74     |
| C           | 36     |

- **Customer A** is the highest spender at Danny's restaurant, with a total of `$76.00`
- **Customer B** who spend `$74.00`
- **Customer C** spends the least, at `$36.00`

## **2. How many days has each customer visited the restaurant?**

```sql
SELECT customer_id, COUNT(DISTINCT order_date) AS visited_days
FROM sales
GROUP BY customer_id;
```

| customer_id | visited_days |
|-------------|--------------|
| A           | 4            |
| B           | 6            |
| C           | 2            |

- **Customer A** visited `4 days`
- **Customer B** visited the most i.e., `6 days`
- **Customer C** visited the least of `2 days`
 
## **3. What was the first item from the menu purchased by each customer?**
```sql
WITH cte AS (
	SELECT *,
 	DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) as rank
  	FROM sales
  	INNER JOIN menu USING(product_id)
)
SELECT customer_id, product_name
FROM cte
WHERE rank = 1
ORDER BY customer_id ASC, product_name ASC;
```

| customer_id | product_name |
|-------------|--------------|
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

- **Customer A** ordered `sushi` and `curry`
- **Customer B** ordered `curry`
- **Customer C** ordered `ramen`
increase sales.

## **4. What is the most purchased item on the menu and how many times was it purchased by all customers? Get customer and number by item most purchased?**

```sql
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
```
| product_name| orders_count |
|-------------|--------------|
| ramen       | 8            |
- `Ramen` is the most demanding dish in the Danny's menu. It was ordered `8 times`

## **5. Which item was the most popular for each customer?**
```sql
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
```
| customer_id | product_name |
|-------------|--------------|
| A           | sushi       |
| B           | sushi       |
| B           | curry       |
| B           | ramen       |
| C           | ramen       |

- **Customer A** likes `sushi` the most
- **Customer B** likes all 3 dishes: `sushi`, `curry` and `ramen`
- **Customer C** likes `ramen` the most

## **6. Which item was purchased first by the customer after they became a member?**
### **Assumption**
_I retrieved the list of orders after the join date._

```sql
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
```
| customer_id | product_name|
|-------------|-------------|
| A           | curry       |
| B           | sushi       |

- **Customer A** ordered `curry` and **Customer B** ordered `sushi` after they joined the membership

## **7. Which item was purchased just before the customer became a member?**
### **Assumption**
_I retrieved the list of orders before the join date._
```sql
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
```
| customer_id | product_name|
|-------------|-------------|
| A           | curry       |
| A           | sushi       |
| B           | sushi       |

- **Customer A** and **Customer B** ordered `sushi` just before they became members
- While **Customer A** also ordered `curry`

## **8. What is the total items and amount spent for each member before they became a member?**
### **Assumption**
_Included only those customers who converted to members_
```sql
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
```
| customer_id | total_amount|
|-------------|-------------|
| A           | 25          |
| B           | 40         |
- **Customer A** spend `$25.00`and **Customer B** spend `$40.00`  just before they become the members

## **9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```sql
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
```

| customer_id | total_points |
|-------------|--------------|
| A           | 860          |
| B           | 940          |
| C           | 360          |

- **Customer A** has total `860 points`
- **Customer B** has maximum of all that is `940 points`
- **Customer C** has least points that is `360 points`

## **10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
```sql
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
```
| customer_id | total_points |
|-------------|--------------|
| A           | 1020          |
| B           | 320          |
- **Customer A** took the most advantage of the offer and earned `1020 points`
- Total points for **Customer B** is `320 points`
