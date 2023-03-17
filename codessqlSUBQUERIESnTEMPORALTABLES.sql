-- Your First Subquery
-- We want to find the average number of events for each day for each channel.

-- We want to find the average number of events for each day for each channel
SELECT channel, AVG(cnt)
FROM
(SELECT DATE_TRUNC('day', occurred_at) Date_time, channel, COUNT(*) cnt
FROM web_events
GROUP BY 1, 2) sub
GROUP BY 1


-- SUBQUERY FOLLOWING A WHERE STATEMENT

-- use DATE_TRUNC to pull "month" level information about the first order ever
-- placed in the orders table
SELECT DATE_TRUNC('month', MIN(occurred_at))
FROM orders

-- Use the result of the previous query to find only the orders that took place
-- in the same month and year as the first order, and then pull the average for
-- each type of paper "qty" in this month

SELECT SUM(standard_qty)/COUNT(standard_qty) Avg_std_qty,
       SUM(gloss_qty)/COUNT(gloss_qty) Avg_gloss_qty,
       SUM(poster_qty)/COUNT(poster_qty) Avg_poster_qty,
       SUM(total_amt_usd) total_spent
FROM  orders
WHERE DATE_TRUNC('month', occurred_at) =
(
SELECT DATE_TRUNC('month', MIN(occurred_at)) month_time
FROM orders
)

SELECT AVG(standard_qty) std_qty,
        AVG(gloss_qty) gloss_qty, AVG(poster_qty) poster_qty
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
(
SELECT DATE_TRUNC('month', MIN(occurred_at)) month_time
FROM orders
)

-- 9. QUIZ: SUBQUERY MANIA

-- 1 Provide the name of the sales_rep in each region with the
-- largest amount of total_amt_usd sales.
SELECT *

FROM ( SELECT reg, MAX(SUM_USD) max_tot
       FROM

(
SELECT SUM(orders.total_amt_usd) SUM_USD, region.name reg, sales_reps.name salesrep
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
GROUP BY 2, 3
ORDER BY 1 DESC
) table_1

GROUP BY 1
)table_2

JOIN

(
  SELECT SUM(orders.total_amt_usd) SUM_USD, region.name reg, sales_reps.name salesrep
  FROM orders
  JOIN accounts
  ON orders.account_id = accounts.id
  JOIN sales_reps
  ON accounts.sales_rep_id = sales_reps.id
  JOIN region
  ON sales_reps.region_id = region.id
  GROUP BY 2, 3
  ORDER BY 1 DESC
) table_3

ON table_2.reg = table_3.reg AND table_2.max_tot = table_3.SUM_USD
ORDER BY max_tot DESC

-- 2. For the region with the largest (sum) of sales total_amt_usd,
-- how many total (count) orders were placed?
SELECT *

FROM ( SELECT reg, MAX(SUM_USD) max_tot, SUM(cnt_total)
       FROM

(
SELECT  SUM(orders.total_amt_usd) SUM_USD, region.name reg,
        COUNT(orders.total) cnt_total
FROM    orders
JOIN    accounts
ON orders.account_id = accounts.id
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
GROUP BY 2
ORDER BY 1 DESC
) table_1

GROUP BY 1
)table_2
ORDER BY max_tot DESC
LIMIT 1

-- their solution
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);


-- 3. How many accounts had more total purchases than the account name which
-- has bought the most standard_qty paper throughout their lifetime as a customer?

-- WRONG SOLUTION BUT GOOD ATTEMPT

-- SELECT accounts.name acct_name, SUM(total) sum_tot
-- -- SELECT COUNT(accounts.name)
-- FROM orders
-- JOIN accounts
-- ON      accounts.id = orders.account_id
-- GROUP BY 1
-- HAVING SUM(total) >
--
-- (SELECT MAX(sum_std_qty)
-- FROM (
-- SELECT  SUM(total) sum_tot, SUM(standard_qty) sum_std_qty, accounts.name acc_name
-- FROM    orders
-- JOIN    accounts
-- ON      accounts.id = orders.account_id
-- GROUP BY 3
-- )sub2
-- )

SELECT COUNT(*)
FROM (SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)
             ) counter_tab;

-- 4. For the customer that spent the most (in total over their lifetime as a
-- customer) total_amt_usd, how many web_events did they have for each channel?


-- QUICK FIX SOLUTION
SELECT channel, accounts.name, COUNT(channel)
FROM accounts
-- JOIN orders
-- ON accounts.id = orders.account_id
JOIN web_events
ON accounts.id = web_events.account_id
WHERE accounts.name = 'EOG Resources'
GROUP BY 1, 2
ORDER BY 3
-- END




SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;


-- upgraded solution
-- ADDING A TABLE THAT YOU DO NOT NEED WILL KILL RESULTS, SEE THE COMMENTS
SELECT channel, accounts.name, COUNT(channel)

FROM accounts
-- JOIN orders
-- ON accounts.id = orders.account_id
JOIN web_events
ON accounts.id = web_events.account_id
WHERE name =
(
SELECT name
FROM
(
SELECT accounts.name, SUM(orders.total_amt_usd)
FROM orders
JOIN accounts
ON accounts.id = orders.account_id
-- JOIN web_events
-- ON accounts.id = web_events.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1
) most_spent

)
GROUP BY 1,2
ORDER BY 3 DESC



-- 5. What is the lifetime average amount spent in terms of total_amt_usd for
-- the top 10 total spending accounts?

-- MISINTERPRETED SELF SOLUTION
SELECT accounts.name, AVG(orders.total_amt_usd)
FROM orders
JOIN accounts
ON accounts.id = orders.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- THEIR SOLUTION
SELECT AVG(tot_spent)
FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
       LIMIT 10) temp;


-- 6. What is the lifetime average amount spent in terms of total_amt_usd,
-- including only the companies that spent more per order, on average,
-- than the average of all orders.

-- THEIR SOLUTION
SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;

-- QUIZ: WITH
-- same questionS as above.

-- 1.
WITH table_1 AS
(
SELECT SUM(orders.total_amt_usd) SUM_USD, region.name reg, sales_reps.name salesrep
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
GROUP BY 2, 3
ORDER BY 1 DESC
),

table_2 AS
( SELECT reg, MAX(SUM_USD) max_tot
       FROM table_1
       GROUP BY 1),

table_3 AS (
  SELECT SUM(orders.total_amt_usd) SUM_USD, region.name reg, sales_reps.name salesrep
  FROM orders
  JOIN accounts
  ON orders.account_id = accounts.id
  JOIN sales_reps
  ON accounts.sales_rep_id = sales_reps.id
  JOIN region
  ON sales_reps.region_id = region.id
  GROUP BY 2, 3
  ORDER BY 1 DESC
)

SELECT *
FROM table_2

JOIN table_3

ON table_2.reg = table_3.reg AND table_2.max_tot = table_3.SUM_USD
ORDER BY max_tot DESC

-- 2
WITH table_1 AS (
SELECT  SUM(orders.total_amt_usd) SUM_USD, region.name reg,
        COUNT(orders.total) cnt_total
FROM    orders
JOIN    accounts
ON orders.account_id = accounts.id
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
GROUP BY 2
ORDER BY 1 DESC
),

table_2 AS ( SELECT reg, MAX(SUM_USD) max_tot, SUM(cnt_total)
       FROM table_1
       GROUP BY 1
)



SELECT *
FROM table_2
ORDER BY max_tot DESC
LIMIT 1

-- their solution edited to WITH statement

WITH sub AS (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
        FROM sales_reps s
        JOIN accounts a
        ON a.sales_rep_id = s.id
        JOIN orders o
        ON o.account_id = a.id
        JOIN region r
        ON r.id = s.region_id
        GROUP BY r.name)

SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM  sub);

-- ACTUAL SOLUTION
WITH t1 AS (
   SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name),
t2 AS (
   SELECT MAX(total_amt)
   FROM t1)
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);


-- 3.

WITH inner_tab AS (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
      FROM accounts a
      JOIN orders o
      ON o.account_id = a.id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 1),
      counter_tab AS (SELECT a.name
             FROM orders o
             JOIN accounts a
             ON a.id = o.account_id
             GROUP BY 1
             HAVING SUM(o.total) > (SELECT total
                         FROM  inner_tab)
                   )

SELECT COUNT(*)
FROM counter_tab;

-- 4.

WITH inner_table AS (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
      LIMIT 1)

SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 5.
WITH temp AS (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
       LIMIT 10)


SELECT AVG(tot_spent)
FROM  temp;

-- 6.
WITH temp_table AS (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o))


SELECT AVG(avg_amt)
FROM  temp_table;
