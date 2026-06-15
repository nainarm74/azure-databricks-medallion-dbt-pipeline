{{ config(
    materialized='table'
) }}

   SELECT
    s.seller_id,
    s.seller_zip_code_prefix AS zip_code_prefix,
    INITCAP(s.seller_city) AS city,
    UPPER(s.seller_state) AS state,
    cd.mql_id,
    cd.sdr_id,
    cd.sr_id,
    CAST(cd.won_date AS TIMESTAMP) AS funnel_won_at,
    cd.business_segment,
    cd.lead_type,
    cd.lead_behaviour_profile,
    cd.business_type,
    current_timestamp() AS silver_processed_at,
    current_user() AS silver_processed_by

from {{ source('bronze', 'sellers_stream') }} as s
-- Add your validation rules directly here to exclude bad data
LEFT JOIN bronze.closed_deals_stream cd  ON s.seller_id = cd.seller_id
where s.seller_id is not null 
  
