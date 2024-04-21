/* 
  The Purpose of this EDA is to investigate reasons behind the YoY loss in profit margins for Eskwegifts in Operations Perspective. 
*/

-- Analyzing the trend in placed orders and quantity of items ordered from 2022 to 2023.
SELECT DATE(purchaseDate), COUNT(orderId) AS orderCount, SUM(itemQty) AS itemCount
FROM `sprint3-415908.sprint3_4_dataset.order_list`
GROUP BY 1
ORDER BY 1 ASC;

/* Customer Analysis */

-- Analyzing the trend of customers placing orders from 2022 to 2023.
SELECT COUNT(DISTINCT(o.accountId)), o.purchaseDate
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
ORDER BY 2;

-- how many distinct customers from the total number of distinct 2022 customers, returned in 2023? how many 2022 customers churned? 
WITH total_customers_22 AS (
SELECT COUNT(DISTINCT(o.accountID)) AS customers_2022
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2022
),
customer_list_22 AS (
SELECT DISTINCT(o.accountID) AS customer_list_2022
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2022
)

SELECT (SELECT customers_2022
FROM total_customers_22) AS total_2022_customers,
COUNT(DISTINCT(o.accountId)) AS returning_2022_customers,
(COUNT(DISTINCT(o.accountId))/
(SELECT customers_2022
FROM total_customers_22)) * 100 AS returning_customers_rate,
(SELECT customers_2022
FROM total_customers_22) - COUNT(DISTINCT(o.accountId)) AS customer_churn,
((SELECT customers_2022
FROM total_customers_22) - COUNT(DISTINCT(o.accountId)))/
(SELECT customers_2022
FROM total_customers_22) * 100 AS churn_rate
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2023 AND o.accountID IN (
SELECT customer_list_2022
FROM customer_list_22);

------ analyzing customer churn ------

-- how many percent from the total number of 2022 customers with past SLA orders, reordered in 2023? how many 2022 customers with past SLA churned?
WITH total_customer_past_SLA_list_22 AS (
SELECT COUNT(DISTINCT(o.accountID)) AS customer_past_SLA_2022
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2022 AND o.ispastSLA = 1
),
customer_past_SLA_list_22 AS (
SELECT DISTINCT(o.accountID) AS customer_past_SLA_list_2022
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2022 AND o.ispastSLA = 1
)

SELECT (SELECT customer_past_SLA_2022
FROM total_customer_past_SLA_list_22) AS total_2022_customers_with_pastSLA,
COUNT(DISTINCT(o.accountId)) AS returning_2022_customers_with_pastSLA,
(COUNT(DISTINCT(o.accountId))/
(SELECT customer_past_SLA_2022
FROM total_customer_past_SLA_list_22)) * 100 AS returning_2022_customers_with_pastSLA_pcnt,
(SELECT customer_past_SLA_2022
FROM total_customer_past_SLA_list_22) - COUNT(DISTINCT(o.accountId)) AS customer_churn_with_pastSLA
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2023 AND o.accountID IN (
SELECT customer_past_SLA_list_2022
FROM customer_past_SLA_list_22);

-- how many percent from the total number of 2022 customers with cancelled order, reordered in 2023? how many 2022 customers with cancelled order churned?
WITH total_customer_cancellation_22 AS (
SELECT COUNT(DISTINCT(o.accountID)) AS total_customer_cancellation_2022
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2022 AND o.isCancelledBeforeSLA = 1
),
customer_cancellation_list_22 AS (
SELECT DISTINCT(o.accountID) AS customer_cancellation_list_2022
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2022 AND o.isCancelledBeforeSLA = 1
)

SELECT
(SELECT total_customer_cancellation_2022
FROM total_customer_cancellation_22) AS total_customer_cancellation_2022,
COUNT(DISTINCT(o.accountId)) AS returning_2022_customers_with_cancellation,
(COUNT(DISTINCT(o.accountId))/
(SELECT total_customer_cancellation_2022
FROM total_customer_cancellation_22)) * 100 AS returning_2022_customers_with_cancellation_pcnt,
(SELECT total_customer_cancellation_2022
FROM total_customer_cancellation_22) - COUNT(DISTINCT(o.accountId)) AS customer_churn_with_cancellation
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2023 AND o.accountID IN (
SELECT customer_cancellation_list_2022
FROM customer_cancellation_list_22);

-- how many percent from the total 2023 customers are returning customers?
WITH total_customers_23 AS (
         SELECT COUNT(DISTINCT(o.accountID)) AS customers_2023
         FROM `sprint3-415908.sprint3_4_dataset.order_list` o
         WHERE o.purchaseYear = 2023
),
customer_list_22 AS (
        SELECT DISTINCT(o.accountID) AS customer_list_2022
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2022    
)

SELECT  COUNT(DISTINCT(o.accountId)) AS returning_customers,
        (SELECT customers_2023
         FROM total_customers_23) AS total_2023_customers,
        (COUNT(DISTINCT(o.accountId))/
        (SELECT customers_2023
         FROM total_customers_23)) * 100 AS returning_customers_pcnt
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2023 AND o.accountID IN (
                SELECT customer_list_2022
                FROM customer_list_22);

-- how many percent from the total 2023 customers are new customers?
WITH total_customers_23 AS (
         SELECT COUNT(DISTINCT(o.accountID)) AS customers_2023
         FROM `sprint3-415908.sprint3_4_dataset.order_list` o
         WHERE o.purchaseYear = 2023
),
customer_list_22 AS (
        SELECT DISTINCT(o.accountID) AS customer_list_2022
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2022    
)

SELECT  COUNT(DISTINCT(o.accountId)) AS new_2023_customers,
        (SELECT customers_2023
         FROM total_customers_23) AS total_2023_customers,
        (COUNT(DISTINCT(o.accountId))/
        (SELECT customers_2023
         FROM total_customers_23)) * 100 AS new_customers_pcnt
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2023 AND o.accountID NOT IN (
                SELECT customer_list_2022
                FROM customer_list_22);

-- getting the number of orders per new customer in 2023 
WITH customer_list_2022 AS(
        SELECT DISTINCT(o.accountId) AS cust_list_2022
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2022
)

SELECT  o.accountId, 
        COUNT(o.orderId) AS order_count_per_customer
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2023 AND o.accountId NOT IN(
        SELECT cust_list_2022
        FROM customer_list_2022)
GROUP BY 1
ORDER BY 2 DESC;

-- what is the average amount per order of new customers in 2023?
WITH customer_list_2022 AS(
        SELECT DISTINCT(o.accountId) AS cust_list_2022
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2022
)

SELECT AVG(o.orderAmount) AS average_amount_per_order
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2023 AND o.accountId NOT IN(
        SELECT cust_list_2022
        FROM customer_list_2022);

-- getting the number of orders of returning customers in 2023 
WITH customer_list_2023 AS(
        SELECT DISTINCT(o.accountId) AS cust_list_2023
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2023
)

SELECT  o.accountId, 
        COUNT(o.orderId) AS order_count_per_customer
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2022 AND o.accountId IN(
        SELECT cust_list_2023
        FROM customer_list_2023)
GROUP BY 1
ORDER BY 2 DESC;

-- getting the average amount per order of returning customers in 2023
WITH customer_list_2023 AS(
        SELECT DISTINCT(o.accountId) AS cust_list_2023
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2023
)

SELECT AVG(o.orderAmount) AS average_amount_per_order
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2022 AND o.accountId IN(
        SELECT cust_list_2023
        FROM customer_list_2023);

-- getting the number of orders per customer with past SLA  who churned 
WITH customer_list_2023 AS(
        SELECT DISTINCT(o.accountId) AS cust_list_2023
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2023
)

SELECT o.accountId, 
        COUNT(o.orderId) AS order_count_per_customer
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE   o.purchaseYear = 2022 AND 
        o.accountId NOT IN(
                SELECT cust_list_2023
                FROM customer_list_2023) AND
        o.ispastSLA = 1
GROUP BY 1
ORDER BY 2 DESC;


-- getting the number of order per customer with cancellation who churned 
WITH customer_list_2023 AS(
        SELECT DISTINCT(o.accountId) AS cust_list_2023
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2023
)

SELECT o.accountId, 
        COUNT(o.orderId) AS order_count_per_customer
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE   o.purchaseYear = 2022 AND 
        o.accountId NOT IN(
                SELECT cust_list_2023
                FROM customer_list_2023) AND
        o.isCancelledBeforeSLA = 1
GROUP BY 1
ORDER BY 2 DESC;


-- getting the number of order per customer without past SLA and cancellation who churned 
WITH customer_list_2023 AS(
        SELECT DISTINCT(o.accountId) AS cust_list_2023
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2023
)

SELECT  o.accountId, 
        COUNT(o.orderId) AS order_count_per_customer
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE   o.purchaseYear = 2022 AND 
        o.accountId NOT IN(
                SELECT cust_list_2023
                FROM customer_list_2023) AND
        o.ispastSLA = 0 AND o.isCancelledBeforeSLA = 0
GROUP BY 1
ORDER BY 2 DESC;

-- getting the average amount per order of customer with past SLA  who churned 
WITH customer_list_2023 AS(
        SELECT DISTINCT(o.accountId) AS cust_list_2023
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2023
)

SELECT AVG(o.orderAmount) AS average_amount_per_order
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE   o.purchaseYear = 2022 AND 
        o.accountId NOT IN(
                SELECT cust_list_2023
                FROM customer_list_2023) AND
        o.ispastSLA = 1;

-- getting the average amount per order of customer with cancellation who churned 
WITH customer_list_2023 AS(
        SELECT DISTINCT(o.accountId) AS cust_list_2023
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2023
)

SELECT AVG(o.orderAmount) AS average_amount_per_order       
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE   o.purchaseYear = 2022 AND 
        o.accountId NOT IN(
                SELECT cust_list_2023
                FROM customer_list_2023) AND
        o.isCancelledBeforeSLA = 1
ORDER BY 1 DESC;

-- getting the average amount per order of customer without past SLA and cancellation who churned  
WITH customer_list_2023 AS(
        SELECT DISTINCT(o.accountId) AS cust_list_2023
        FROM `sprint3-415908.sprint3_4_dataset.order_list` o
        WHERE o.purchaseYear = 2023
)

SELECT  AVG(o.orderAmount) AS average_amount_per_order
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE   o.purchaseYear = 2022 AND 
        o.accountId NOT IN(
                SELECT cust_list_2023
                FROM customer_list_2023) AND
        o.ispastSLA = 0 AND o.isCancelledBeforeSLA = 0;


/* SLA analysis */

-- trend of past SLA 
SELECT DATE(o.purchaseDate) AS DATE, o.isPastSLA
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
ORDER BY 1 ASC;

-- Number of canceled orders due to past SLA and not started
SELECT COUNT(orderId) AS canceledPastSLA
FROM `sprint3-415908.sprint3_4_dataset.order_list`
WHERE isCancelledReasonNotStarted = 1;

 -- Number of canceled orders due to past SLA and not started
SELECT COUNT(orderId) AS canceledBeforeSLA
FROM `sprint3-415908.sprint3_4_dataset.order_list`
WHERE isCancelledBeforeSLA = 1;

-- Number of days between purchase date and customization start date
SELECT DATE_DIFF(DATE(o.customizeStartDate),DATE(o.purchaseDate), DAY) AS diff
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE isCancelledBeforeSLA = 1
ORDER BY 1 DESC;

SELECT DATE(o.customizeStartDate),DATE(o.purchaseDate)
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE isCancelledBeforeSLA = 0
ORDER BY 2 DESC;

-- Location of users cancelling orders
SELECT u.location, COUNT(o.orderId) AS cancelledOrderCnt
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
LEFT JOIN `sprint3-415908.sprint3_4_dataset.user_list` u
ON o.accountId = u.id
WHERE isCancelledReasonNotStarted = 1 OR isCancelledBeforeSLA = 1
GROUP BY 1;

-- explore where does the delay happen for past SLA orders 
SELECT  o.orderId, 
        u.location, 
        o.purchaseDate, 
        o.customizeStartDate, 
        o.customizeEndDate, 
        o.deliveryDate, 
        DATE_DIFF(o.customizeEndDate,o.customizeStartDate, DAY) AS customization_lead_time, 
        DATE_DIFF(o.deliveryDate,o.customizeEndDate, DAY) AS delivery_lead_time,
FROM `sprint3-415908.sprint3_4_dataset.order_list` o 
LEFT JOIN `sprint3-415908.sprint3_4_dataset.user_list` u
ON o.accountId = u.id
WHERE o.isPastSLA = 1;

-- exploring the delays in customization
SELECT  o.orderId, 
        u.location, 
        o.purchaseDate, 
        o.customizeStartDate, 
        o.customizeEndDate, 
        o.deliveryDate, 
        DATE_DIFF(o.customizeEndDate,o.customizeStartDate, DAY) AS customization_delay, 
        --DATE_DIFF(o.deliveryDate,o.customizeEndDate, DAY) AS delivery_delay,
FROM `sprint3-415908.sprint3_4_dataset.order_list` o 
LEFT JOIN `sprint3-415908.sprint3_4_dataset.user_list` u
ON o.accountId = u.id
WHERE o.isPastSLA = 1 AND DATE_DIFF(o.customizeEndDate,o.customizeStartDate, DAY) > 7;

-- exploring the delays in delivery
SELECT  o.orderId, 
        u.location, 
        o.purchaseDate, 
        o.customizeStartDate, 
        o.customizeEndDate, 
        o.deliveryDate, 
        --DATE_DIFF(o.customizeEndDate,o.customizeStartDate, DAY) AS customization_delay, 
        DATE_DIFF(o.deliveryDate,o.customizeEndDate, DAY) AS delivery_delay,
FROM `sprint3-415908.sprint3_4_dataset.order_list` o 
LEFT JOIN `sprint3-415908.sprint3_4_dataset.user_list` u
ON o.accountId = u.id
WHERE o.isPastSLA = 1 AND 
((u.location = 'Metro Manila' AND DATE_DIFF(o.deliveryDate,o.customizeEndDate, DAY) > 1) OR
 (u.location = 'Luzon' AND DATE_DIFF(o.deliveryDate,o.customizeEndDate, DAY) > 2) OR
 (u.location = 'Visayas' AND DATE_DIFF(o.deliveryDate,o.customizeEndDate, DAY) > 3) OR
 (u.location = 'Mindanao' AND DATE_DIFF(o.deliveryDate,o.customizeEndDate, DAY) > 4))
 ORDER BY 7 ASC;

-- getting the average customization and delivery lead time per order of the top 10% returning customers with the highest order amount on each location. 
WITH customer_list_22 AS (
SELECT DISTINCT(o.accountID) AS customer_list_2022
FROM `sprint3-415908.sprint3_4_dataset.order_list` o
WHERE o.purchaseYear = 2022
),

returning_2022_cs AS (
SELECT *
FROM `dab-cohort13-414306.eskwegifts_data.order_user_list` o
WHERE o.purchaseYear = 2023 AND o.accountID IN (
SELECT customer_list_2022
FROM customer_list_22)
),

order_per_cs AS(
SELECT  location,
        accountId,
        SUM(orderAmount) AS totalOrderAmount, 
        COUNT(orderId) As totalNumOrder, 
        AVG(orderAmount) AS avgAmountPerOrder,
        AVG(DATE_DIFF(customizeEndDate,customizeStartDate, DAY)) AS customization_lead_time, 
        AVG(DATE_DIFF(deliveryDate,customizeEndDate, DAY)) AS delivery_lead_time,
        NTILE(20) OVER (ORDER BY SUM(orderAmount) DESC) AS percentile
FROM returning_2022_cs
GROUP BY 1, 2
--ORDER BY 1, 3 DESC, 4 DESC
)

SELECT  location,
        AVG(totalOrderAmount) AS avgTotalOrderAmount,
        AVG(totalNumOrder) AS avgOrderCount,
        AVG(customization_lead_time) AS avgCustomizationDays,
        AVG(delivery_lead_time) AS avgDeliveryDays
FROM order_per_cs
WHERE percentile = 1
GROUP BY 1
ORDER BY 1;


---- getting the average customization and delivery lead time per order of the top 10% customers with the highest purchase frequency/ order count on each location for year 2023 
WITH order_per_cs AS(
SELECT  location,
        accountId,
        SUM(orderAmount) AS totalOrderAmount, 
        COUNT(orderId) As totalNumOrder, 
        AVG(orderAmount) AS avgAmountPerOrder,
        AVG(DATE_DIFF(customizeEndDate,customizeStartDate, DAY)) AS customization_lead_time, 
        AVG(DATE_DIFF(deliveryDate,customizeEndDate, DAY)) AS delivery_lead_time,
        NTILE(10) OVER (ORDER BY COUNT(orderId) DESC) AS percentile
FROM `dab-cohort13-414306.eskwegifts_data.order_user_list`
WHERE purchaseYear = 2022
GROUP BY 1, 2
--ORDER BY 1, 3 DESC, 4 DESC
)

SELECT  location,
        AVG(totalOrderAmount) AS avgTotalOrderAmount,
        AVG(totalNumOrder) AS avgOrderCount,
        AVG(customization_lead_time) AS avgCustomizationDays,
        AVG(delivery_lead_time) AS avgDeliveryDays
FROM order_per_cs
WHERE percentile = 1
GROUP BY 1
ORDER BY 1;   
