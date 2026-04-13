# datadog-saas-expansion-model
SaaS Expansion Scenario Model using real Datadog FY2025 data. SQL + Financial Modeling.
# Datadog SaaS Expansion Scenario Model

**Stack:** PostgreSQL · SQL (CTEs, window functions) · Financial modeling  
**Data:** Datadog FY2025 public financials - $3.43B revenue, 4,310 enterprise customers  
**Built:** April 2026

---

## What this project models

Three forward-looking scenarios for Datadog's geographic expansion into
EMEA and APAC, measuring the impact on ARR, churn, NRR, LTV/CAC, and
expansion ROI over a 24-month horizon.

---

## Datadog FY2025 baseline (verified)

| Metric | Value |
|---|---|
| Full-year revenue | $3.43B (+28% YoY) |
| Q4 revenue | $953M |
| Customers > $100K ARR | 4,310 |
| Customers > $1M ARR | 603 |
| GAAP gross margin | 80.0% |
| Free cash flow | $915M |

Source: [Datadog Q4 FY2025 Earnings, February 10 2026](https://investors.datadoghq.com/news-releases/news-release-details/datadog-announces-fourth-quarter-and-fiscal-year-2025-financial)

---

## Scenarios

| Scenario | ARR growth yr 1 | Investment |
|---|---|---|
| Base (core markets only) | 20% | - |
| EMEA Expansion | ~23% | ~$80M |
| Aggressive (EMEA + APAC) | ~27% | ~$180M |

---

## SQL techniques demonstrated

- MRR / ARR calculation with `LAG()` window function for MoM growth
- MRR waterfall using `CASE WHEN` pivot across revenue types
- Cohort revenue retention with `AGE()` and integer month indexing
- LTV / CAC and CAC payback by market and customer segment
- Three-scenario comparison engine via a dedicated `scenario_revenue` table

---

## Repository structure
