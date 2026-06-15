{{ config(
    materialized='table'
) }}

SELECT
    order_id,
    CAST(payment_sequential AS INT) AS payment_sequence,
    payment_type,
    CAST(payment_installments AS INT) AS payment_installments,
    CAST(payment_value AS DECIMAL(10,2)) AS payment_value,
    current_timestamp() AS silver_processed_at,
    current_user() AS silver_processed_by
from {{ source('bronze', 'order_payments_stream') }} p
where  exists (select order_id from  {{ source('bronze', 'orders_stream') }}  o where p.order_id = o.order_id );

-- Add your validation rules directly here to exclude bad data

-- Add your validation rules directly here to exclude bad data
