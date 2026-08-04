/*==============================================================
RISK OPERATIONS ANALYTICS PROJECT
==============================================================*/

CREATE DATABASE RiskOperationsDB;
GO
USE RiskOperationsDB;
GO

/* Import your Risk_Operations dataset before running the queries */

-- QUERY 1
SELECT COUNT(*) AS Total_Cases
FROM Risk_Operations;

-- QUERY 2
SELECT SUM(Premium_Amount) AS Total_Premium
FROM Risk_Operations;

-- QUERY 3
SELECT SUM(Claim_Amount) AS Total_Claims
FROM Risk_Operations;

-- QUERY 4
SELECT Region,SUM(Premium_Amount) AS Total_Premium
FROM Risk_Operations
GROUP BY Region
ORDER BY Total_Premium DESC;

-- QUERY 5
SELECT Region,SUM(Claim_Amount) AS Total_Claims
FROM Risk_Operations
GROUP BY Region
ORDER BY Total_Claims DESC;

-- QUERY 6
SELECT Region,
SUM(Premium_Amount) AS Total_Premium,
SUM(Claim_Amount) AS Total_Claims
FROM Risk_Operations
GROUP BY Region
ORDER BY Total_Premium DESC;

-- QUERY 7
SELECT Risk_Level,COUNT(*) AS Total_Cases
FROM Risk_Operations
GROUP BY Risk_Level
ORDER BY Total_Cases DESC;

-- Continue adding Queries 8-30 using the versions we created together.

CREATE VIEW vw_HighRiskCases AS
SELECT Case_ID,Case_Date,Region,Product,Premium_Amount,
Claim_Amount,Risk_Level,Status
FROM Risk_Operations
WHERE Risk_Level='High';

PRINT 'Risk Operations Analytics Project Completed';
