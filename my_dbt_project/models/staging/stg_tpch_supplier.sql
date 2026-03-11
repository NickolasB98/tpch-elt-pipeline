with source as (
        select * from {{ source('tpch', 'supplier') }}
  ),
  renamed as (
      select
          {{ adapter.quote("S_SUPPKEY") }} as suppkey,
          {{ adapter.quote("S_NAME") }} as name,
          {{ adapter.quote("S_PHONE") }} as phone,
          {{ adapter.quote("S_ACCTBAL") }} as acctbal
      from source
  )
  select * from renamed
    