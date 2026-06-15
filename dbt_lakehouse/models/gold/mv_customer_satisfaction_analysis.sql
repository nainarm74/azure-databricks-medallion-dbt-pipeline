{{ config(
    materialized='view',
    description='Analytical view correlating customer review scores with product category, seller data, and delivery margins.'
) }}
SELECT 
    r.review_id,
    r.order_id,
    r.review_score,
    r.review_created_at,
    r.review_answered_at,
    -- Calculate the review response turnaround time in hours
    DATEDIFF(hour, r.review_created_at, r.review_answered_at) AS review_response_time_hours,
    
    -- Content Indicators for Sentiment Propensity
    CASE WHEN r.review_comment_message IS NOT NULL THEN 1 ELSE 0 END AS has_comment_message,
    CASE WHEN r.review_comment_title IS NOT NULL THEN 1 ELSE 0 END AS has_comment_title,
    LENGTH(r.review_comment_message) AS comment_message_char_length,
    
    -- Operational Drivers of Satisfaction
    o.order_status,
    o.purchase_at,
    o.estimated_delivery_at,
    o.delivered_to_customer_at,
    o.actual_delivery_days,
    -- Positive values imply delivery occurred ahead of schedule, negative values mean it was late
    DATEDIFF(day, o.delivered_to_customer_at, o.estimated_delivery_at) AS days_ahead_of_schedule,
    
    -- Demographics and Dimensional Metadata
    c.customer_unique_id,
    c.city AS customer_city,
    c.state AS customer_state,
    p.product_id,
    p.product_category_name_english,
    s.seller_id,
    s.business_segment AS seller_business_segment,
    s.business_type AS seller_business_type,
    
    -- Financials
    oi.price,
    oi.freight_value,
    oi.total_item_value
FROM {{ref('fct_order_review')}} r
INNER JOIN {{ref('fct_order')}} o ON r.order_id = o.order_id
INNER JOIN {{ref('dim_customer')}} c ON o.customer_id = c.customer_id
LEFT JOIN {{ref('fct_order_item')}} oi ON o.order_id = oi.order_id
LEFT JOIN {{ref('dim_product')}} p ON oi.product_id = p.product_id
LEFT JOIN {{ref('dim_seller')}} s ON oi.seller_id = s.seller_id;