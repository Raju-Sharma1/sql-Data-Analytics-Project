/*
========================================================================================

===============
Creating View: PRODUCT REPORT
===============

Purpose:
-------
        - This report consolidates key product metrics and behaviours

Highlights:
----------
        1. Gathers essential fields such as product name, Category, sub-category and cost.
        2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
        3. Aggregates product-level metrics:
            - Total orders
            - Total sales
            - Total quantity purchased
            - Total customers (unique)
            - Lifespan (In Months)
        4. Calculates valuable KPI's:
            - Recency (Months since last order)
            - Average order revenue
            - Average monthly revenue

========================================================================================
*/


-- Taking out all the required Columns from both Fact_Sales and Dim_products Tables in (CTE product_data)
CREATE VIEW gold.Product_Report AS
WITH product_info as
(
Select
    s.order_number,
    s.order_date,
    s.customer_key,
    s.sales_amount,
    s.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
    From gold.fact_sales as s
    LEFT JOIN gold.dim_products as p
    On s.product_key = p.product_key
        Where s.order_date is not null -- Considering only valid sales Dates
),
-- Aggregating key metrics required CTE
Product_Aggregation AS
(
Select
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as LifeSpan,
    MAX(order_date) as last_order_date,
    COUNT(distinct customer_key) as Total_Customers,
    SUM(sales_amount) as Total_Sales,
    COUNT(distinct order_number) as Total_Orders,
    SUM(quantity) as Total_Quantity_purchased,
    AVG(sales_amount)as Avg_Selling_Price
    From product_info
        GROUP BY 
                product_key,
                product_name,
                category,
                subcategory,
                cost
)
Select
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_order_date,
    DATEDIFF(MONTH, last_order_date, GETDATE()) Recency_in_months,
    CASE
        WHEN Total_Sales > 50000 THEN 'High-Performer'
        WHEN Total_Sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-performer'
    END as Product_Segment,
    LifeSpan,
    Total_Orders,
    Total_Sales,
    Total_Quantity_purchased,
    Total_Customers,
    Avg_Selling_Price,
    -- Average Order Revenue
    CASE
        WHEN Total_Orders = 0 THEN 0
        ELSE Total_Sales / Total_Orders
    END as Avg_Order_Revenue,
    -- Average Monthly Revenue
    CASE
        WHEN LifeSpan = 0 THEN 0
        ELSE Total_Sales / LifeSpan
    END as Avg_Monthly_Revenue 
    From Product_Aggregation;
