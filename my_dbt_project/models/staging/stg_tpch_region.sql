with source as (
        select * from {{ source('tpch', 'region') }}
  ),
  renamed as (
      select
          {{ adapter.quote("R_REGIONKEY") }} as regionkey,
          {{ adapter.quote("R_NAME") }} as name
      from source
  )
  select * from renamed
    