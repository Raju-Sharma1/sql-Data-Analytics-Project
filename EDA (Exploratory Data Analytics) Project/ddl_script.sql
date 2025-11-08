-- Switching to Master Database to create a Database in the system.
USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database.
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE DataWarehouseAnalytics
END;
GO

-- Creating 'DataWarehouseAnalytics' Database.
CREATE DATABASE DataWarehouseAnalytics;
GO

-- Switching to 'DataWarehouseAnalytics' Database to starting building it.
USE DataWarehouseAnalytics;
GO

-- Creating Schemas
CREATE SCHEMA gold;
GO

/*
=========================================================
Creating Tables in the Database 'DataWarehouseAnalytics'
=========================================================
DDL Commands
------------
*/

-- Creating Table 'gold.dim_customers'
CREATE TABLE gold.dim_customers (
    customer_key INT,
	customer_id INT,
	customer_number NVARCHAR(50),
	first_name NVARCHAR(50),
	last_name NVARCHAR(50),
	country NVARCHAR(50),
	marital_status NVARCHAR(50),
	gender NVARCHAR(50),
	birthdate DATE,
	create_date DATE
);
GO

-- Creating Table 'gold.dim_products'
CREATE TABLE gold.dim_products(
	product_key INT ,
	product_id INT ,
	product_number NVARCHAR(50) ,
	product_name NVARCHAR(50) ,
	category_id NVARCHAR(50) ,
	category NVARCHAR(50) ,
	subcategory NVARCHAR(50) ,
	maintenance NVARCHAR(50) ,
	cost INT,
	product_line NVARCHAR(50),
	start_date DATE 
);
GO

--Creating Table 'gold.fact_sales'
CREATE TABLE gold.fact_sales (
    order_number NVARCHAR(50),
    product_key INT,
    customer_key INT,
    customer_id INT,
    order_date DATE,
    shipping_date DATE,
    due_date DATE,
    sales_amount INT,
    quantity TINYINT,
    price INT
);
GO
