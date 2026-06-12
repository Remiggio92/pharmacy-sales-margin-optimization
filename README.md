# Pharmacy Sales & Margin Optimization Analytics

## Project Overview
This project delivers a comprehensive data analytics solution designed to optimize financial operations and product performance for a network of pharmacies. Utilizing a **Star Schema** data model, the analysis evaluates monthly revenue trends, tracks real-time profitability against dynamic targets, and conducts generic substitution checks to identify cost-saving opportunities.

The core engineering and analytics were performed in **Google BigQuery** using advanced SQL, and the insights were visualized in an interactive dashboard via **Tableau Public**.

* **Interactive Dashboard:** [📊 See the interactive dashboard in Tableau Public](https://public.tableau.com/app/profile/remiggio.kowalczyk/viz/European_Pharmacies_Sales/PharmacySalesMarginOptimizationDashboard)]
* **SQL Code Location:** [💻 See full SQL code](analytics_view.sql)

---

## Business Goal & Analytical Approach
The objective of this analysis is to support data-driven decision-making in healthcare financial operations by addressing three critical challenges:
1. **Dynamic Margin Alignment:** Evaluating individual pharmacy performance against corporate margin targets that scale over time.
2. **Generic Substitution Tracking:** Quantifying the revenue split between high-cost brand drugs and cost-effective generic alternatives.
3. **Growth & Trend Analysis:** Conducting Root Cause Analysis on Month-over-Month (MoM) revenue fluctuations and tracking Year-to-Date (YTD) cumulative progress.

---

## Tech Stack & Tools
* **Database / Data Warehouse:** Google BigQuery (SQL)
* **Visualization BI Tool:** Tableau Public
* **Data Prep / Storage Source:** Google Sheets / Google Drive

---

## Data Model Architecture
The project is built on a robust **Star Schema** architecture consisting of one central fact table and three dimension tables:
* **`FactSales`:** Contains transactional data (SalesID, UnitsSold, RevenueEUR, CostEUR, MarginEUR, PromoFlag).
* **`DimProduct`:** Holds product-level details (ProductID, ProductName, Category, Brand, IsGeneric, ListPriceEUR).
* **`DimPharmacy`:** Stores store location and metadata (PharmacyID, PharmacyName, City, Region, PharmacyType).
* **`DimDate`:** Provides standard calendar attributes for time-series analysis (DateKey, FullDate, Year, MonthNumber, YearMonth).

---

## Advanced SQL Features Implemented
To ensure optimal performance and avoid expensive self-joins, the analytical dataset (*Data Mart*) was engineered directly in BigQuery using:
* **Recursive CTEs:** Dynamically generated incremental business margin targets across a 12-month fiscal timeline.
* **Standard CTEs:** Organised and modularized complex multi-table joins to maintain clean, readable, and maintainable code.
* **Conditional Aggregation (`SUM(CASE WHEN...)`):** Pivoted structural transactional rows into distinct metrics for Generic vs. Brand revenue tracking.
* **Window Functions (`LAG`, `LEAD`, `SUM() OVER`):** * `LAG` & `LEAD` were utilized to capture adjacent monthly revenue performance for MoM growth metrics.
  * `SUM() OVER (PARTITION BY... ROWS BETWEEN...)` computed the cumulative Year-to-Date (YTD) asset performance directly at the database level, optimizing dashboard load times.

---

## Key Business Insights Derived
* **Target Variance:** Identified specific pharmacies and product categories failing to keep pace with the shifting 15%–20.5% scaling margin target.
* **Substitution Optimization:** Highlighted high-revenue product lines dominated by brand medications where active generic substitution programs could dramatically increase operational margins.
* **Growth Vectors:** Isolated localized market anomalies where MoM growth rates experienced unprecedented negative spikes, providing clear indicators for localized audits.
