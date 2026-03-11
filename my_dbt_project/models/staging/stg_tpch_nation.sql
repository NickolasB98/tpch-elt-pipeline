with source as (
        select * from {{ source('tpch', 'nation') }}
  ),
  renamed as (
      select
          {{ adapter.quote("N_NATIONKEY") }} as nationkey,
          {{ adapter.quote("N_NAME") }} as name,
          {{ adapter.quote("N_REGIONKEY") }} as regionkey

      from source
  )
  select * from renamed
    