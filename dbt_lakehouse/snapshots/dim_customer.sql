{% snapshot dim_customer %}

{{
    config(
      target_catalog='bde2026',
      target_schema='silver',
      unique_key='customer_id',
      strategy='check',
      check_cols=[
          'customer_unique_id', 
          'customer_zip_code_prefix', 
          'customer_city', 
          'customer_state'
      ],
      invalidate_hard_deletes=True,
      updated_at='ingestion_timestamp'
    )
}}

select
    customer_id,
    customer_unique_id,
    cast(customer_zip_code_prefix as integer) as customer_zip_code_prefix,
    customer_city,
    customer_state,
    cast(null as double) as customer_lat,
    cast(null as double) as customer_lng,
    ingestion_timestamp,
    ingestion_user
-- from {{ source('bronze', 'customers_stream') }}
from {{ ref('stg_customers_filtered') }}

{% endsnapshot %}
