with orders as (
    select * from {{ ref('stg_tpch_orders')}}
), line_items as (
    select * from {{ ref('stg_tpch_line_items')}}
),
    joined as (
        select
            o.orderkey,
            o.custkey,
            o.orderstatus,
            o.orderdate,
            o.totalprice,
            li.order_item_key,
            li.linenumber,
            li.partkey,
            li.extended_price,
            li.discount_percentage,
            li.tax_rate
        from orders o 
        left join line_items li
            on o.orderkey = li.orderkey
    ) 
    
select * from joined