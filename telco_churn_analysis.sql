SELECT *
FROM telco_churn;

DESCRIBE telco_churn;

/* Renaming column names, replacing capital first letter with lowercase and adding underscore in between*/

ALTER TABLE telco_churn
RENAME COLUMN customerID to customer_id;

ALTER TABLE telco_churn
RENAME COLUMN SeniorCitizen to senior_citizen;

ALTER TABLE telco_churn
RENAME COLUMN Partner to partner;

ALTER TABLE telco_churn
RENAME COLUMN Dependents to dependents;

ALTER TABLE telco_churn
RENAME COLUMN tenure to tenure_months;

ALTER TABLE telco_churn
RENAME COLUMN PhoneService to phone_service;

ALTER TABLE telco_churn
RENAME COLUMN MultipleLines to multiple_lines;

ALTER TABLE telco_churn
RENAME COLUMN InternetService to internet_service;

ALTER TABLE telco_churn
RENAME COLUMN OnlineSecurity to online_security;

ALTER TABLE telco_churn
RENAME COLUMN OnlineBackup to online_backup;

ALTER TABLE telco_churn
RENAME COLUMN DeviceProtection to device_protection;

ALTER TABLE telco_churn
RENAME COLUMN TechSupport to tech_support;

ALTER TABLE telco_churn
RENAME COLUMN StreamingTV to streaming_tv;

ALTER TABLE telco_churn
RENAME COLUMN StreamingMovies to streaming_movies;

ALTER TABLE telco_churn
RENAME COLUMN Contract to contract;

ALTER TABLE telco_churn
RENAME COLUMN PaperlessBilling to paperless_billing;

ALTER TABLE telco_churn
RENAME COLUMN MonthlyCharges to monthly_charges;

ALTER TABLE telco_churn
RENAME COLUMN PaymentMethod to payment_method;

ALTER TABLE telco_churn
RENAME COLUMN TotalCharges to total_charges;

ALTER TABLE telco_churn
RENAME COLUMN Churn to churn;

SHOW COLUMNS FROM telco_churn;

-- Overall Churn Rate
SELECT ROUND(SUM(CASE WHEN churn = "Yes" THEN 1 ELSE 0 END)*100.00 / COUNT(*) , 2) AS Churned_Customer
FROM telco_churn;

-- Churn Rate based on Internet Service (Yes)
SELECT ROUND(SUM(CASE WHEN churn = "Yes" THEN 1 ELSE 0 END)*100.00 / COUNT(*) , 2) AS Churned_Customer, internet_service
FROM telco_churn
WHERE internet_service != "No"
GROUP BY internet_service;

WITH internet_service_yes AS (
	SELECT internet_service, churn
    FROM telco_churn
    WHERE internet_service != "No"
)
SELECT internet_service, churn, ROUND(COUNT(*)*100.00 / SUM(COUNT(*)) OVER(PARTITION BY internet_service) , 2) AS Churned_Customer
FROM internet_service_yes
GROUP BY internet_service, churn
ORDER BY internet_service, churn DESC;

SELECT contract, COUNT(*)
FROM telco_churn
GROUP BY contract;

-- Churned customer pct per contract

SELECT contract, churn, COUNT(*) AS Total, ROUND(COUNT(*)*100.00 / SUM(COUNT(*)) OVER(PARTITION BY contract) , 2) AS Churned_Customer
FROM telco_churn
GROUP BY contract, churn
ORDER BY contract, churn DESC;

-- Churned customer pct per Phone Service

SELECT phone_service, churn, COUNT(*) AS Total, ROUND(COUNT(*)*100.00 / SUM(COUNT(*)) OVER(PARTITION BY phone_service) , 2) AS Churned_Customer
FROM telco_churn
WHERE phone_service = "Yes"
GROUP BY phone_service, churn
ORDER BY phone_service, churn DESC;

-- Churned customer pct per Internet Service

SELECT internet_service, churn, COUNT(*) AS Total, ROUND(COUNT(*)*100.00 / SUM(COUNT(*)) OVER(PARTITION BY internet_service) , 2) AS Churned_Customer
FROM telco_churn
WHERE internet_service != "No"
GROUP BY internet_service, churn
ORDER BY internet_service, churn DESC;

SELECT SUM(churn = "Yes")*100.00 / COUNT(*), COUNT(*)
FROM telco_churn
WHERE internet_service != "No";

SELECT
    ROUND(SUM(churn = 'Yes') * 100.00 / COUNT(*) , 2) AS churn_rate
FROM telco_churn
WHERE internet_service != 'No';

SELECT internet_service, contract, COUNT(contract) AS Total, ROUND(AVG(monthly_charges),2) AS Average_Monthly_Charges
FROM telco_churn
WHERE internet_service = "Fiber optic" AND churn = "Yes"
GROUP BY contract, internet_service
ORDER BY contract ASC;


-- fiber total, and fiber churned
SELECT contract, COUNT(*), SUM(churn = "Yes"), ROUND(SUM(churn = "Yes")*100.00 / COUNT(*) ,2) AS Churned_Pct, ROUND(AVG(monthly_charges) ,2) AS Average_Monthly_Charges
FROM telco_churn
WHERE internet_service = "Fiber optic"
GROUP BY contract;

SELECT MIN(monthly_charges) AS Minimum, MAX(monthly_charges) AS Maximum, ROUND(AVG(monthly_charges) ,2) AS Average
FROM telco_churn;

WITH charge_bucket AS (
    SELECT *,
        CASE
            WHEN monthly_charges < 40 THEN "< RM40"
            WHEN monthly_charges < 60 THEN "Between RM40 - RM59"
            WHEN monthly_charges < 80 THEN "Between RM60 - RM79"
            WHEN monthly_charges < 100 THEN "Between RM80 - RM99"
            ELSE "RM100+"
        END AS Bucket_Monthly_Charge
    FROM telco_churn
)
SELECT COUNT(*) AS Total_Customers,
    Bucket_Monthly_Charge,
    SUM(churn = 'Yes') AS Churned_Customers,
    ROUND(SUM(churn = 'Yes') * 100.0 / COUNT(*), 2) AS Churn_Rate,
    SUM(internet_service = 'Fiber optic') AS Fiber_Optic_Customers,
    SUM(contract = 'Month-to-month') AS Month_to_Month_Customers
FROM charge_bucket
GROUP BY Bucket_Monthly_Charge;

ALTER TABLE telco_churn
ADD COLUMN Bucket_Monthly_Charges DOUBLE;

ALTER TABLE telco_churn
MODIFY Bucket_Monthly_Charges VARCHAR(30);

SET SQL_SAFE_UPDATES = 0;

UPDATE telco_churn
SET Bucket_Monthly_Charges = 
	CASE
		WHEN monthly_charges < 40 THEN "< RM40"
        WHEN monthly_charges < 60 THEN "Between RM40 - RM59"
        WHEN monthly_charges < 80 THEN "Between RM60 - RM79"
        WHEN monthly_charges < 100 THEN "Between RM80 - RM99"
	ELSE "RM100+"
    END
WHERE monthly_charges >= 0;

SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM telco_churn;

select COUNT(churn), internet_service, churn
from telco_churn
group by internet_service, churn;

SELECT
    COUNT(*) AS total_rows,
    COUNT(customer_id) AS non_null_customer_ids,
    COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM telco_churn;

SELECT
    internet_service,
    churn,
    COUNT(*) AS total
FROM telco_churn
GROUP BY internet_service, churn
ORDER BY internet_service, churn;

SELECT
    CONCAT('[', internet_service, ']') AS internet_service_value,
    CONCAT('[', churn, ']') AS churn_value,
    COUNT(*) AS total
FROM telco_churn
GROUP BY internet_service, churn;

select internet_service, churn, count(*)
from telco_churn
group by internet_service, churn;