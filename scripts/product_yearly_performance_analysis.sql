-- Analyze the yearly performance of products
-- Comparing each product’s yearly sales against:
-- 1. The product’s average sales over all years
-- 2. The previous year’s sales

WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p 
        ON f.product_key = p.product_key
    WHERE YEAR(f.order_date) IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)

SELECT 
    order_year,
    product_name,
    current_sales,

    -- Calculate average sales across all years for each product
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,

    -- Difference from average
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,

    -- Performance label based on difference from average
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Good Performance'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Bad Performance'
        ELSE 'Average Performance'
    END AS performance,

    -- Previous year's sales
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,

    -- Difference from previous year
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,

    -- Year-over-year performance label
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS performance_diff_py

FROM yearly_product_sales
ORDER BY product_name, order_year;
