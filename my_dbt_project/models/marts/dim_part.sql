with stg_part as (
    select * from {{ ref ('stg_tpch_part')}}
), 
    with_surrogate_key as (
        select
            {{ dbt_utils.generate_surrogate_key (
                ['partkey']
            ) }} as dim_part_key,
            partkey as part_key,
            name as part_name,
            lower(replace(manufacturer, '#', '')) as manufacturer,
            lower(type) as type,
            size,
            retailprice,
            current_timestamp() as dbt_loaded_at
        from stg_part
)

select * from with_surrogate_key