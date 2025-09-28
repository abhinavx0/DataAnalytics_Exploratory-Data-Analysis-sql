
-- ========================================
-- PRODUCT LEVEL KPIs
-- ========================================

-- Total Sales per Product
SELECT 
    p.product_name,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name;

-- Total Orders per Product
SELECT 
    p.product_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name;

-- Total Quantity Sold per Product
SELECT 
    p.product_name,
    SUM(f.quantity) AS total_quantity
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name;

-- Total Unique Customers per Product
SELECT 
    p.product_name,
    COUNT(DISTINCT f.customer_key) AS total_customers
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name;

-- Lifespan per Product (in months)
SELECT 
    p.product_name,
    TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan_months
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name;

-- Recency per Product (months since last sale)
SELECT 
    p.product_name,
    TIMESTAMPDIFF(MONTH, MAX(f.order_date), NOW()) AS recency_months
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name;

-- Average Order Revenue (AOR) per Product
SELECT 
    p.product_name,
    SUM(f.sales_amount) / COUNT(DISTINCT f.order_number) AS average_order_revenue
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name;

-- Average Monthly Revenue per Product
SELECT 
    p.product_name,
    SUM(f.sales_amount) / NULLIF(TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)),0) AS avg_monthly_revenue
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name;



-- ========================================
-- CUSTOMER LEVEL KPIs
-- ========================================

-- Total Orders per Customer
SELECT 
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, customer_name;

-- Total Sales / Spend per Customer
SELECT 
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, customer_name;

-- Total Quantity Purchased per Customer
SELECT 
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(f.quantity) AS total_quantity
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, customer_name;

-- Total Distinct Products Purchased per Customer
SELECT 
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    COUNT(DISTINCT f.product_key) AS total_products
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, customer_name;

-- Lifespan per Customer (in months)
SELECT 
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan_months
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, customer_name;

-- Recency per Customer (months since last order)
SELECT 
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    TIMESTAMPDIFF(MONTH, MAX(f.order_date), NOW()) AS recency_months
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, customer_name;

-- Average Order Value (AOV) per Customer
SELECT 
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(f.sales_amount) / COUNT(DISTINCT f.order_number) AS average_order_value
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, customer_name;

-- Average Monthly Spend per Customer
SELECT 
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(f.sales_amount) / NULLIF(TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)),0) AS avg_monthly_spend
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, customer_name;



-- ========================================
-- TREND COMPARATIVE KPIs
-- ========================================

-- Monthly Sales Trend with Running Total & 3-Month Moving Average
SELECT 
    DATE_FORMAT(f.order_date,'%Y-%m-01') AS month_start,
    SUM(f.sales_amount) AS total_sales,
    SUM(SUM(f.sales_amount)) OVER (ORDER BY DATE_FORMAT(f.order_date,'%Y-%m-01')) AS running_total,
    AVG(SUM(f.sales_amount)) OVER (ORDER BY DATE_FORMAT(f.order_date,'%Y-%m-01') ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3month
FROM gold.fact_sales f
GROUP BY month_start
ORDER BY month_start;

-- Yearly Sales Performance per Product vs Avg and Previous Year
WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_prev_year
FROM yearly_product_sales
ORDER BY product_name, order_year;


