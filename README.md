# Ukraine Humanitarian Funding Analysis

An interactive Power BI project exploring how humanitarian funding in Ukraine compares with reported needs across sectors from **2022 to 2026**.

The project uses data from the **OCHA Financial Tracking Service (FTS)** and combines **PostgreSQL and Power BI** to move from raw humanitarian funding data to a cleaned analytical dataset and an interactive dashboard.

### [View the interactive Tableau dashboard](https://app.fabric.microsoft.com/view?r=eyJrIjoiMGYxNGIxOTctYjE3OC00NGMxLWI4MGItYWNiMzViOTYxZTg1IiwidCI6Ijk0YjQwY2YyLWU5NGUtNDA1Ny1hMmVkLWZiYmY1MjUzYjVlMCJ9)
<sup>Please click the **Fit to page** button in the bottom-right corner.</sup>

![Dashboard demo](assets/dashboard_demo.gif)

## What I wanted to explore

Humanitarian sectors report how much funding they need, but how much of those needs are actually covered?

The dashboard helps answer questions such as:

- Which sectors receive the most funding?
- Which sectors have the largest funding gaps?
- How much of reported requirements is actually covered?
- How has funding changed from year to year?
- Which sectors experienced the strongest decline in funding?

## Dashboard

The report includes:

**Funding** — reported funding that can be compared with requirements  
**Requirements** — reported humanitarian needs  
**Funding Gap** — Requirements − Funding  
**Coverage** — Funding / Requirements  
**YoY Funding Change** — change in funding compared with the previous year

The dashboard can be filtered by **year** and **sector**.

It also highlights three dynamic insights:

**Largest Funding Gap**  
**Lowest Funding Coverage**  
**Biggest YoY Funding Decline**

![Dashboard](assets/dashboard.png)

## Data Pipeline
 
```text
OCHA FTS / HDX
      ↓
CSV
      ↓
PostgreSQL
      ↓
Data validation & SQL transformations
      ↓
Analytical View
      ↓
Power BI
      ↓
DAX measures & dashboard
```
## Data Quality

One of the main challenges was that not every sector has both `funding` and `requirements` reported for every year.

I deliberately did **not** replace missing values with zero:

**NULL ≠ 0**

If a requirement is missing, it would be misleading to calculate funding coverage or a funding gap for that observation.

Because of this, **Coverage** and **Funding Gap** are calculated only where both funding and requirements are available.

I also checked the data for:

- duplicate sector-year observations
- missing funding and requirements
- zero and negative values
- consistency of the source `percent_funded`
- sector availability across years
- duplicate humanitarian plans in 2022

The final analytical scope covers **2022–2026**.

An obsolete 2022 plan record (`plan_id = 1081`) was excluded from the analysis.

## PostgreSQL Layer

I used PostgreSQL as the analytical layer between the raw FTS data and Power BI.

The dashboard connects to a prepared SQL view that defines the analysis scope and separates humanitarian sectors from technical funding categories.

```sql
CREATE OR REPLACE VIEW public.funding_vs_requirements AS
SELECT
    plan_id,
    year,
    sector,
    requirements,
    funding,
    CASE
        WHEN sector IN ('Not specified', 'Multiple clusters/sectors (shared)')
            THEN 'Unallocated'
        WHEN sector = 'Multi-sector'
            THEN 'Cross-sector'
        WHEN sector = 'Other'
            THEN 'Other'
        ELSE 'Sector'
    END AS sector_type
FROM raw.requirements_funding_globalcluster
WHERE year >= 2022;
```

I also shortened several sector names in Power BI to make the dashboard easier to read:

```text
Protection - Mine Action → Mine Action
Protection - Child Protection → Child Protection
Protection - Gender-Based Violence → Gender-Based Violence
Water Sanitation Hygiene → WASH
Emergency Shelter and NFI → Shelter & NFI
```

## Tools

- **PostgreSQL** — data storage, validation and analytical transformations
- **DBeaver** — SQL development and data quality checks
- **Power BI** — data modelling, DAX and dashboard development
- **Git / GitHub** — version control and project documentation

## Data Source

**OCHA Financial Tracking Service (FTS)** 
Dataset: *Ukraine — Requirements and Funding Data*  
Available through the [Humanitarian Data Exchange (HDX)](https://data.humdata.org/dataset/ukr-requirements-and-funding-data)

Primary file used:

`fts_requirements_funding_globalcluster_ukr.csv`

## Project Structure

```text
.
├── README.md
├── powerbi/
│   └── ukraine_humanitarian_funding.pbix
└── assets/
    └── dashboard_demo.gif
    └── dashboard.png
```
