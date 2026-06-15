{{ config(
    materialized='table'
) }}

select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix AS zip_code_prefix,
    INITCAP(customer_city) AS city,
    UPPER(customer_state) AS state,
    current_timestamp() AS silver_processed_at,
    current_user() AS silver_processed_by

from {{ source('bronze', 'customers_stream') }}
-- Add your validation rules directly here to exclude bad data
where customer_id is not null 
  and customer_zip_code_prefix is not null
