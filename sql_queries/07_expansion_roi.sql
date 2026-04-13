-- ============================================================
-- Expansion ROI: incremental ARR vs total investment per market
-- ============================================================
-- We compare what we spent to enter a new market (expansion_events)
-- against the ARR generated exclusively from that market.
--
-- Key output metrics:
--   arr_per_dollar_invested: target > 1.0 within 24 months
--   payback_months: target < 24 months for enterprise SaaS
--
-- Context: Datadog generated $915M FCF in FY2025, which means
-- the company can sustain ~$180M expansion spend without
-- compromising cash generation at the corporate level.
-- ============================================================

WITH expansion_cost AS (

    SELECT
        m.market_name,
        m.region_type,
        SUM(ee.investment_usd)  AS total_investment_usd,
        MIN(ee.event_date)      AS expansion_start_date
    FROM expansion_events ee
    JOIN markets m ON ee.market_id = m.market_id
    GROUP BY 1, 2

),

incremental_arr AS (

    -- ARR from expansion markets only, in non-base scenarios
    SELECT
        m.market_name,
        SUM(sr.mrr_usd) * 12           AS expansion_arr_usd,
        COUNT(DISTINCT sr.customer_id) AS expansion_customers
    FROM scenario_revenue sr
    JOIN scenarios s ON sr.scenario_id = s.scenario_id
    JOIN markets   m ON sr.market_id   = m.market_id
    WHERE s.scenario_name IN ('emea_expansion', 'aggressive')
      AND m.region_type = 'expansion'
    GROUP BY 1

)

SELECT
    ec.market_name,
    ec.expansion_start_date,
    ROUND(ec.total_investment_usd, 0)   AS total_investment_usd,
    ROUND(ia.expansion_arr_usd, 0)      AS incremental_arr_usd,
    ia.expansion_customers,

    ROUND(
        ia.expansion_arr_usd / NULLIF(ec.total_investment_usd, 0),
    2) AS arr_per_dollar_invested,

    -- Investment / (monthly ARR contribution)
    ROUND(
        ec.total_investment_usd / NULLIF(ia.expansion_arr_usd / 12, 0),
    1) AS payback_months

FROM expansion_cost ec
JOIN incremental_arr ia ON ec.market_name = ia.market_name
ORDER BY arr_per_dollar_invested DESC;
