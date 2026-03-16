select *
from {{ ref('fct_mrr_movements') }}
where abs(
    start_of_period_mrr + new_mrr + expansion_mrr - contraction_mrr - lost_mrr
    - end_of_period_mrr
) > 0.01