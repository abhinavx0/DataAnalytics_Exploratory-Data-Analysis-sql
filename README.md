# EDA Project: Product & Customer Analytics

## Project Overview
This project performs an extensive **Exploratory Data Analysis (EDA)** on transactional data to derive **insights for products and customers**. Using the `gold` schema, we created consolidated views to analyze sales trends, product performance, customer behavior, and segmentation. The analysis provides **key performance indicators (KPIs)** and actionable insights for business decision-making.  

---

## Data Sources
- **Fact Table:** `gold.fact_sales` – contains transactional sales data including order number, product key, customer key, order date, quantity, and sales amount.  
- **Dimension Tables:**  
  - `gold.dim_products` – contains product details (name, category, subcategory, cost).  
  - `gold.dim_customers` – contains customer details (first name, last name, birthdate, customer number).  

---

## Project Components

### 1. Product Performance Analysis
**Goal:** Understand product-level performance across time and revenue categories.  

**Key Steps:**
- Aggregate product metrics: total orders, total sales, total quantity sold, unique customers, lifespan in months.  
- Segment products based on revenue: High-Performance, Mid-Performance, Low-Performance.  
- Calculate KPIs:
  - **Recency:** Months since last sale.  
  - **Average Order Revenue (AOR):** Total sales / total orders.  
  - **Average Monthly Revenue:** Total sales / lifespan.  
- Analyze **yearly sales trends**:
  - Compare current year sales against average sales across all years.
  - Compare current year sales with previous year.  
  - Label performance as **Good / Bad / Average** and track **year-over-year change (Increase / Decrease / No Change)**.  
- Analyze **monthly trends** with running totals and 3-month moving averages.  

**Questions Answered:**
- Which products are performing best over time?  
- How is a product performing compared to its historical average?  
- Which products show consistent growth or decline?  

---

### 2. Customer Behavior & Segmentation
**Goal:** Understand customer purchasing patterns and segment customers for targeted strategies.  

**Key Steps:**
- Aggregate customer-level metrics:
  - Total orders, total sales, total quantity purchased, total distinct products, lifespan in months.  
- Calculate KPIs:
  - **Recency:** Months since last purchase.  
  - **Average Order Value (AOV):** Total sales / total orders.  
  - **Average Monthly Spend:** Total sales / lifespan.  
- Segment customers by:
  - **Engagement/Tier:** VIP, Regular, New.  
  - **Age Groups:** Under 20, 20–29, 30–39, 40–49, 50+.  

**Questions Answered:**
- Who are the high-value (VIP) customers?  
- Which customers are new vs. regular?  
- What is the age distribution of the customer base?  
- How frequently are customers purchasing, and how much do they spend?  

---

### 3. Sales Trend Analysis
**Goal:** Track and visualize sales trends over time to identify patterns and seasonality.  

**Key Steps:**
- Aggregate monthly and yearly sales data.  
- Calculate running totals (cumulative sales) and moving averages for smoother trend analysis.  
- Analyze total sales, total quantity sold, and total unique customers per month/year.  

**Questions Answered:**
- Are sales increasing or decreasing over time?  
- What months show peak sales activity?  
- How does the sales trend compare across products and customer segments?  

---

## KPIs Calculated

### Product KPIs
- Total Orders  
- Total Sales  
- Total Quantity Sold  
- Unique Customers  
- Lifespan (months)  
- Recency (months since last sale)  
- Average Order Revenue (AOR)  
- Average Monthly Revenue  
- Year-over-Year Growth  

### Customer KPIs
- Total Orders  
- Total Sales  
- Total Quantity Purchased  
- Total Distinct Products Purchased  
- Lifespan (months)  
- Recency (months since last purchase)  
- Average Order Value (AOV)  
- Average Monthly Spend  
- Customer Segmentation (VIP, Regular, New)  

---

## Insights Derived
1. **Product Insights**
   - High-performing products generate over ₹50,000 in total revenue and maintain consistent monthly sales.  
   - Mid-performance products often have irregular sales patterns and may require marketing support.  
   - Products with declining year-over-year sales can be flagged for promotions or review.  

2. **Customer Insights**
   - VIP customers contribute significantly to revenue and have a lifespan of 12+ months.  
   - New customers (<12 months or low spend) can be targeted with retention campaigns.  
   - Age segmentation helps identify the most profitable demographic groups.  

3. **Trend Insights**
   - Monthly and yearly sales trends reveal seasonal spikes and periods of low activity.  
   - Moving averages help smooth out fluctuations to understand underlying performance.  

---

## Project Structure

```
/EDA_Project
│
├─ README.md                     # Project documentation
├─ report_customers.sql          # SQL script to generate customer view
├─ report_products.sql           # SQL script to generate product view
├─ yearly_sales_analysis.sql     # Yearly product performance analysis
├─ monthly_sales_trends.sql      # Monthly sales trends with moving averages
└─ customer_segmentation.sql     # Customer segmentation and lifetime metrics
```

---

## Potential Next Steps
- Integrate **visualization dashboards** using Tableau/Power BI for interactive insights.  
- Extend analysis to include **profitability, discount impact, and product return rates**.  
- Develop **predictive models** for churn, customer lifetime value (CLV), and product demand forecasting.
