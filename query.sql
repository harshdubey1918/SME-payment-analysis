-- ============================================
-- SME Payment Delay Analysis — SQL Queries
-- Database: MySQL
-- Dataset: 45,839 B2B Invoice Transactions
-- ============================================

USE sme_payments;

-- Query 1: Overall Delay Distribution
SELECT 
    Delay_Bins,
    COUNT(*) AS invoice_count,
    ROUND(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM invoices), 1) AS percentage
FROM invoices
GROUP BY Delay_Bins
ORDER BY invoice_count DESC;

-- Query 2: Amount At Risk
SELECT 
    Amount_Bins,
    COUNT(*) AS total_invoices,
    SUM(DelayFlag) AS delayed_invoices,
    ROUND(SUM(DelayFlag)*100.0/COUNT(*),1) AS delay_rate_pct,
    SUM(Amount) AS total_amount
FROM invoices
GROUP BY Amount_Bins
ORDER BY total_amount DESC;

-- Query 3: Payment Method Analysis
SELECT 
    Payment_Method_description,
    COUNT(*) AS total_invoices,
    SUM(DelayFlag) AS late_payments,
    ROUND(SUM(DelayFlag)*100.0/COUNT(*),1) AS late_pct,
    ROUND(AVG(Days_Overdue_Delay),1) AS avg_delay_days
FROM invoices
GROUP BY Payment_Method_description
ORDER BY late_pct DESC;

-- Query 4: Customer Age vs Delay
SELECT 
    Customer_Age_Year_Bins,
    COUNT(*) AS total_invoices,
    ROUND(AVG(DelayFlag)*100,1) AS delay_rate_pct,
    ROUND(AVG(Days_Overdue_Delay),1) AS avg_delay_days
FROM invoices
GROUP BY Customer_Age_Year_Bins
ORDER BY delay_rate_pct DESC;

-- Query 5: Chronic Late Payers
SELECT 
    Customer_Name, Region,
    COUNT(*) AS total_invoices,
    SUM(DelayFlag) AS late_payments,
    ROUND(SUM(DelayFlag)*100.0/COUNT(*),1) AS late_pct,
    MAX(Days_Overdue_Delay) AS worst_delay_days
FROM invoices
GROUP BY Customer_Name, Region
HAVING late_payments >= 5
ORDER BY late_pct DESC
LIMIT 20;

-- Query 6: Quarterly Trend
SELECT 
    Quarter_clearing,
    COUNT(*) AS invoices,
    ROUND(AVG(DelayFlag)*100,1) AS delay_rate_pct,
    SUM(Amount) AS total_amount
FROM invoices
GROUP BY Quarter_clearing
ORDER BY Quarter_clearing;

-- Query 7: KPI Summary
SELECT 
    COUNT(*) AS total_invoices,
    SUM(DelayFlag) AS delayed_count,
    ROUND(SUM(DelayFlag)*100.0/COUNT(*),1) AS delay_pct,
    SUM(Amount) AS total_billed,
    SUM(CASE WHEN DelayFlag=1 THEN Amount ELSE 0 END) 
        AS delayed_amount,
    ROUND(AVG(CASE WHEN DelayFlag=1 
        THEN Days_Overdue_Delay END),1) AS avg_delay_days,
    MAX(Days_Overdue_Delay) AS max_delay_days
FROM invoices;
