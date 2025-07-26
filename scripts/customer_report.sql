/*
=================================================================================
Customer Report View: gold.report_customers
=================================================================================

Purpose:
- This report consolidates key customer metrics and behavioral insights.

Highlights:
1. Retrieves customer demographics and transactional data.
2. Segments customers into:
   - Engagement tiers: VIP, Regular, New
   - Age groups: Under 20, 20–29, ..., 50+
3. Aggregates customer-level metrics:
   - Total orders
   - Total sales
   - Total quantity purchased
   - Total distinct products
   - Lifespan (in months)
4. Calculates KPIs:
   - Recency (months since last order)
   - Average Order Value (AOV)
   - Average Monthly Spend

=================================================================================
*/

CREATE VIEW gold.report_customers AS

-- ======================================================
-- 1. Base Query: Retrieve core transactional and customer data
-- ======================================================
WITH base_query AS (
    SELECT 
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        TIMESTAMPDIFF(YEAR, c.birthdate, NOW()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
      AND c.customer_key IS NOT NULL
),

-- ======================================================
-- 2. Customer Aggregation: Summarize metrics per customer
-- ======================================================
customer_aggregation AS (
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        
        MAX(order_date) AS last_order,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY customer_key, customer_number, customer_name, age
)

-- ======================================================
-- 3. Final Selection with Segments and KPIs
-- ======================================================
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    -- Age Segmentation
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20 - 29'
        WHEN age BETWEEN 30 AND 39 THEN '30 - 39'
        WHEN age BETWEEN 40 AND 49 THEN '40 - 49'
        ELSE 'Above 50'
    END AS age_segmentation,

    total_orders,
    total_sales,
    total_quantity,
    total_products,
    last_order,
    
    -- Recency: months since last order
    TIMESTAMPDIFF(MONTH, last_order, NOW()) AS order_recency,
    
    lifespan,

    -- Average Order Value (AOV): total_sales / total_orders
    CASE 
        WHEN total_orders = 0 THEN 0 
        ELSE total_sales / total_orders 
    END AS average_order_value,

    -- Average Monthly Spend: total_sales / lifespan
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan 
    END AS average_monthly_spend,

    -- Customer Segmentation by value & tenure
    CASE 
        WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
        WHEN total_sales <= 5000 AND lifespan >= 12 THEN 'REGULAR'
        ELSE 'NEW'
    END AS customer_segmentation

FROM customer_aggregation;
