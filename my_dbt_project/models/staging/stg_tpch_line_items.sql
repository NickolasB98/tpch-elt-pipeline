with source as (
        select * from {{ source('tpch', 'lineitem') }}
  ),
  renamed as (
      select
          {{ dbt_utils.generate_surrogate_key (

              ['L_ORDERKEY', 'L_LINENUMBER']

          ) }} as order_item_key,
          {{ adapter.quote("L_ORDERKEY") }} as orderkey,
          {{ adapter.quote("L_PARTKEY") }} as partkey,
          {{ adapter.quote("L_LINENUMBER") }} as linenumber,
          {{ adapter.quote("L_QUANTITY") }} as quantity,
          {{ adapter.quote("L_EXTENDEDPRICE") }} as extended_price,
          {{ adapter.quote("L_DISCOUNT") }} as discount_percentage,
          {{ adapter.quote("L_TAX") }} as tax_rate
      from source
  )
  select * from renamed
    