-- ============================================================
-- Revenue cohort retention analysis (NRR by cohort-month)
-- ============================================================
-- We group customers by their first subscription month (cohort).
-- For each subsequent month we measure what % of the cohort's
-- original MRR is still active or has expanded.
--
-- NRR > 100% = expansion revenue outpacing churn within cohort.
-- At ~115% NRR (Datadog analyst estimate, FY2025), a cohort
-- grows revenue even if some customers cancel.
--
-- Fix vs prior version: added ::INT cast on months_since_start
-- to prevent float precision errors in GROUP BY.
-- ============================================================

WITH cohort_base AS (

    -- Each customer's cohort month and their initial MRR
    SELECT
        c.customer_id,
        DATE_TRUNC('month', c.acquisition_date) AS cohort_month,
        s.mrr_usd                               AS initial_mrr
    FROM customers c
    JOIN subscriptions s ON c.customer_id = s.customer_id
    -- First subscription only: start_date matches acquisition_date
    WHERE s.start_date = c.acquisition_date

),

cohort_revenue AS (

    -- Monthly revenue per customer, tagged with their cohort
    SELECT
        cb.cohort_month,
        DATE_TRUNC('month', re.event_month) AS revenue_month,
        cb.customer_id,
        SUM(re.mrr_usd)                     AS monthly_mrr
    FROM cohort_base cb
    JOIN revenue_events re ON cb.customer_id = re.customer_id
    WHERE re.mrr_usd > 0
    GROUP BY 1, 2, 3

),

cohort_aggregated AS (

    SELECT
        cohort_month,
        revenue_month,

        -- Integer month index: 0 = first month, 12 = one year later
        -- ::INT cast avoids float comparison issues in GROUP BY
        (
            EXTRACT(YEAR  FROM AGE(revenue_month, cohort_month)) * 12
          + EXTRACT(MONTH FROM AGE(revenue_month, cohort_month))
        )::INT                         AS months_since_start,

        SUM(monthly_mrr)               AS cohort_mrr,
        COUNT(DISTINCT customer_id)    AS active_customers

    FROM cohort_revenue
    GROUP BY 1, 2, 3

),

cohort_initial AS (

    -- Month 0 MRR = the denominator for all retention calculations
    SELECT
        cohort_month,
        cohort_mrr AS initial_cohort_mrr
    FROM cohort_aggregated
    WHERE months_since_start = 0

)

SELECT
    ca.cohort_month,
    ca.revenue_month,
    ca.months_since_start,
    ca.cohort_mrr,
    ci.initial_cohort_mrr,
    ca.active_customers,

    -- NRR: current cohort MRR as a % of month-0 MRR
    -- >100% confirms expansion is outpacing churn
    ROUND(
        ca.cohort_mrr / NULLIF(ci.initial_cohort_mrr, 0) * 100,
    1) AS nrr_pct

FROM cohort_aggregated ca
JOIN cohort_initial ci ON ca.cohort_month = ci.cohort_month
ORDER BY ca.cohort_month, ca.months_since_start;
