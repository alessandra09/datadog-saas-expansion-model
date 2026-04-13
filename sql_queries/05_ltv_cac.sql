-- ============================================================
-- LTV / CAC ratio and CAC payback period by market and segment
-- ============================================================
-- LTV    = (Avg MRR per customer × Gross Margin) / Monthly churn rate
-- CAC Payback = CAC / (Avg MRR × Gross Margin)
-- LTV/CAC     = LTV / CAC
--
-- Gross margin used: 0.80 (80.0% GAAP, Datadog FY2025)
-- Source: stocktitan.net/financials/DDOG
--
-- Benchmark (Benchmarkit 2025 SaaS Performance Metrics):
--   Median LTV/CAC: 3.6x
--   Healthy target: >3x
--   CAC payback target: <18 months (enterprise)
-- ============================================================

WITH customer_mrr AS (

    SELECT
        c.customer_id,
        c.segment,
        m.market_name,
        m.region_type,
        c.cac_usd,
        AVG(re.mrr_usd)         AS avg_mrr,

        -- 0.80 = verified GAAP gross margin, Datadog FY2025
        AVG(re.mrr_usd) * 0.80  AS gross_margin_mrr

    FROM customers c
    JOIN markets m         ON c.market_id  = m.market_id
    JOIN revenue_events re ON c.customer_id = re.customer_id
    WHERE re.revenue_type IN ('new', 'expansion')
      AND re.mrr_usd > 0
    GROUP BY 1, 2, 3, 4, 5

),

churn_by_segment AS (

    -- Monthly churn rate per segment and market
    -- = customers lost / total customers in that group
    SELECT
        m.market_name,
        c.segment,
        COUNT(DISTINCT ce.customer_id)::FLOAT
            / NULLIF(COUNT(DISTINCT c.customer_id), 0) AS monthly_churn_rate
    FROM customers c
    JOIN markets m      ON c.market_id  = m.market_id
    LEFT JOIN churn_events ce ON c.customer_id = ce.customer_id
    GROUP BY 1, 2

)

SELECT
    cm.market_name,
    cm.region_type,
    cm.segment,
    ROUND(AVG(cm.avg_mrr), 0)               AS avg_mrr_per_customer,
    ROUND(AVG(cm.gross_margin_mrr), 0)      AS gm_mrr_per_customer,
    ROUND(AVG(cm.cac_usd), 0)               AS avg_cac_usd,
    ROUND(cbs.monthly_churn_rate * 100, 2)  AS monthly_churn_rate_pct,

    -- LTV: present value of gross margin stream assuming constant churn
    ROUND(
        AVG(cm.gross_margin_mrr)
        / NULLIF(cbs.monthly_churn_rate, 0),
    0) AS ltv_usd,

    ROUND(
        (AVG(cm.gross_margin_mrr) / NULLIF(cbs.monthly_churn_rate, 0))
        / NULLIF(AVG(cm.cac_usd), 0),
    2) AS ltv_cac_ratio,

    -- How many months until gross margin earned back the acquisition cost
    ROUND(
        AVG(cm.cac_usd)
        / NULLIF(AVG(cm.gross_margin_mrr), 0),
    1) AS cac_payback_months

FROM customer_mrr cm
JOIN churn_by_segment cbs
    ON  cm.market_name = cbs.market_name
    AND cm.segment     = cbs.segment
GROUP BY
    cm.market_name,
    cm.region_type,
    cm.segment,
    cbs.monthly_churn_rate
ORDER BY
    cm.region_type,
    cm.market_name,
    cm.segment;
