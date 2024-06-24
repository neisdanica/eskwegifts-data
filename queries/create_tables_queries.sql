/* Adding a column on order_list table categorizing new customers with repeat customers
   Saved as table: order_list_updated
 */
 
SELECT *,
  CASE
    WHEN order_sequence = 1 THEN 1  -- New Customer
    ELSE 0  -- Returning Customer
  END AS is_new_customer
FROM (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY accountId ORDER BY purchaseDate) AS order_sequence
  FROM
    `dab-cohort13-414306.eskwegifts_data.orders`
) AS CustomerOrders
ORDER BY purchaseDate;


/*  Left join item-info table and user_list table with order_list_updated table to get the COGs data and customer information.
    Added key financial metrics: revenue, operating expenses (past SLA losses), gross profit and net profit.
    Replaced null values for CoGS with 0.
*/

SELECT  o.*,
        DATE(o.purchaseDate) AS purchaseDate,
        u.location,
        COALESCE(i.CoGS,0) AS itemCoGS,
        o.itemQty * COALESCE(i.CoGS, 0) AS totalCoGS,
        o.orderAmount - (o.itemQty * COALESCE(i.CoGS, 0)) AS grossProfit,
        CASE WHEN isPastSLA = 1 THEN o.orderAmount - (o.orderDiscount + o.shippingDiscount) - (o.itemQty * COALESCE(i.CoGS, 0))
             WHEN isPastSLA = 0 THEN o.orderAmount - (o.itemQty * COALESCE(i.CoGS, 0))
             ELSE 0
        END AS netProfit,
        CASE WHEN isPastSLA = 1 THEN o.orderDiscount + o.shippingDiscount 
             ELSE 0
        END AS pastSLAExpenses,
        CASE WHEN purchaseYear = 2022 AND accountId NOT IN (
              SELECT DISTINCT accountId
              FROM `dab-cohort13-414306.ESKWEGIFTS_DATA.order_list_updated`
              WHERE purchaseYear = 2023) THEN 1
              ELSE 0
        END AS churnedCustomer

FROM `dab-cohort13-414306.ESKWEGIFTS_DATA.order_list_updated` o
LEFT JOIN `dab-cohort13-414306.eskwegifts_data.item_info` i
    ON o.skuId = i.skuId
LEFT JOIN `dab-cohort13-414306.eskwegifts_data.user_list` u
    ON o.accountId = u.id;

/* 
   Created new table called customer_churn_data.
   Extracted list of churned customers. 
   Categorize churned customers based on their order history.
*/
WITH ChurnedCustomers AS (
  SELECT purchaseDate_1, accountId,location, orderAmount 
  FROM `dab-cohort13-414306.ESKWEGIFTS_DATA.all_data`
  WHERE purchaseYear = 2022
  AND accountId NOT IN (
    SELECT DISTINCT accountId
    FROM `dab-cohort13-414306.ESKWEGIFTS_DATA.all_data`
    WHERE purchaseYear = 2023
  )
),
CustomerOrders AS (
  SELECT
    accountId,
    MAX(isCancelledBeforeSLA) AS has_cancelled_order,
    MAX(isPastSLA) AS has_past_sla_order
  FROM
    `dab-cohort13-414306.ESKWEGIFTS_DATA.all_data`
  WHERE
    purchaseYear = 2022
  GROUP BY
    accountId
)

SELECT
  t1.*,
  CASE
    WHEN t2.has_cancelled_order = 1 AND t2.has_past_sla_order = 1 THEN 'PastSLA & Cancelled'
    WHEN t2.has_cancelled_order = 1 AND t2.has_past_sla_order = 0 THEN 'Cancelled Order'
    WHEN t2.has_cancelled_order = 0 AND t2.has_past_sla_order = 1 THEN 'PastSLA Order'
    ELSE 'Good Orders'
  END AS churn_category
FROM
  ChurnedCustomers t1
LEFT JOIN
  CustomerOrders t2
ON
  t1.accountId = t2.accountId;


/* Created a new table, past_sla_data, categorizing cause of delay (Customization or Delivery).
   Added column for customization and delivery lead time 
*/

SELECT  *,
        DATE_DIFF(DATE(customizeEndDate), DATE(customizeStartDate), DAY) AS customization_days,
        DATE_DIFF(DATE(deliveryDate), DATE(customizeEndDate), DAY) AS delivery_days,
        CASE 
            WHEN DATE_DIFF(DATE(customizeEndDate),DATE(customizeStartDate), DAY) > 7 AND 
              ((location = 'Metro Manila' AND DATE_DIFF(DATE(deliveryDate),DATE(customizeEndDate), DAY) > 1) OR
              (location = 'Luzon' AND DATE_DIFF(DATE(customizeEndDate),DATE(customizeStartDate), DAY) > 2) OR
              (location = 'Visayas' AND DATE_DIFF(DATE(deliveryDate),DATE(customizeEndDate), DAY) > 3) OR
              (location = 'Mindanao' AND DATE_DIFF(DATE(deliveryDate),DATE(customizeEndDate), DAY) > 4)) THEN 'Customization + Delivery'
            WHEN (location = 'Metro Manila' AND DATE_DIFF(DATE(deliveryDate),DATE(customizeEndDate), DAY) > 1) THEN 'Delivery'
            WHEN (location = 'Luzon' AND DATE_DIFF(DATE(deliveryDate),DATE(customizeEndDate), DAY) > 2) THEN 'Delivery'
            WHEN (location = 'Visayas' AND DATE_DIFF(DATE(deliveryDate),DATE(customizeEndDate), DAY) > 3) THEN 'Delivery'
            WHEN (location = 'Mindanao' AND DATE_DIFF(DATE(deliveryDate),DATE(customizeEndDate), DAY) > 4) THEN 'Delivery'
            WHEN DATE_DIFF(DATE(customizeEndDate),DATE(customizeStartDate), DAY) > 7 THEN 'Customization'
            ELSE 'On Time'
        END AS delay_type
FROM `dab-cohort13-414306.ESKWEGIFTS_DATA.all_data` a ;
