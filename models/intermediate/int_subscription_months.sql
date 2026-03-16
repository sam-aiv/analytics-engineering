with subscription_revenue as (

    select * from {{ ref('int_subscription_revenue') }}

)

select
    subscription_id,
    customer_id,
    month_start as month,
    monthly_mrr_eur
from subscription_revenue,
generate_series(
    date_trunc('month', start_date),
    date_trunc('month', start_date) + interval 11 month,
    interval 1 month
) as t(month_start)