# Data Dictionary

**Source file:** `SQL-268.csv`
**Rows:** ~1,990
**Period:** 2004-2015
**Target table:** `dbo.Sales`

## Columns

| Column | Type | Nullable | Description | Notes |
|---|---|---|---|---|
| `SaleID` | INT | No | Transaction identifier from the source system | **Not unique** - at least one ID repeats. A surrogate key `SaleKey` is added during loading. |
| `SaleDate` | DATE | No | Date the transaction occurred | Range 2004-2015 |
| `City` | VARCHAR(50) | No | City of the selling outlet | Dammam, Riyadh, Jeddah, Abha, Hail, Jubail |
| `Rep` | VARCHAR(50) | No | Sales representative | Yahia, Mjeed, Abdul, Maliha, Ghalia |
| `Store` | VARCHAR(50) | No | Retail outlet name | Contains inconsistent naming in the raw file |
| `Prod` | VARCHAR(50) | No | Product sold | |
| `Cost` | DECIMAL(12,2) | No | Cost of goods for the transaction | Currency: SAR |
| `Sale` | DECIMAL(12,2) | No | Sale value of the transaction | Currency: SAR |

## Derived columns

| Column | Definition | Where |
|---|---|---|
| `SaleKey` | `IDENTITY(1,1)` surrogate primary key | `02_create_tables.sql` |
| `Profit` | `Sale - Cost`, computed and persisted | `02_create_tables.sql` |
| `MarginPct` | `100 * Profit / Sale` | calculated in queries and views |

## Known data quality issues

| # | Issue | Example | Impact if ignored | Fixed in |
|---|---|---|---|---|
| 1 | Misspelled rep name | `Mjeeed` instead of `Mjeed` (SaleID 3) | One rep is split into two, understating his totals and corrupting every rep ranking | `05_data_cleaning.sql` |
| 2 | Inconsistent store naming | `Lulu Hyper` vs `Lulu` (SaleID 3) | The same outlet appears twice in store reports | `05_data_cleaning.sql` |
| 3 | Duplicate `SaleID` | SaleID 3 appears more than once | `SaleID` cannot be used as a primary key | `02_create_tables.sql` (surrogate key) |
| 4 | Possible leading/trailing spaces | `'Riyadh '` vs `'Riyadh'` | Splits groups silently in `GROUP BY` | `05_data_cleaning.sql` |
| 5 | Text values in numeric columns | any non-numeric `Cost` or `Sale` | `INSERT` aborts, or values silently become NULL | `05_data_cleaning.sql` (`TRY_CONVERT`) |

Run `04_data_quality_audit.sql` to reproduce the evidence for every row of this table.
