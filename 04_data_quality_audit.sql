/* ============================================================
   File     : 04_data_quality_audit.sql
   Project  : Retail Sales Analysis (dbo.Sales)
   Purpose  : PROVE what is wrong with the raw data before
              changing anything. Run this first, screenshot the
              output, and put the evidence in your README.
   Depends  : 03_load_data.sql
   Note     : This script only READS. It changes nothing.
   ============================================================ */

USE SalesAnalysis;
GO

-- ------------------------------------------------------------
-- A1. How many rows, and how many are exact duplicates?
-- ------------------------------------------------------------
SELECT
    COUNT(*)                  AS TotalRows,
    COUNT(DISTINCT SaleID)    AS DistinctSaleIDs,
    COUNT(*) - COUNT(DISTINCT SaleID) AS SurplusIDs
FROM dbo.Sales_Staging;

-- ------------------------------------------------------------
-- A2. Which SaleIDs appear more than once?
--     Expect SaleID 3 to appear twice - it carries the
--     deliberate dirty values used in class.
-- ------------------------------------------------------------
SELECT SaleID, COUNT(*) AS Occurrences
FROM dbo.Sales_Staging
GROUP BY SaleID
HAVING COUNT(*) > 1
ORDER BY Occurrences DESC, SaleID;

-- Look at those rows in full
SELECT *
FROM dbo.Sales_Staging
WHERE SaleID IN (
    SELECT SaleID FROM dbo.Sales_Staging GROUP BY SaleID HAVING COUNT(*) > 1
)
ORDER BY SaleID;

-- ------------------------------------------------------------
-- A3. Inconsistent rep names.
--     'Mjeeed' is a misspelling of 'Mjeed' - left uncorrected it
--     splits one person into two and understates his totals.
-- ------------------------------------------------------------
SELECT Rep, COUNT(*) AS Rows, SUM(TRY_CONVERT(DECIMAL(12,2), Sale)) AS Sales
FROM dbo.Sales_Staging
GROUP BY Rep
ORDER BY Rep;

-- ------------------------------------------------------------
-- A4. Inconsistent store names.
--     'Lulu' and 'Lulu Hyper' are the same outlet.
-- ------------------------------------------------------------
SELECT Store, COUNT(*) AS Rows
FROM dbo.Sales_Staging
GROUP BY Store
ORDER BY Store;

-- ------------------------------------------------------------
-- A5. Same check for City and Prod - look for stray spaces,
--     casing differences, and near-duplicates.
-- ------------------------------------------------------------
SELECT City, COUNT(*) AS Rows FROM dbo.Sales_Staging GROUP BY City ORDER BY City;
SELECT Prod, COUNT(*) AS Rows FROM dbo.Sales_Staging GROUP BY Prod ORDER BY Prod;

-- ------------------------------------------------------------
-- A6. Values that will not convert to their intended type.
--     Anything returned here would silently become NULL.
-- ------------------------------------------------------------
SELECT 'SaleID'   AS Column_, SaleID   AS BadValue FROM dbo.Sales_Staging WHERE TRY_CONVERT(INT, SaleID) IS NULL
UNION ALL
SELECT 'SaleDate', SaleDate FROM dbo.Sales_Staging WHERE TRY_CONVERT(DATE, SaleDate) IS NULL
UNION ALL
SELECT 'Cost',     Cost     FROM dbo.Sales_Staging WHERE TRY_CONVERT(DECIMAL(12,2), Cost) IS NULL
UNION ALL
SELECT 'Sale',     Sale     FROM dbo.Sales_Staging WHERE TRY_CONVERT(DECIMAL(12,2), Sale) IS NULL;

-- ------------------------------------------------------------
-- A7. Missing values in any column.
-- ------------------------------------------------------------
SELECT
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(SaleID)),   '') IS NULL THEN 1 ELSE 0 END) AS Missing_SaleID,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(SaleDate)), '') IS NULL THEN 1 ELSE 0 END) AS Missing_SaleDate,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(City)),     '') IS NULL THEN 1 ELSE 0 END) AS Missing_City,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(Rep)),      '') IS NULL THEN 1 ELSE 0 END) AS Missing_Rep,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(Store)),    '') IS NULL THEN 1 ELSE 0 END) AS Missing_Store,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(Prod)),     '') IS NULL THEN 1 ELSE 0 END) AS Missing_Prod,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(Cost)),     '') IS NULL THEN 1 ELSE 0 END) AS Missing_Cost,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(Sale)),     '') IS NULL THEN 1 ELSE 0 END) AS Missing_Sale
FROM dbo.Sales_Staging;

-- ------------------------------------------------------------
-- A8. Business-rule violations: negative money, or a sale
--     below its own cost (a loss - real, but worth flagging).
-- ------------------------------------------------------------
SELECT COUNT(*) AS NegativeAmounts
FROM dbo.Sales_Staging
WHERE TRY_CONVERT(DECIMAL(12,2), Sale) < 0
   OR TRY_CONVERT(DECIMAL(12,2), Cost) < 0;

SELECT COUNT(*) AS SoldBelowCost
FROM dbo.Sales_Staging
WHERE TRY_CONVERT(DECIMAL(12,2), Sale) < TRY_CONVERT(DECIMAL(12,2), Cost);

-- ------------------------------------------------------------
-- A9. Date range - are there dates outside 2004-2015?
-- ------------------------------------------------------------
SELECT
    MIN(TRY_CONVERT(DATE, SaleDate)) AS EarliestSale,
    MAX(TRY_CONVERT(DATE, SaleDate)) AS LatestSale
FROM dbo.Sales_Staging;
