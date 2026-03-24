use Datawarehouse

/*
                        Sales Analysis
                        --------------
*/
/*
Revenue by product category:
==============================================
*/
SELECT
    p.category,
    SUM(s.Sales_amount) as Total_Revenue
    From gold.fact_sales as s 
    LEFT JOIN gold.dim_products as p
        ON s.product_key = p.product_key
    GROUP BY p.category

/*
Monthly Sales Trends:
==============================================
*/
SELECT
    DATENAME(MONTH, order_date) as Months,
    SUM(Sales_amount) as Total_sales
    FROM gold.fact_sales
        GROUP BY 
                DATENAME(MONTH, order_date),
                Month(order_date)
            Having DATENAME(MONTH, order_date) is NOT NULL
        ORDER BY Month(order_date) ASC

/*
Top Performing Products: (Top 5)
================================================
*/

Select Top 5
    p.product_name,
    SUM(s.Sales_amount) as Total_Sales
    From gold.fact_sales as s
    LEFT JOIN gold.dim_products as p
        ON p.product_key =  s.product_key
    GROUP BY p.product_name
    ORDER BY Total_Sales DESC
/*
=======================================================
=======================================================
*/

/*
                        Customer Analysis
                        -----------------
*/

/*
Top Customers:
================================================
*/

Select
    CONCAT(c.first_name,' ', c.last_name) as customer_name,
    COUNT(s.customer_id) as Total_orders
    From gold.fact_sales as s 
    LEFT JOIN gold.dim_customers as c
        ON s.customer_id = c.customer_id
    GROUP BY CONCAT(c.first_name,' ', c.last_name)
    ORDER BY Total_orders DESC

/*
Here I am writing this code to check whether there are any duplicates in the customer_names
*/

Select
    concat(first_name, ' ', last_name) as customer_name,
    birthdate,
    COUNT(*) as Total_count
    From gold.dim_customers
    GROUP BY 
        concat(first_name, ' ', last_name),
        birthdate
    HAVING COUNT(*) > 1

/*
    Customer Purchase Frequency
    ===========================
*/

Select
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    s.customer_id as customerid,
    COUNT(s.customer_id) as Purchase_Frequency
    From gold.fact_sales as s
    LEFT JOIN gold.dim_customers as c
        ON s.customer_id = c.customer_id
    GROUP BY 
            CONCAT(c.first_name, ' ', c.last_name),
            s.customer_id

/*
    Customer Lifetime Value
    =======================
*/

Select
    CONCAT(c.first_name, ' ', c.last_name) as Customer_Name,
    SUM(s.Sales_amount) as Lifetime_Value
    From gold.fact_sales as s
    Join gold.dim_customers as c
        ON s.customer_id = c.customer_id
    GROUP BY
        CONCAT(c.first_name, ' ', c.last_name)
    ORDER BY
        Lifetime_Value DESC

/*
=======================================================
=======================================================
*/


/*
                        Geographic Analysis
                        -------------------
*/

/*
    Sales By Region
    ===============
*/

Select * from gold.fact_sales
Select * from gold.dim_customers

Select
    c.country as Country,
    SUM(s.Sales_amount) as Total_Sales
    From gold.fact_sales as s
    JOIN gold.dim_customers as c
        ON s.customer_id = c.customer_id
    GROUP BY
        c.country
    ORDER BY
        Total_Sales DESC

/*
    Regional Growth Trends
    ======================
*/

SELECT
    c.country as Country,
    Coalesce(SUM(
        Case 
            When YEAR(s.order_date) = 2010 Then s.sales_amount
            END    
        ), 0) as '2010_Sales',
    Coalesce(SUM(
        CASE 
            WHEN YEAR(s.order_date) = 2011 THEN s.sales_amount
            END
        ), 0) as '2011_Sales',
    Coalesce(SUM(
        CASE 
            WHEN YEAR(s.order_date) = 2012 THEN s.sales_amount
            END
        ), 0) as '2012_Sales',
    Coalesce(SUM(
        CASE 
            WHEN YEAR(s.order_date) = 2013 THEN s.sales_amount
            END
        ), 0) as '2013_Sales',
    Coalesce(SUM(
        CASE 
            WHEN YEAR(s.order_date) = 2014 THEN s.sales_amount
            END
        ),0) as '2014_Sales'
    FROM gold.fact_sales as s
    JOIN gold.dim_customers as c
        ON s.customer_id = c.customer_id
    GROUP BY c.country
