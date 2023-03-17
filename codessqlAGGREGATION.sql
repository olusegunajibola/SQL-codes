-- QUIZ SUM

-- Find the total amount of poster_qty paper ordered in the orders table.
SELECT SUM(poster_qty)
FROM orders

-- 4. Find the total amount spent on standard_amt_usd and gloss_amt_usd paper
-- for each order in the orders table. This should give a dollar amount for
-- each order in the table.
SELECT standard_amt_usd + gloss_amt_usd AS total_standard_gloss
FROM orders;

-- Find the standard_amt_usd per unit of standard_qty paper.
-- Your solution should use both an aggregation and a mathematical operator.
SELECT SUM(standard_amt_usd)/SUM(standard_qty) usdperUnit
FROM orders

-- Questions: MIN, MAX, & AVERAGE
-- 1. When was the earliest order ever placed? You only need to return the date.
SELECT  MIN(occurred_at)
FROM orders

-- 2. Try performing the same query as in question 1 without using an aggregation function.

SELECT orders.occurred_at
FROM orders
-- WHERE orders.occurred_at <= '2014-01-01'
ORDER BY occurred_at
LIMIT 1

-- 3. When did the most recent (latest) web_event occur?
SELECT  MAX(occurred_at)
FROM web_events

-- 4. Try to perform the result of the previous query without using an
-- aggregation function.
SELECT web_events.occurred_at
FROM web_events
-- WHERE web_events.occurred_at <= '2014-01-01'
ORDER BY occurred_at DESC
LIMIT 1

-- 5. Find the mean (AVERAGE) amount spent per order on each paper type,
-- as well as the mean amount of each paper type purchased per order.
-- Your final answer should have 6 values - one for each paper type for the
-- average number of sales, as well as the average amount.
SELECT AVG(standard_qty) standard_qty_avg, AVG(standard_amt_usd) standard_amt_usd_avg,
AVG(poster_qty) poster_qty_avg, AVG(poster_amt_usd) poster_amt_usd_avg,
AVG(gloss_qty) gloss_qty_avg, AVG(gloss_amt_usd) gloss_amt_usd_avg
FROM orders

-- 6. Via the video, you might be interested in how to calculate the MEDIAN.
-- Though this is more advanced than what we have covered so far try finding
-- - what is the MEDIAN total_usd spent on all orders?
SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2
-- The nested loop gives the top half of the table sorted by "total_amt_usd".
-- ORDER BY reaarranges the loop from gratest to the smallest
-- LIMIT 2: picks the top 2 values that can be divided into 2 to derive the median
SELECT COUNT(total_amt_usd)/2 AS cnt
FROM orders
-- the code above shows the likely index of the median

-- GROUP BY QUIZ
-- 1. Which account (by name) placed the earliest order? Your solution should have
-- the account name and the date of the order.
SELECT accounts.name, orders.occurred_at
FROM orders
JOIN accounts
ON accounts.id = orders.account_id
ORDER BY orders.occurred_at
LIMIT 1

-- 2. Find the total sales in usd for each account.
-- You should include two columns - the total sales for each company's
-- orders in usd and the company name.

-- SELECT accounts.name, orders.total_amt_usd
-- FROM orders
-- JOIN accounts
-- ON accounts.id = orders.account_id
-- ORDER BY total_amt_usd DESC
SELECT a.name, SUM(total_amt_usd) total_sales
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_sales

-- 3. Via what channel did the most recent (latest) web_event occur,
-- which account was associated with this web_event? Your query
-- should return only three values - the date, channel, and account name
SELECT web_events.occurred_at, web_events.channel, accounts.name
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
ORDER BY occurred_at

-- 4. Find the total number of times each type of channel from the web_events
-- was used. Your final table should have two columns -
-- the channel and the number of times the channel was used.
SELECT COUNT(web_events.channel) CNT, web_events.channel
FROM web_events
GROUP BY web_events.channel
ORDER BY CNT

-- 5. Who was the primary contact associated with the earliest web_event?
SELECT web_events.occurred_at,  accounts.primary_poc
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
ORDER BY occurred_at
LIMIT 1

SELECT a.primary_poc
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;

-- 6. What was the smallest order placed by each account in terms of total usd.
-- Provide only two columns - the account name and the total usd.
-- Order from smallest dollar amounts to largest.

-- SELECT accounts.name, orders.total_amt_usd
-- FROM orders
-- JOIN accounts
-- ON accounts.id = orders.account_id
-- --WHERE total_amt_usd = 0
-- ORDER BY total_amt_usd
SELECT a.name, MIN(total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;

-- 7. Find the number of sales reps in each region. Your final table should have
-- two columns - the region and the number of sales_reps.
-- Order from fewest reps to most reps.
SELECT COUNT(sales_reps.region_id) CNTsales_rep, region.name
FROM sales_reps
JOIN region
ON sales_reps.region_id = region.id
GROUP BY region.name
ORDER BY CNTsales_rep


-- QUIZ: GROUP BY part 2

-- 1. For each account, determine the average amount of each type of paper they
-- purchased across their orders. Your result should have four columns - one for
-- the account name and one for the average quantity purchased for each of
-- the paper types for each account.
SELECT accounts.name, AVG(standard_qty) standard_qty_avg,
AVG(poster_qty) poster_qty_avg, AVG(gloss_qty) gloss_qty_avg
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY accounts.name


-- 2. For each account, determine the average amount spent per order on each
-- paper type. Your result should have four columns - one for the account name
-- and one for the average amount spent on each paper type.
SELECT accounts.name, AVG(standard_amt_usd) standard_usd_avg,
AVG(poster_amt_usd) poster_usd_avg, AVG(gloss_amt_usd) gloss_usd_avg
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY accounts.name

-- 3. Determine the number of times a particular channel was used in the
-- web_events table for each sales rep. Your final table should have three
-- columns - the name of the sales rep, the channel, and the number of
-- occurrences. Order your table with the highest number of occurrences first.
SELECT COUNT(web_events.channel), sales_reps.name, web_events.channel
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
GROUP BY sales_reps.name, web_events.channel
ORDER BY count DESC


-- 4. Determine the number of times a particular channel was used in the
-- web_events table for each region. Your final table should have three columns
-- - the region name, the channel, and the number of occurrences.
-- Order your table with the highest number of occurrences first.
SELECT COUNT(web_events.channel), region.name, web_events.channel
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
GROUP BY region.name, web_events.channel
ORDER BY count DESC

-- DISTINCT
-- 1. Use DISTINCT to test if there are any accounts associated with more
-- than one region.

-- solution 1
SELECT DISTINCT accounts.name acctname, region.name region
FROM accounts
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
ORDER BY acctname
-- solution 2
SELECT DISTINCT accounts.name acctname, COUNT(region.name) AS cnt
FROM accounts
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
GROUP BY acctname
ORDER BY cnt DESC
-- solution 3
SELECT DISTINCT accounts.name acctname, COUNT(region.name) AS cnt
FROM accounts
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
GROUP BY acctname
HAVING COUNT(region.name) > 1

-- 2. Have any sales reps worked on more than one account?
SELECT DISTINCT COUNT(accounts.name) AS cnt, sales_reps.name as salesperson
FROM accounts
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
GROUP BY salesperson
ORDER BY cnt DESC

-- HAVING
-- 1. How many of the sales reps have more than 5 accounts that they manage?
SELECT COUNT(accounts.id), sales_reps.name
FROM accounts
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
GROUP BY sales_reps.name
HAVING  COUNT(accounts.id) > 5
ORDER BY count DESC
-- THEIR solution
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;


-- 2. How many accounts have more than 20 orders?
SELECT COUNT(orders.id), accounts.name
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY accounts.name
HAVING  COUNT(orders.id) > 20

-- 3. Which account has the most orders?
SELECT COUNT(orders.id), accounts.name
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY accounts.name
HAVING  COUNT(orders.id) > 20
ORDER BY count DESC
LIMIT 1

-- 4. Which accounts spent more than 30,000 usd total across all orders?
SELECT SUM(orders.total_amt_usd), accounts.name
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY accounts.name
HAVING  SUM(orders.total_amt_usd) > 30000
ORDER BY SUM DESC

-- 5. Which accounts spent less than 1,000 usd total across all orders?
SELECT SUM(orders.total_amt_usd), accounts.name
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY accounts.name
HAVING  SUM(orders.total_amt_usd) < 1000
ORDER BY SUM DESC

-- 6. Which account has spent the most with us?
SELECT SUM(orders.total_amt_usd), accounts.name
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY accounts.name
HAVING  SUM(orders.total_amt_usd) > 30000
ORDER BY SUM DESC
LIMIT 1

-- 7. Which account has spent the least with us?
SELECT SUM(orders.total_amt_usd), accounts.name
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY accounts.name
HAVING  SUM(orders.total_amt_usd) < 1000
ORDER BY SUM
LIMIT 1

-- 8. Which accounts used facebook as a channel to contact customers more
-- than 6 times?

SELECT accounts.name, COUNT(web_events.channel)
FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id
GROUP BY accounts.name, web_events.channel
HAVING web_events.channel = 'facebook' AND COUNT(web_events.channel) > 6
ORDER BY count
-- their solution
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6 AND w.channel = 'facebook'
ORDER BY use_of_channel;

-- 9. Which account used facebook most as a channel?
SELECT accounts.name, COUNT(web_events.channel)
FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id
WHERE web_events.channel = 'facebook'
GROUP BY accounts.name
ORDER BY count DESC
LIMIT 1

-- 10. Which channel was most frequently used by most accounts?
SELECT accounts.name, COUNT(web_events.channel), web_events.channel
FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id
GROUP BY accounts.name, web_events.channel
ORDER BY count DESC

-- DATE functionS

-- 1.Find the sales in terms of total dollars for all orders in each year,
-- ordered from greatest to least. Do you notice any trends in the
-- yearly sales totals?
SELECT SUM(total_amt_usd), DATE_TRUNC('year', occurred_at)
FROM orders
GROUP BY 2
ORDER BY 1 DESC


-- 2. Which month did Parch & Posey have the greatest sales in terms of
-- total dollars? Are all months evenly represented by the dataset?
SELECT SUM(total_amt_usd), DATE_PART('month', occurred_at)
FROM orders
GROUP BY 2
ORDER BY 1 DESC
-- their solution
SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Which year did Parch & Posey have the greatest sales in terms of total
-- number of orders? Are all years evenly represented by the dataset?
SELECT SUM(total), DATE_PART('year', occurred_at)
FROM orders
GROUP BY 2
ORDER BY 1 DESC

-- 4. Which month did Parch & Posey have the greatest sales in terms of total
-- number of orders? Are all months evenly represented by the dataset?
SELECT SUM(total), DATE_PART('month', occurred_at)
FROM orders
GROUP BY 2
ORDER BY 1 DESC

-- 5. In which month of which year did Walmart spend the most on gloss paper
-- in terms of dollars?
SELECT SUM(orders.gloss_amt_usd), DATE_TRUNC('month', orders.occurred_at),
accounts.name
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
WHERE accounts.name = 'Walmart'
GROUP BY 2, 3
ORDER BY 1 DESC

-- CASE QUIZ

-- 1. Write a query to display for each order, the account ID, total amount of
-- the order, and the level of the order - ‘Large’ or ’Small’ - depending on
-- if the order is $3000 or more, or smaller than $3000.

SELECT accounts.name, accounts.id, orders.total_amt_usd,
CASE WHEN orders.total_amt_usd >= 3000 THEN 'Large'
    ELSE 'Small' END AS order_size
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
GROUP BY 1, 2, 3

-- SELECT
-- CASE WHEN total >= 3000 THEN 'Large'
-- ELSE 'Small' END AS order_size, COUNT(*) catgory
-- FROM orders
-- GROUP BY 1
-- ORDER BY SUM(total)

-- 2. Write a query to display the number of orders in each of three categories,
-- based on the total number of items in each order. The three categories are:
-- 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.

-- WRONG SOLUTION
-- SELECT
-- CASE WHEN SUM(total) >= 2000 THEN 'At Least 2000'
-- WHEN SUM(total) >= 1000 AND SUM(total) < 2000 THEN 'Between 1000 and 2000'
-- ELSE 'Less than 1000' END AS order_category
-- FROM orders
-- GROUP BY 1
-- WRONG SOLUTION

SELECT
CASE WHEN total >= 2000 THEN 'At Least 2000'
WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
ELSE 'Less than 1000' END AS order_category, COUNT(*)  order_cnt
FROM orders
GROUP BY 1

-- 3. We would like to understand 3 different levels of customers based on the
-- amount associated with their purchases. The top level includes anyone with
-- a Lifetime Value (total sales of all orders) greater than 200,000 usd.
-- The second level is between 200,000 and 100,000 usd.
-- The lowest level is anyone under 100,000 usd.
-- Provide a table that includes the level associated with each account.
-- You should provide the account name, the total sales of all orders
-- for the customer, and the level. Order with the top spending customers listed first.

SELECT accounts.name, SUM(orders.total_amt_usd),
CASE WHEN SUM(total_amt_usd) > 200000 THEN 'greater than 200,000 usd'
WHEN SUM(total_amt_usd) > 100000 AND SUM(total_amt_usd) <= 200000 THEN 'between 200,000 and 100,000 usd'
ELSE 'under 100,000 usd' END AS level
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
GROUP BY 1
ORDER BY sum DESC

-- 4. We would now like to perform a similar calculation to the first,
-- but we want to obtain the total amount spent by customers only
-- in 2016 and 2017. Keep the same levels as in the previous question.
-- Order with the top spending customers listed first.

-- WRONG
-- SELECT accounts.name, SUM(orders.total_amt_usd), DATE_PART('year', occurred_at) AS year_only,
-- CASE WHEN SUM(total_amt_usd) >= 200000 THEN 'greater than 200,000 usd'
-- WHEN SUM(total_amt_usd) >= 100000 AND SUM(total_amt_usd) < 200000 THEN 'between 200,000 and 100,000 usd'
-- ELSE 'under 100,000 usd' END AS level
-- FROM orders
-- JOIN accounts
-- ON orders.account_id = accounts.id
-- WHERE occurred_at >= '2016-01-01' AND  occurred_at <= '2018-01-01'
-- GROUP BY 1, 3
-- ORDER BY name DESC

SELECT accounts.name, SUM(orders.total_amt_usd),
CASE WHEN SUM(total_amt_usd) > 200000 THEN 'greater than 200,000 usd'
WHEN SUM(total_amt_usd) > 100000 THEN 'between 200,000 and 100,000 usd'
ELSE 'under 100,000 usd' END AS level
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
WHERE occurred_at > '2015-12-31'
GROUP BY 1
ORDER BY name DESC

-- 5. We would like to identify top performing sales reps, which are sales reps
-- associated with more than 200 orders. Create a table with the sales rep name,
-- the total number of orders, and a column with top or not depending on if
-- they have more than 200 orders. Place the top sales people first in your final table.

-- SELECT sales_reps.name, SUM(orders.total),
-- CASE WHEN SUM(orders.total) > 200 THEN 'top'
--      ELSE 'not' END AS level
-- FROM sales_reps
-- JOIN accounts
-- ON accounts.sales_rep_id = sales_reps.id
-- JOIN orders
-- ON orders.account_id = accounts.id
-- GROUP BY 1
-- ORDER BY sum DESC

SELECT sales_reps.name, COUNT(orders.total),
CASE WHEN COUNT(orders.total) > 200 THEN 'top'
     ELSE 'not' END AS level
FROM sales_reps
JOIN accounts
ON accounts.sales_rep_id = sales_reps.id
JOIN orders
ON orders.account_id = accounts.id
GROUP BY 1
ORDER BY 2 DESC

-- their SOLUTION
SELECT s.name, COUNT(*) num_ords,
     CASE WHEN COUNT(*) > 200 THEN 'top'
     ELSE 'not' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 2 DESC;

-- 6. The previous didn't account for the middle, nor the dollar amount
-- associated with the sales. Management decides they want to see these
-- characteristics represented as well. We would like to identify top
-- performing sales reps, which are sales reps associated with
-- more than 200 orders or more than 750000 in total sales.
-- The middle group has any rep with more than 150 orders or 500000 in sales.
-- Create a table with the sales rep name, the total number of orders,
-- total sales across all orders, and a column with top, middle, or low
-- depending on this criteria. Place the top sales people based on dollar
-- amount of sales first in your final table. You might see a few upset sales
-- people by this criteria!



SELECT sales_reps.name, COUNT(orders.total),
SUM(orders.total_amt_usd) total_usd_sum,
CASE WHEN COUNT(orders.total) > 200 OR SUM(orders.total_amt_usd) > 750000 THEN 'top'
     WHEN COUNT(orders.total) > 150 OR SUM(orders.total_amt_usd) > 500000 THEN 'middle'
     ELSE 'low' END AS level
FROM sales_reps
JOIN accounts
ON accounts.sales_rep_id = sales_reps.id
JOIN orders
ON orders.account_id = accounts.id
GROUP BY 1
ORDER BY total_usd_sum DESC

-- THEIR solution

SELECT s.name, COUNT(*), SUM(o.total_amt_usd) total_spent,
     CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
     WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
     ELSE 'low' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC;
