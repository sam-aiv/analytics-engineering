select
    cast(subscription_id as varchar) as subscription_id,
    cast(customer_id as varchar) as customer_id,
    plan_name,
    number_of_licenses,
    cast(start_date as date) as start_date,
    cast(end_date as date) as end_date
from {{ ref('subscriptions') }}
