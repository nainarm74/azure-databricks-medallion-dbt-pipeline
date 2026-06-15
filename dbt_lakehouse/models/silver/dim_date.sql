{{ config(
    materialized='table'
) }}

   SELECT
date_id
full_date
day_of_week
calendar_month_number
calendar_quarter_number
calendar_quarter_desc
calendar_year
holiday_indicator
black_friday_indicator
from {{ source('silver', 'dim_date') }} as s
-- Add your validation rules directly here to exclude bad data

  
