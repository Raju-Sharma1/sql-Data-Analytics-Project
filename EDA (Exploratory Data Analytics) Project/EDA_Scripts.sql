/*
=======================================
EDA PROCESS (EXPLORATORY DATA ANALYSIS)
=======================================
*/

/*
-----------------------------------------------------------------
1. DATABASE EXPLORATION:-
		Exploring the Database to understand the Data Structure.
-----------------------------------------------------------------
*/
-- Explore all Objects in the Database (Tables, Views (None in Database - In the Start), Stored Procedures (None in Database - In the start))

Select * from INFORMATION_SCHEMA.TABLES

-- Explore all Columns in the Database

Select * From INFORMATION_SCHEMA.COLUMNS
	Where TABLE_NAME = 'dim_customers'

Select * From INFORMATION_SCHEMA.COLUMNS
	Where TABLE_NAME = 'dim_products'

Select * From INFORMATION_SCHEMA.COLUMNS
	Where TABLE_NAME = 'fact_sales'


/*
-------------------------------------------------------------------------
2. DIMENSION EXPLORATION:-
		- Exploring all the columns in Tables to identify unique values.
		- Recognizing how data might be grouped or segmented, which is
		  is useful for later analysis.
-------------------------------------------------------------------------
*/

-- Exploring all countries our customers come from
Select Distinct
	country
	From gold.dim_customers


-- Explore all Product Categories 'The Major Divisions'
Select Distinct category From gold.dim_products
Select Distinct Subcategory from gold.dim_products
Select Distinct category, subcategory From gold.dim_products
Select Distinct product_name from gold.dim_products
Select Distinct category, subcategory, product_name From gold.dim_products

-- Finding no of times customers appeared, and then from that segmented list aggregating total count how many times they appeared
Select Distinct Customer_count,
	Count(*) No_OF_TIMES_appeared
From (
Select 
	CONCAT(first_name, last_name) as Customer_name,
	COUNT(*) Over(PARTITION BY CONCAT(first_name, last_name)) Customer_count
	From gold.dim_customers
)t
		Group BY Customer_count
	

/*
-------------------------------------------------------------------------
3. DATE EXPLORATION:-
-------------------------------------------------------------------------
*/
-- Find the Date of the First and Last Order
-- How many years of Sales is available

Select
	Min(order_date) First_order,
	Max(order_date) Last_order,
	Cast(DATEDIFF(YEAR, Min(order_date), Max(order_date)) as nvarchar) + ' Years' Year_Diff
	From gold.fact_sales

-- Find the Youngest and Oldest customer (Optional Advanced: Along with Age in it)
SELECT
	Cast(MIN(birthdate) as nvarchar) + ' - '+ Cast(DATEDIFF(Year, MIN(birthdate), GETDATE())  as nvarchar) + ' Age' as Oldest_customer,
	Cast(MAX(birthdate) as nvarchar) + ' - '+ CAST(DATEDIFF(YEAR, Max(birthdate), GETDATE()) as nvarchar) + ' Age' Youngest_customer,
	DATEDIFF(YEAR, MIN(birthdate), MAX(birthdate)) as Years_gap_Bet_Young_Old
	From gold.dim_customers


-- FIND THE OLDEST AND YOUNGEST CUSTOMER (SHOW: Customer name, Birthdate) (Advanced)
Select
	Customer_name,
	Case 
		When Oldest_customer = '1916-02-10' Then 'Oldest '+ Cast(Oldest_customer as Nvarchar)
		When Youngest_customer = '1986-06-25' Then 'Youngest ' + cast(Youngest_customer as nvarchar)
	End Customer_type
	From (	
Select
	CONCAT(first_name, last_name) as Customer_name,
	MIN(birthdate) as Oldest_customer,
	MAX(birthdate) as Youngest_customer
	FROM gold.dim_customers
		GROUP BY CONCAT(first_name, last_name)
	)t
		where Case 
		When Oldest_customer = '1916-02-10' Then 'Oldest'+ Cast(Oldest_customer as Nvarchar)
		When Youngest_customer = '1986-06-25' Then 'Youngest' + cast(Youngest_customer as nvarchar)
	End is not null

-- Find Youngest and Oldest customer (Advanced)
Select
	Case 
		When Oldest_customer = '1916-02-10' Then Customer_name + ' ' + Cast(Oldest_customer as Nvarchar)
	End Oldest_customer1,
	Case
		When Youngest_customer = '1986-06-25' Then Customer_name + ' ' + CAST(Youngest_customer as nvarchar)
	End Youngest_customer1
	From (	
Select
	CONCAT(first_name, last_name) as Customer_name,
	MIN(birthdate) as Oldest_customer,
	MAX(birthdate) as Youngest_customer
	FROM gold.dim_customers
		GROUP BY CONCAT(first_name, last_name)
	)t
		where Case 
		When Oldest_customer = '1916-02-10' Then Customer_name + ' ' + Cast(Oldest_customer as Nvarchar)
	End is not null OR Case
		When Youngest_customer = '1986-06-25' Then Customer_name + ' ' + CAST(Youngest_customer as nvarchar)
	End is NOT NULL

-- Advanced (Better aligned)

Select Distinct
	(Select CONCAT(first_name,' ', last_name) From gold.dim_customers 
		where birthdate = (select MIN(birthdate) from gold.dim_customers)) as 'Customer Name',
	(select MIN(birthdate) from gold.dim_customers) as Birthdate,
	'Oldest' as 'Type'
	from gold.dim_customers
UNION ALL
SELECT DISTINCT
	(Select Top 1 CONCAT(first_name, ' ',last_name) From gold.dim_customers 
		where birthdate = (select MAX(birthdate) from gold.dim_customers)) as  'Customer Name',
	(select MAX(birthdate) from gold.dim_customers) as Birthdate,
	'Youngest' as 'Type'
	From gold.dim_customers
UNION ALL
SELECT DISTINCT
	(Select top 1 CONCAT(first_name,' ', last_name) From gold.dim_customers 
		where birthdate = (select MAX(birthdate) from gold.dim_customers) ORDER BY 1 desc) as 'Customer Name',
	(select MAX(birthdate) from gold.dim_customers) as Birthdate,
	'Youngest' as 'Type'
	From gold.dim_customers

/*
-------------------------------------------------------------------------
3. MEASURES EXPLORATIONS :-
-------------------------------------------------------------------------
*/

-- Find the total sales
Select
	SUM(sales_amount) as Total_Sales
	From gold.fact_sales

-- ---------------------------------------------------

-- Find how many items are sold
Select
	SUM(quantity) as Total_sold_items
	From gold.fact_sales

-- ---------------------------------------------------

-- Find the average selling price
Select
	AVG(price) as Avg_price
	From gold.fact_sales

-- ---------------------------------------------------

-- Find the total number of orders
Select
	order_number,
	COUNT(*)
	From gold.fact_sales
		GROUP BY order_number
			HAVING COUNT(*) > 1
-- We have Duplicate Order_numbers , Hence using Distinct Count

Select
	COUNT(Distinct order_number) as Total_No_of_orders
	From gold.fact_sales

-- ---------------------------------------------------

-- Find the total number of products
Select
	product_id,
	COUNT(*)
	From gold.dim_products
		GROUP BY product_id
			HAVING COUNT(*) > 1
-- No Duplicates Found

Select
	COUNT(product_id) as Total_No_of_products
	From gold.dim_products

-- ---------------------------------------------------

-- Find the total number of customers
Select
	customer_id,
	COUNT(*)
	From gold.dim_customers
		GROUP BY customer_id
			HAVING COUNT(*) > 1
-- No Duplicates Found

Select
	COUNT(customer_id) as Total_No_of_customers
	From gold.dim_customers


Select
	s.customer_id,
	c.customer_id
	From gold.fact_sales as s
	RIGHT JOIN gold.dim_customers as c
		On s.customer_key = c.customer_key
			Where s.customer_id is NULL

-- ---------------------------------------------------

-- Find the total number of customers that has placed an order 
-- (Logic: Order_date Not NUll = Placed orders, Order_date null = Unplaced Orders)
Select
	customer_id,
	COUNT(*)
	From gold.fact_sales
		GROUP BY customer_id
			HAVING COUNT(*) > 1
-- We have Duplicate customer_id, Hence using Distinct Count

Select 
	COUNT(Distinct customer_id) as Customer_with_orders
	From gold.fact_sales

Select
	COUNT(Distinct customer_id) as Total_No_of_customers_with_orders 
	From gold.fact_sales
		Where order_date is NOT NULL

-- Using SUb-Query
Select 
	COUNT(customer) as Total_No_of_customers_with_orders 
	FROM
	(
SELECT Distinct 
	customer_id as customer
	From gold.fact_sales
		Where order_date is NOT NULL	
	)t
-- ---------------------------------------------------

-- Generate all Key metrics of the Business
Select
	SUM(s.sales_amount) as Total_Sales,
	SUM(s.quantity) as Total_items_sold,
	AVG(s.price) as Avg_price,
	COUNT(Distinct s.order_number) as Total_No_of_orders,
	(Select COUNT(distinct product_id) from gold.dim_products )as Total_No_of_products,
	(select COUNT(distinct customer_id) from gold.dim_customers) as Total_No_of_customers,
	COUNT(Distinct s.customer_id) as Customer_with_orders
	From gold.fact_sales as s
	LEFT JOIN gold.dim_customers as c 
		On s.customer_key = c.customer_key

-- Another Better (Advanced)
Select
	'Total Sales' as Measure_Name, SUM(sales_amount) as Measure_Value
	From gold.fact_sales
UNION ALL
Select
	'Total_sold_items' as Measure_Name, SUM(quantity) as Measure_Value
	From gold.fact_sales
UNION ALL
Select
	'Avg_Price' as Measure_Name, AVG(price) as Measure_Value
	From gold.fact_sales
UNION ALL
Select
	'Total_No_of_orders' as Measure_Name, COUNT(Distinct order_number) as Measure_Value
	From gold.fact_sales
UNION ALL
Select
	'Total_No_of_products' as Measure_Name, COUNT(product_id) as Measure_Value
	From gold.dim_products
UNION ALL
Select
	'Total_No_of_customers' as Measure_Name, COUNT(customer_id) as Measure_Value
	From gold.dim_customers
UNION ALL
Select 
	'Customer_with_orders' as Measure_Name, COUNT(Distinct customer_id) as Measure_Value
	From gold.fact_sales


/*
-------------------------------------------------------------------------
5. MAGNITUDE ANALYSIS:-
-------------------------------------------------------------------------
*/

-- FIND THE TOTAL CUSTOMERS BY COUNTRIES -- Logic: COUNT CUSTOMERS GROUP COUNTRIES

Select
	country,
	COUNT( distinct customer_id) as Customer_count
	From gold.dim_customers
		GROUP BY country
		ORDER BY Customer_count DESC

-- FIND TOTAL CUSTOMERS BY GENDER -- Logic: COUNT CUSTOMERS GROUP GENDER

Select
	gender,
	COUNT(distinct customer_id) as Customer_count
	From gold.dim_customers
		GROUP BY gender
		ORDER BY Customer_count DESC

-- FIND TOTAL PRODUCTS BY CATEGORY -- Logic: COUNT PRODUCTS GROUP CATEGORY

Select
	category,
	COUNT(Distinct product_id) as Product_count
	From gold.dim_products
		GROUP BY category
		ORDER BY Product_count DESC

-- WHAT IS THE AVERAGE COST IN EACH CATEGORY ? -- Logic: AVG COST GROUP CATEGORY

Select
	category,
	AVG(cost) as Avg_Cost
	From gold.dim_products
		GROUP BY category
			ORDER BY Avg_Cost DESC

-- WHAT IS THE TOTAL REVENUE GENERATED FOR EACH CATEGORY ? --Logic: SUM SALES GROUP CATEGORY

Select
	p.category,
	SUM(s.sales_amount) as Total_Revenue
	From gold.fact_sales as s 
	LEFT JOIN gold.dim_products as p  
	ON s.product_key = p.product_key
		GROUP BY p.category
		ORDER BY Total_Revenue DESC

-- FIND THE TOTAL REVENUE GENERATED BY EACH CUSTOMER -- Logic: SUM SALES GROUP CUSTOMER

Select Distinct
	c.customer_id,
	CONCAT(c.first_name,' ' , c.last_name) as Customer,
	SUM(s.sales_amount) as Total_Revenue
	From gold.fact_sales as s 
	LEFT JOIN gold.dim_customers as c
	ON s.customer_key = c.customer_key
		GROUP BY c.customer_id, CONCAT(c.first_name,' ' , c.last_name)
		ORDER BY Total_Revenue DESC


-- WHAT IS THE DISTRIBUTION OF SOLD ITEMS ACROSS COUNTRIES ? -- Logic: SUM QUANTITY GROUP COUNTRIES

Select Distinct
	c.country,
	SUM(s.quantity) as Total_sold_items
	From gold.fact_sales as s 
	LEFT JOIN gold.dim_customers as c
	ON s.customer_key = c.customer_key
		GROUP BY c.country
		ORDER BY Total_sold_items DESC

/*
-------------------------------------------------------------------------
5. RANKING ANALYSIS:-
-------------------------------------------------------------------------
*/

-- Ranking Countries with Highest Customer Count
Select
ROW_NUMBER() OVER(ORDER BY Customer_count Desc) as Ranking,
*
From
(
Select
	country,
	COUNT( distinct customer_id) as Customer_count
	From gold.dim_customers
		GROUP BY country
)t 
ORDER BY Customer_count DESC

-- Find the Top 5 Products By Quantity
Select Top 5
	ROW_NUMBER() OVER( ORDER BY SUM(s.quantity) desc) as Ranking,
	p.product_name
	From gold.fact_sales as s
	LEFT JOIN gold.dim_products as p
	ON s.product_key = p.product_key
		GROUP BY p.product_name
	
-- Find Bottom 3 Distinct Customers By Total Sales

Select Top 1
	c.first_name,
	c.last_name,
	SUM(Distinct s.sales_amount) as Total_Sales
	From gold.fact_sales as s
	LEFT JOIN gold.dim_customers as c 
	ON s.customer_key = c.customer_key
		GROUP BY c.first_name, c.last_name
		HAVING SUM(s.sales_amount) = 2
UNION ALL
Select Top 1
	c.first_name,
	c.last_name,
	SUM(s.sales_amount) as Total_Sales
	From gold.fact_sales as s
	LEFT JOIN gold.dim_customers as c 
	ON s.customer_key = c.customer_key
		GROUP BY c.first_name, c.last_name
		HAVING SUM(s.sales_amount) = 4
UNION ALL
Select Top 1
	c.first_name,
	c.last_name,
	SUM(s.sales_amount) as Total_Sales
	From gold.fact_sales as s
	LEFT JOIN gold.dim_customers as c 
	ON s.customer_key = c.customer_key
	GROUP BY c.first_name, c.last_name
	HAVING SUM(s.sales_amount) = 5
	ORDER BY Total_Sales ASC


-- Which 5 products Generate the Highest Revenue
Select Top 5
	p.product_name,
	SUM(s.sales_amount) as Total_Revenue
	From gold.fact_sales as s
	LEFT JOIN gold.dim_products as p
	ON s.product_key = p.product_key
		GROUP BY p.product_name
			ORDER BY Total_Revenue DESC

-- Solving the Same Task using Window Function

Select
	
	*
	FROM
	(
Select
	ROW_NUMBER() OVER( ORDER BY SUM(s.sales_amount) DESC) as Ranking,
	p.product_name,
	SUM(s.sales_amount) as Total_Revenue
	From gold.fact_sales as s
	LEFT JOIN gold.dim_products as p
	ON s.product_key = p.product_key
		GROUP BY p.product_name
	)t
		Where Ranking <=5
	


-- What are the 5 Worst-Performing products in terms of sales?
Select Top 5
	p.product_name,
	SUM(s.sales_amount) as Total_Revenue
	From gold.fact_sales as s
	LEFT JOIN gold.dim_products as p
	ON s.product_key = p.product_key
		GROUP BY p.product_name
			ORDER BY Total_Revenue ASC

-- Find the Top 10 customers who have generated the highest revenue
Select Top 10
	c.customer_id, 
	c.first_name, 
	c.last_name,
	SUM(s.sales_amount) as Total_Revenue
	From gold.fact_sales as s
	LEFT JOIN gold.dim_customers as c
	ON s.customer_key = c.customer_key
		GROUP BY c.customer_id, c.first_name, c.last_name
			ORDER BY Total_Revenue DESC

-- Find 3 customer with fewest orders placed
Select Top 3
	c.customer_id, 
	c.first_name, 
	c.last_name,
	COUNT(Distinct s.order_number) as Orders_count
	From gold.fact_sales as s
	LEFT JOIN gold.dim_customers as c
	ON s.customer_key = c.customer_key
		GROUP BY c.customer_id, c.first_name, c.last_name
			ORDER BY Orders_count ASC
