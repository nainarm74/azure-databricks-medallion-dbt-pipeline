{{ config(
    materialized='table'
) }}

SELECT
    review_id,
    order_id,
    coalesce(try_cast(review_score as int), -9) AS review_score,
    review_comment_title,
    review_comment_message,
    coalesce(try_to_timestamp(review_creation_date), to_timestamp('9999-12-31 23:59:59', 'yyyy-MM-dd HH:mm:ss')) AS review_created_at,
    coalesce(try_to_timestamp(review_answer_timestamp), to_timestamp('9999-12-31 23:59:59', 'yyyy-MM-dd HH:mm:ss')) AS review_answered_at,
    current_timestamp() AS silver_processed_at,
    current_user() AS silver_processed_by FROM
 {{ source('bronze', 'order_reviews_stream') }} r
where  exists (select order_id from  {{ source('bronze', 'orders_stream') }}  o where r.order_id = o.order_id );

-- Add your validation rules directly here to exclude bad data
