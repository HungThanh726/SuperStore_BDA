-- ============================================================
-- SUPERSTORE BUSINESS ANALYST INSIGHT REPORT
-- Period: FY2014 – FY2017 
-- 4 Dimensions: Sales - Profit - Customer - Product
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 0. TABLE SETUP ( import từ CSV vào SQL Server)

/*
CREATE TABLE dbo.Superstore (
    RowID         INT,
    OrderID       VARCHAR(20),
    OrderDate     DATE,
    ShipDate      DATE,
    ShipMode      VARCHAR(30),
    CustomerID    VARCHAR(20),
    CustomerName  VARCHAR(100),
    Segment       VARCHAR(30),
    Country       VARCHAR(50),
    City          VARCHAR(50),
    [State]       VARCHAR(50),
    PostalCode    VARCHAR(10),
    Region        VARCHAR(20),
    ProductID     VARCHAR(30),
    Category      VARCHAR(30),
    SubCategory   VARCHAR(30),
    ProductName   VARCHAR(200),
    Sales         DECIMAL(10,4),
    Quantity      INT,
    Discount      DECIMAL(5,4),
    Profit        DECIMAL(10,4)
);

*/

-- ============================================================
-- 1. EXECUTIVE KPI OVERVIEW
-- ============================================================

-- 1.1 Tổng hợp KPI toàn giai đoạn
SELECT
    COUNT(DISTINCT OrderID)                              AS TotalOrders,
    COUNT(DISTINCT CustomerID)                           AS TotalCustomers,
    ROUND(SUM(Sales), 2)                                 AS TotalSales,
    ROUND(SUM(Profit), 2)                                AS TotalProfit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS ProfitMarginPct,
    ROUND(SUM(Profit) / NULLIF(COUNT(DISTINCT OrderID), 0), 2) AS AvgProfitPerOrder
FROM dbo.Superstore;

-- ────────────────────────────────────────────────────────────
-- 1.2 Xu hướng doanh thu theo năm (Revenue Trend)
-- 2017 revenue đỉnh nhưng margin giảm 0.7pp → 'growth at a cost'
-- ────────────────────────────────────────────────────────────
SELECT
    YEAR(OrderDate)                                      AS [Year],
    COUNT(DISTINCT OrderID)                              AS Orders,
    ROUND(SUM(Sales), 2)                                 AS Sales,
    ROUND(SUM(Profit), 2)                                AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct,
    -- YoY margin change (Window Function)
    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100
        - LAG(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 1)
            OVER (ORDER BY YEAR(OrderDate)),
    2) AS MarginChangeYoY_pp
FROM dbo.Superstore
GROUP BY YEAR(OrderDate)
ORDER BY [Year];


-- ============================================================
-- 2. SALES & PROFIT ANALYSIS
-- ============================================================

-- 2.1 Category Performance
-- Furniture chiếm 32% sales nhưng chỉ 6.4% profit → audit ngay
SELECT
    Category,
    COUNT(DISTINCT OrderID)                              AS Orders,
    ROUND(SUM(Sales), 2)                                 AS Sales,
    ROUND(SUM(Sales) / SUM(SUM(Sales)) OVER () * 100, 2) AS SalesPct,
    ROUND(SUM(Profit), 2)                                AS Profit,
    ROUND(SUM(Profit) / SUM(SUM(Profit)) OVER () * 100, 2) AS ProfitContribPct,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct,
    CASE
        WHEN SUM(Profit)/NULLIF(SUM(Sales),0) < 0.05 THEN '⚠️ LOW MARGIN — RISK'
        WHEN SUM(Profit)/NULLIF(SUM(Sales),0) > 0.15 THEN '✅ BEST MARGIN'
        ELSE 'NORMAL'
    END AS Flag
FROM dbo.Superstore
GROUP BY Category
ORDER BY Sales DESC;

-- ────────────────────────────────────────────────────────────
-- 2.2 Sub-Category Profit Ranking (Top & Bottom)
-- WARNING: Tables là sub-category duy nhất lỗ ròng (-$17,725)
-- ────────────────────────────────────────────────────────────
SELECT
    SubCategory,
    Category,
    ROUND(SUM(Sales), 2)                                 AS Sales,
    ROUND(SUM(Profit), 2)                                AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct,
    DENSE_RANK() OVER (ORDER BY SUM(Profit) DESC)        AS ProfitRank,
    CASE WHEN SUM(Profit) < 0 THEN '🔴 LOSS' ELSE '✅ PROFIT' END AS Status
FROM dbo.Superstore
GROUP BY SubCategory, Category
ORDER BY Profit;

-- ────────────────────────────────────────────────────────────
-- 2.3 Region Performance
-- Central margin 7.9% — gap 7pp vs West → $35K/năm bị 'bỏ quên'
-- ────────────────────────────────────────────────────────────
SELECT
    Region,
    COUNT(DISTINCT CustomerID)                           AS Customers,
    COUNT(DISTINCT OrderID)                              AS Orders,
    ROUND(SUM(Sales), 2)                                 AS Sales,
    ROUND(SUM(Profit), 2)                                AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct,
    -- Margin gap vs best region (Window Function)
    ROUND(
        MAX(SUM(Profit) / NULLIF(SUM(Sales), 0)) OVER ()
        - SUM(Profit) / NULLIF(SUM(Sales), 0),
    4) * 100                                             AS MarginGapVsBest_pp
FROM dbo.Superstore
GROUP BY Region
ORDER BY MarginPct DESC;

-- ────────────────────────────────────────────────────────────
-- 2.4 Region × Sub-Category Cross Analysis
-- (Tìm hiểu tại sao Central thấp: sản phẩm khác hay discount khác?)
-- ────────────────────────────────────────────────────────────
SELECT
    Region,
    SubCategory,
    ROUND(SUM(Sales), 2)                                 AS Sales,
    ROUND(SUM(Profit), 2)                                AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct,
    ROUND(AVG(Discount) * 100, 2)                        AS AvgDiscountPct
FROM dbo.Superstore
GROUP BY Region, SubCategory
ORDER BY Region, Profit;


-- ============================================================
-- 3. DISCOUNT IMPACT ANALYSIS — "The Hidden Profit Killer"
-- ============================================================

-- 3.1 Discount band analysis
-- >50% discount → margin -119%: bán $1 thì lỗ $1.19
SELECT
    CASE
        WHEN Discount = 0          THEN '0%'
        WHEN Discount <= 0.10      THEN '1-10%'
        WHEN Discount <= 0.20      THEN '11-20%'
        WHEN Discount <= 0.30      THEN '21-30%'
        WHEN Discount <= 0.40      THEN '31-40%'
        WHEN Discount <= 0.50      THEN '41-50%'
        ELSE                            '>50%'
    END                                                  AS DiscountBand,
    COUNT(*)                                             AS Rows,
    ROUND(SUM(Sales), 2)                                 AS Sales,
    ROUND(SUM(Profit), 2)                                AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct,
    CASE
        WHEN SUM(Profit) < 0 THEN '🔴 LOSS'
        WHEN SUM(Profit)/NULLIF(SUM(Sales),0) > 0.20 THEN '✅ HEALTHY'
        ELSE '⚠️ WARNING'
    END AS Insight
FROM dbo.Superstore
GROUP BY
    CASE
        WHEN Discount = 0          THEN '0%'
        WHEN Discount <= 0.10      THEN '1-10%'
        WHEN Discount <= 0.20      THEN '11-20%'
        WHEN Discount <= 0.30      THEN '21-30%'
        WHEN Discount <= 0.40      THEN '31-40%'
        WHEN Discount <= 0.50      THEN '41-50%'
        ELSE                            '>50%'
    END
ORDER BY MIN(Discount);

-- ────────────────────────────────────────────────────────────
-- 3.2 Loss from over-discounting — Total recoverable profit
-- Cap discount tại 20% → recover ~$125K/năm
-- ────────────────────────────────────────────────────────────
SELECT
    COUNT(*) FILTER (WHERE Discount > 0.30)      AS LossRows_Over30pct,
    -- T-SQL equivalent (no FILTER):
    SUM(CASE WHEN Discount > 0.30 THEN 1 ELSE 0 END) AS LossRows_Over30pct_TSQL,
    ROUND(SUM(CASE WHEN Discount > 0.30 THEN Profit ELSE 0 END), 2)  AS ProfitLost_Over30pct,
    ROUND(SUM(CASE WHEN Discount > 0.50 THEN Profit ELSE 0 END), 2)  AS ProfitLost_Over50pct,
    ROUND(SUM(CASE WHEN Discount > 0.20 THEN Profit ELSE 0 END), 2)  AS TotalLoss_Over20pct
FROM dbo.Superstore;

-- ────────────────────────────────────────────────────────────
-- 3.3 High-risk transactions (discount >50%, negative profit)
-- Review ngay 856 giao dịch
-- ────────────────────────────────────────────────────────────
SELECT TOP 20
    OrderID, OrderDate, CustomerName, Category, SubCategory,
    ProductName,
    ROUND(Sales, 2)    AS Sales,
    Discount,
    ROUND(Profit, 2)   AS Profit,
    ROUND(Profit / NULLIF(Sales, 0) * 100, 2) AS MarginPct
FROM dbo.Superstore
WHERE Discount > 0.50 AND Profit < 0
ORDER BY Profit ASC;


-- ============================================================
-- 4. CUSTOMER ANALYSIS
-- ============================================================

-- 4.1 Customer Segment Performance
SELECT
    Segment,
    COUNT(DISTINCT CustomerID)                           AS Customers,
    COUNT(DISTINCT OrderID)                              AS Orders,
    ROUND(SUM(Sales), 2)                                 AS Sales,
    ROUND(SUM(Profit), 2)                                AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct,
    ROUND(SUM(Sales) / NULLIF(COUNT(DISTINCT CustomerID), 0), 2) AS AvgSalesPerCustomer
FROM dbo.Superstore
GROUP BY Segment
ORDER BY MarginPct DESC;

-- ────────────────────────────────────────────────────────────
-- 4.2 Segment × Category Profit Matrix
-- Best: Home Office + Office Supplies = 20.8% → target for combo marketing
-- ────────────────────────────────────────────────────────────
SELECT
    Segment,
    Category,
    ROUND(SUM(Sales), 2)                                 AS Sales,
    ROUND(SUM(Profit), 2)                                AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct,
    RANK() OVER (PARTITION BY Segment ORDER BY SUM(Profit)/NULLIF(SUM(Sales),0) DESC) AS RankInSegment
FROM dbo.Superstore
GROUP BY Segment, Category
ORDER BY Segment, MarginPct DESC;

-- ────────────────────────────────────────────────────────────
-- 4.3 Customer Loyalty Analysis (3+ active years = loyal)
-- ────────────────────────────────────────────────────────────
WITH CustomerYears AS (
    SELECT
        CustomerID,
        CustomerName,
        COUNT(DISTINCT YEAR(OrderDate)) AS ActiveYears
    FROM dbo.Superstore
    GROUP BY CustomerID, CustomerName
)
SELECT
    COUNT(*)                                             AS TotalCustomers,
    SUM(CASE WHEN ActiveYears >= 3 THEN 1 ELSE 0 END)   AS LoyalCustomers,
    ROUND(
        SUM(CASE WHEN ActiveYears >= 3 THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100, 2)                 AS LoyaltyRatePct
FROM CustomerYears;

-- ────────────────────────────────────────────────────────────
-- 4.4 Top 10 customers by revenue — với profit flag
-- Sean Miller $25K sales nhưng lỗ $1,981 → 'expensive loyalty'
-- ────────────────────────────────────────────────────────────
SELECT TOP 10
    CustomerID,
    CustomerName,
    Segment,
    COUNT(DISTINCT OrderID)                              AS Orders,
    ROUND(SUM(Sales), 2)                                 AS Sales,
    ROUND(SUM(Profit), 2)                                AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct,
    CASE WHEN SUM(Profit) < 0 THEN '🔴 NET LOSS VIP' ELSE '✅ PROFITABLE' END AS VIPStatus
FROM dbo.Superstore
GROUP BY CustomerID, CustomerName, Segment
ORDER BY Sales DESC;

-- ────────────────────────────────────────────────────────────
-- 4.5 Top 10 customers by profit (truly valuable customers)
-- ────────────────────────────────────────────────────────────
SELECT TOP 10
    CustomerName, Segment,
    ROUND(SUM(Sales), 2)                                 AS Sales,
    ROUND(SUM(Profit), 2)                                AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct
FROM dbo.Superstore
GROUP BY CustomerID, CustomerName, Segment
ORDER BY Profit DESC;


-- ============================================================
-- 5. PRODUCT & OPERATIONAL ANALYSIS
-- ============================================================

-- 5.1 Top 10 products by revenue
SELECT TOP 10
    ProductName, Category, SubCategory,
    ROUND(SUM(Sales), 2)    AS Sales,
    ROUND(SUM(Profit), 2)   AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct
FROM dbo.Superstore
GROUP BY ProductName, Category, SubCategory
ORDER BY Sales DESC;

-- ────────────────────────────────────────────────────────────
-- 5.2 Top 10 loss-making products — cần review ngay
-- WARNING: Cubify 3D Printer -80% margin
-- ────────────────────────────────────────────────────────────
SELECT TOP 10
    ProductName, Category, SubCategory,
    ROUND(SUM(Sales), 2)    AS Sales,
    ROUND(SUM(Profit), 2)   AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct,
    ROUND(AVG(Discount) * 100, 2) AS AvgDiscountPct
FROM dbo.Superstore
GROUP BY ProductName, Category, SubCategory
HAVING SUM(Profit) < 0
ORDER BY Profit ASC;

-- ────────────────────────────────────────────────────────────
-- 5.3 Shipping Mode Analysis
-- 60% dùng Standard (5 ngày) → xem xét push Second Class cho đơn >$500
-- ────────────────────────────────────────────────────────────
SELECT
    ShipMode,
    COUNT(DISTINCT OrderID)                              AS Orders,
    ROUND(COUNT(DISTINCT OrderID) * 100.0 / SUM(COUNT(DISTINCT OrderID)) OVER (), 2) AS OrderPct,
    ROUND(AVG(DATEDIFF(day, OrderDate, ShipDate)), 2)    AS AvgShipDays,
    ROUND(SUM(Profit), 2)                                AS Profit
FROM dbo.Superstore
GROUP BY ShipMode
ORDER BY Orders DESC;


-- ============================================================
-- 6. ADVANCED ANALYTICS (Window Functions & CTEs)
-- ============================================================

-- 6.1 Running cumulative profit by year (tích lũy lợi nhuận)
SELECT
    YEAR(OrderDate)  AS [Year],
    MONTH(OrderDate) AS [Month],
    ROUND(SUM(Profit), 2) AS MonthlyProfit,
    ROUND(SUM(SUM(Profit)) OVER (
        ORDER BY YEAR(OrderDate), MONTH(OrderDate)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS CumulativeProfit
FROM dbo.Superstore
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY [Year], [Month];

-- ────────────────────────────────────────────────────────────
-- 6.2 Sub-category ranking within each Category
-- (Dùng RANK để so sánh nội bộ trong từng ngành hàng)
-- ────────────────────────────────────────────────────────────
SELECT
    Category,
    SubCategory,
    ROUND(SUM(Sales), 2)  AS Sales,
    ROUND(SUM(Profit), 2) AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS MarginPct,
    RANK() OVER (PARTITION BY Category ORDER BY SUM(Profit) DESC) AS RankInCategory
FROM dbo.Superstore
GROUP BY Category, SubCategory
ORDER BY Category, RankInCategory;

-- ────────────────────────────────────────────────────────────
-- 6.3 Customer RFM Segmentation (Recency - Frequency - Monetary)
-- Cơ sở để xây dựng loyalty program chính thức
-- ────────────────────────────────────────────────────────────
WITH RFM_Raw AS (
    SELECT
        CustomerID,
        CustomerName,
        DATEDIFF(day, MAX(OrderDate), '2018-01-01')  AS Recency_Days,
        COUNT(DISTINCT OrderID)                       AS Frequency,
        ROUND(SUM(Sales), 2)                          AS Monetary
    FROM dbo.Superstore
    GROUP BY CustomerID, CustomerName
),
RFM_Scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency_Days ASC)  AS R_Score,  -- lower = better
        NTILE(5) OVER (ORDER BY Frequency DESC)    AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC)     AS M_Score
    FROM RFM_Raw
)
SELECT
    CustomerID, CustomerName,
    Recency_Days, Frequency, Monetary,
    R_Score, F_Score, M_Score,
    R_Score + F_Score + M_Score                       AS RFM_Total,
    CASE
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN '🌟 Champions'
        WHEN R_Score >= 3 AND F_Score >= 3             THEN '💚 Loyal Customers'
        WHEN R_Score >= 4 AND F_Score <= 2             THEN '🆕 Promising'
        WHEN R_Score <= 2 AND F_Score >= 3             THEN '⚠️ At Risk'
        WHEN R_Score <= 2 AND F_Score <= 2             THEN '💀 Lost'
        ELSE                                                '👀 Needs Attention'
    END AS CustomerSegment
FROM RFM_Scored
ORDER BY RFM_Total DESC;

-- ────────────────────────────────────────────────────────────
-- 6.4 Month-over-Month (MoM) Revenue Growth Rate
-- ────────────────────────────────────────────────────────────
WITH Monthly AS (
    SELECT
        YEAR(OrderDate)  AS [Year],
        MONTH(OrderDate) AS [Month],
        SUM(Sales)       AS MonthlySales
    FROM dbo.Superstore
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT
    [Year], [Month],
    ROUND(MonthlySales, 2) AS Sales,
    ROUND(LAG(MonthlySales) OVER (ORDER BY [Year], [Month]), 2) AS PrevMonthSales,
    ROUND(
        (MonthlySales - LAG(MonthlySales) OVER (ORDER BY [Year],[Month]))
        / NULLIF(LAG(MonthlySales) OVER (ORDER BY [Year],[Month]), 0) * 100
    , 2) AS MoM_GrowthPct
FROM Monthly
ORDER BY [Year], [Month];

-- ────────────────────────────────────────────────────────────
-- 6.5 Profitability Cohort: New vs Returning customers by year
-- ────────────────────────────────────────────────────────────
WITH FirstOrder AS (
    SELECT CustomerID, MIN(YEAR(OrderDate)) AS FirstYear
    FROM dbo.Superstore
    GROUP BY CustomerID
)
SELECT
    YEAR(s.OrderDate)   AS OrderYear,
    CASE WHEN fo.FirstYear = YEAR(s.OrderDate) THEN 'New' ELSE 'Returning' END AS CustomerType,
    COUNT(DISTINCT s.CustomerID)  AS Customers,
    ROUND(SUM(s.Sales), 2)        AS Sales,
    ROUND(SUM(s.Profit), 2)       AS Profit,
    ROUND(SUM(s.Profit)/NULLIF(SUM(s.Sales),0)*100, 2) AS MarginPct
FROM dbo.Superstore s
JOIN FirstOrder fo ON s.CustomerID = fo.CustomerID
GROUP BY YEAR(s.OrderDate),
         CASE WHEN fo.FirstYear = YEAR(s.OrderDate) THEN 'New' ELSE 'Returning' END
ORDER BY OrderYear, CustomerType;


-- ============================================================
-- 7. RECOMMENDATION VALIDATION QUERIES
-- ============================================================

-- 7.1 Estimate profit recovery if discount capped at 20%
SELECT
    'Current Profit'  AS Scenario,
    ROUND(SUM(Profit), 2) AS EstimatedProfit
FROM dbo.Superstore

UNION ALL

SELECT
    'Projected (cap discount at 20%)' AS Scenario,
    ROUND(SUM(
        CASE
            WHEN Discount <= 0.20 THEN Profit
            ELSE Sales * (Profit/NULLIF(Sales,0)) * 0.20/NULLIF(Discount,0)  -- scaled estimate
        END
    ), 2) AS EstimatedProfit
FROM dbo.Superstore;

-- ────────────────────────────────────────────────────────────
-- 7.2 Tables sub-category — confirm loss and discount driver
-- ────────────────────────────────────────────────────────────
SELECT
    SubCategory,
    COUNT(*)                            AS Transactions,
    ROUND(SUM(Sales), 2)                AS Sales,
    ROUND(SUM(Profit), 2)               AS Profit,
    ROUND(AVG(Discount)*100, 2)         AS AvgDiscountPct,
    ROUND(MAX(Discount)*100, 2)         AS MaxDiscountPct,
    ROUND(SUM(Profit)/NULLIF(SUM(Sales),0)*100, 2) AS MarginPct
FROM dbo.Superstore
WHERE SubCategory = 'Tables'
GROUP BY SubCategory;

-- ────────────────────────────────────────────────────────────
-- 7.3 Home Office + Office Supplies — confirm 20.8% margin
-- ────────────────────────────────────────────────────────────
SELECT
    Segment, Category,
    ROUND(SUM(Sales), 2)    AS Sales,
    ROUND(SUM(Profit), 2)   AS Profit,
    ROUND(SUM(Profit)/NULLIF(SUM(Sales),0)*100, 2) AS MarginPct
FROM dbo.Superstore
WHERE Segment = 'Home Office' AND Category = 'Office Supplies'
GROUP BY Segment, Category;

-- ────────────────────────────────────────────────────────────
-- 7.4 Central vs West region deep-dive
-- (product mix so sánh và discount behaviour)
-- ────────────────────────────────────────────────────────────
SELECT
    Region,
    Category,
    ROUND(SUM(Sales), 2)              AS Sales,
    ROUND(SUM(Profit), 2)             AS Profit,
    ROUND(SUM(Profit)/NULLIF(SUM(Sales),0)*100, 2) AS MarginPct,
    ROUND(AVG(Discount)*100, 2)       AS AvgDiscountPct
FROM dbo.Superstore
WHERE Region IN ('Central','West')
GROUP BY Region, Category
ORDER BY Region, Category;


-- ============================================================
-- END OF FILE
-- Superstore Business Analyst Insight Report | FY2014-2017
-- ============================================================
