# Datadog SaaS Expansion Scenario Model

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)
![Data](https://img.shields.io/badge/Data-Datadog%20FY2025-orange)

**Stack:** PostgreSQL · SQL (CTEs, Window Functions) · Financial Modeling  
**Data:** Real Datadog FY2025 public financials  
**Author:** Oleksandra Hordieieva
**Built:** April 2026

---

## What this project does

Models how Datadog's geographic expansion into EMEA and APAC markets
impacts ARR, churn, NRR, LTV/CAC, and unit economics.
Three scenarios are compared over a 24-month horizon using
verified FY2025 financial data as the baseline.

---

## Datadog FY2025 baseline (verified public data)

| Metric | Value | Source |
|---|---|---|
| Full-year revenue | $3,427M (+28% YoY) | Q4 FY2025 Earnings, Feb 10 2026 |
| Q4 revenue | $953M | Q4 FY2025 Earnings |
| Customers > $100K ARR | 4,310 | Dec 31, 2025 |
| Customers > $1M ARR | 603 | Dec 31, 2025 |
| GAAP gross margin | 80.0% | FY2025 |
| Free cash flow | $915M | FY2025 |

Source: [Datadog Q4 FY2025 Earnings Release](https://investors.datadoghq.com/news-releases/news-release-details/datadog-announces-fourth-quarter-and-fiscal-year-2025-financial)

---

## Three scenarios modeled

| Scenario | ARR Growth Year 1 | New Markets | Investment |
|---|---|---|---|
| Base (core only) | 20% | None | — |
| EMEA Expansion | ~23% | EMEA_NEW | ~$80M |
| Aggressive | ~27% | EMEA_NEW + APAC | ~$180M |

---

## SQL techniques used

- **MRR / ARR by market** — with `LAG()` window function for MoM growth rate
- **MRR Waterfall** — monthly revenue bridge using `CASE WHEN` pivot
- **Cohort Retention** — NRR analysis with `AGE()` and integer month indexing
- **Gross Churn Rate** — monthly and annualized, with `LEFT JOIN` on churn events
- **LTV / CAC** — by customer segment and market, with CAC payback period
- **Scenario Comparison** — three-scenario ARR engine via `scenario_revenue` table
- **Expansion ROI** — incremental ARR vs investment cost per market

---

## Repository structure

**data_model/**
| File | Description |
|---|---|
| `01_schema.sql` | Relational schema — 8 tables with relationships |
| `02_seed_data.sql` | Reference data + verified modeling assumptions |

**sql_queries/**
| File | Description |
|---|---|
| `01_mrr_arr.sql` | MRR and ARR by market with MoM growth |
| `02_mrr_waterfall.sql` | Monthly MRR movement bridge |
| `03_cohort_retention.sql` | Revenue cohort NRR analysis |
| `04_churn_rate.sql` | Gross churn rate monthly and annualized |
| `05_ltv_cac.sql` | LTV / CAC by segment and market |
| `06_scenario_comparison.sql` | Three-scenario ARR comparison |
| `07_expansion_roi.sql` | Expansion investment ROI |

**docs/**
| File | Description |
|---|---|
| `assumptions_and_sources.md` | All data sources and modeling assumptions |

---

## Key business insight

New markets structurally start with lower NRR (~95% in year 1) due to
higher churn, GDPR compliance overhead, and weaker local support coverage.
The model shows that if expansion-market NRR crosses 100% by month 18,
the investment becomes self-funding. Datadog's $915M FCF in FY2025
confirms the company can sustain ~$180M expansion spend
without impairing cash generation.

---

## Data sources

- [Datadog Investor Relations](https://investors.datadoghq.com)
- [High Alpha / OpenView SaaS Benchmarks 2024](https://www.highalpha.com/saas-benchmarks/2024)
- [Benchmarkit 2025 SaaS Performance Metrics](https://www.benchmarkit.ai/2025benchmarks)
