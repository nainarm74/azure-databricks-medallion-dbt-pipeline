{{ config(
    materialized='table'
) }}

SELECT
    p.product_id,
    p.product_category_name,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS product_category_name_english,
    p.product_name_lenght AS product_name_length,         -- Fixing original source schema typo
    p.product_description_lenght AS product_description_length,
    p.product_photos_qty AS product_photos_count,
    p.product_weight_g AS weight_g,
    p.product_length_cm AS length_cm,
    p.product_height_cm AS height_cm,
    p.product_width_cm AS width_cm,
    current_timestamp() AS silver_processed_at,
    current_user() AS silver_processed_by
from {{ source('bronze', 'products_stream') }} p
LEFT JOIN {{ source('bronze', 'translation_stream') }} t 
  ON p.product_category_name = t.product_category_name;
-- Add your validation rules directly here to exclude bad data
