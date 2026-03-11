with stg_region as (
    select * from {{ ref ('stg_tpch_region')}}
), 
    with_surrogate_key as (
        select
            {{ dbt_utils.generate_surrogate_key (
                ['regionkey']
            ) }} as dim_region_key,
            regionkey as region_key,
            initcap(name) as region_name,
            current_timestamp() as dbt_loaded_at
        from stg_region
)

select * from with_surrogate_key