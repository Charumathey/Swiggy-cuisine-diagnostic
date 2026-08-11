# AI-Assisted Prompt Log

## Prompt #1 — Debugging the variance/percentage\_variance query (RCTCF)



**Role**: I am an experienced SQLite analyst helping me debug a derived-fields query for a Swiggy-style cuisine revenue diagnostic.



**Context**: I have a cuisine\_targets table (cuisine, target\_revenue\_inr, both stored as INTEGER) and a subquery that computes total\_revenue (also INTEGER)
per cuisine from orders JOIN restaurants, Delivered orders only. I need to compute percentage\_variance = ((total\_revenue - target\_revenue\_inr) / target\_revenue\_inr) \* 100, but every row is coming back as 0 or -0 instead of a real percentage like -8.69.



**Task**: Explain why the percentage is coming back as 0, and rewrite the expression so it returns the correct floating-point percentage.

Constraints: Must stay valid SQLite syntax (no MONTH()/YEAR() style functions), must not change the underlying column types in the schema, and the fix must be a change to the SELECT expression only — not to how the data is generated or stored.



**Format**: Give me the corrected single SQL expression, plus a one-sentence explanation of the root cause.

AI's core suggestion: SQLite performs integer division when both operands of / are INTEGER columns, so (total\_revenue - target\_revenue\_inr) / target\_revenue\_inr truncates to 0 before the \* 100 ever runs. Fix by forcing floating-point division early — multiply by 100.0 (a REAL literal) before dividing, i.e. ((total\_revenue - target\_revenue\_inr) \* 100.0) / target\_revenue\_inr, or wrap either operand in CAST(... AS REAL).

Verification actually performed: I applied the corrected expression in 03\_reporting.sql, ran the full query against swiggy\_capstone.db in DB Browser for SQLite, and manually recomputed the percentage for two cuisines by hand — Chinese (127840 vs target 140000 → -8.685714...) and Desserts (19694 vs target 25000 → -21.224) — both matched the query's.



## Prompt #2 — Designing the Above/Below Target calculated field in Tableau (RCTCF)

**Role:** I am a Tableau Public expert helping me design a calculated field for a dashboard.



**Context:** My data source is `monthly\_cuisine\_revenue.csv` with columns `cuisine, month, order\_count, total\_revenue, avg\_revenue— one row per cuisine per month (34 rows total, 6 cuisines x up to 6 months). It has no
target column. I already know each cuisine's fixed monthly target from a separate SQL table (North Indian 180000, Chinese 140000, South Indian 50000, Fast Food 60000, Desserts 25000, Italian 10000), and I need to color a cuisine-level bar chart by whether each cuisine is Above or Below that target.



**Task:** Give me a Tableau calculated field (or pair of fields) that tags each cuisine 'Above Target' or 'Below Target' for use as a color legend on a bar chart aggregated by cuisine.



**Constraints:** No external join to a separate targets file — the six targets are fixed and small enough to hardcode directly in a calculated field using Tableau's CASE syntax. The final field must evaluate correctly when the view is aggregated to one mark per cuisine (i.e. after summing across that cuisine's monthly rows).



**Format:** Give me the exact calculated-field formula(s), plus the Tableau function name I should aggregate them with in the view.



**AI's core suggestion:** Two calculated fields — first, `Target Revenue`: `CASE \[Cuisine] WHEN 'North Indian' THEN 180000 WHEN 'Chinese' THEN 140000 WHEN 'South Indian' THEN 50000 WHEN 'Fast Food' THEN 60000 WHEN 'Desserts' THEN 25000 WHEN 'Italian' THEN 10000 END`; second, `Target Status`: IF SUM(\[Total Revenue]) >= SUM(\[Target Revenue]) THEN 'Above Target' ELSE 'Below Target' END`, dragged onto Color.



**Verification actually performed:** I built both fields in Tableau Public exactly as suggested and dropped `Target Status` onto Color for the cuisine bar chart. Chinese and Fast Food — which I already knew from Parts A/B should be "Below Target" — rendered as "Above Target" instead, which was visibly wrong. I checked the underlying issue by adding `SUM(\[Target Revenue])` as a text label on the chart: for Chinese it showed 840,000 instead of 140,000 — exactly 6x too high, matching Chinese's 6 monthly rows in the CSV. `SUM()` was adding the same constant target once per month row instead of treating it as a single per-cuisine value. I fixed it by replacing `SUM(\[Target Revenue])` with `MIN(\[Target Revenue])` in the `Target Status` formula (any aggregation that doesn't multiply a constant works, since the value is identical across all of a cuisine's rows). After the fix, I re-checked all 6 cuisines' colors against the Above/Below Target table already confirmed in `DATA\_STORY.md` (Part A/B) and every cuisine matched: North Indian, South Indian, and Italian rendered Above Target; Chinese, Fast Food, and Desserts rendered Below Target.



