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
