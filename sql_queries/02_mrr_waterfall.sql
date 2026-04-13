-- ============================================================
-- MRR movement waterfall: the standard SaaS revenue bridge
-- ============================================================
-- Ending MRR = Starting MRR
--            + New MRR          (first-time customers)
--            + Expansion MRR    (existing customers buying more)
--            - Contraction MRR  (existing customers downgrading)
--            - Churned MRR      (cancellations)
--            + Reactivation MRR (returning customers)
--
-- Why this matters: Datadog's 28% growth in FY2025 is driven
-- largely by expansion from existing customers (NRR ~115%).
-- This query makes that dynamic visible month by month.
-- ============================================================

WITH mrr_components AS (

    SELECT
        DATE_TRUNC('month', event_month) AS month,
        revenue_type,
        SUM(mrr_usd)                     AS component_mrr

    FROM revenue_events
    GROUP BY 1, 2

),

waterfall AS (

    SELECT
        month,
        SUM(CASE WHEN revenue_type = 'new'
                 THEN component_mrr         ELSE 0 END) AS new_mrr,

        SUM(CASE WHEN revenue_type = 'expansion'
                 THEN component_mrr         ELSE 0 END) AS expansion_mrr,

        -- ABS() because contraction values are stored as negative
        SUM(CASE WHEN revenue_type = 'contraction'
                 THEN ABS(component_mrr)    ELSE 0 END) AS contraction_mrr,

        SUM(CASE WHEN revenue_type = 'churn'
                 THEN ABS(component_mrr)    ELSE 0 END) AS churned_mrr,

        SUM(CASE WHEN revenue_type = 'reactivation'
                 THEN component_mrr         ELSE 0 END) AS reactivation_mrr

    FROM mrr_components
    GROUP BY 1

)

SELECT
    month,
    ROUND(new_mrr, 0)                     AS new_mrr,
    ROUND(expansion_mrr, 0)               AS expansion_mrr,
    ROUND(contraction_mrr, 0)             AS contraction_mrr,
    ROUND(churned_mrr, 0)                 AS churned_mrr,
    ROUND(reactivation_mrr, 0)            AS reactivation_mrr,

    ROUND(
        new_mrr + expansion_mrr + reactivation_mrr
        - contraction_mrr - churned_mrr,
    0) AS net_new_mrr,

    -- Running cumulative MRR from the first month in the dataset
    ROUND(
        SUM(new_mrr + expansion_mrr + reactivation_mrr
            - contraction_mrr - churned_mrr)
        OVER (ORDER BY month
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
    0) AS cumulative_mrr

FROM waterfall
ORDER BY month;
