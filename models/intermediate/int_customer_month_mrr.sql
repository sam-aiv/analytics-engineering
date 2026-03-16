with subscription_months as (

    select * from {{ ref('int_subscription_months') }}

)

select
    customer_id,
    month,
    sum(monthly_mrr_eur) as mrr_eur
from subscription_months
group by 1, 2