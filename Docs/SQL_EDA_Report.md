# SQL-Based Exploratory Data Analysis (EDA) for Customer Churn Prediction

## Overview
This document provides a step-by-step **SQL-based Exploratory Data Analysis (EDA)** for the **Customer Churn Prediction** project. The analysis was conducted using **PostgreSQL** in **pgAdmin 4**. The goal is to analyze customer behavior, identify trends, and extract insights to build a robust churn prediction model.

---

## 1. Checking the Number of Records
### **Query:**
```sql
SELECT COUNT(*) FROM churn_data;
```
### **Output:**
The table contains **1000 rows**, indicating the dataset size.

---

## 2. Checking Column Names & Data Types
### **Query:**
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'churn_data';
```
### **Output:**
| Column Name | Data Type |
|------------|----------|
| Churn_Probability | double precision |
| Lifetime_Value | double precision |
| Launch_Date | date |
| Peak_Sales_Date | date |
| Purchase_Frequency | double precision |
| Time_Between_Purchases | double precision |
| Average_Order_Value | double precision |
| Customer_ID | text |
| Retention_Strategy | text |
| Product_ID | text |
| Transaction_ID | text |
| Most_Frequent_Category | text |
| Region | text |
| Season | text |
| Preferred_Purchase_Times | text |

**Insight:**
- The dataset contains **both numerical and categorical columns**.
- **Dates are correctly stored** in the `date` format.

---

## 3. Checking for Missing Values (NULLs) in Each Column
### **Query:**
```sql
SELECT  
    COUNT(*) - COUNT("Customer_ID") AS missing_customer_id,
    COUNT(*) - COUNT("Product_ID") AS missing_product_id,
    COUNT(*) - COUNT("Transaction_ID") AS missing_transaction_id,
    COUNT(*) - COUNT("Purchase_Frequency") AS missing_purchase_frequency,
    COUNT(*) - COUNT("Average_Order_Value") AS missing_average_order_value,
    COUNT(*) - COUNT("Most_Frequent_Category") AS missing_most_frequent_category,
    COUNT(*) - COUNT("Time_Between_Purchases") AS missing_time_between_purchases,
    COUNT(*) - COUNT("Region") AS missing_region,
    COUNT(*) - COUNT("Churn_Probability") AS missing_churn_probability,
    COUNT(*) - COUNT("Lifetime_Value") AS missing_lifetime_value,
    COUNT(*) - COUNT("Launch_Date") AS missing_launch_date,
    COUNT(*) - COUNT("Peak_Sales_Date") AS missing_peak_sales_date,
    COUNT(*) - COUNT("Season") AS missing_season,
    COUNT(*) - COUNT("Preferred_Purchase_Times") AS missing_preferred_purchase_times,
    COUNT(*) - COUNT("Retention_Strategy") AS missing_retention_strategy
FROM churn_data;
```
### **Output:**
All columns have **0 missing values**, meaning the dataset is complete.

---

## 4. Basic Statistics on Numerical Columns
### **Query:**
```sql
SELECT  
    MIN("Purchase_Frequency") AS min_purchase_frequency,  
    MAX("Purchase_Frequency") AS max_purchase_frequency,  
    AVG("Purchase_Frequency") AS avg_purchase_frequency,  
    MIN("Average_Order_Value") AS min_average_order_value,  
    MAX("Average_Order_Value") AS max_average_order_value,  
    AVG("Average_Order_Value") AS avg_average_order_value,
    MIN("Time_Between_Purchases") AS min_time_between_purchases,  
    MAX("Time_Between_Purchases") AS max_time_between_purchases,  
    AVG("Time_Between_Purchases") AS avg_time_between_purchases
FROM churn_data;
```
### **Output:**
| Metric | Purchase Frequency | Average Order Value | Time Between Purchases |
|--------|--------------------|--------------------|--------------------|
| Min | 1 | 20.01 | 5 |
| Max | 19 | 199.96 | 89 |
| Average | 9.96 | 110.01 | 46.88 |

**Insights:**
- The **average purchase frequency is ~10**, indicating repeat customers.
- The **average order value is $110**, with a wide range from $20 to $200.
- The **time between purchases varies widely**, affecting customer retention strategies.

---

## 5. Identifying Top Regions Contributing to Churn
### **Query:**
```sql
SELECT "Region", COUNT(*) AS churned_customers
FROM churn_data
WHERE "Churn_Probability" > 0.5
GROUP BY "Region"
ORDER BY churned_customers DESC
LIMIT 5;
```
### **Output:**
| Region | Churned Customers |
|--------|------------------|
| Asia | 1250 |
| South America | 1241 |
| North America | 1231 |
| Europe | 1209 |

**Insights:**
- **Asia, South America, and North America** have the highest number of churned customers.
- Region-based marketing strategies might be required to **retain customers in these areas**.

---

## 6. Finding Top 5 Most Purchased Product Categories
### **Query:**
```sql
SELECT "Most_Frequent_Category", COUNT(*) AS purchase_count
FROM churn_data
GROUP BY "Most_Frequent_Category"
ORDER BY purchase_count DESC
LIMIT 5;
```
### **Output:**
| Most Frequent Category | Purchase Count |
|------------------------|---------------|
| Electronics | 2567 |
| Clothing | 2510 |
| Home | 2476 |
| Sports | 2447 |

**Insights:**
- **Electronics and Clothing** are the most frequently purchased categories.
- These categories may have the highest impact on **customer retention and churn rates**.

---

## **Conclusion**
By performing **SQL-based EDA**, we:
- Verified the dataset structure and completeness.  
- Identified key statistics on customer behavior.  
- Discovered churn trends by region.  
- Found the most frequently purchased product categories.  

Next, we will **repeat this analysis in VS Code** using **PostgreSQL** to demonstrate proficiency in both environments.