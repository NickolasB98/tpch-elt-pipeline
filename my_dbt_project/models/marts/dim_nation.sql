with stg_nation as (
    select * from {{ ref ('stg_tpch_nation')}}
), 
    with_surrogate_key as (
        select
            {{ dbt_utils.generate_surrogate_key (
                ['nationkey']
            ) }} as dim_nation_key,
            nationkey as nation_key,
            initcap(name) as region_name,
            regionkey as region_key,
            current_timestamp() as dbt_loaded_at
        from stg_nation
)

select * from with_surrogate_key