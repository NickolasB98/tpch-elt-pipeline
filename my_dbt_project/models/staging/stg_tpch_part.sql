with source as (
        select * from {{ source('tpch', 'part') }}
  ),
  renamed as (
      select
          {{ adapter.quote("P_PARTKEY") }} as partkey,
          {{ adapter.quote("P_NAME") }} as name,
          {{ adapter.quote("P_MFGR") }} as manufacturer,
          {{ adapter.quote("P_TYPE") }} as type,
          {{ adapter.quote("P_SIZE") }} as size,
          {{ adapter.quote("P_RETAILPRICE") }} as retailprice
      from source
  )
  select * from renamed
    