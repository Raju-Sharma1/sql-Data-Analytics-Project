import pandas as pd


#                             Cleaning Customers Tables Data:
#                             xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

file = "C:/Users/rajsh/OneDrive/Desktop/SQL Project/Data Analytics Project/gold.dim_customers.csv"

dim_customers = pd.read_csv(file)
print(dim_customers)
dim_customers.isnull().sum()

# Handling missing values.
#=========================

dim_customers["country"] = dim_customers["country"].fillna(dim_customers["country"].mode()[0])
dim_customers["gender"] = dim_customers["gender"].fillna(dim_customers["gender"].mode()[0])
dim_customers["birthdate"] = dim_customers["birthdate"].fillna("Unknown")

# Updating the csv file.
#=======================
dim_customers.to_csv("Cleaned_gold.dim_customers.csv", index=False)
#=======================================================================================================
#=======================================================================================================

#                             Cleaning Products Table Data:
#                             xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

file = "C:/Users/rajsh/OneDrive/Desktop/SQL Project/Data Analytics Project/gold.dim_products.csv"

dim_products = pd.read_csv(file)
dim_products
dim_products.isnull().sum()

# Handling null values.
#======================
dim_products = dim_products.fillna("Unknown")

# Updating the csv file.
#=======================
dim_products.to_csv("Cleaned_gold.dim_products.csv", index=False)
#=======================================================================================================
#=======================================================================================================

#                             Cleaning Sales Tables Data:
#                             xxxxxxxxxxxxxxxxxxxxxxxxxxx

file = "C:/Users/rajsh/OneDrive/Desktop/SQL Project/Data Analytics Project/gold.fact_sales2.csv"

fact_sales = pd.read_csv(file)

fact_sales.isnull().sum()

# Handling null vales.
#=====================
fact_sales["order_date"] = pd.to_datetime(fact_sales["order_date"])
fact_sales["shipping_date"] = pd.to_datetime(fact_sales["shipping_date"])
fact_sales["due_date"] = pd.to_datetime(fact_sales["due_date"])
fact_sales["order_date"] = fact_sales["order_date"].fillna(fact_sales["shipping_date"] - pd.Timedelta(days=7))
fact_sales["order_date"] = str(fact_sales["order_date"])
fact_sales["shipping_date"] = str(fact_sales["shipping_date"])

# checking if the date was filled correctly in the missing columns.
#==================================================================
fact_salesfiltered = fact_sales[fact_sales["order_number"] == "SO64338"]
fact_salesfiltered[["order_date", "shipping_date"]]
fact_sales.dtypes

fact_sales[["order_date", "shipping_date", "due_date"]]

# Updating the csv file.
#=======================
fact_sales.to_csv("Cleaned_gold.fact_sales.csv", index=False)

#=======================================================================================================
#=======================================================================================================
