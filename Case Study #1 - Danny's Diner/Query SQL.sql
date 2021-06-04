/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT
    customer_id,
    SUM(price) AS total_amount
FROM dannys_diner.sales s 
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY customer_id;

| customer_id | total_amount |
| ----------- | ------------ |
| A           | 76           |
| B           | 74           |
| C           | 36           |

---

-- 2. How many days has each customer visited the restaurant?

SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS total_days_visited
FROM dannys_diner.sales s
GROUP BY customer_id
ORDER BY customer_id;

| customer_id | total_days_visited |
| ----------- | ------------------ |
| A           | 4                  |
| B           | 6                  |
| C           | 2                  |

---

-- 3. What was the first item from the menu purchased by each customer?

SELECT 
    t1.customer_id, 
    m.product_name
FROM
(SELECT 
     customer_id, 
     order_date, 
     product_id, 
     ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS row_no
FROM dannys_diner.sales) t1
INNER JOIN dannys_diner.menu m
ON t1.product_id = m.product_id
WHERE t1.row_no = 1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
    m.product_name, 
    COUNT(s.product_id) AS number_of_times_purchased
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY number_of_times_purchased DESC
LIMIT 1;

| product_name | number_of_times_purchased |
| ------------ | ------------------------- |
| ramen        | 8                         |

---

-- 5. Which item was the most popular for each customer?

SELECT 
    customer_id, 
    product_name
FROM
(SELECT 
     s.customer_id, 
     s.product_id, 
     m.product_name, 
     COUNT(s.product_id) AS count_of_product,
     RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rnk
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id, s.product_id, m.product_name) t1
WHERE rnk = 1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | ramen        |
| B           | sushi        |
| B           | curry        |
| C           | ramen        |

---

-- 6. Which item was purchased first by the customer after they became a member?

SELECT 
    customer_id, 
    product_name
FROM
(SELECT 
     s.customer_id, 
     s.order_date, 
     ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS row_no,
     mn.product_name
FROM dannys_diner.sales s
INNER JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
INNER JOIN dannys_diner.menu mn
ON s.product_id = mn.product_id
WHERE s.order_date >= m.join_date) t1
WHERE row_no = 1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| B           | sushi        |

---

-- 7. Which item was purchased just before the customer became a member?

SELECT 
    customer_id, 
    product_name
FROM
(SELECT 
     s.customer_id, 
     s.order_date,  
     mn.product_name,
     RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
FROM dannys_diner.sales s
INNER JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
INNER JOIN dannys_diner.menu mn
ON s.product_id = mn.product_id
WHERE s.order_date < m.join_date) t1
where rnk = 1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | sushi        |

---

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
    s.customer_id, 
    COUNT(s.product_id) AS total_items,
    SUM(m.price) AS amount_spent
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
INNER JOIN dannys_diner.members mb
ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

| customer_id | total_items | amount_spent |
| ----------- | ----------- | ------------ |
| A           | 2           | 25           |
| B           | 3           | 40           |

---

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
    customer_id, 
    SUM(points) as points
FROM
(SELECT 
     customer_id,
     CASE WHEN product_name = 'sushi' THEN SUM(price)*10*2 ELSE SUM(price)*10 END AS points
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY customer_id, product_name) t1
GROUP BY customer_id
ORDER BY customer_id;

| customer_id | points |
| ----------- | ------ |
| A           | 860    |
| B           | 940    |
| C           | 360    |

---

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT 
    s.customer_id,
    SUM(CASE 
           WHEN product_name = 'sushi' THEN price*10*2
           WHEN order_date BETWEEN join_date AND join_date+7 THEN price*10*2
           ELSE price*10 
           END) AS points
FROM dannys_diner.sales s
INNER JOIN dannys_diner.members mb
ON s.customer_id = mb.customer_id
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
WHERE order_date < '2021-02-01'
GROUP BY s.customer_id;

| customer_id | points |
| ----------- | ------ |
| A           | 1370   |
| B           | 940    |

---

-- Bonus Question 1: Join All The Things

SELECT 
    s.customer_id, 
    s.order_date, 
    m.product_name, 
    m.price,
    CASE WHEN s.order_date < mb.join_date OR mb.join_date IS NULL THEN 'N' ELSE 'Y' END AS member
FROM dannys_diner.sales s
LEFT JOIN dannys_diner.menu m
ON s.product_id = m.product_id
LEFT JOIN dannys_diner.members mb
ON s.customer_id = mb.customer_id
ORDER BY s.customer_id, s.order_date, m.price DESC;

| customer_id | order_date               | product_name | price | member |
| ----------- | ------------------------ | ------------ | ----- | ------ |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |

---

-- Bonus Question 2: Rank All The Things

SELECT 
    *,
    CASE WHEN member = 'N' THEN NULL ELSE RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date) END AS ranking
FROM
(SELECT 
     s.customer_id, 
     s.order_date, 
     m.product_name, 
     m.price,
     CASE WHEN s.order_date < mb.join_date OR mb.join_date IS NULL THEN 'N' ELSE 'Y' END AS member
FROM dannys_diner.sales s
LEFT JOIN dannys_diner.menu m
ON s.product_id = m.product_id
LEFT JOIN dannys_diner.members mb
ON s.customer_id = mb.customer_id
ORDER BY s.customer_id, s.order_date, m.price desc) t1;

| customer_id | order_date               | product_name | price | member | ranking |
| ----------- | ------------------------ | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      | null    |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      | null    |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      | 1       |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      | null    |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      | null    |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      | null    |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      | null    |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      | null    |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      | null    |

---
