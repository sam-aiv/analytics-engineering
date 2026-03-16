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

## Output Tables
| File | Description |
|------|-------------|
| `fct_mrr_movements_clean.csv` | Monthly MRR movements by category |
| `fct_mrr_cohort_retention_clean.csv` | Cohort retention by month number |

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

## Documentation
Full documentation covering the data architecture, business logic, data quality findings,
and modeling decisions is included in the submission.
