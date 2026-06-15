{{ config(
    materialized='view',
    description='Fulfillment pipeline evaluation tracking approval lag, warehouse processing speed, and actual vs target SLA margins.'
) }}

SELECT 
    o.order_id,
    o.order_status,
    o.purchase_at,
    o.approved_at,
    o.delivered_to_carrier_at,
    o.delivered_to_customer_at,
    o.estimated_delivery_at,
    
    -- Operational Milestones Metrics (Durations)
    o.actual_delivery_days AS total_delivery_days,
    DATEDIFF(day, o.purchase_at, o.approved_at) AS days_to_approve,
    DATEDIFF(day, o.approved_at, o.delivered_to_carrier_at) AS carrier_handover_days,
    DATEDIFF(day, o.delivered_to_carrier_at, o.delivered_to_customer_at) AS carrier_transit_days,
    DATEDIFF(day, o.delivered_to_customer_at, o.estimated_delivery_at) AS sla_safety_margin_days,
    
    -- Financial & Cargo Profile Parameters impacting Speed
    oi.freight_value,
    oi.price,
    p.weight_g AS product_weight_g,
    p.length_cm * p.height_cm * p.width_cm AS product_volume_cm3,
    p.product_category_name_english,
    
    -- Shipping Route Profiles
    c.city AS customer_city,
    c.state AS customer_state,
    c.zip_code_prefix AS customer_zip_code_prefix,
    s.city AS seller_city,
    s.state AS seller_state,
    s.zip_code_prefix AS seller_zip_code_prefix,
    
    -- Route Classification Feature
    CASE 
        WHEN c.state = s.state THEN 'Intra-State'
        ELSE 'Inter-State'
    END AS shipping_route_type
from {{ ref('fct_order') }} o
inner join {{ ref('dim_customer') }} c on o.customer_id = c.customer_id
inner join {{ ref('fct_order_item') }} oi on o.order_id = oi.order_id
inner join {{ ref('dim_product') }} p on oi.product_id = p.product_id
inner join {{ ref('dim_seller') }} s on oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered';