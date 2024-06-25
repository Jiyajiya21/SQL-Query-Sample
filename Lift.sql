-- To find the Max Capacity of Lift we will start by cumalating Sum

with cte as (Select *
, sum(Weight) over(partition by lift_id order by weight asc) as cum_sum
, case when capacity_kg >= sum(Weight) over(partition by lift_id order by weight asc) as Total
		then 1 else 0 end as flag
from Lift_passenger lp 
join lift l 
on lp.Lift_id = l.id)
select lift_id, STRING_AGG(Passenger_name, ',')
from cte
where flag = 1; 