with fct_orders as (
    select * from {{ ref('fct_orders')}}
),
    customer_metrics as (
        select
            custkey,
            count(distinct orderkey) as lifetime_orders,
            count(*) as lifetime_line_items,
            round(sum(totalprice), 2) as lifetime_revenue,
            round(avg(totalprice), 2) as avg_order_value,
            round(min(totalprice), 2) as min_order_value,
            round(max(totalprice), 2) as max_order_value
        from fct_orders
        group by custkey
    )

select
    *,
    current_timestamp() as dbt_loaded_at
from customer_metrics

