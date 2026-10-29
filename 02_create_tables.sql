/* ============================================================
   File     : 02_create_tables.sql
   Project  : Retail Sales Analysis (dbo.Sales)
   Purpose  : Create a staging table (all text) and the final
              typed table. Loading into staging first means one
              bad row cannot abort the whole import.
   Depends  : 01_create_database.sql
   ============================================================ */

USE SalesAnalysis;
GO

/* ---------- Staging: every column is text ---------- */
DROP TABLE IF EXISTS dbo.Sales_Staging;
GO

CREATE TABLE dbo.Sales_Staging
(
    SaleID    VARCHAR(50),
    SaleDate  VARCHAR(50),
    City      VARCHAR(100),
    Rep       VARCHAR(100),
    Store     VARCHAR(100),
    Prod      VARCHAR(100),
    Cost      VARCHAR(50),
    Sale      VARCHAR(50)
);
GO

/* ---------- Final: correct types + constraints ---------- */
DROP TABLE IF EXISTS dbo.Sales;
GO

CREATE TABLE dbo.Sales
(
    SaleKey   INT IDENTITY(1,1) PRIMARY KEY,   -- surrogate key: SaleID has duplicates
    SaleID    INT           NOT NULL,
    SaleDate  DATE          NOT NULL,
    City      VARCHAR(50)   NOT NULL,
    Rep       VARCHAR(50)   NOT NULL,
    Store     VARCHAR(50)   NOT NULL,
    Prod      VARCHAR(50)   NOT NULL,
    Cost      DECIMAL(12,2) NOT NULL,
    Sale      DECIMAL(12,2) NOT NULL,
    Profit    AS (Sale - Cost) PERSISTED       -- computed once, stored
);
GO

/* Indexes on the columns we group and filter by most */
CREATE INDEX IX_Sales_SaleDate ON dbo.Sales (SaleDate);
CREATE INDEX IX_Sales_City     ON dbo.Sales (City) INCLUDE (Sale, Cost);
CREATE INDEX IX_Sales_Rep      ON dbo.Sales (Rep)  INCLUDE (Sale, Cost);
GO

PRINT 'Tables created.';
