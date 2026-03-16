with source as (

    select * from {{ ref('orders') }}

),

deduped as (

    select *
    from (
        select
            *,
            row_number() over (
                partition by subscription_id
                order by cast(order_date as date) desc, cast(order_id as varchar) desc
            ) as rn
        from source
    )
    where rn = 1

)

select
    cast(order_id as varchar) as order_id,
    cast(subscription_id as varchar) as subscription_id,
    cast(order_date as date) as order_date,
    cast(gross_amount as double) as gross_amount,
    json_extract_string(checkout_metadata, '$.currency') as currency,
    try_cast(json_extract_string(checkout_metadata, '$.exchange_rate') as double) as exchange_rate,
    coalesce(
        try_cast(json_extract_string(checkout_metadata, '$.tax_percentage') as double),
        0.0
    ) as tax_percentage
from deduped