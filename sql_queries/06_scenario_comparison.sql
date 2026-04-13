-- ============================================================
-- Three-scenario ARR comparison over a 24-month horizon
-- ============================================================
-- Starting point: $3,427M ARR (Datadog FY2025 actual)
-- Implied MRR January 2025: $285.6M ($3,427M / 12)
--
-- Base:       20% YoY growth. No new market investment.
-- EMEA:       +8% ARR uplift over 18 months. ~$80M spend.
-- Aggressive: +18% ARR uplift over 24 months. ~$180M spend.
--             Includes EMEA_NEW + APAC launched simultaneously.
--
-- All three scenarios share the same base, so the delta columns
-- isolate the pure incremental effect of expansion.
-- ============================================================

WITH base_arr AS (

    SELECT
        sr.event_month,
        SUM(sr.mrr_usd) * 12           AS arr_usd,
        COUNT(DISTINCT sr.customer_id) AS customers
    FROM scenario_revenue sr
    JOIN scenarios s ON sr.scenario_id = s.scenario_id
    WHERE s.scenario_name = 'base'
    GROUP BY 1

),

emea_arr AS (

    SELECT
        sr.event_month,
        SUM(sr.mrr_usd) * 12           AS arr_usd,
        COUNT(DISTINCT sr.customer_id) AS customers
    FROM scenario_revenue sr
    JOIN scenarios s ON sr.scenario_id = s.scenario_id
    WHERE s.scenario_name = 'emea_expansion'
    GROUP BY 1

),

aggressive_arr AS (

    SELECT
        sr.event_month,
        SUM(sr.mrr_usd) * 12           AS arr_usd,
        COUNT(DISTINCT sr.customer_id) AS customers
    FROM scenario_revenue sr
    JOIN scenarios s ON sr.scenario_id = s.scenario_id
    WHERE s.scenario_name = 'aggressive'
    GROUP BY 1

)

SELECT
    b.event_month,

    ROUND(b.arr_usd, 0)              AS base_arr_usd,
    ROUND(e.arr_usd, 0)              AS emea_arr_usd,
    ROUND(a.arr_usd, 0)              AS aggressive_arr_usd,

    -- Absolute incremental ARR from expansion vs base
    ROUND(e.arr_usd - b.arr_usd, 0)  AS emea_incremental_arr,
    ROUND(a.arr_usd - b.arr_usd, 0)  AS aggressive_incremental_arr,

    -- Relative uplift as a % of base ARR
    ROUND(
        (e.arr_usd - b.arr_usd) / NULLIF(b.arr_usd, 0) * 100,
    2) AS emea_uplift_pct,

    ROUND(
        (a.arr_usd - b.arr_usd) / NULLIF(b.arr_usd, 0) * 100,
    2) AS aggressive_uplift_pct,

    b.customers  AS base_customers,
    e.customers  AS emea_customers,
    a.customers  AS aggressive_customers

FROM base_arr b
LEFT JOIN emea_arr      e ON b.event_month = e.event_month
LEFT JOIN aggressive_arr a ON b.event_month = a.event_month
ORDER BY b.event_month;
