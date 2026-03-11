with source as (
        select * from {{ source('tpch', 'customer') }}
  ),
  renamed as (
      select
          {{ adapter.quote("C_CUSTKEY") }} as custkey,
          {{ adapter.quote("C_NAME") }} as name,
          {{ adapter.quote("C_PHONE") }} as phone

      from source
  )
  select * from renamed
    