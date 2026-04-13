-- ============================================================
-- Reference data: markets and scenarios
-- All financial anchors verified against public disclosures
--
-- Datadog FY2025 (year ended December 31, 2025):
--   Total revenue:           $3,427M  (+28% YoY)
--   MRR implied (Dec 2025):  $285.6M  ($3,427M / 12)
--   Customers >$100K ARR:    4,310
--   Customers >$1M ARR:      603
--   GAAP gross margin:       80.0%
--   Non-GAAP gross margin:   ~81%
--   Free cash flow:          $915M
--
-- Source: Datadog Q4 FY2025 Earnings Release, February 10 2026
--   https://investors.datadoghq.com/news-releases/news-release-details/
--   datadog-announces-fourth-quarter-and-fiscal-year-2025-financial
-- ============================================================


-- Markets
-- US and EMEA_CORE are live revenue-generating markets
-- EMEA_NEW and APAC are the expansion targets we model
INSERT INTO markets
    (market_id, market_name, region_type, launch_date, target_segment)
VALUES
    (1, 'US',        'core',      '2010-01-01', 'enterprise'),
    (2, 'EMEA_CORE', 'core',      '2016-06-01', 'enterprise'),
    (3, 'EMEA_NEW',  'expansion', '2025-01-01', 'mid-market'),
    (4, 'APAC',      'expansion', '2025-07-01', 'mid-market'),
    (5, 'LATAM',     'expansion',  NULL,         'SMB');


-- Scenarios
-- Base uses 20% YoY growth (conservative vs 28% FY2025 actual)
-- We discount because one strong year does not guarantee the next
INSERT INTO scenarios
    (scenario_id, scenario_name, description)
VALUES
    (1, 'base',
        'Core markets only (US + EMEA_CORE). '
        '20% YoY ARR growth. '
        'Starting ARR: $3,427M (Datadog FY2025 actual). '
        'No new market investment.'),

    (2, 'emea_expansion',
        'Enter EMEA_NEW in Q1 2025. '
        'ARR uplift: +8% over 18 months (linear ramp). '
        'New market NRR starts at 95%, reaches 108% by month 18. '
        'Investment: ~$80M (S&M hires + infrastructure). '
        'Higher early churn expected: GDPR compliance overhead, '
        'limited local support coverage.'),

    (3, 'aggressive',
        'Enter EMEA_NEW (Q1 2025) and APAC (Q3 2025) simultaneously. '
        'ARR uplift: +18% over 24 months. '
        'New market NRR: 92% year 1 (split focus = higher churn). '
        'Investment: ~$180M. '
        'Greater upside but lower unit economics in year 1.');


-- ============================================================
-- Modeling assumptions (documented for transparency)
-- ============================================================
--
-- 1. Base ARR (January 2025):  $3,427M  =  MRR $285.6M x 12
--
-- 2. Base growth rate: 20% YoY
--    FY2025 actual was 28%. We model 20% as a conservative forward
--    estimate, consistent with analyst consensus for FY2026.
--
-- 3. Gross margin used in LTV calculations: 0.80 (80.0% GAAP)
--    Source: stocktitan.net/financials/DDOG (FY2025)
--
-- 4. NRR estimate (core markets): ~115%
--    Datadog stopped disclosing NRR publicly after 2023.
--    115% is the analyst consensus estimate based on expansion
--    revenue trends visible in quarterly results.
--
-- 5. NRR new markets year 1: 95% (EMEA), 92% (Aggressive)
--    New markets structurally start lower due to:
--    - Higher churn from product-market fit gaps
--    - Less mature partner and support ecosystems
--    - Longer sales cycles in unfamiliar geographies
--
-- 6. LTV/CAC benchmark: >3x healthy, >5x excellent
--    Market median 2024: 3.6x
--    Source: Benchmarkit 2025 SaaS Performance Metrics
--    https://www.benchmarkit.ai/2025benchmarks
-- ============================================================
