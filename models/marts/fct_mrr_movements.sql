with customer_month_mrr as (

    select
        customer_id,
        month,
        mrr_eur
    from {{ ref('int_customer_month_mrr') }}

),

last_active_month as (

    select
        customer_id,
        max(month) as last_mrr_month
    from customer_month_mrr
    group by 1

),

mrr_with_exit_month as (

    select
        customer_id,
        month,
        mrr_eur
    from customer_month_mrr

    union all

    select
        customer_id,
        last_mrr_month + interval 1 month as month,
        0 as mrr_eur
    from last_active_month

),

movement_base as (

    select
        customer_id,
        month,
        mrr_eur,
        lag(mrr_eur, 1, 0) over (
            partition by customer_id
            order by month
        ) as prev_mrr_eur
    from mrr_with_exit_month

),

customer_movements as (

    select
        customer_id,
        month,

        prev_mrr_eur as start_of_period_mrr,

        case
            when prev_mrr_eur = 0 and mrr_eur > 0 then mrr_eur
            else 0
        end as new_mrr,

        case
            when prev_mrr_eur > 0 and mrr_eur > prev_mrr_eur then mrr_eur - prev_mrr_eur
            else 0
        end as expansion_mrr,

        case
            when prev_mrr_eur > 0 and mrr_eur > 0 and mrr_eur < prev_mrr_eur then prev_mrr_eur - mrr_eur
            else 0
        end as contraction_mrr,

        case
            when prev_mrr_eur > 0 and mrr_eur = 0 then prev_mrr_eur
            else 0
        end as lost_mrr,

        mrr_eur as end_of_period_mrr
    from movement_base

),

aggregated as (

    select
        month,
        sum(start_of_period_mrr) as start_of_period_mrr,
        sum(new_mrr) as new_mrr,
        sum(expansion_mrr) as expansion_mrr,
        sum(contraction_mrr) as contraction_mrr,
        sum(lost_mrr) as lost_mrr,
        sum(end_of_period_mrr) as end_of_period_mrr,
        sum(new_mrr) + sum(expansion_mrr) - sum(contraction_mrr) - sum(lost_mrr) as net_new_mrr
    from customer_movements
    group by 1

)

select
    month,
    cast(start_of_period_mrr as decimal(18,2)) as start_of_period_mrr,
    cast(new_mrr as decimal(18,2)) as new_mrr,
    cast(expansion_mrr as decimal(18,2)) as expansion_mrr,
    cast(contraction_mrr as decimal(18,2)) as contraction_mrr,
    cast(lost_mrr as decimal(18,2)) as lost_mrr,
    cast(end_of_period_mrr as decimal(18,2)) as end_of_period_mrr,
    cast(net_new_mrr as decimal(18,2)) as net_new_mrr
from aggregated
order by 1