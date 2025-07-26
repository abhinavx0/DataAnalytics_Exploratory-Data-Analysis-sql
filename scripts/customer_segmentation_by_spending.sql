-- ============================================
-- Customer Segmentation query
-- ============================================

WITH customer_segmentation AS (
    SELECT 
        c.customer_key,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        SUM(f.sales_amount) AS cost_spent,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE c.customer_key IS NOT NULL
    GROUP BY c.customer_key, CONCAT(c.first_name, ' ', c.last_name)
)

-- Final Segmentation Summary
SELECT 
    customer_segment,
    COUNT(*) AS total_customers
FROM (
    SELECT 
        customer_key,
        full_name,
        cost_spent,
        lifespan,
        CASE 
            WHEN cost_spent > 5000 AND lifespan >= 12 THEN 'VIP'
            WHEN cost_spent <= 5000 AND lifespan >= 12 THEN 'REGULAR'
            ELSE 'NEW'
        END AS customer_segment
    FROM customer_segmentation
) t
GROUP BY customer_segment;
