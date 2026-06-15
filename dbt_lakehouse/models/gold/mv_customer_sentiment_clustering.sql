{{ config(
    materialized='view',
    description='Feature store preparation matrix targeting textual clusters linked to order values and delivery indicators.'
) }}

SELECT 
    r.review_id,
    r.order_id,
    c.customer_unique_id,
    r.review_score,
    r.review_comment_title,
    r.review_comment_message,
    COALESCE(LENGTH(r.review_comment_message), 0) AS text_message_length,
    COALESCE(LENGTH(r.review_comment_title), 0) AS text_title_length,
    
    -- Behavioral Context of the associated order
    o.purchase_at,
    o.order_status,
    o.actual_delivery_days,
    
    -- Aggregated order traits (to see if higher spending or bulky delivery impacts mood)
    SUM(oi.price) AS order_total_price,
    SUM(oi.freight_value) AS order_total_freight,
    COUNT(oi.product_id) AS order_item_count,
    
    -- Experience Indicators
    CASE 
        WHEN o.delivered_to_customer_at > o.estimated_delivery_at THEN 1 
        ELSE 0 
    END AS is_delivery_delayed,
    
    -- Regional Location Core Feature
    c.city AS customer_city,
    c.state AS customer_state
from {{ ref('fct_order_review') }} r
inner join {{ ref('fct_order') }} o on r.order_id = o.order_id
inner join {{ ref('dim_customer') }} c on o.customer_id = c.customer_id
left join {{ ref('fct_order_item') }} oi on o.order_id = oi.order_id
GROUP BY 
    r.review_id, 
    r.order_id, 
    c.customer_unique_id, 
    r.review_score, 
    r.review_comment_title, 
    r.review_comment_message, 
    o.purchase_at, 
    o.order_status, 
    o.actual_delivery_days, 
    o.delivered_to_customer_at, 
    o.estimated_delivery_at, 
    c.city, 
    c.state;