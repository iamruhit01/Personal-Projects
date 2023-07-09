CREATE SCHEMA pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
-- Example Query:
SELECT
	runners.runner_id,
    runners.registration_date,
	COUNT(DISTINCT runner_orders.order_id) AS orders
FROM pizza_runner.runners
INNER JOIN pizza_runner.runner_orders
	ON runners.runner_id = runner_orders.runner_id
WHERE runner_orders.cancellation IS NOT NULL
GROUP BY
	runners.runner_id,
    runners.registration_date;




-- Cleaning customer_orders
DROP TABLE customer_orders_t;
CREATE TEMPORARY TABLE customer_orders_t
	SELECT order_id, customer_id, pizza_id, 
	  CASE 
		WHEN  exclusions LIKE 'null' OR exclusions = '' THEN NULL
		ELSE exclusions
		END AS exclusions,
	  CASE 
		WHEN extras LIKE 'null'  OR extras = '' THEN NULL
		ELSE extras 
		END AS extras, 
	  order_time
	FROM customer_orders;
    
-- Cleaning runner_orders
DROP TABLE runner_orders_t;
CREATE TEMPORARY TABLE runner_orders_t
	SELECT order_id, runner_id,
	  CASE 
		WHEN pickup_time LIKE 'null' THEN NULL
		ELSE pickup_time 
		END AS pickup_time,
	  CASE 
		WHEN distance LIKE 'null' THEN NULL
		WHEN distance LIKE '%km' THEN TRIM('km' from distance) 
		ELSE distance END AS distance,
	  CASE 
		WHEN duration LIKE 'null' THEN NULL
		WHEN duration LIKE '%mins' THEN TRIM('mins' from duration) 
		WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)        
		WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)       
		ELSE duration END AS duration,
	  CASE 
		WHEN cancellation = '' THEN NULL
		WHEN cancellation = 'null' THEN NULL
		ELSE cancellation END AS cancellation
	FROM runner_orders;
    
-- Changing Datatypes
ALTER TABLE runner_orders_t
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance FLOAT,
MODIFY COLUMN duration INT;


SELECT * FROM customer_orders_t;
SELECT * FROM runner_orders_t;
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;
SELECT * FROM runners;

-- How many pizzas were ordered?

SELECT COUNT(*) AS pizza_count FROM customer_orders_t;

-- How many unique customer orders were made?

SELECT COUNT(DISTINCT(order_id)) AS unique_customers FROM customer_orders_t;

-- How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(*) orders_delivered FROM runner_orders_t WHERE cancellation IS NULL GROUP BY runner_id;

-- How many of each type of pizza was delivered?

SELECT pizza_name,COUNT(*) AS pizza_count FROM customer_orders_t AS C
INNER JOIN pizza_names AS P ON P.pizza_id = C.pizza_id
INNER JOIN runner_orders_t AS R ON R.order_id = C.order_id
WHERE R.distance IS NOT NULL
GROUP BY pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id,pizza_name,COUNT(*) AS pizza_count FROM customer_orders_t AS C
INNER JOIN pizza_names AS P ON P.pizza_id = C.pizza_id
GROUP BY customer_id, pizza_name ORDER BY customer_id;

-- What was the maximum number of pizzas delivered in a single order?

SELECT COUNT(*) AS pizzas_per_order FROM customer_orders_t AS C
INNER JOIN runner_orders_t AS R ON R.order_id = C.order_id
WHERE R.distance IS NOT NULL
GROUP BY C.order_id ORDER BY pizzas_per_order DESC LIMIT 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
    customer_id,
    SUM(CASE
			WHEN C.exclusions LIKE '%' OR C.extras LIKE '%' THEN 1
            ELSE 0
		END ) AS atleast_one_change,
        
	SUM(CASE
			WHEN C.exclusions IS NULL AND C.extras IS NULL THEN 1
            ELSE 0
		END ) AS no_change
FROM
    customer_orders_t AS C
        INNER JOIN
    pizza_names AS P ON P.pizza_id = C.pizza_id
        INNER JOIN
    runner_orders_t AS R ON R.order_id = C.order_id
WHERE
    R.distance IS NOT NULL
GROUP BY customer_id
ORDER BY customer_id;

-- How many pizzas were delivered that had both exclusions and extras?

SELECT 
    SUM(CASE
			WHEN C.exclusions LIKE '%' AND C.extras LIKE '%' THEN 1
            ELSE 0
	END ) AS both_exclusons_extras
FROM
    customer_orders_t AS C
INNER JOIN
    runner_orders_t AS R ON R.order_id = C.order_id
WHERE
    R.distance IS NOT NULL;

-- What was the total volume of pizzas ordered for each hour of the day?

	SELECT HOUR(order_time) AS hours, COUNT(*) as total_orders FROM customer_orders
    GROUP BY HOUR(order_time) ORDER BY hours;
    
-- What was the volume of orders for each day of the week?

	SELECT DAYOFWEEK(order_time) AS days, COUNT(*) AS total_orders FROM customer_orders
    GROUP BY DAYOFWEEK(order_time) ORDER BY days;


SELECT * FROM runners;
SELECT * FROM runner_orders_t;
SELECT * FROM customer_orders_t;

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
	COUNT(runner_id) AS runner_count,
    WEEK(registration_date) AS week
FROM runners
GROUP BY week;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id, ROUND(AVG(TIMESTAMPDIFF(MINUTE, C.order_time,pickup_time)),2) AS avg_arrival_time FROM runner_orders_t AS R
JOIN customer_orders_t AS C ON C.order_id = R.order_id
GROUP BY runner_id;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT C.order_id,COUNT(*) AS no_of_pizzas, ROUND(AVG(TIMESTAMPDIFF(MINUTE, C.order_time,pickup_time)),2) AS preperation_time FROM runner_orders_t AS R
JOIN customer_orders_t AS C ON C.order_id = R.order_id
GROUP BY C.order_id;

-- What was the average distance travelled for each customer?
SELECT C.customer_id, ROUND(AVG(R.distance),2) AS avg_distance_travelled FROM runner_orders_t AS R
JOIN customer_orders_t AS C ON C.order_id = R.order_id
GROUP BY C.customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration)- MIN(duration) AS delivery_time_diff FROM runner_orders_t WHERE duration IS NOT NULL;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id,C.order_id, ROUND(AVG(distance*60/duration),2) AS avg_speed FROM runner_orders_t AS R
JOIN customer_orders_t AS C ON C.order_id = R.order_id
WHERE duration IS NOT NULL
GROUP BY runner_id,order_id;

-- What is the successful delivery percentage for each runner?

WITH success_cte AS (
SELECT  runner_id, 
		SUM(CASE WHEN duration IS NOT NULL THEN 1 ELSE 0 END) AS successful_delivery, 
        SUM(CASE WHEN duration IS  NULL THEN 1 ELSE 0 END) AS unsuccessful_delivery,
		COUNT(*) AS total_delivery
FROM runner_orders_t AS R
GROUP BY runner_id)

SELECT runner_id, successful_delivery,unsuccessful_delivery,successful_delivery*100/total_delivery AS success_rate FROM success_cte;

-- Normalize Pizza Recipe table
drop table if exists pizza_recipes1;
create table pizza_recipes1 
(
 pizza_id int,
    toppings int);
insert into pizza_recipes1
(pizza_id, toppings) 
values
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,8),
(1,10),
(2,4),
(2,6),
(2,7),
(2,9),
(2,11),
(2,12);
SELECT * FROM pizza_recipes1;
SELECT * FROM pizza_names;
SELECT * FROM pizza_toppings;
SELECT * FROM customer_orders_t;

-- What are the standard ingredients for each pizza?
WITH cte AS (
SELECT pizza_name,PR.pizza_id,topping_name FROM pizza_recipes1 PR
JOIN pizza_names AS PN ON PN.pizza_id = PR.pizza_id
JOIN pizza_toppings AS PT ON PT.topping_id = PR.toppings
ORDER BY pizza_id
)

SELECT pizza_name, GROUP_CONCAT(topping_name) AS StandardToppings
FROM cte
GROUP BY pizza_name;

--  What was the most commonly added extra?
SELECT extras,COUNT(*) FROM customer_orders_t AS C
WHERE extras IS NOT NULL 
GROUP BY extras;


-- What was the most common exclusion?
SELECT exclusions,COUNT(*) FROM customer_orders_t AS C
WHERE exclusions IS NOT NULL 
GROUP BY exclusions;

-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes -
-- how much money has Pizza Runner made so far if there are no delivery fees?

SELECT 
	SUM(CASE
			WHEN pizza_id=1 THEN 12
			ELSE 10
		END) AS income
FROM customer_orders_t AS C
JOIN runner_orders_t AS R ON R.order_id=C.order_id
WHERE R.distance IS NOT NULL;

-- What if there was an additional $1 charge for any pizza extras?
SET @basecost = 138;
SELECT (LENGTH(GROUP_CONCAT(extras)) - LENGTH(REPLACE(GROUP_CONCAT(extras), ',', '')) + 1) + @basecost as Total
FROM customer_orders_t
INNER JOIN runner_orders_t
ON customer_orders_t.order_id = runner_orders_t.order_id
WHERE extras IS NOT NULL AND  distance is not null;

-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- how would you design an additional table for this new dataset 
-- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

create table ratings (
order_id integer,
rating integer);
insert into ratings
(order_id, rating)
values
(1,3),
(2,5),
(3,3),
(4,1),
(5,5),
(7,3),
(8,4),
(10,3);

-- Using your newly generated table — can you join all of the information together to form a table which has the following information for successful deliveries?

SELECT customer_id,C.order_id,runner_id,rating,order_time,pickup_time,
ROUND(AVG(TIMESTAMPDIFF(MINUTE, C.order_time,pickup_time)),2) AS preperation_time,duration,
ROUND(AVG(distance*60/duration),2) AS avg_speed,COUNT(*) AS pizzas_ordered FROM customer_orders_t AS C
JOIN runner_orders_t AS R ON R.order_id=C.order_id
JOIN ratings ON ratings.order_id = C.order_id
GROUP BY customer_id, C.order_id,runner_id,C.order_time,pickup_time,rating,distance,duration;


-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is 
-- paid $0.30 per kilometre traveled — how much money does Pizza Runner have left over after these deliveries?
set @pizzaamountearned = 138;
select @pizzaamountearned - ROUND((sum(distance))*0.3,2) as Finalamount
from runner_orders_t;



