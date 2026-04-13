-- ============================================================
-- Gross churn rate: monthly and annualized
-- ============================================================
-- Gross churn measures only revenue lost to cancellations.
-- It intentionally excludes expansion, which is why gross churn
-- can be high while NRR remains above 100%.
--
-- Formula:
--   Gross churn rate = Churned MRR / MRR at start of month
--
-- Benchmark (enterprise SaaS, 2025):
--   Monthly gross churn:    0.25 – 0.65%
--   Annualized gross churn: 3 – 8%
--   Source: ChartMogul SaaS Retention Report 2024
--
-- Datadog does not publicly disclose gross churn.
-- Enterprise-segment estimates place it in the 3–5% annual range.
-- ============================================================

WITH start_mrr AS (

    SELECT
        DATE_TRUNC('month', event_month) AS month,
        SUM(mrr_usd)                     AS mrr_at_start
    FROM revenue_events
    WHERE revenue_type IN ('new', 'expansion')
      AND mrr_usd > 0
    GROUP BY 1

),

churn_totals AS (

    SELECT
        DATE_TRUNC('month', churn_date) AS month,
        SUM(churned_mrr_usd)            AS total_churned_mrr,
        COUNT(*)                         AS churned_customers
    FROM churn_events
    GROUP BY 1

)

SELECT
    s.month,
    ROUND(s.mrr_at_start, 0)                          AS mrr_at_start,
    ROUND(COALESCE(c.total_churned_mrr, 0), 0)         AS churned_mrr,
    COALESCE(c.churned_customers, 0)                   AS churned_customers,

    ROUND(
        COALESCE(c.total_churned_mrr, 0)
        / NULLIF(s.mrr_at_start, 0) * 100,
    2) AS gross_churn_rate_monthly_pct,

    -- Multiply by 12 to compare against annual benchmarks
    ROUND(
        COALESCE(c.total_churned_mrr, 0)
        / NULLIF(s.mrr_at_start, 0) * 12 * 100,
    2) AS gross_churn_rate_annualized_pct

FROM start_mrr s
LEFT JOIN churn_totals c ON s.month = c.month
ORDER BY s.month;
