{{ config(
    materialized='view',
    description='Daily aggregated historical dataset tracking volumes, item visuals features and gross item revenues for forecasting.'
) }}
SELECT 
    CAST(o.purchase_at AS DATE) AS sales_date,
    EXTRACT(YEAR FROM o.purchase_at) AS sales_year,
    EXTRACT(MONTH FROM o.purchase_at) AS sales_month,
    EXTRACT(DAYOFWEEK FROM o.purchase_at) AS sales_day_of_week,
    p.product_category_name_english,
    c.state AS destination_state,
    
    -- ML Targets: Volumes and Revenue
    SUM(oi.total_item_value) AS total_item_value_sold,
    SUM(oi.price) AS total_revenue,
    SUM(oi.freight_value) AS total_freight_revenue,
    COUNT(oi.order_id) AS total_units_sold,
    COUNT(DISTINCT o.order_id) AS unique_orders_count,
    
    -- Leading Indicators / Predictive Features
    AVG(oi.price) AS average_item_price,
    AVG(p.weight_g) AS average_product_weight_g,
    AVG(p.product_photos_count) AS average_product_photos_count
from {{ ref('fct_order') }} o
inner join {{ ref('fct_order_item') }} oi on o.order_id = oi.order_id
inner join {{ ref('dim_product') }} p on oi.product_id = p.product_id
inner join {{ ref('dim_customer') }} c on o.customer_id = c.customer_id
WHERE o.order_status <> 'canceled' -- Filter noise to maximize demand accuracy
GROUP BY 
    CAST(o.purchase_at AS DATE),
    EXTRACT(YEAR FROM o.purchase_at),
    EXTRACT(MONTH FROM o.purchase_at),
    EXTRACT(DAYOFWEEK FROM o.purchase_at),
    p.product_category_name_english,
    c.state;