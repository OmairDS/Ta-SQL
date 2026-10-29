/* ============================================================
   File     : 01_create_database.sql
   Project  : Retail Sales Analysis (dbo.Sales)
   Author   : <your name>
   Purpose  : Create the project database. Safe to re-run.
   Runs on  : SQL Server 2019+
   Depends  : nothing - this is the first script
   ============================================================ */

USE master;
GO

IF DB_ID('SalesAnalysis') IS NULL
BEGIN
    CREATE DATABASE SalesAnalysis;
    PRINT 'Database SalesAnalysis created.';
END
ELSE
    PRINT 'Database SalesAnalysis already exists - skipping.';
GO

USE SalesAnalysis;
GO
