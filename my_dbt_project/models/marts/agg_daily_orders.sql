with fct_orders as (
    select * from {{ ref('fct_orders')}}
),
    daily_summary as (
        select
            orderdate,
            CASE 
                WHEN orderstatus = 'F' THEN 'Completed'
                WHEN orderstatus = 'O' THEN 'Open'
                WHEN orderstatus = 'P' THEN 'Pending'
                ELSE 'Other'
            END as orderstatus,
            count(distinct orderkey) as num_orders,
            count(*) as num_line_items,
            round(sum(totalprice), 2) as total_revenue,
            round(avg(totalprice), 2) as avg_order_value,
            round(min(totalprice), 2) as min_order_value,
            round(max(totalprice), 2) as max_order_value
        from fct_orders
        group by orderdate, orderstatus
    )
select 
    *,
    current_timestamp() as dbt_loaded_at
from daily_summary