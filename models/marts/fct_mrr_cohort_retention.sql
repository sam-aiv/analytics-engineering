with customer_month_mrr as (

    select *
    from {{ ref('int_customer_month_mrr') }}
    where mrr_eur > 0

),

customer_cohorts as (

    select
        customer_id,
        min(month) as cohort_month
    from customer_month_mrr
    group by 1

),

cohort_mrr as (

    select
        c.cohort_month,
        m.customer_id,
        m.month,
        date_diff('month', c.cohort_month, m.month) as month_number,
        m.mrr_eur
    from customer_month_mrr m
    join customer_cohorts c
      on m.customer_id = c.customer_id
    where m.month >= c.cohort_month

),

aggregated as (

    select
        cohort_month,
        month_number,
        sum(mrr_eur) as retained_mrr_eur
    from cohort_mrr
    group by 1, 2

),

cohort_base as (

    select
        cohort_month,
        retained_mrr_eur as cohort_mrr_month_0
    from aggregated
    where month_number = 0

)

select
    a.cohort_month,
    a.month_number,
    cast(a.retained_mrr_eur as decimal(18,2)) as retained_mrr_eur,
    cast(b.cohort_mrr_month_0 as decimal(18,2)) as cohort_mrr_month_0,
    round(
        case
            when b.cohort_mrr_month_0 = 0 then null
            else a.retained_mrr_eur / b.cohort_mrr_month_0
        end,
        4
    ) as retention_pct
from aggregated a
left join cohort_base b
  on a.cohort_month = b.cohort_month
order by 1, 2