-- ============================================================
-- Datadog SaaS Expansion Model
-- Schema design: relational data model for SaaS analytics
-- Author: Olelsandra Hordieieva | April 2026
-- Data basis: Datadog FY2025 financials
--   Revenue: $3,427M | Customers >$100K ARR: 4,310
--   Source: investors.datadoghq.com, Feb 10 2026
-- ============================================================


-- Markets: geographic segments we track
-- region_type separates live markets from expansion targets
CREATE TABLE markets (
    market_id      SERIAL       PRIMARY KEY,
    market_name    VARCHAR(50)  NOT NULL,
    region_type    VARCHAR(20)  NOT NULL,   -- 'core' or 'expansion'
    launch_date    DATE,
    target_segment VARCHAR(50)
);


-- Customers: one row per customer, links to their market
CREATE TABLE customers (
    customer_id      SERIAL        PRIMARY KEY,
    customer_name    VARCHAR(100),
    market_id        INT           REFERENCES markets(market_id),
    segment          VARCHAR(20),            -- 'enterprise', 'mid-market', 'SMB'
    acquisition_date DATE          NOT NULL,
    acquired_channel VARCHAR(30),            -- 'inbound', 'outbound', 'partner'
    cac_usd          NUMERIC(12,2)           -- acquisition cost per customer
);


-- Subscriptions: active plan per customer with current MRR
-- end_date = NULL means the subscription is still active
CREATE TABLE subscriptions (
    subscription_id SERIAL        PRIMARY KEY,
    customer_id     INT           REFERENCES customers(customer_id),
    market_id       INT           REFERENCES markets(market_id),
    plan_name       VARCHAR(50),            -- 'Infrastructure', 'APM', 'Logs', 'Platform'
    start_date      DATE          NOT NULL,
    end_date        DATE,
    mrr_usd         NUMERIC(12,2) NOT NULL,
    status          VARCHAR(20)             -- 'active', 'churned', 'expanded', 'contracted'
);


-- Revenue events: monthly grain fact table, one row per customer per month
-- This is the primary source for all MRR/ARR calculations
-- revenue_type drives the waterfall: new / expansion / contraction / churn
CREATE TABLE revenue_events (
    event_id     SERIAL        PRIMARY KEY,
    customer_id  INT           REFERENCES customers(customer_id),
    market_id    INT           REFERENCES markets(market_id),
    event_month  DATE          NOT NULL,    -- always first day of month: 2025-01-01
    mrr_usd      NUMERIC(12,2) NOT NULL,
    revenue_type VARCHAR(20)   NOT NULL
);


-- Churn events: one row per lost customer
-- Keeping this separate lets us analyze churn reasons independently
CREATE TABLE churn_events (
    churn_id        SERIAL        PRIMARY KEY,
    customer_id     INT           REFERENCES customers(customer_id),
    market_id       INT           REFERENCES markets(market_id),
    churn_date      DATE          NOT NULL,
    churned_mrr_usd NUMERIC(12,2) NOT NULL,
    churn_reason    VARCHAR(50)             -- 'price', 'competitor', 'no_budget', 'product_fit'
);


-- Expansion events: investment costs tied to entering a new market
-- Used in ROI calculation: incremental ARR vs total spend
CREATE TABLE expansion_events (
    expansion_id   SERIAL        PRIMARY KEY,
    market_id      INT           REFERENCES markets(market_id),
    event_date     DATE          NOT NULL,
    investment_usd NUMERIC(14,2) NOT NULL,  -- S&M + infrastructure cost
    event_type     VARCHAR(30)              -- 'market_launch', 'sales_hire', 'office_open'
);


-- Scenarios: named modeling assumptions (base / emea / aggressive)
CREATE TABLE scenarios (
    scenario_id   SERIAL       PRIMARY KEY,
    scenario_name VARCHAR(50)  NOT NULL,
    description   TEXT
);


-- Scenario revenue: projected monthly revenue per scenario
-- Keeping this separate from revenue_events preserves actuals vs projections
CREATE TABLE scenario_revenue (
    id           SERIAL        PRIMARY KEY,
    scenario_id  INT           REFERENCES scenarios(scenario_id),
    customer_id  INT           REFERENCES customers(customer_id),
    market_id    INT           REFERENCES markets(market_id),
    event_month  DATE          NOT NULL,
    mrr_usd      NUMERIC(12,2) NOT NULL,
    revenue_type VARCHAR(20)   NOT NULL
);
