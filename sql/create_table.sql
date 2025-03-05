DROP TABLE IF EXISTS churn_data;

CREATE TABLE churn_data (
    CustomerID SERIAL PRIMARY KEY,
    Average_Order_Value FLOAT,
    Time_Between_Purchases_log FLOAT,
    purchase_behavior FLOAT,
    Churn_Probability INT
);