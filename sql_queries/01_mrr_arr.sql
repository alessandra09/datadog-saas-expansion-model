-- ============================================================
-- MRR and ARR by market, with month-over-month growth rate
-- ============================================================
-- ARR = MRR x 12. Standard SaaS convention: we annualize
-- the current month's recurring revenue rather than summing
-- the trailing twelve months.
--
-- Validation target: December 2025 ARR should reconcile to
-- Datadog's reported $3,427M for FY2025.
-- ============================================================

WITH monthly_mrr AS (

    SELECT
        re.event_month,
        m.market_name,
        m.region_type,
        SUM(re.mrr_usd)                AS total_mrr,
        COUNT(DISTINCT re.customer_id) AS active_customers

    FROM revenue_events re
    JOIN markets m ON re.market_id = m.market_id

    -- Include positive revenue movements only
    -- Churn and contraction are handled separately in the waterfall
    WHERE re.revenue_type IN ('new', 'expansion', 'contraction')
      AND re.mrr_usd > 0

    GROUP BY
        re.event_month,
        m.market_name,
        m.region_type
)

SELECT
    event_month,
    market_name,
    region_type,
    ROUND(total_mrr, 2)       AS mrr_usd,
    ROUND(total_mrr * 12, 2)  AS arr_usd,
    active_customers,

    -- LAG fetches the previous month's MRR for the same market
    -- NULLIF guards against division by zero on the first month
    ROUND(
        (total_mrr
            - LAG(total_mrr) OVER (PARTITION BY market_name ORDER BY event_month))
        / NULLIF(
            LAG(total_mrr) OVER (PARTITION BY market_name ORDER BY event_month),
          0) * 100,
    2) AS mrr_growth_mom_pct

FROM monthly_mrr
ORDER BY event_month, market_name;
