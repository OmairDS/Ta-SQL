# How to use this repository (trainee instructions)

This is a **reference implementation**. Do not fork it and submit it as your
own - build your own repo using this as the standard to match.

## Step 1 - Get it running (30 minutes)

1. Open SSMS or Azure Data Studio and connect to your SQL Server instance.
2. Run the scripts in order:

   | Order | Script | What it does |
   |---|---|---|
   | 1 | `01_create_database.sql` | Creates `SalesAnalysis` |
   | 2 | `02_create_tables.sql` | Staging + final table + indexes |
   | 3 | `03_load_data.sql` | **Edit the file path first**, then load the CSV |
   | 4 | `04_data_quality_audit.sql` | Read-only. Screenshot the output. |
   | 5 | `05_data_cleaning.sql` | Applies the fixes, loads `dbo.Sales` |
   | 6 | `06_exploratory_analysis.sql` | Profiles the data |
   | 7 | `07_business_questions.sql` | The ten answers |
   | 8 | `08_views_and_procedures.sql` | Views + stored procedure |

3. If step 3 fails, read the comment block inside it - the SSMS Import Flat
   File wizard is the fallback.

## Step 2 - Make it yours (this is the graded part)

- Replace at least **four** of the ten business questions with your own.
- Fill in `docs/findings.md` with your real numbers.
- Add at least one chart to `results/screenshots/`.
- Rewrite the README findings section in your own words.

## Step 3 - Publish it

Follow `how-to-build-a-sql-project-on-github.md` and
`how-to-write-and-upload-a-readme.md`.

## What "done" looks like

- [ ] All eight scripts run top to bottom on a clean database
- [ ] `04_data_quality_audit.sql` output screenshotted into the README
- [ ] `docs/findings.md` has no `___` left in it
- [ ] At least four questions are yours, not copied
- [ ] Repo is public, README renders, all images display
- [ ] At least 8 commits with meaningful messages

## The order that matters most

Create > Load > **Audit** > Clean > Explore > Answer > Package.

Trainees who skip the audit step always produce wrong rankings. The dirty
values in this dataset are there specifically to catch that.
