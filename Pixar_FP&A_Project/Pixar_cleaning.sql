-- Create a new database for your portfolio project
CREATE DATABASE IF NOT EXISTS pixar_fpa_project;

-- Tell MySQL to use this database for the upcoming queries
USE pixar_fpa_project;

USE pixar_fpa_project;

DROP TABLE IF EXISTS pixar_budget_raw;

CREATE TABLE pixar_budget_raw (
    Transaction_Date VARCHAR(50),
    Project_Name VARCHAR(100),
    Department VARCHAR(100),
    Expense_Type VARCHAR(100),
    Budget_Amount VARCHAR(50),
    Actual_Amount VARCHAR(50)
);


SELECT 
    -- 1. Standardize Date Format
    CASE 
        WHEN Transaction_Date LIKE '%/%/%' THEN CAST(STR_TO_DATE(Transaction_Date, '%m/%d/%Y') AS DATE)
        ELSE CAST(Transaction_Date AS DATE)
    END AS Transaction_Date,

    -- 2. Handle Missing Project Names
    CASE 
        WHEN Project_Name IS NULL OR Project_Name = '' THEN 'Unallocated Corporate Overhead'
        ELSE Project_Name 
    END AS Project_Name,

    -- 3. Standardize Inconsistent Department Names
    CASE 
        WHEN Department IN ('Animation & Prod', 'Anim & Production') THEN 'Production & Animation'
        WHEN Department IN ('Tech Ops - Render', 'RENDERING') THEN 'Technical Operations (Render Farm)'
        WHEN Department = 'Pre-Production & Story' THEN 'Pre-Production & Story'
        WHEN Department = 'Post-Prod & Sound' THEN 'Post-Production & Sound'
        WHEN Department = 'Marketing' THEN 'Marketing & Franchise'
        ELSE Department
    END AS Department,

    Expense_Type,

    -- 4. Clean Budget and Actual Amounts (Strip '$' and commas, cast to decimal)
    CAST(REPLACE(REPLACE(Budget_Amount, '$', ''), ',', '') AS DECIMAL(10,2)) AS Budget_Amount,
    CAST(REPLACE(REPLACE(Actual_Amount, '$', ''), ',', '') AS DECIMAL(10,2)) AS Actual_Amount,

    -- 5. Calculate FP&A Core Metrics
    (CAST(REPLACE(REPLACE(Actual_Amount, '$', ''), ',', '') AS DECIMAL(10,2)) - 
     CAST(REPLACE(REPLACE(Budget_Amount, '$', ''), ',', '') AS DECIMAL(10,2))) AS Variance_Amount

FROM pixar_budget_raw;

USE pixar_fpa_project;

USE pixar_fpa_project;

WITH cleaned_metrics AS (
    SELECT 
        CAST(REPLACE(REPLACE(Budget_Amount, '$', ''), ',', '') AS DECIMAL(10,2)) AS Budget,
        CAST(REPLACE(REPLACE(Actual_Amount, '$', ''), ',', '') AS DECIMAL(10,2)) AS Actual
    FROM pixar_budget_raw
)
SELECT 
    CONCAT('$', FORMAT(SUM(Budget), 2)) AS Total_Q1_Budget,
    CONCAT('$', FORMAT(SUM(Actual), 2)) AS Total_Q1_Actuals,
    CONCAT('$', FORMAT(SUM(Actual) - SUM(Budget), 2)) AS Grand_Variance_Amount,
    CONCAT(FORMAT((SUM(Actual) / SUM(Budget)) * 100, 1), '%') AS Overall_Burn_Rate
FROM cleaned_metrics;
