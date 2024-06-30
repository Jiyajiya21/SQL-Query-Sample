
-- calculating the active user penetration rate in specific countries.

with Active_User as (
  SELECT 
    country, 
    count(user_id) as active 
  FROM 
    penetration_analysis 
  where 
    last_active_date >= (
      DATE '2024-01-31' - INTERVAL '30 days'
    ) 
    and sessions >= 5 
    and listening_hours >= 10 
  group by 
    1
), 
total_users as (
  select 
    country, 
    count(user_id) as total 
  from 
    penetration_analysis 
  group by 
    1
) 
select 
  au.country, 
  round(
    cast(au.active as numeric) / CAST(ta.total AS numeric), 
    2
  ) AS active_user_penetration_rate 
from 
  Active_User au 
  join total_users ta on au.country = ta.country;
