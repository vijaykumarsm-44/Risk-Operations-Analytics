/*====================================================================
					RISK OPERATIONS ANALYTICS PROJECT
======================================================================

Project Name : Risk Operations Analytics
Author       : Vijay
Database     : SQL Server
Tools Used   : SQL Server, Power BI, Excel

Description:
This project analyzes insurance risk operations data to generate
business insights related to premium collection, claims, regional
performance, compliance, SLA, and risk levels.

==============================================================*/

/*==============================================================
EXECUTION ORDER

Step 1 : Create Database
Step 2 : Import Dataset into Risk_Operations
Step 3 : Execute Queries 1–30
Step 4 : Create View
Step 5 : Verify Results

==============================================================*/

-- ================================================================
-- DATABASE
-- ================================================================

CREATE DATABASE RiskOperationsDB;
GO

USE RiskOperationsDB;
GO

/*====================================================================
TABLE INFORMATION

Table Name : Risk_Operations

Dataset Columns:
- Case_ID
- Case_Date
- Region
- Product
- Premium_Amount
- Claim_Amount
- Risk_Level
- Status
- Resolution_Days
- Compliance_Flag
- Customer_Satisfaction
- Channel


====================================================================*/

-- ================================================================
-- QUERY 1
-- Business Question:
-- How many operational cases are available?
-- Concept: COUNT()
-- ================================================================

SELECT COUNT(*) AS Total_Cases
FROM Risk_Operations;

-- ================================================================
-- QUERY 2
-- Business Question:
-- What is the total premium collected?
-- Concept: SUM()
-- ================================================================

SELECT SUM(Premium_Amount) AS Total_Premium
FROM Risk_Operations;

-- ================================================================
-- QUERY 3
-- Business Question:
-- What is the total claim amount?
-- Concept: SUM()
-- ================================================================

SELECT SUM(Claim_Amount) AS Total_Claims
FROM Risk_Operations;

-- ================================================================
-- QUERY 4
-- Business Question:
-- Which region generated the highest premium?
-- Concept: GROUP BY + SUM + ORDER BY
-- ================================================================

SELECT
	Region,
	SUM(Premium_Amount) AS Total_Premium
FROM Risk_Operations
GROUP BY Region
ORDER BY Total_Premium DESC;

-- ================================================================
-- QUERY 5
-- Business Question:
-- Which region recorded the highest claims?
-- Concept: GROUP BY + SUM + ORDER BY
-- ================================================================

SELECT
	Region,
	SUM(Claim_Amount) AS Total_Claims
FROM Risk_Operations
GROUP BY Region
ORDER BY Total_Claims DESC;

-- ================================================================
-- QUERY 6
-- Business Question:
-- Compare premium and claims by region.
-- Concept: Multiple Aggregate Functions
-- ================================================================

SELECT
	Region,
	SUM(Premium_Amount) AS Total_Premium,
	SUM(Claim_Amount) AS Total_Claims
FROM Risk_Operations
GROUP BY Region
ORDER BY Total_Premium DESC;

-- ================================================================
-- QUERY 7
-- Business Question:
-- How many cases belong to each risk level?
-- Concept: COUNT() + GROUP BY
-- ================================================================

SELECT
	Risk_Level,
	COUNT(*) AS Total_Cases
FROM Risk_Operations
GROUP BY Risk_Level
ORDER BY Total_Cases DESC;

-- ================================================================
-- QUERY 8
-- Business Question:
-- How many cases are in each status?
-- Concept: COUNT() + GROUP BY
-- ================================================================

SELECT
	Status,
	COUNT(*) AS Total_Cases
FROM Risk_Operations
GROUP BY Status
ORDER BY Total_Cases DESC;

-- ================================================================
-- QUERY 9
-- Business Question:
-- What is the average premium amount for each product?
-- Concept: AVG() + GROUP BY
-- ================================================================

SELECT
	Product,
	AVG(Premium_Amount) AS Average_Premium
FROM Risk_Operations
GROUP BY Product
ORDER BY Average_Premium DESC;

-- ================================================================
-- QUERY 10
-- Business Question:
-- How many High Risk cases are there?
-- Concept: WHERE + COUNT()
-- ================================================================

SELECT COUNT(*) AS High_Risk_Cases
FROM Risk_Operations
WHERE Risk_Level = 'High';

-- ================================================================
-- QUERY 11
-- Business Question:
-- Which region has the highest number of High Risk cases?
-- Concept: WHERE + GROUP BY + ORDER BY
-- ================================================================

SELECT
	Region,
	COUNT(*) AS High_Risk_Cases
FROM Risk_Operations
WHERE Risk_Level = 'High'
GROUP BY Region
ORDER BY High_Risk_Cases DESC;

-- ================================================================
-- QUERY 12
-- Business Question:
-- Which are the Top 5 cases with the highest premium amount?
-- Concept: TOP + ORDER BY
-- ================================================================

SELECT TOP 5
	Case_ID,
	Region,
	Product,
	Premium_Amount
FROM Risk_Operations
ORDER BY Premium_Amount DESC;

-- ================================================================
-- QUERY 13
-- Business Question:
-- Which region takes the longest to resolve cases on average?
-- Concept: AVG() + GROUP BY
-- ================================================================

SELECT
	Region,
	AVG(Resolution_Days) AS Average_Resolution_Days
FROM Risk_Operations
GROUP BY Region
ORDER BY Average_Resolution_Days DESC;

-- ================================================================
-- QUERY 14
-- Business Question:
-- Which regions have processed more than 100 cases?
-- Concept: GROUP BY + HAVING
-- ================================================================

SELECT
	Region,
	COUNT(*) AS Total_Cases
FROM Risk_Operations
GROUP BY Region
HAVING COUNT(*) > 100
ORDER BY Total_Cases DESC;

-- ================================================================
-- QUERY 15
-- Business Question:
-- Which products have an average premium greater than the
-- overall average premium?
-- Concept: Subquery + HAVING
-- ================================================================

SELECT
	Product,
	AVG(Premium_Amount) AS Average_Premium
FROM Risk_Operations
GROUP BY Product
HAVING AVG(Premium_Amount) >
(
	SELECT AVG(Premium_Amount)
	FROM Risk_Operations
)
ORDER BY Average_Premium DESC;

-- ================================================================
-- QUERY 16
-- Business Question:
-- List all cases where Premium Amount is greater than ₹75,000.
-- Concept: CTE (Common Table Expression)
-- ================================================================

WITH HighPremiumCases AS
(
	SELECT
		Case_ID,
		Region,
		Product,
		Premium_Amount
	FROM Risk_Operations
	WHERE Premium_Amount > 75000
)

SELECT *
FROM HighPremiumCases
ORDER BY Premium_Amount DESC;

-- ================================================================
-- QUERY 17
-- Business Question:
-- Assign a unique row number to each case within each region
-- based on Premium Amount.
-- Concept: ROW_NUMBER()
-- ================================================================

SELECT
	Case_ID,
	Region,
	Product,
	Premium_Amount,
	ROW_NUMBER() OVER
	(
		PARTITION BY Region
		ORDER BY Premium_Amount DESC
	) AS Row_Num
FROM Risk_Operations;

-- ================================================================
-- QUERY 18
-- Business Question:
-- Rank cases within each region based on Premium Amount.
-- Concept: RANK()
-- ================================================================

SELECT
	Case_ID,
	Region,
	Product,
	Premium_Amount,
	RANK() OVER
	(
		PARTITION BY Region
		ORDER BY Premium_Amount DESC
	) AS Premium_Rank
FROM Risk_Operations;

-- ================================================================
-- QUERY 19
-- Business Question:
-- Assign Dense Rank within each region based on Premium Amount.
-- Concept: DENSE_RANK()
-- ================================================================

SELECT
	Case_ID,
	Region,
	Product,
	Premium_Amount,
	DENSE_RANK() OVER
	(
		PARTITION BY Region
		ORDER BY Premium_Amount DESC
	) AS Dense_Rank
FROM Risk_Operations;

-- ================================================================
-- QUERY 20
-- Business Question:
-- Categorize Premium Amount into High, Medium and Low Premium.
-- Concept: CASE WHEN
-- ================================================================

SELECT
	Case_ID,
	Region,
	Product,
	Premium_Amount,

	CASE
		WHEN Premium_Amount > 75000 THEN 'High Premium'
		WHEN Premium_Amount >= 40000 THEN 'Medium Premium'
		ELSE 'Low Premium'
	END AS Premium_Category

FROM Risk_Operations;

-- ================================================================
-- QUERY 21
-- Business Question:
-- Create a reusable view for High Risk cases.
-- Concept: VIEW
-- ================================================================

CREATE VIEW vw_HighRiskCases AS
SELECT
	Case_ID,
	Case_Date,
	Region,
	Product,
	Premium_Amount,
	Claim_Amount,
	Risk_Level,
	Status
FROM Risk_Operations
WHERE Risk_Level = 'High';

-- View Usage

SELECT *
FROM vw_HighRiskCases;

-- ================================================================
-- QUERY 22
-- Business Question:
-- Which product generated the highest total premium?
-- Concept: SUM() + GROUP BY
-- ================================================================

SELECT
	Product,
	SUM(Premium_Amount) AS Total_Premium
FROM Risk_Operations
GROUP BY Product
ORDER BY Total_Premium DESC;

-- ================================================================
-- QUERY 23
-- Business Question:
-- What is the monthly premium collection trend?
-- Concept: YEAR() + MONTH() + GROUP BY
-- ================================================================

SELECT
	YEAR(Case_Date) AS Year,
	MONTH(Case_Date) AS Month,
	SUM(Premium_Amount) AS Total_Premium
FROM Risk_Operations
GROUP BY
	YEAR(Case_Date),
	MONTH(Case_Date)
ORDER BY
	Year,
	Month;

-- ================================================================
-- QUERY 24
-- Business Question:
-- Which region has the highest Claim Ratio?
-- Concept: Aggregate Functions
-- ================================================================

SELECT
	Region,
	SUM(Premium_Amount) AS Total_Premium,
	SUM(Claim_Amount) AS Total_Claims,
	ROUND(
		(SUM(Claim_Amount) * 100.0) /
		SUM(Premium_Amount),
		2
	) AS Claim_Ratio_Percentage
FROM Risk_Operations
GROUP BY Region
ORDER BY Claim_Ratio_Percentage DESC;

-- ================================================================
-- QUERY 25
-- Business Question:
-- How many cases are compliant and non-compliant?
-- Concept: GROUP BY
-- ================================================================

SELECT
	Compliance_Flag,
	COUNT(*) AS Total_Cases
FROM Risk_Operations
GROUP BY Compliance_Flag
ORDER BY Total_Cases DESC;

-- ================================================================
-- QUERY 26
-- Business Question:
-- Rank products based on Total Premium.
-- Concept: RANK()
-- ================================================================

SELECT
	Product,
	SUM(Premium_Amount) AS Total_Premium,
	RANK() OVER
	(
		ORDER BY SUM(Premium_Amount) DESC
	) AS Product_Rank
FROM Risk_Operations
GROUP BY Product;

-- ================================================================
-- QUERY 27
-- Business Question:
-- Analyze SLA Performance.
-- Concept: CASE WHEN
-- ================================================================

SELECT
	CASE
		WHEN Resolution_Days <= 30 THEN 'SLA Met'
		ELSE 'SLA Breached'
	END AS SLA_Status,
	COUNT(*) AS Total_Cases
FROM Risk_Operations
GROUP BY
	CASE
		WHEN Resolution_Days <= 30 THEN 'SLA Met'
		ELSE 'SLA Breached'
	END
ORDER BY Total_Cases DESC;

-- ================================================================
-- QUERY 28
-- Business Question:
-- Executive KPI Summary.
-- Concept: Aggregate Functions
-- ================================================================

SELECT
	COUNT(*) AS Total_Cases,
	SUM(Premium_Amount) AS Total_Premium,
	SUM(Claim_Amount) AS Total_Claims,
	AVG(Premium_Amount) AS Average_Premium,
	AVG(Claim_Amount) AS Average_Claim,
	AVG(Resolution_Days) AS Average_Resolution_Days
FROM Risk_Operations;

-- ================================================================
-- QUERY 29
-- Business Question:
-- Which regions generated above-average premium?
-- Concept: HAVING + Subquery
-- ================================================================

SELECT
	Region,
	AVG(Premium_Amount) AS Average_Premium
FROM Risk_Operations
GROUP BY Region
HAVING AVG(Premium_Amount) >
(
	SELECT AVG(Premium_Amount)
	FROM Risk_Operations
)
ORDER BY Average_Premium DESC;

-- ================================================================
-- QUERY 30
-- Business Question:
-- Create an Executive Dashboard Dataset.
-- Concept: Dashboard Dataset
-- ================================================================

SELECT
	Region,
	COUNT(*) AS Total_Cases,
	SUM(Premium_Amount) AS Total_Premium,
	SUM(Claim_Amount) AS Total_Claims,
	AVG(Premium_Amount) AS Average_Premium,
	AVG(Claim_Amount) AS Average_Claim,
	AVG(Resolution_Days) AS Average_Resolution_Days,
	ROUND(
		(SUM(Claim_Amount) * 100.0) /
		SUM(Premium_Amount),
		2
	) AS Claim_Ratio_Percentage
FROM Risk_Operations
GROUP BY Region
ORDER BY Total_Premium DESC;

-- ================================================================
-- INTERVIEW CONCEPTS COVERED
-- ================================================================

-- SELECT
-- WHERE
-- ORDER BY
-- GROUP BY
-- HAVING
-- Aggregate Functions
-- CASE WHEN
-- TOP
-- Subqueries
-- CTE (Common Table Expression)
-- VIEW
-- ROW_NUMBER()
-- RANK()
-- DENSE_RANK()
-- DATE FUNCTIONS
-- WINDOW FUNCTIONS

-- ================================================================
-- END OF PROJECT
-- ================================================================

PRINT 'Risk Operations Analytics SQL Portfolio Project Completed Successfully';