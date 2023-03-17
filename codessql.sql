-- CTRL + "/" for comments

SELECT
FROM
WHERE
LIMIT
ORDER BY ____ DESC


SELECT
FROM
JOIN
ON
WHERE



# practice
-- # 1. ten earliest orders
SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY occurred_at
LIMIT 10


-- 2. top 5 orders in terms of total_amt_usd
SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5


-- lowest 20 orders
SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY total_amt_usd
LIMIT 20

-- ORDER BY Part II
# 1
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC

#2
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id
-- QUIZ WHERE
SELECT id, gloss_amt_usd
FROM orders
WHERE gloss_amt_usd >= 1000
LIMIT 5

SELECT id, total_amt_usd
FROM orders
WHERE total_amt_usd <500
LIMIT 10

-- #Practice Question Using WHERE with Non-Numeric Data
SELECT name, website, primary_poc
FROM accounts
WHERE name = 'Exxon Mobil';

 -- Questions using Arithmetic Operations
 select id, account_id, (standard_amt_usd/standard_qty) AS unit_price
from orders
LIMIT 10

select id, account_id, poster_amt_usd/(standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS poster_pct
from orders
LIMIT 10

-- Questions using the LIKE operator
-- Use the accounts table to find
SELECT name
FROM accounts
-- WHERE name LIKE 'C%' --All the companies whose names start with 'C'.
-- WHERE name LIKE '%one%' --All companies whose names contain the string 'one' somewhere in the name.
WHERE name LIKE '%s' --All companies whose names end with 's'.


-- Questions using IN operator
-- Use the accounts table to find the account name,
-- primary_poc, and sales_rep_id for Walmart, Target, and Nordstrom.

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name in ('Walmart','Target', 'Nordstrom')

-- Use the web_events table to find all information regarding
-- individuals who were contacted via the channel of organic or adwords.

SELECT *
FROM web_events
WHERE channel in ('organic','adwords')
ORDER BY channel

-- Questions using the NOT operator
-- We can pull all of the rows that were excluded from
-- the queries in the previous two concepts with our new operator.

-- Use the accounts table to find the account name, primary poc, and sales rep id for all stores except Walmart, Target, and Nordstrom.
SELECT id, primary_poc, sales_rep_id, name
FROM accounts
WHERE name NOT IN ('Walmart','Target','Nordstrom')

-- Use the web_events table to find all information
-- regarding individuals who were contacted via any method
-- except using organic or adwords methods.
SELECT *
FROM web_events
WHERE channel NOT IN ('organic','adwords')

-- Use the accounts table to find:

-- All the companies whose names do not start with 'C'.
SELECT name
FROM accounts
WHERE name NOT LIKE  'C%'
ORDER BY name

-- All companies whose names do not contain
-- the string 'one' somewhere in the name.
SELECT name
FROM accounts
WHERE name NOT LIKE  '%one%'
ORDER BY name

-- All companies whose names do not end with 's'.
SELECT name
FROM accounts
WHERE name NOT LIKE  '%s'
ORDER BY name

-- Questions using AND and BETWEEN operators
-- Write a query that returns all the orders where
-- the standard_qty is over 1000, the poster_qty is 0,
-- and the gloss_qty is 0.

SELECT standard_qty, poster_qty, gloss_qty
FROM orders
WHERE standard_qty > 1000 AND poster_qty = 0 AND gloss_qty = 0

-- Using the accounts table, find all the companies
-- whose names do not start with 'C' and end with 's'.
SELECT name
FROM accounts
WHERE name NOT LIKE 'C%' AND name LIKE '%s'

-- When you use the BETWEEN operator in SQL, do the results include the values of your endpoints, or not? Figure out the answer to this important question by writing a query that displays the order date and gloss_qty data for all orders where gloss_qty is between 24 and 29. Then look at your output to see if the BETWEEN operator included the begin and end values or not.

SELECT *
FROM orders
WHERE gloss_qty BETWEEN 24 AND 29
ORDER BY gloss_qty
--IT DOES INCLUDE THE ENDPOINTS

-- Use the web_events table to find all information regarding individuals who
-- were contacted via the organic or adwords channels, and started their account
-- at any point in 2016, sorted from newest to oldest.
SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;

-- #OR
-- Find list of orders ids where either gloss_qty or poster_qty is greater than 4000. Only include the id field in the resulting table.
SELECT gloss_qty, poster_qty, id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000
LIMIT 20

-- Write a query that returns a list of orders where the standard_qty is zero and either the gloss_qty or poster_qty is over 1000.
SELECT gloss_qty, poster_qty, id, standard_qty
FROM orders
WHERE (standard_qty = 0 ) AND (gloss_qty > 1000 OR poster_qty > 1000)


-- Find all the company names that start with a 'C' or 'W',
-- and the primary contact contains 'ana' or 'Ana', but it doesn't
 -- contain 'eana'.
SELECT name, primary_poc
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%' )
AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
AND (primary_poc NOT LIKE '%eana%'))
ORDER BY primary_poc


-- Quiz Questions JOIN
-- Try pulling all the data from the accounts table,
-- and all the data from the orders table.

SELECT accounts.*, orders.*
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
LIMIT 10

-- Try pulling standard_qty, gloss_qty, and poster_qty
-- from the orders table, and the website and the primary_poc
-- from the accounts table.
SELECT accounts.website,accounts.primary_poc, orders.standard_qty, orders.gloss_qty, orders.poster_qty
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
LIMIT 10

-- QUIZ: JOIN Questions Part I

-- 1. Provide a table for all web_events associated with account
-- name of Walmart. There should be three columns. Be sure to include
-- the primary_poc, time of the event, and the channel for each event.
-- Additionally, you might choose to add a fourth column to assure only
--  Walmart events were chosen.

SELECT accounts.name,  accounts.primary_poc, web_events.channel, web_events.occurred_at
FROM accounts
JOIN web_events
ON web_events.account_id = accounts.id
WHERE accounts.name = 'Walmart'

-- 2. Provide a table that provides the region for each sales_rep along with their
--  associated accounts. Your final table should include three columns: the
--  region name, the sales rep name, and the account name. Sort the accounts
--  alphabetically (A-Z) according to account name.

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY a.name;

SELECT region.name, sales_reps.name, accounts.name
FROM sales_reps
JOIN region
ON region.id = sales_reps.region_id
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id

-- 3. Provide the name for each region for every order, as well as the
-- account name and the unit price they paid (total_amt_usd/total) for
-- the order. Your final table should have 3 columns: region name,
-- account name, and unit price. A few accounts have 0 for total,
-- so I divided by (total + 0.01) to assure not dividing by zero.

SELECT region.name region, (orders.total_amt_usd/ (orders.total + 0.01))
        unit_price,  accounts.name account
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id

-- SQL JOINS final QUIZ

-- 1 Provide a table that provides the region for each sales_rep along
 -- with their associated accounts. This time only for the Midwest region.
  -- Your final table should include three columns: the region name,
   -- the sales rep name, and the account name.
   -- Sort the accounts alphabetically (A-Z) according to account name.

SELECT region.name regname, sales_reps.name salesname, accounts.name accName
FROM accounts
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
WHERE region.name = 'Midwest'
ORDER BY accounts.name

-- 2. Provide a table that provides the region for each sales_rep along with
-- their associated accounts. This time only for accounts where the sales rep
-- has a first name starting with S and in the Midwest region.
-- Your final table should include three columns: the region name,
-- the sales rep name, and the account name.
-- Sort the accounts alphabetically (A-Z) according to account name.

SELECT region.name regname, sales_reps.name salesname, accounts.name accName
FROM accounts
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
WHERE region.name = 'Midwest' AND sales_reps.name LIKE 'S%'
ORDER BY accounts.name

-- 3. Provide a table that provides the region for each sales_rep along with
-- their associated accounts. This time only for accounts where the sales rep
-- has a last name starting with K and in the Midwest region.
-- Your final table should include three columns: the region name, the
-- sales rep name, and the account name. Sort the accounts alphabetically (A-Z)
-- according to account name.

SELECT region.name regname, sales_reps.name salesname, accounts.name accName
FROM accounts
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
WHERE region.name = 'Midwest'
AND UPPER(sales_reps.name) LIKE UPPER('% K%')
-- or [WHERE r.name = 'Midwest' AND s.name LIKE '% K%']
ORDER BY accounts.name

-- 4. Provide the name for each region for every order, as well as the account name
-- and the unit price they paid (total_amt_usd/total) for the order. However,
-- you should only provide the results if the standard order quantity exceeds 100.
-- Your final table should have 3 columns: region name, account name, and unit price.
-- In order to avoid a division by zero error, adding .01 to the denominator here is
-- helpful total_amt_usd/(total+0.01).

SELECT region.name regname, (orders.total_amt_usd/(orders.total + 0.01)) unit_price, accounts.name accName
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
JOIN sales_reps
ON accounts.sales_rep_id  = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
WHERE orders.standard_qty > 100

-- 5. Provide the name for each region for every order, as well as the
-- account name and the unit price they paid (total_amt_usd/total) for the order.
-- However, you should only provide the results if the standard order quantity
-- exceeds 100 and the poster order quantity exceeds 50. Your final table should
-- have 3 columns: region name, account name, and unit price. Sort for the
-- smallest unit price first. In order to avoid a division by zero error,
-- adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).

SELECT region.name regname, (orders.total_amt_usd/(orders.total + 0.01)) unit_price, accounts.name accName
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
JOIN sales_reps
ON accounts.sales_rep_id  = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id
WHERE orders.standard_qty > 100 AND orders.poster_qty > 50
ORDER BY unit_price -- DESC

-- 7. What are the different channels used by account id 1001? Your final table
-- should have only 2 columns: account name and the different channels.
-- You can try SELECT DISTINCT to narrow down the results to only the unique values.

SELECT DISTINCT accounts.name, web_events.channel
FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id
WHERE accounts.id = 1001


-- 8. Find all the orders that occurred in 2015. Your final table should
-- have 4 columns: occurred_at, account name, order total, and order total_amt_usd.

SELECT accounts.name, orders.occurred_at, orders.total, orders.total_amt_usd
FROM  accounts
JOIN orders
ON orders.account_id = accounts.id
WHERE orders.occurred_at BETWEEN '2015-01-01' AND '2016-01-01'
-- '2016-01-01' and not '2015-12-31'
