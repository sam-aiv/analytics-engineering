# Analytics Engineer —  SaaS Metrics Assignment
**Author:** Samantha Aivazi | **Date:** March 2026

## Overview
This project builds a reproducible analytics pipeline to compute two core SaaS metrics:
- **MRR Movements** — monthly changes in recurring revenue (New, Expansion, Contraction, Lost)
- **MRR Cohort Retention** — how revenue from customer cohorts evolves over time

Built using **dbt Core** with **DuckDB** as the local analytical database.

## Project Structure
```
ninox_project/
├── models/
│   ├── staging/        # Raw data cleaning and normalization
│   ├── intermediate/   # Business logic and revenue calculations
│   └── marts/          # Final analytical outputs
├── seeds/              # Raw CSV source files
├── tests/              # Custom business rule tests
└── dbt_project.yml
```

## Models

### Staging
| Model | Description |
|-------|-------------|
| `stg_orders` | Casts and cleans raw orders. Deduplicates by `subscription_id` keeping the most recent order. Parses `checkout_metadata` JSON to extract `currency`, `exchange_rate`, and `tax_percentage` (defaulting null tax to 0.0). |
| `stg_subscriptions` | Casts and cleans raw subscriptions. No deduplication needed. |

### Intermediate
| Model | Description |
|-------|-------------|
| `int_subscription_revenue` | Joins subscriptions to orders and computes net revenue in EUR: `(gross_amount / (1 + tax_percentage)) / exchange_rate`. Divides by 12 to get `monthly_mrr_eur`. Filters out records with missing dates or invalid revenue values. |
| `int_subscription_months` | Expands each subscription into 12 monthly rows using `generate_series`, one per calendar month starting from the subscription start month. |
| `int_customer_month_mrr` | Aggregates MRR to the customer-month level by summing across all active subscriptions for that customer in a given month. |

### Marts
| Model | Description |
|-------|-------------|
| `fct_mrr_movements` | Computes monthly MRR movements (New, Expansion, Contraction, Lost) at the customer level using a window function to compare each month to the previous. Appends a synthetic zero-MRR row after each customer's final active month to correctly detect churn. Aggregates to month level for the final output. |
| `fct_mrr_cohort_retention` | Assigns each customer to a cohort based on their first active MRR month. Tracks total retained MRR and retention percentage relative to month 0 for each cohort over time. |

## Output Tables
| File | Description |
|------|-------------|
| `fct_mrr_movements.csv` | Monthly MRR movements by category |
| `fct_mrr_cohort_retention.csv` | Cohort retention by month number |

## How to Run
```bash
# Install dependencies
pip install dbt-core dbt-duckdb

# Load seed data
dbt seed

# Run models
dbt run

# Run tests
dbt test
```

## Tests
- **Schema tests** — uniqueness and non-null checks on key identifiers and metric columns
- **Balance assertion** — verifies that `start + new + expansion - contraction - lost = end` holds across all months
