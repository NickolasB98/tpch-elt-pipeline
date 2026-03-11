with stg_supplier as (
    select * from {{ ref ('stg_tpch_supplier')}}
), 
    with_surrogate_key as (
        select
            {{ dbt_utils.generate_surrogate_key (
                ['suppkey']
            ) }} as dim_supplier_key,
            suppkey as supplier_key,
            lower(replace(name, '#', '')) as supplier_name,
            lower(replace(phone, '-', '')) as phone,
            acctbal as account_balance,
            current_timestamp() as dbt_loaded_at
        from stg_supplier
)

select * from with_surrogate_key