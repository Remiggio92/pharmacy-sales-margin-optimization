-- 1. RECURSIVE CTE: Generating dynamic margin targets for each month 
-- (e.g., assuming target margin grows by 0.5% MoM, starting at 15%)
WITH RECURSIVE MarginTargets AS (
  SELECT 1 AS MonthNumber, 0.15 AS TargetMarginRate
  UNION ALL
  SELECT MonthNumber + 1, TargetMarginRate + 0.005
  FROM MarginTargets
  WHERE MonthNumber < 12
),

-- 2. STANDARD CTE: Joining dimensions with facts and performing basic aggregation
MonthlySalesAgg AS (
  SELECT 
    d.Year,
    d.MonthNumber,
    d.YearMonth,
    ph.PharmacyName,
    pr.Category,
    -- CONDITIONAL AGGREGATION: Splitting revenue into generic and brand drugs in separate columns
    SUM(CASE WHEN pr.IsGeneric = TRUE THEN f.RevenueEUR ELSE 0 END) AS GenericRevenue,
    SUM(CASE WHEN pr.IsGeneric = FALSE THEN f.RevenueEUR ELSE 0 END) AS BrandRevenue,
    SUM(f.RevenueEUR) AS TotalRevenue,
    SUM(f.MarginEUR) AS TotalMargin
  FROM `my-first-project-457721.pharmacy_analysis.FactSales` f
  JOIN `my-first-project-457721.pharmacy_analysis.DimDate` d ON f.DateKey = d.DateKey
  JOIN `my-first-project-457721.pharmacy_analysis.DimProduct` pr ON f.ProductID = pr.ProductID
  JOIN `my-first-project-457721.pharmacy_analysis.DimPharmacy` ph ON f.PharmacyID = ph.PharmacyID
  GROUP BY 1, 2, 3, 4, 5
),

-- 3. WINDOW FUNCTIONS: LEAD, LAG, and Running Totals
AdvancedAnalytics AS (
  SELECT 
    m.Year,
    m.MonthNumber,
    m.YearMonth,
    m.PharmacyName,
    m.Category,
    m.TotalRevenue,
    m.GenericRevenue,
    m.BrandRevenue,
    -- Calculating actual profitability (Margin Rate)
    SAFE_DIVIDE(m.TotalMargin, m.TotalRevenue) AS ActualMarginRate,
    
    -- LAG: Retrieving previous month's revenue for the same pharmacy and category
    LAG(m.TotalRevenue) OVER(PARTITION BY m.PharmacyName, m.Category ORDER BY m.YearMonth) AS PrevMonthRevenue,
    
    -- LEAD: Retrieving next month's revenue
    LEAD(m.TotalRevenue) OVER(PARTITION BY m.PharmacyName, m.Category ORDER BY m.YearMonth) AS NextMonthRevenue,
    
    -- SUM() OVER(): Calculating cumulative annual revenue (YTD - Year To Date)
    SUM(m.TotalRevenue) OVER(PARTITION BY m.Year, m.PharmacyName, m.Category ORDER BY m.YearMonth 
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS YTD_Revenue
  FROM MonthlySalesAgg m
)

-- 4. FINAL SELECT: Calculating metrics against business targets
SELECT 
  a.YearMonth,
  a.PharmacyName,
  a.Category,
  a.TotalRevenue,
  a.GenericRevenue,
  a.BrandRevenue,
  a.YTD_Revenue,
  ROUND(a.ActualMarginRate * 100, 2) AS ActualMargin_Pct,
  ROUND(t.TargetMarginRate * 100, 2) AS TargetMargin_Pct,
  -- Calculating MoM (Month-over-Month) growth dynamic using the LAG function value
  ROUND(SAFE_MULTIPLY(SAFE_DIVIDE(a.TotalRevenue - a.PrevMonthRevenue, a.PrevMonthRevenue), 100), 2) AS MoM_Growth_Pct
FROM AdvancedAnalytics a
LEFT JOIN MarginTargets t ON a.MonthNumber = t.MonthNumber
ORDER BY a.PharmacyName, a.Category, a.YearMonth;
