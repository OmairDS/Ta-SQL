/* ============================================================
   File     : 03_load_data.sql
   Project  : Retail Sales Analysis (dbo.Sales)
   Purpose  : Load SQL-268.csv into the staging table.
   Depends  : 02_create_tables.sql

   >>> ACTION REQUIRED <<<
   Change the path on the BULK INSERT line to where SQL-268.csv
   sits ON THE MACHINE RUNNING SQL SERVER, not on your laptop.
   ============================================================ */

USE SalesAnalysis;
GO

TRUNCATE TABLE dbo.Sales_Staging;
GO

BULK INSERT dbo.Sales_Staging
FROM 'C:\SQLData\SQL-268.csv'          -- <<< CHANGE THIS PATH
WITH (
    FIRSTROW        = 2,               -- skip the header row
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',          -- 0x0a = Unix line ending; try '\n' if this fails
    CODEPAGE        = '65001',         -- UTF-8, needed for Arabic text
    TABLOCK
);
GO

/* --- If BULK INSERT is blocked by permissions (common on hosted
       servers), use the SSMS wizard instead:
       Right-click SalesAnalysis > Tasks > Import Flat File
       Target table: dbo.Sales_Staging, every column as text.     --- */

-- Sanity check: expect roughly 1,990 rows
SELECT COUNT(*) AS RowsLoaded FROM dbo.Sales_Staging;
GO
