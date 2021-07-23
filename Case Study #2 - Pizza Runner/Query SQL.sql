/* --------------------
   Case Study Questions
   --------------------*/

A. Pizza Metrics

-- 1. How many pizzas were ordered?

SELECT
  COUNT(pizza_id) AS pizza_orders
FROM pizza_runner.updated_customer_orders;

| pizza_orders |
| ------------ |
| 14           |

---

-- 2. How many unique customer orders were made?

SELECT
  COUNT(distinct order_id) AS unique_customer_orders
FROM pizza_runner.updated_customer_orders;

| unique_customer_orders |
| ---------------------- |
| 10                     |

---

-- 3. How many successful orders were delivered by each runner?

SELECT
  runner_id,
  COUNT(order_id) AS successful_orders
FROM pizza_runner.runner_orders
WHERE cancellation IS NULL
OR cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY runner_id
ORDER BY successful_orders DESC;

| runner_id | successful_orders |
| --------- | ----------------- |
| 1         | 4                 |
| 2         | 3                 |
| 3         | 1                 |

---

-- 4. How many of each type of pizza was delivered?

SELECT
  pn.pizza_name,
  COUNT(co.*) AS pizza_type_count
FROM pizza_runner.updated_customer_orders AS co
INNER JOIN pizza_runner.pizza_names AS pn
   ON co.pizza_id = pn.pizza_id
INNER JOIN pizza_runner.runner_orders AS ro
   ON co.order_id = ro.order_id
WHERE cancellation IS NULL
OR cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY pn.pizza_name
ORDER BY pn.pizza_name;

| pizza_name | pizza_type_count |
| ---------- | ---------------- |
| Meatlovers | 9                |
| Vegetarian | 3                |

---

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
  customer_id,
  SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS meat_lovers,
  SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS vegetarian
FROM pizza_runner.updated_customer_orders
GROUP BY customer_id;

| customer_id | meat_lovers | vegetarian |
| ----------- | ----------- | ---------- |
| 101         | 2           | 1          |
| 103         | 3           | 1          |
| 104         | 3           | 0          |
| 105         | 0           | 1          |
| 102         | 2           | 1          |

---

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT MAX(pizza_count) AS max_count
FROM (
SELECT
  co.order_id,
  COUNT(co.pizza_id) AS pizza_count
FROM pizza_runner.updated_customer_orders AS co
INNER JOIN pizza_runner.updated_runner_orders AS ro
  ON co.order_id = ro.order_id
WHERE 
  ro.cancellation IS NULL
  OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY co.order_id) AS mycount;

| max_count |
| --------- |
| 3         |

---

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
  co.customer_id,
  SUM (CASE WHEN co.exclusions IS NOT NULL OR co.extras IS NOT NULL THEN 1 ELSE 0 END) AS changes,
  SUM (CASE WHEN co.exclusions IS NULL OR co.extras IS NULL THEN 1 ELSE 0 END) AS no_change
FROM pizza_runner.updated_customer_orders AS co
INNER JOIN pizza_runner.updated_runner_orders AS ro
  ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
  OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY co.customer_id
ORDER BY co.customer_id;

| customer_id | changes | no_change |
| ----------- | ------- | --------- |
| 101         | 2       | 0         |
| 102         | 3       | 0         |
| 103         | 3       | 0         |
| 104         | 3       | 0         |
| 105         | 1       | 0         |

---

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT
  SUM(CASE WHEN co.exclusions IS NOT NULL 
      AND co.exclusions!=''
      AND co.extras IS NOT NULL 
      AND co.extras!=''
      THEN 1 ELSE 0 END) as pizza_count
FROM pizza_runner.customer_orders AS co
INNER JOIN pizza_runner.runner_orders AS ro
  ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
  OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation');

| pizza_count |
| ----------- |
| 5           |

---

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT
  DATE_PART('hour', order_time::TIMESTAMP) AS hour_of_day,
  COUNT(*) AS pizza_count
FROM pizza_runner.updated_customer_orders
WHERE order_time IS NOT NULL
GROUP BY hour_of_day
ORDER BY hour_of_day;

| hour_of_day | pizza_count |
| ----------- | ----------- |
| 11          | 1           |
| 13          | 3           |
| 18          | 3           |
| 19          | 1           |
| 21          | 3           |
| 23          | 3           |

---

-- 10. What was the volume of orders for each day of the week?

SELECT
  TO_CHAR(order_time, 'Day') AS day_of_week,
  COUNT(*) AS pizza_count
FROM pizza_runner.updated_customer_orders
GROUP BY 
  day_of_week, 
  DATE_PART('dow', order_time)
ORDER BY day_of_week;

| day_of_week | pizza_count |
| ----------- | ----------- |
| Friday      | 1           |
| Saturday    | 5           |
| Thursday    | 3           |
| Wednesday   | 5           |

---
