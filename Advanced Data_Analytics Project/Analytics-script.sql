/*
==================================
ADVANCED DATA ANALYTICS PROJECT
==================================

These scripts follows key analytic metrics of the dim_products, dim_customers and fact_sales
--------------------------------------------------------------------------------------------
*/

/*
-----------------------------------
1. CHANGES OVER TIME ANALYSIS
-----------------------------------
*/

-- Analyze Sales Performance Over Time
Select
    order_date,
    SUM(sales_amount) as Total_Sales
    FROM gold.fact_sales
        GROUP BY order_date
            HAVING order_date IS NOT NULL
            ORDER BY order_date ASC

-- Yearly Trend
Select
    DATEPART(YEAR, order_date) as Year_Trend,
    SUM(sales_amount) as Total_Sales,
    COUNT(distinct customer_id) as Customer_count,
    SUM(quantity) as Sold_items
    FROM gold.fact_sales
        Where DATEPART(YEAR, order_date) IS NOT NULL
        GROUP BY DATEPART(YEAR, order_date)
            ORDER BY Year_Trend ASC

-- Year wise Monthly Trends
Select
    DATETRUNC(MONTH, order_date) as Yearly_month_Trends,
    SUM(sales_amount) as Total_Sales
    FROM gold.fact_sales
        GROUP BY DATETRUNC(MONTH, order_date)
            HAVING DATETRUNC(MONTH, order_date) IS NOT NULL
            ORDER BY DATETRUNC(MONTH, order_date) ASC


/*
-----------------------------------
2. CUMULATIVE ANALYSIS
-----------------------------------
*/

-- Calculate the Total Sales per month
Select
    Datetrunc(Month, order_date) as Trend,
    Sum(sales_amount) as Total_Sales
    From gold.fact_sales
        WHERE Datetrunc(Month, order_date) is NOT NULL
        GROUP BY Datetrunc(Month, order_date)
        ORDER BY Datetrunc(Month, order_date)

-- Calculate yearly total sales and Calculate the running total of Sales Over Time
SELECT
    *,
    SUM(Total_Sales) OVER(ORDER BY Year_Trend Rows Between Unbounded preceding and current row) as Running_total
    FROM
    (
SELECT
    YEAR(order_date) as Year_Trend,
    Sum(Sales_amount) as Total_Sales
    FROM gold.fact_sales
        Where  YEAR(order_date) is NOT NULL
        GROUP BY YEAR(order_date)
    )t 
        ORDER BY Year_Trend ASC

-- Calculate Year wise Monthly total sales  and Calculate the running total of Sales Over Time
SELECT
    *,
    SUM(Total_sales) OVER(Partition By Year(Trend) ORDER BY Trend Rows Between unbounded preceding and current row) as Running_total
    From 
    (
Select
    Datetrunc(Month, order_date) as Trend,
    Sum(sales_amount) as Total_Sales
    From gold.fact_sales
        WHERE Datetrunc(Month, order_date) is NOT NULL
        GROUP BY Datetrunc(Month, order_date)
    )t
        ORDER BY Trend ASC

-- Monthly Total Sales and Running total of Monthly Total Sales Over Time
SELECT
    *,
    SUM(Total_sales) OVER(ORDER BY Trend Rows Between unbounded preceding and current row) as Running_total
    From 
    (
Select
    Datetrunc(Month, order_date) as Trend,
    Sum(sales_amount) as Total_Sales
    From gold.fact_sales
        WHERE Datetrunc(Month, order_date) is NOT NULL
        GROUP BY Datetrunc(Month, order_date)
    )t
        ORDER BY Trend ASC

-- Calculate Average Yearly Price and Calculate Moving Average price Over-Time
SELECT
    *,
    AVG(Avg_Price) OVER(ORDER BY Trend Rows Between unbounded preceding and current row)as Moving_Average
    From 
    (
Select
    Datetrunc(YEAR, order_date) as Trend,
    Avg(price) as Avg_Price
    From gold.fact_sales
        WHERE Datetrunc(YEAR, order_date) is NOT NULL
        GROUP BY Datetrunc(YEAR, order_date)
    )t
        ORDER BY Trend ASC

-- Find the Average of Sales in Year 2010
Select
    Sum(sales_amount) / COUNT(*) as Avg_Sales
    From gold.fact_sales
        Where YEAR(order_date) = 2012


/*
-----------------------------------
3. PERFORMANCE ANALYSIS
-----------------------------------
*/

-- Find the Total sales of 2011 and 2012 and then check the performance difference in 2012 from 2011

Select
YEAR(Order_date) as YEAR,
SUM(sales_amount) as Total_Sales,
SUM(sales_amount) - LAG(SUM(sales_amount)) OVER(ORDER BY YEAR(order_date)) as DIFFERENCE
FROM gold.fact_sales
    Where order_date is NOT NULL
    --Where YEAR(order_date) in (2010,2011)
    GROUP BY YEAR(order_date);
GO

-- Analyze the yearly performance of products by comparing each products sales to both its average sales performance 
-- and the previous year's sales
With Year_Sales as
(
Select
    YEAR(s.order_date) as Order_Year,
    p.product_name,
    SUM(s.sales_amount) as Current_Sales
    From gold.fact_sales as s
    LEFT JOIN gold.dim_products as p
    ON s.product_key = p.product_key
        Where order_date is not null  
        GROUP BY YEAR(s.order_date), p.product_name
)
-- Year-Over-Year Analysis
Select
    Order_Year,
    product_name,
    Current_Sales,
    LAG(Current_Sales) OVER(Partition By product_name ORDER BY Order_Year) as Previous_Sales,
    Current_Sales - LAG(Current_Sales) OVER(Partition By product_name ORDER BY Order_Year) as Diff_Sales,
    CASE
        WHEN Current_Sales < LAG(Current_Sales) OVER(Partition By product_name ORDER BY Order_Year)
            THEN 'Decrease '
        WHEN LAG(Current_Sales) OVER(Partition By product_name ORDER BY Order_Year) is null
            THEN 'No Change'
            Else 'Increase'
    END as Sales_Change,
    AVG(Current_Sales) OVER(PARTITION BY product_name) as Avg_Sales,
    Current_Sales - AVG(Current_Sales) OVER(PARTITION BY product_name) as Diff_Avg,
    CASE
        WHEN Current_Sales - AVG(Current_Sales) OVER(PARTITION BY product_name) > AVG(Current_Sales) OVER(PARTITION BY product_name)
            THEN 'Above Average'
            Else 'Below Average'
    END as Avg_Change
    From Year_Sales 
         ORDER BY product_name ASC, Order_Year ASC

-- ----------------------------------------------------------------------------
Select
    order_date,
    product_name,
    Total_Sales,
    LAG(Total_Sales) OVER(Partition By product_name ORDER BY order_date ASC) as Previous_Year_Sales,
    Total_Sales - LAG(Total_Sales) OVER(Partition By product_name ORDER BY order_date ASC) as Sales_Difference,
    AVG(Total_Sales) OVER(Partition By product_name) as _Avg_Sales,
    Total_Sales - AVG(Total_Sales) OVER(Partition By product_name) as Avg_Difference
    From 
    (
Select
    Year(s.order_date) as order_date,
    p.product_name,
    sum(s.sales_amount) as Total_Sales
    From gold.fact_sales as s
    LEFT JOIN gold.dim_products as p
    ON s.product_key = p.product_key
        Where order_date is not null
        GROUP BY p.product_name, Year(s.order_date)
    )t
        Where product_name = 'All-Purpose Bike Stand'
        ORDER BY product_name, order_date asc

/*
-----------------------------------
3. PERFORMANCE ANALYSIS
-----------------------------------
*/

-- Which Categories contribute the most to the overall Sales?
-- Using Sub-Query (Cannot be re-used)
Select
    category, 
    SUM(Contribution) OVER() as Total_Sales,
    Contribution,
    cast(Cast(Round(Contribution * 100.00 / SUM(Contribution) OVER(), 2, 1) as float) as nvarchar) + '%' as Contri_Percent
    From 
    (
Select
    p.category,
    SUM(s.sales_amount) as Contribution
    From gold.fact_sales as s
    LEFT JOIN gold.dim_products as p
    On s.product_key = p.product_key
        GROUP BY p.category
    ) t
        ORDER BY Contribution DESC

-- Using CTE (Can be re-Used)
With Sales AS
(
Select
    p.category,
    SUM(s.sales_amount) as Contribution
    From gold.fact_sales as s
    LEFT JOIN gold.dim_products as p
    On s.product_key = p.product_key
        GROUP BY p.category
)
Select
    category, 
    SUM(Contribution) OVER() as Total_Sales,
    Contribution,
    cast(Cast(Round(Contribution * (100.00) / SUM(Contribution) OVER(), 2, 1) as float) as nvarchar) + '%' as Contri_Percent,
    Cast(Round((Cast(Contribution as Float) / SUM(Contribution) OVER()) * (100), 2) as nvarchar) + '%' as Contri_Percent2 
    From Sales
    ORDER BY Contribution DESC


/*
-----------------------------------
3. DATA SEGMENTATION
-----------------------------------
*/

-- Segment products into cost Ranges and Count how many products fall into each Segmets
With product as
    (
Select
    product_name,
    cost,
    CASE
        WHEN cost < 100 Then '(Below 100)'
        WHEN cost >= 100 and cost <= 500 Then '(100 - 500)'
        WHEN cost > 500 and cost <= 1000 Then '(500 - 1000)'
        Else '(Above 1000)'
    END as Cost_Range
    from gold.dim_products
    )
    Select
    [Cost_Range],
    COUNT(distinct product_name) as Count_of_product
        From product
        GROUP BY [Cost_Range];
GO

/* Group customers into Three Segments based on their spending behaviors: 
VIP:        At least 12 months of history and spendng more than 5000.
REGULAR:    At least 12 month of history but spending 5000 or less.
NEW:        Lifespan less than 12 months.
*/

WITH customer_Data as 
(
SELECT
    c.customer_key,
    concat(c.first_name, ' ', c.last_name) as customer_name,
    SUM(s.sales_amount) as Total_spending,
    MIN(order_date) as First_order,
    MAX(order_date) as Last_order,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan
    FROM gold.fact_sales as s
    LEFT JOIN gold.dim_customers as c
    ON s.customer_key = c.customer_key
        GROUP BY concat(c.first_name, ' ', c.last_name), c.customer_key
)
SELECT
    CASE
        WHEN lifespan > 12 and Total_spending >= 5000 THEN 'VIP'
        WHEN lifespan > 12 and Total_spending < 5000 THEN 'Regular'
        Else 'NEW'
    END as Customer_Segment,
    COUNT(customer_name) as No_of_Customers
    From customer_Data
        GROUP BY CASE
        WHEN lifespan > 12 and Total_spending >= 5000 THEN 'VIP'
        WHEN lifespan > 12 and Total_spending < 5000 THEN 'Regular'
        Else 'NEW'
    END
