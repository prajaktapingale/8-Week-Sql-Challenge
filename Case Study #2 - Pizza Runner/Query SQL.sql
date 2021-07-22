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










What was the maximum number of pizzas delivered in a single order?
For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
How many pizzas were delivered that had both exclusions and extras?
What was the total volume of pizzas ordered for each hour of the day?
What was the volume of orders for each day of the week?
