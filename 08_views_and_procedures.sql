/* ============================================================
   File     : 08_views_and_procedures.sql
   Project  : Retail Sales Analysis (dbo.Sales)
   Purpose  : Package the analysis as reusable objects so BI
              tools (Power BI, Excel) can connect directly.
   Depends  : 05_data_cleaning.sql
   ============================================================ */

USE SalesAnalysis;
GO

/* ---------- View 1: monthly revenue by city ---------- */
CREATE OR ALTER VIEW dbo.vw_MonthlyRevenueByCity
AS
SELECT
    DATEFROMPARTS(YEAR(SaleDate), MONTH(SaleDate), 1) AS MonthStart,
    City,
    COUNT(*)    AS Transactions,
    SUM(Sale)   AS Revenue,
    SUM(Profit) AS Profit
FROM dbo.Sales
GROUP BY DATEFROMPARTS(YEAR(SaleDate), MONTH(SaleDate), 1), City;
GO

/* ---------- View 2: rep scorecard ---------- */
CREATE OR ALTER VIEW dbo.vw_RepPerformance
AS
SELECT
    Rep,
    COUNT(*)                                       AS Deals,
    SUM(Sale)                                      AS Revenue,
    SUM(Profit)                                    AS Profit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sale),0) AS DECIMAL(5,2)) AS MarginPct,
    CAST(AVG(Sale) AS DECIMAL(12,2))               AS AvgTicket,
    MIN(SaleDate)                                  AS FirstSale,
    MAX(SaleDate)                                  AS LastSale
FROM dbo.Sales
GROUP BY Rep;
GO

/* ---------- View 3: product profitability ---------- */
CREATE OR ALTER VIEW dbo.vw_ProductProfitability
AS
SELECT
    Prod,
    COUNT(*)                                       AS UnitsSold,
    SUM(Sale)                                      AS Revenue,
    SUM(Cost)                                      AS Cost,
    SUM(Profit)                                    AS Profit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sale),0) AS DECIMAL(5,2)) AS MarginPct
FROM dbo.Sales
GROUP BY Prod;
GO

/* ---------- Procedure: filtered city report ---------- */
CREATE OR ALTER PROCEDURE dbo.usp_CityReport
    @City      VARCHAR(50) = NULL,   -- NULL = all cities
    @StartDate DATE        = NULL,
    @EndDate   DATE        = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        City,
        Rep,
        COUNT(*)    AS Deals,
        SUM(Sale)   AS Revenue,
        SUM(Profit) AS Profit
    FROM dbo.Sales
    WHERE (@City      IS NULL OR City     = @City)
      AND (@StartDate IS NULL OR SaleDate >= @StartDate)
      AND (@EndDate   IS NULL OR SaleDate <= @EndDate)
    GROUP BY City, Rep
    ORDER BY City, Revenue DESC;
END
GO

/* ---------- Test the objects ---------- */
SELECT TOP (12) * FROM dbo.vw_MonthlyRevenueByCity ORDER BY MonthStart;
SELECT * FROM dbo.vw_RepPerformance ORDER BY Revenue DESC;
SELECT * FROM dbo.vw_ProductProfitability ORDER BY MarginPct DESC;

EXEC dbo.usp_CityReport @City = 'Riyadh';
EXEC dbo.usp_CityReport @StartDate = '2012-01-01', @EndDate = '2015-12-31';
GO
