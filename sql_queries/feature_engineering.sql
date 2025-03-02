-- Fetching first 5 rows to check the dataset is loaded properly
SELECT * FROM churn_data LIMIT 5;

-- Checking table structure
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'churn_data';

-- HANDLING MISSING VALUES

-- Checking for the missing values in each column

SELECT 
    column_name, 
    SUM(CASE WHEN value IS NULL THEN 1 ELSE 0 END) AS missing_values
FROM (
    SELECT 'Customer_ID' AS column_name, 'Customer_ID' AS value FROM churn_data
    UNION ALL
    SELECT 'Product_ID', 'Product_ID' FROM churn_data
    UNION ALL
    SELECT 'Transaction_ID', 'Transaction_ID' FROM churn_data
    UNION ALL
    SELECT 'Purchase_Frequency', 'Purchase_Frequency' FROM churn_data
    UNION ALL
    SELECT 'Average_Order_Value', 'Average_Order_Value' FROM churn_data
    UNION ALL
    SELECT 'Most_Frequent_Category', 'Most_Frequent_Category' FROM churn_data
    UNION ALL
    SELECT 'Time_Between_Purchases', 'Time_Between_Purchases' FROM churn_data
    UNION ALL
    SELECT 'Region', 'Region' FROM churn_data
    UNION ALL
    SELECT 'Churn_Probability', 'Churn_Probability' FROM churn_data
    UNION ALL
    SELECT 'Lifetime_Value', 'Lifetime_Value' FROM churn_data
    UNION ALL
    SELECT 'Launch_Date', 'Launch_Date' FROM churn_data
    UNION ALL
    SELECT 'Peak_Sales_Date', 'Peak_Sales_Date' FROM churn_data
    UNION ALL
    SELECT 'Season', 'Season' FROM churn_data
    UNION ALL
    SELECT 'Preferred_Purchase_Times', 'Preferred_Purchase_Times' FROM churn_data
    UNION ALL
    SELECT 'Retention_Strategy', 'Retention_Strategy' FROM churn_data
) subquery
GROUP BY column_name
ORDER BY missing_values DESC;

-- from the above it's confirmed that there are no missing values in the dataset

/*
Creating new column based on existing data to improve model performance.
This identify trends related to time-based patterns.
*/

-- Extracting Year and Month from Dates
ALTER TABLE churn_data ADD COLUMN launch_year INT;
UPDATE churn_data SET launch_year = EXTRACT(YEAR FROM "Launch_Date");

ALTER TABLE churn_data ADD COLUMN launch_month INT;
UPDATE churn_data SET launch_month = EXTRACT(MONTH FROM "Launch_Date");

-- Calculating how long customer has been associated with the business
ALTER TABLE churn_data ADD COLUMN customer_tenure INT;
UPDATE churn_data
SET customer_tenure = EXTRACT(YEAR FROM CURRENT_DATE) - launch_year;

-- Checking about the purchase made by the customer last time
ALTER TABLE churn_data ADD COLUMN recency INT;
UPDATE churn_data 
SET recency = EXTRACT(DAY FROM CURRENT_DATE - "Peak_Sales_Date");

-- Creating a score based on 'Purchase_Frequency', 'Average_Order_Value', and 'Time_Between_Purchases'
ALTER TABLE churn_data ADD COLUMN engagement_score INT;
UPDATE churn_data
SET engagement_score = ("Purchase_Frequency" * "Average_Order_Value") / NULLIF("Time_Between_Purchases", 0);

SELECT * FROM churn_data LIMIT 10; -- all the new columns displayed

-- Checking for any NULL values in the new columns
SELECT
    COUNT(*) AS total_rows,
    COUNt(launch_year) AS launch_year_filled,
    COUNt(launch_month) AS launch_month_filled,
    COUNt(customer_tenure) AS customer_tenure_filled,
    COUNt(recency) AS recency_filled,
    COUNt(engagement_score) AS engagement_score_filled
FROM churn_data;

-- From the Output, recency and engagement_score have NULL values filled in it

SELECT "Peak_Sales_Date" FROM churn_data LIMIT 10;

-- updating recency with explicit date subtraction which returns the difference in days on subtracting two date columns
UPDATE churn_data
SET recency = CURRENT_DATE - "Peak_Sales_Date";

SELECT "Time_Between_Purchases" FROM churn_data LIMIT 10; -- did not found any Null values

-- Checking if there are any NULL values
SELECT COUNT(*)
FROM churn_data
WHERE "Time_Between_Purchases" IS NULL;

-- Checking if there are any 0 in this coulmn
SELECT COUNT(*) 
FROM churn_data 
WHERE "Time_Between_Purchases" = 0;

-- Checking if there is any NULL values in "Purchase_Frequency" or "Average_Order_Value"
SELECT COUNT(*) 
FROM churn_data 
WHERE "Purchase_Frequency" IS NULL OR "Average_Order_Value" IS NULL;

UPDATE churn_data
SET engagement_score = ("Purchase_Frequency" * "Average_Order_Value") / "Time_Between_Purchases";

-- Chekcing again for any NULL values after updating
SELECT
    COUNT(*) AS total_rows,
    COUNt(launch_year) AS launch_year_filled,
    COUNt(launch_month) AS launch_month_filled,
    COUNt(customer_tenure) AS customer_tenure_filled,
    COUNt(recency) AS recency_filled,
    COUNt(engagement_score) AS engagement_score_filled
FROM churn_data;

-- Checking Min and Max values for key features
SELECT
    MIN("Purchase_Frequency") AS min_purchase_freq, MAX("Purchase_Frequency") AS max_purchase_freq,
    MIN("Average_Order_Value") AS min_order_value, MAX("Average_Order_Value") AS max_order_value,
    MIN("Time_Between_Purchases") AS min_time_between, MAX("Time_Between_Purchases") AS max_time_between,
    MIN("customer_tenure") AS min_tenure, MAX("customer_tenure") AS max_tenure,
    MIN("recency") AS min_recency, MAX("recency") AS max_recency,
    MIN("engagement_score") AS min_engagement, MAX("engagement_score") AS max_engagement
FROM churn_data;

-- Checking for the unique values in each categorical columns
SELECT DISTINCT "Most_Frequent_Category" FROM churn_data;
SELECT DISTINCT "Region" FROM churn_data;
SELECT DISTINCT "Season" FROM churn_data;
SELECT DISTINCT "Preferred_Purchase_Times" FROM churn_data;
SELECT DISTINCT "Retention_Strategy" FROM churn_data;

-- Min Max scaling because recency (424–788) and engagement_score (0–689) have much larger ranges compared to other features

-- Adding new columns for Min-Max Scaled values
ALTER TABLE churn_data ADD COLUMN purchase_freq_scaled FLOAT;
ALTER TABLE churn_data ADD COLUMN avg_order_value_scaled FLOAT;
ALTER TABLE churn_data ADD COLUMN time_between_scaled FLOAT;
ALTER TABLE churn_data ADD COLUMN customer_tenure_scaled FLOAT;
ALTER TABLE churn_data ADD COLUMN recency_scaled FLOAT;
ALTER TABLE churn_data ADD COLUMN engagement_score_scaled FLOAT;

-- Performing Min-Max- Scaling
UPDATE churn_data
SET purchase_freq_scaled = ("Purchase_Frequency" - (SELECT MIN("Purchase_Frequency") FROM churn_data)) / ((SELECT MAX("Purchase_Frequency") FROM churn_data) - (SELECT MIN("Purchase_Frequency") FROM churn_data));

UPDATE churn_data
SET avg_order_value_scaled = ("Average_Order_Value" - (SELECT MIN("Average_Order_Value") FROM churn_data)) / ((SELECT MAX("Average_Order_Value") FROM churn_data) - (SELECT MIN("Average_Order_Value") FROM churn_data));

UPDATE churn_data
SET time_between_scaled = ("Time_Between_Purchases" - (SELECT MIN("Time_Between_Purchases") FROM churn_data)) / ((SELECT MAX("Time_Between_Purchases") FROM churn_data) -(SELECT MIN("Time_Between_Purchases") FROM churn_data));

UPDATE churn_data
SET customer_tenure_scaled = ("customer_tenure" - (SELECT MIN("customer_tenure") FROM churn_data)) / ((SELECT MAX("customer_tenure") FROM churn_data) - (SELECT MIN("customer_tenure") FROM churn_data));

UPDATE churn_data
SET recency_scaled = ("recency" - (SELECT MIN("recency") FROM churn_data)) / ((SELECT MAX("recency") FROM churn_data) - (SELECT MIN("recency") FROM churn_data));

update churn_data
SET engagement_score_scaled = ("engagement_score" - (SELECT MIN("engagement_score") FROM churn_data)) / ((SELECT MAX("engagement_score") FROM churn_data) - (SELECT MIN("engagement_score") FROM churn_data));

SELECT purchase_freq_scaled, avg_order_value_scaled, time_between_scaled, customer_tenure_scaled, recency_scaled, engagement_score_scaled
FROM churn_data
LIMIT 10;

-- Standardization using Z-score scaling

-- Add new columns for Standardized values
ALTER TABLE churn_data ADD COLUMN purchase_freq_standardized FLOAT;
ALTER TABLE churn_data ADD COLUMN avg_order_value_standardized FLOAT;
ALTER TABLE churn_data ADD COLUMN time_between_standardized FLOAT;
ALTER TABLE churn_data ADD COLUMN customer_tenure_standardized FLOAT;
ALTER TABLE churn_data ADD COLUMN recency_standardized FLOAT;
ALTER TABLE churn_data ADD COLUMN engagement_score_standardized FLOAT;

-- Standardization
UPDATE churn_data
SET purchase_freq_standardized = ("Purchase_Frequency" - (SELECT AVG("Purchase_Frequency") FROM churn_data)) / (SELECT STDDEV("Purchase_Frequency") FROM churn_data);

UPDATE churn_data
SET avg_order_value_standardized = ("Average_Order_Value" - (SELECT AVG("Average_Order_Value") FROM churn_data)) / (SELECT STDDEV("Average_Order_Value") FROM churn_data);

UPDATE churn_data
SET time_between_standardized = ("Time_Between_Purchases" - (SELECT AVG("Time_Between_Purchases") FROM churn_data)) / (SELECT STDDEV("Time_Between_Purchases") FROM churn_data);

UPDATE churn_data
SET customer_tenure_standardized = ("customer_tenure" - (SELECT AVG("customer_tenure") FROM churn_data)) / (SELECT STDDEV("customer_tenure") FROM churn_data);

UPDATE churn_data
SET recency_standardized = ("recency" - (SELECT AVG("recency") FROM churn_data)) / (SELECT STDDEV("recency") FROM churn_data);

UPDATE churn_data
SET engagement_score_standardized = ("engagement_score" - (SELECT AVG("engagement_score") FROM churn_data)) / (SELECT STDDEV("engagement_score") FROM churn_data);

SELECT purchase_freq_standardized, avg_order_value_standardized, time_between_standardized, customer_tenure_standardized, recency_standardized, engagement_score_standardized
FROM churn_data
LIMIT 10;

-- Observations: 'recency_scaled' and 'engagement_score_scaled' in Min-Max Scaling are all 0. Standardization maintains variance, but some values are extreme

-- Checking statistics for each numerical feature
SELECT
    MIN("Purchase_Frequency") AS min_val,
    MAX("Purchase_Frequency") AS max_val,
    AVG("Purchase_Frequency") AS avg_val,
    STDDEV("Purchase_Frequency") AS std_dev
FROM churn_data;

SELECT
    MIN("Average_Order_Value") AS min_val,
    MAX("Average_Order_Value") AS max_val,
    AVG("Average_Order_Value") AS avg_val,
    STDDEV("Average_Order_Value") AS std_dev
FROM churn_data;

SELECT
    MIN("Time_Between_Purchases") AS min_val,
    MAX("Time_Between_Purchases") AS max_val,
    AVG("Time_Between_Purchases") AS avg_val,
    STDDEV("Time_Between_Purchases") AS std_dev
FROM churn_data;

SELECT
    MIN("customer_tenure") AS min_val,
    MAX("customer_tenure") AS max_val,
    AVG("customer_tenure") AS avg_val,
    STDDEV("customer_tenure") AS std_dev
FROM churn_data;

SELECT
    MIN("recency") AS min_val,
    MAX("recency") AS max_val,
    AVG("recency") AS avg_val,
    STDDEV("recency") AS std_dev
FROM churn_data;

SELECT
    MIN("engagement_score") AS min_val,
    MAX("engagement_score") AS max_val,
    AVG("engagement_score") AS avg_val,
    STDDEV("engagement_score") AS std_dev
FROM churn_data;