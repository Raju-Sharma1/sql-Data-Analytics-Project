/*
========================================================================================

===============================
Creating View : CUSTOMER REPORT
===============================

Purpose:
-------
        - This report consolidates key customer metrics and behaviours

Highlights:
----------
        1. Gathers essential fields such as names, ages, and transaction details.
        2. Segments customers into categories (VIP, Regular, New) and age groups.
        3. Aggregates customer-level metrics:
            - Total orders
            - Total sales
            - Total quantity purchased
            - Total products
            - Lifespan (In Months)
        4. Calculates valuable KPI's:
            - Recency (Months since last order)
            - Average order value
            - Average monthly spend

========================================================================================
*/

CREATE View gold.Customer_Report as 
With base_query AS 
(
Select
    s.order_number,
    s.product_key,
    s.order_date,
    s.sales_amount,
    s.quantity,
    c.customer_key,
    c.customer_number,
    Concat(c.first_name, ' ', c.last_name) as Customer_Name,
    YEAR(GETDATE()) - YEAR(c.birthdate) as Age
    From gold.fact_sales as s
    LEFT JOIN gold.dim_customers as c
    on s.customer_key = c.customer_key
),
    customer_aggregation AS
    (
    Select
        customer_key,
        customer_number,
        Customer_Name,
        Age,
        COUNT(order_number) as Total_Orders,
        SUM(sales_amount) as Total_Sales,
        SUM(quantity) as Total_Quantity_purchased,
        COUNT(Distinct product_key) as Total_products,
        MAX(order_date) as Last_Order,
        MIN(order_date) as First_Order,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as Lifespan
        From base_query
            GROUP BY 
                    customer_key,
                    customer_number,
                    Customer_Name,
                    Age
    )
        Select
            b.customer_key,
            c.Customer_Name,
            CASE
                WHEN b.Age < 20 Then 'Under 20'
                WHEN b.Age between 20 and 29 Then '20-29'
                WHEN b.Age between 30 and 39 Then '30-39'
                WHEN b.Age between 40 and 49 Then '40-49'
                ELSE '50 and Above'
            END as Age_Group,
            c.lifespan,
            CASE
                WHEN lifespan > 12 and Total_Sales >= 5000 THEN 'VIP'
                WHEN lifespan > 12 and Total_Sales < 5000 THEN 'Regular'
                Else 'NEW'
            END as Customer_Segment,
            cast(DATEDIFF(MONTH, c.First_Order, c.Last_Order) as Nvarchar) + '-Months' as Recency,
            CASE
                WHEN c.Total_Sales = 0 Then 0
                ELSE c.Total_Sales / c.Total_Orders
            END Avg_Order_Value,
            AVG(MONTH(Total_Sales)) as Avg_Monthly_Spend,
            CASE
                WHEN Lifespan = 0 Then 0
                ELSE c.Total_Sales / c.Lifespan
            END as Avg_Monthly_Spend1           
            From base_query as b
            LEFT JOIN customer_aggregation as c
            On b.customer_key = c.customer_key
                GROUP BY
                        b.customer_key,
                        c.Customer_Name,
                        CASE
                            WHEN lifespan > 12 and Total_Sales >= 5000 THEN 'VIP'
                            WHEN lifespan > 12 and Total_Sales < 5000 THEN 'Regular'
                        Else 'NEW'
                        END,
                        CASE
                            WHEN b.Age < 20 Then 'Under 20'
                            WHEN b.Age between 20 and 29 Then '20-29'
                            WHEN b.Age between 30 and 39 Then '30-39'
                            WHEN b.Age between 40 and 49 Then '40-49'
                        ELSE '50 and Above'
                        END,
                        cast(DATEDIFF(MONTH, c.First_Order, c.Last_Order) as Nvarchar) + '-Months',
                        -- Compute Average Order Value (AVO)
                        CASE
                            WHEN c.Total_Sales = 0 Then 0
                            ELSE c.Total_Sales / c.Total_Orders
                        END,
                        c.Lifespan,
                        CASE
                            WHEN Lifespan = 0 Then 0
                            ELSE c.Total_Sales / c.Lifespan
                        END;
