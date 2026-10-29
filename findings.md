# Findings

> **Trainee: this file is a template.** Run the queries in
> `sql/07_business_questions.sql`, paste your real result tables below, and
> replace every `___` with your number. A finding without a number is not a
> finding.

---

## Q1 - Revenue by city

```sql
SELECT City, COUNT(*) AS Transactions, SUM(Sale) AS Revenue,
       CAST(100.0 * SUM(Sale) / SUM(SUM(Sale)) OVER () AS DECIMAL(5,2)) AS PctOfRevenue
FROM dbo.Sales
GROUP BY City
ORDER BY Revenue DESC;
```

| City | Transactions | Revenue | % of Revenue |
|---|---|---|---|
| | | | |

**Read:** ___ leads with ___% of revenue, but ___ has the highest average
transaction value at SAR ___. The opportunity is ___.

---

## Q2 - Rep performance: revenue vs margin

| Rep | Deals | Revenue | Profit | Margin % | Rank by revenue | Rank by profit |
|---|---|---|---|---|---|---|
| | | | | | | |

**Read:** ___ ranks #___ on revenue but #___ on profit - volume is masking
weak pricing. ___ is the reverse case and is worth studying.

---

## Q3 - Year-over-year growth

| Year | Revenue | Growth % |
|---|---|---|
| | | |

**Read:** Revenue moved from SAR ___ in 2004 to SAR ___ in 2015, a ___%
change. The sharpest drop was in ___, driven by ___.

![Revenue trend](../results/screenshots/yearly_trend.png)

---

## Q4 - Seasonality

**Read:** ___ is consistently the strongest month; ___ the weakest. The
pattern repeats in ___ of the ___ years, so it is seasonal rather than noise.

---

## Q5 - Product profitability

| Product | Units | Revenue | Margin % | Assessment |
|---|---|---|---|---|
| | | | | |

**Read:** ___ is the volume leader but carries only ___% margin. ___ sells
___ units yet contributes SAR ___ in profit.

---

## Q8 - Revenue concentration (Pareto)

**Read:** The top 20% of transactions account for ___% of revenue. This
[does / does not] follow the 80/20 pattern, which means ___.

---

## Data quality note

Two deliberate errors were found and corrected before any of the above was
calculated (see `data/data_dictionary.md`). Left uncorrected, the rep ranking
in Q2 would have been wrong: `Mjeeed` and `Mjeed` would have appeared as two
people, splitting ___ transactions and SAR ___ of revenue.

---

## Recommendations

1. ___
2. ___
3. ___
