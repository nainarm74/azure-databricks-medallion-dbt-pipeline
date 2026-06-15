{{ config(
    materialized='table'
) }}

SELECT
    order_id,
    CAST(order_item_id AS INT) AS item_sequence,
    product_id,
    seller_id,
    CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_at,
    CAST(price AS DECIMAL(10,2)) AS price,
    CAST(freight_value AS DECIMAL(10,2)) AS freight_value,
    (CAST(price AS DECIMAL(10,2)) + CAST(freight_value AS DECIMAL(10,2))) AS total_item_value,
    current_timestamp() AS silver_processed_at,
    current_user() AS silver_processed_by
from {{ source('bronze', 'order_items_stream') }} 
-- Add your validation rules directly here to exclude bad data
