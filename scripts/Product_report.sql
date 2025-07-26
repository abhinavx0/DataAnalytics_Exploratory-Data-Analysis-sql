/*
————————————————————————————————————————
Product Report View: gold.report_products
————————————————————————————————————————

Purpose:
- This report consolidates key product metrics and performance behavior.

Highlights:
1. Gathers essential product fields such as name, category, subcategory, and cost.
2. Segments products based on revenue into: High-Performers, Mid-Range, or Low-Performers.
3. Aggregates product-level metrics:
    - Total orders
    - Total sales
    - Total quantity sold
    - Total unique customers
    - Lifespan (in months)
4. Calculates additional KPIs:
    - Recency (months since last sale)
    - Average Order Revenue (AOR)
    - Average Monthly Revenue

————————————————————————————————————————
*/

CREATE VIEW gold.report_products AS

-- Step 1: Base query to join product and sales data
WITH base_query_product AS (
    SELECT
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        f.sales_amount,
        f.quantity,
        f.customer_key,
        f.order_number,
        f.order_date
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

-- Step 2: Aggregate data per product
product_aggregation AS (
    SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        
        -- Product lifespan in months (between first and last order)
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        
        -- Last recorded order date
        MAX(order_date) AS last_order,
        
        -- Total number of distinct orders
        COUNT(DISTINCT order_number) AS total_orders,
        
        -- Total revenue from product
        SUM(sales_amount) AS total_sales,
        
        -- Total quantity sold
        COUNT(quantity) AS total_quantity,
        
        -- Number of unique customers
        COUNT(DISTINCT customer_key) AS total_customers,
        
        -- Average price per item sold (row-level average)
        AVG(sales_amount / NULLIF(quantity, 0)) AS average_selling_price

    FROM base_query_product
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

-- Step 3: Final selection with KPI calculations and segmentation
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_order,
    
    -- Recency: months since the last sale
    TIMESTAMPDIFF(MONTH, last_order, NOW()) AS order_recency,

    -- Product segmentation based on total revenue
    CASE 
        WHEN total_sales >= 50000 THEN 'High-performance'
        WHEN total_sales >= 10000 THEN 'Mid-performance'
        ELSE 'Low-performance'
    END AS product_segmentation,

    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    lifespan,
    
    -- Average revenue per order
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS average_order_revenue,

    -- Average monthly revenue over lifespan
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS monthly_revenue

FROM product_aggregation;
