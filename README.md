# Logistics Operations Analysis (2022 – 2024)

**Tools:** PostgreSQL · pgAdmin 4 · Power BI  
**Skills:** Relational Database Design · SQL Querying · Data Modelling · Dashboard Development · Business Analysis  
**Status:** Completed

---

## Project Overview

A logistics and trucking company operating across the United States had accumulated three years of operational data with no structured framework to evaluate performance. Revenue had been flat, two major customers had gone inactive, and the business had no visibility into which routes, trucks, and drivers were driving profitability or creating risk.

This project analyses **85,410 loads** across customer, route, fleet, and safety datasets to identify the root causes of operational inefficiency and recommend actionable changes.

---

## Technical Workflow & Methodology

To process and analyse the data effectively, I used a multi-tool pipeline:

- **Database Design (PostgreSQL):** Loaded all 14 CSV tables into a relational PostgreSQL database with proper data types, primary keys, and foreign key relationships. Assessed data quality — identified and documented null values in the trips and safety tables and handled them in the query layer.

- **Business Analysis (SQL):** Wrote 7 analytical SQL views covering all four analysis areas using:
  - Multi-table JOINs across loads, trips, customers, routes, drivers, and maintenance tables
  - Aggregations with GROUP BY to summarise revenue, cost, and incident data
  - CASE WHEN statements for conditional counts (on-time vs late, at-fault vs not at fault)
  - NULLIF to protect against division-by-zero errors in revenue-per-mile calculations
  - MODE() WITHIN GROUP for most frequent maintenance type per truck

- **Data Visualisation (Power BI):** Connected Power BI directly to PostgreSQL views using Import mode and built a 4-page interactive dashboard with slicers, KPI cards, bar charts, donut charts, and page navigation.

*(The complete SQL scripts are in the repository files)*

---

## Key Findings

| Area | Finding |
|---|---|
| Revenue | Flat at ~$88M across 3 years with a dip to $87M in 2023 — no growth detected |
| Customers | Top 2 customers inactive — XYZ Foods and Metro Group — over $6M in lost annual revenue |
| Delivery | 45% late delivery rate and 93 minutes average detention across all customers — systemic issue |
| Routes | Columbus → Los Angeles leads revenue per mile at $2.65. Average idle time is 7 hours per trip |
| Maintenance | Peterbilt trucks lead downtime at 14.1K hours. TRK00003 alone cost $90K with 47 days out of service |
| Safety | 53.85% of incidents were driver at fault. David Miller — 7 at-fault incidents, $118K in claims, still active |

---

## Strategic Recommendations

1. **Re-engage XYZ Foods and Metro Group** — these two inactive customers represent over $6M in lost annual revenue and should be the first priority for account recovery.

2. **Investigate the 45% late delivery rate** — this affects every customer and points to a scheduling or capacity planning failure, not isolated incidents.

3. **Phase out 2015 trucks** — older trucks consistently drive the highest maintenance costs and downtime hours. A structured replacement plan would reduce both repair spend and lost earning days.

4. **Review David Miller's employment status** — 7 at-fault incidents and $118K in claims while remaining active is a direct financial and legal liability to the business.

5. **Prioritise Contract customer acquisition** — Contract customers generate $46K average revenue per load compared to $33K for Dedicated, making them the highest-value customer segment to grow.

---

## Dashboard Preview

### Executive Summary
![Executive Summary](screenshots/01_Executive_Summary.png)

### Customer Analysis
![Customer Analysis](screenshots/02_Customer_Analysis.png)

### Route & Maintenance Analysis
![Route and Maintenance](screenshots/03_Route_and_Maintenance.png)

### Safety Analysis
![Safety Analysis](screenshots/04_Safety_Analysis.png)

---

## Project Files

| File | Description |
|---|---|
| `Logistics_Operations_Database_Setup.sql` | Creates all 14 tables and loads data into PostgreSQL |
| `Logistics_Operations_Analysis_Views.sql` | Creates 7 analytical SQL views used in the dashboard |
| `Logistics_Operations_Dashboard.pdf` | Exported Power BI dashboard — all 4 pages |
| `Logistics_Operations_Analysis_Report.docx` | Full written report with findings and recommendations |

---

## About

**Muizza Adetoro**  
TS Academy — Data Analytics Capstone Project | May 2026

