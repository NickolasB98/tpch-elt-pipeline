with stg_customer as (
    select * from {{ ref ('stg_tpch_customer')}}
), 
    with_surrogate_key as (
        select
            {{ dbt_utils.generate_surrogate_key (
                ['custkey']
            ) }} as dim_customer_key,
            custkey,
            substr(name, POSITION('#' IN name) + 1, length(name)) AS customer_name,
    replace(phone, '-', '') AS phone,
            current_timestamp() as dbt_loaded_at
        from stg_customer
)

select * from with_surrogate_key