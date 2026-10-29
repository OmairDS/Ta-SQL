/* ============================================================
   File     : 06_exploratory_analysis.sql
   Project  : Retail Sales Analysis (dbo.Sales)
   Purpose  : Understand the shape of the data before answering
              business questions. Nobody should analyse a table
              they have not profiled.
   Depends  : 05_data_cleaning.sql
   ============================================================ */

USE SalesAnalysis;
GO

-- ------------------------------------------------------------
-- E1. First look
-- ------------------------------------------------------------
SELECT TOP (10) * FROM dbo.Sales ORDER BY SaleDate;

-- ------------------------------------------------------------
-- E2. Scale of the dataset
-- ------------------------------------------------------------
SELECT
    COUNT(*)                 AS Transactions,
    COUNT(DISTINCT City)     AS Cities,
    COUNT(DISTINCT Rep)      AS Reps,
    COUNT(DISTINCT Store)    AS Stores,
    COUNT(DISTINCT Prod)     AS Products,
    MIN(SaleDate)            AS FirstSale,
    MAX(SaleDate)            AS LastSale,
    DATEDIFF(YEAR, MIN(SaleDate), MAX(SaleDate)) AS YearsCovered
FROM dbo.Sales;

-- ------------------------------------------------------------
-- E3. Money summary - totals and spread
-- ------------------------------------------------------------
SELECT
    SUM(Sale)                          AS TotalRevenue,
    SUM(Cost)                          AS TotalCost,
    SUM(Profit)                        AS TotalProfit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sale),0) AS DECIMAL(5,2)) AS MarginPct,
    AVG(Sale)                          AS AvgTransaction,
    MIN(Sale)                          AS SmallestSale,
    MAX(Sale)                          AS LargestSale
FROM dbo.Sales;

-- ------------------------------------------------------------
-- E4. Median and quartiles - the average alone hides skew
-- ------------------------------------------------------------
SELECT DISTINCT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Sale) OVER () AS Q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Sale) OVER () AS Median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Sale) OVER () AS Q3
FROM dbo.Sales;

-- ------------------------------------------------------------
-- E5. Rows per year - is any year under-represented?
-- ------------------------------------------------------------
SELECT
    YEAR(SaleDate) AS SaleYear,
    COUNT(*)       AS Transactions,
    SUM(Sale)      AS Revenue
FROM dbo.Sales
GROUP BY YEAR(SaleDate)
ORDER BY SaleYear;

-- ------------------------------------------------------------
-- E6. Distribution across each dimension
-- ------------------------------------------------------------
SELECT City,  COUNT(*) AS Transactions, SUM(Sale) AS Revenue FROM dbo.Sales GROUP BY City  ORDER BY Revenue DESC;
SELECT Rep,   COUNT(*) AS Transactions, SUM(Sale) AS Revenue FROM dbo.Sales GROUP BY Rep   ORDER BY Revenue DESC;
SELECT Store, COUNT(*) AS Transactions, SUM(Sale) AS Revenue FROM dbo.Sales GROUP BY Store ORDER BY Revenue DESC;
SELECT Prod,  COUNT(*) AS Transactions, SUM(Sale) AS Revenue FROM dbo.Sales GROUP BY Prod  ORDER BY Revenue DESC;

-- ------------------------------------------------------------
-- E7. Outliers - transactions more than 3 standard deviations
--     above the mean. Check them before trusting any total.
-- ------------------------------------------------------------
WITH stats AS (
    SELECT AVG(Sale) AS MeanSale, STDEV(Sale) AS SdSale FROM dbo.Sales
)
SELECT s.SaleID, s.SaleDate, s.City, s.Rep, s.Prod, s.Sale
FROM dbo.Sales s
CROSS JOIN stats
WHERE s.Sale > stats.MeanSale + 3 * stats.SdSale
ORDER BY s.Sale DESC;
