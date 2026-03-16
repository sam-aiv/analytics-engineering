with subscriptions as (

    select *
    from {{ ref('stg_subscriptions') }}
    where start_date is not null
      and end_date is not null
      and end_date > start_date

),

orders as (

    select *
    from {{ ref('stg_orders') }}
    where tax_percentage is not null
      and exchange_rate is not null
      and exchange_rate > 0
      and gross_amount is not null
      and gross_amount > 0

),

joined as (

    select
        s.subscription_id,
        s.customer_id,
        s.plan_name,
        s.number_of_licenses,
        s.start_date,
        s.end_date,
        o.order_id,
        o.order_date,
        o.currency,
        o.exchange_rate,
        o.tax_percentage,
        o.gross_amount
    from subscriptions s
    inner join orders o
        on s.subscription_id = o.subscription_id

),

revenue as (

    select
        *,
        gross_amount / (1 + tax_percentage) as gross_ex_tax_local,
        (gross_amount / (1 + tax_percentage)) / exchange_rate as net_revenue_eur,
        ((gross_amount / (1 + tax_percentage)) / exchange_rate) / 12 as monthly_mrr_eur
    from joined

)

select * from revenue