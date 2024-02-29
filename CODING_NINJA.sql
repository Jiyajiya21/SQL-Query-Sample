--Write an SQL query to recommend pages to the user with user_id = 1 
--using the pages that your friends liked. It should not recommend pages you already liked.
--SOLUTION 1
with cte as
      (select user1_id, user2_id, page_id  
        from friendship f join likes l 
        on f.user1_id = l.user_id
        where user1_id = 1 or user2_id = 1)

, cte2 as 
   (select l.user_id, cte.user1_id, l.page_id
    from likes l right join cte 
     on l.user_id = cte.user2_id)

select distinct l1.page_id as recommended_page  
from cte2 join likes l1 
on cte2.user1_id = l1.user_id
where l1.page_id not in (select page_id from likes where user_id = 1)

union 

select page_id as recommended_page 
from cte2 
where user1_id = 1 
 
--SOLUTION 2
SELECT DISTINCT page_id AS recommended_page 
FROM Likes WHERE user_id IN 
(SELECT user2_id AS friend_id 
FROM Friendship WHERE user1_id = 1
 UNION 
 SELECT user1_id AS friend_id 
 FROM Friendship
 WHERE user2_id = 1) 
 AND
page_id NOT IN ( SELECT page_id FROM Likes WHERE user_id = 1 );

--Write an SQL query to 
--find the names of all the activities with neither maximum, nor minimum number of participants.
with cte as 

  (select a.name
   , count(*) 
    from friends f left join activities a 
    on f.activity = a.name 
     group by 1)

 select name as activity 
 from cte where count <> (select max(count) from cte) and 
                count <> (select min(count) from cte)

--Write an SQL query to find the countries where this company can invest.
select c.name as country from
(select caller_id as id, duration 
from calls 
union
select callee_id as id, duration
from calls) f join person p 
on p.id = f.id
join country c on c.country_code = LEFT(p.phone_number, 3)
group by 1 
having avg(duration)> (select avg(duration) from calls)

--Write an SQL query to find the confirmation rate of each user.
select s.user_id  
, round(avg(case when action_value = 'confirmed' 
            then 1 else 0 end),2) as confirmation_rate
from signups s left join confirmations c 
on s.user_id = c.user_id 
group by 1

--Write an SQL query to find all the pairs of users with the maximum number of common followers. In other words, if the maximum number of common followers between any two users is maxCommon
--, then you have to return all pairs of users that have maxCommon common followers.
select user1_id, user2_id 
from 
(select r1.user_id as user1_id
, r2.user_id as user2_id
, dense_rank()over(order by count(r1.follower_id) desc) as rk 
from Relations r1, Relations r2 
where r1.user_id < r2.user_id and r1.follower_id = r2.follower_id 
group by r1.user_id, r2.user_id)

 temp where rk = 1;


