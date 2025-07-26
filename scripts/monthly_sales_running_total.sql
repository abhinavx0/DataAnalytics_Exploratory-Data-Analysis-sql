-- ================================================
-- Monthly Sales Trend with Running Total and Moving Average
-- ================================================
SELECT 
	order_date,                                 -- Monthly bucket (1st of each month)
    total_sales,                                -- Total sales for the month
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total,     -- Cumulative sales up to current month
    AVG(avg_price) OVER (ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_average -- 3-month moving average
FROM (
	SELECT 
		DATE_FORMAT(order_date, '%Y-%m-01') AS order_date, -- Standardize to first day of month
		SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
) t;
