/* ============================================================
   File     : 05_data_cleaning.sql
   Project  : Retail Sales Analysis (dbo.Sales)
   Purpose  : Move staging -> dbo.Sales, applying every fix the
              audit justified. Each fix states the issue, the
              business impact, and the decision taken.
   Depends  : 04_data_quality_audit.sql
   Rule     : Never edit the raw CSV. All cleaning lives here,
              in version control, and is repeatable.
   ============================================================ */

USE SalesAnalysis;
GO

TRUNCATE TABLE dbo.Sales;
GO

/* ============================================================
   FIX 1 - Whitespace
   Issue  : Leading/trailing spaces make 'Riyadh ' and 'Riyadh'
            group as two different cities.
   Action : TRIM every text column on the way in.

   FIX 2 - Misspelled rep
   Issue  : 'Mjeeed' (SaleID 3) is 'Mjeed' typed with an extra e.
   Impact : Splits one rep across two rows in every report.
   Action : Map back to 'Mjeed'.

   FIX 3 - Inconsistent store naming
   Issue  : 'Lulu Hyper' and 'Lulu' are the same outlet.
   Action : Standardise on 'Lulu'.

   FIX 4 - Type safety
   Issue  : A non-numeric value would abort the whole INSERT.
   Action : TRY_CONVERT, then reject unconvertible rows below.

   FIX 5 - Duplicate SaleID
   Issue  : SaleID 3 appears twice.
   Decision: Keep BOTH rows - they are distinct transactions that
            share a badly assigned ID, not a double entry. The
            surrogate key SaleKey guarantees uniqueness instead.
            (If your audit shows fully identical rows, switch to
            the ROW_NUMBER de-duplication in the block below.)
   ============================================================ */

WITH cleaned AS
(
    SELECT
        TRY_CONVERT(INT,  LTRIM(RTRIM(SaleID)))            AS SaleID,
        TRY_CONVERT(DATE, LTRIM(RTRIM(SaleDate)))          AS SaleDate,
        LTRIM(RTRIM(City))                                 AS City,

        -- FIX 2
        CASE WHEN LTRIM(RTRIM(Rep)) = 'Mjeeed' THEN 'Mjeed'
             ELSE LTRIM(RTRIM(Rep)) END                    AS Rep,

        -- FIX 3
        CASE WHEN LTRIM(RTRIM(Store)) LIKE 'Lulu%' THEN 'Lulu'
             ELSE LTRIM(RTRIM(Store)) END                  AS Store,

        LTRIM(RTRIM(Prod))                                 AS Prod,
        TRY_CONVERT(DECIMAL(12,2), LTRIM(RTRIM(Cost)))     AS Cost,
        TRY_CONVERT(DECIMAL(12,2), LTRIM(RTRIM(Sale)))     AS Sale
    FROM dbo.Sales_Staging
)
INSERT INTO dbo.Sales (SaleID, SaleDate, City, Rep, Store, Prod, Cost, Sale)
SELECT SaleID, SaleDate, City, Rep, Store, Prod, Cost, Sale
FROM cleaned
WHERE SaleID   IS NOT NULL      -- FIX 4: drop rows that failed conversion
  AND SaleDate IS NOT NULL
  AND Cost     IS NOT NULL
  AND Sale     IS NOT NULL
  AND NULLIF(City,  '') IS NOT NULL
  AND NULLIF(Rep,   '') IS NOT NULL
  AND NULLIF(Store, '') IS NOT NULL
  AND NULLIF(Prod,  '') IS NOT NULL;
GO

/* ---- Optional: de-duplicate fully identical rows ------------
   Use ONLY if the audit showed genuine double entry.
   Keeps the first occurrence of each identical combination.

WITH ranked AS (
    SELECT SaleKey,
           ROW_NUMBER() OVER (
               PARTITION BY SaleID, SaleDate, City, Rep, Store, Prod, Cost, Sale
               ORDER BY SaleKey
           ) AS rn
    FROM dbo.Sales
)
DELETE FROM ranked WHERE rn > 1;
-------------------------------------------------------------- */

/* ============================================================
   VERIFICATION - always prove the cleaning worked
   ============================================================ */

-- How many rows survived, and how many were rejected?
SELECT
    (SELECT COUNT(*) FROM dbo.Sales_Staging) AS RowsInStaging,
    (SELECT COUNT(*) FROM dbo.Sales)         AS RowsLoaded,
    (SELECT COUNT(*) FROM dbo.Sales_Staging)
  - (SELECT COUNT(*) FROM dbo.Sales)         AS RowsRejected;

-- 'Mjeeed' must return zero rows
SELECT COUNT(*) AS RemainingMjeeed FROM dbo.Sales WHERE Rep = 'Mjeeed';

-- 'Lulu Hyper' must return zero rows
SELECT COUNT(*) AS RemainingLuluHyper FROM dbo.Sales WHERE Store = 'Lulu Hyper';

-- Final distinct values - screenshot this for the README
SELECT 'City' AS Dimension, City AS Value, COUNT(*) AS Rows FROM dbo.Sales GROUP BY City
UNION ALL
SELECT 'Rep',   Rep,   COUNT(*) FROM dbo.Sales GROUP BY Rep
UNION ALL
SELECT 'Store', Store, COUNT(*) FROM dbo.Sales GROUP BY Store
ORDER BY Dimension, Value;
