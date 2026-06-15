{{ config(
    materialized='table'
) }}

select
    geolocation_zip_code_prefix AS zip_code_prefix,
    AVG(geolocation_lat) AS latitude,
    AVG(geolocation_lng) AS longitude,
    INITCAP(FIRST(geolocation_city)) AS city,
    UPPER(FIRST(geolocation_state)) AS state,
    current_timestamp() AS silver_processed_at,
    current_user() AS silver_processed_by
    
from {{ source('bronze', 'geolocation_stream') }}
GROUP BY geolocation_zip_code_prefix

