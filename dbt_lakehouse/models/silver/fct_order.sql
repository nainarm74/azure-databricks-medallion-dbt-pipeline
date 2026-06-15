{{ config(
    materialized='table'
) }}

SELECT
    order_id,
    customer_id,
    order_status,
    CAST(order_purchase_timestamp AS TIMESTAMP) AS purchase_at,
    CAST(order_approved_at AS TIMESTAMP) AS approved_at,
    CAST(order_delivered_carrier_date AS TIMESTAMP) AS delivered_to_carrier_at,
    CAST(order_delivered_customer_date AS TIMESTAMP) AS delivered_to_customer_at,
    CAST(order_estimated_delivery_date AS TIMESTAMP) AS estimated_delivery_at,
    DATEDIFF(CAST(order_delivered_customer_date AS TIMESTAMP), CAST(order_purchase_timestamp AS TIMESTAMP)) AS actual_delivery_days,
    current_timestamp() AS silver_processed_at,
    current_user() AS silver_processed_by
from {{ source('bronze', 'orders_stream') }} 
-- Add your validation rules directly here to exclude bad data
