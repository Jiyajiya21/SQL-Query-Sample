-- 1)Write an SQL query to recommend pages to the user with user_id = 1 
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

-- 2)Write an SQL query to 
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

-- 3)Write an SQL query to find the countries where this company can invest.
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

-- 4)Write an SQL query to find all the pairs of users with the maximum number of common followers. In other words, if the maximum number of common followers between any two users is maxCommon
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

 
-- 5)Write an SQL query to report the Capital gain/loss for each stock.
with cte as(select stock_name
, operation
, operation_day,price
, row_number() over (partition by stock_name order by operation_day) as rn
from stocks ),

cte2 as (select *
, case when rn%2 != 0 then lead(price)
over(partition by stock_name order by operation_day) - price
 end as profit
from cte )

select stock_name, sum(profit) as capital_gain_loss
from cte2
group by 1


-- 6)Write an SQL query to find the salaries of the employees after applying taxes.

select company_id, employee_id, employee_name
, case when max(salary) 
        over(partition by company_id) < 1000 then salary
       when max(salary) 
       over(partition by company_id) >= 1000 and 
        max(salary) over(partition by company_id) <= 10000
          then salary - (salary * 24)/100 
       else salary - (salary * 49)/100 
       end as salary

    from salaries

-- 7)Write an SQL query to evaluate the boolean expressions in Expressions table.

select v.name as left_operand , e.operator, v2.name as right_operand
, case when e.operator = '<' and v.value < v2.value then 'true'
        WHEN e.operator = '>' and v.value > v2.value then 'true' 
        WHEN e.operator = '=' and v.value = v2.value then 'true' 
        else 'false' end as value
from variables v join expressions e 
on v.name = e.left_operand 
join variables v2 
on v2.name = e.right_operand

-- 8)Write an SQL query to recommend pages to the user with user_id = 1
--using the pages that your friends liked. It should not recommend pages
-- you already liked.

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

-- 9)Write an SQL query to find the following for each invoice_id:

/*customer_name: The name of the customer the invoice is related to.
price: The price of the invoice.
contacts_cnt: The number of contacts related to the customer.
trusted_contacts_cnt: The number of contacts related to the customer and at the same time they are customers to the shop. (i.e His/Her email exists in the Customers table.)
Order the result table by invoice_id.*/

with cte as 
(select customer_id, customer_name, contact_name, email, contact_email
  , invoice_id, i.price
from customers c left join contacts con
on c.customer_id = con.user_id
right join invoices i 
on i.user_id = c.customer_id 
)
select invoice_id, customer_name, price
, count(contact_name) as contacts_cnt 
, sum(case when contact_name in
       (select customer_name from customers) 
       then 1 else 0 end) as trusted_contacts_cnt 
from cte
group by 1, 2, 3
order by 1

-- 10)Write an SQL query to find the countries where this company can invest.
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

-- 11)Write an SQL query to report the IDs of all suspicious bank accounts.

with cte as 
(SELECT *, A.ACCOUNT_ID as acc_id, TO_CHAR(DAY, 'MM')
FROM ACCOUNTS A LEFT JOIN TRANSACTIONS T 
ON A.ACCOUNT_ID = T.account_id),

cte2 as (select acc_id, TO_CHAR(DAY, 'MM'), sum(amount)    
from cte  
where type_pro  = 'Creditor'
group by 1,2
--
order by acc_id ) 

select acc_id as account_id  from (select *
, CASE WHEN LEAD(to_char::integer) OVER (PARTITION BY acc_id ORDER BY to_char::integer) = to_char::integer + 1 THEN 1 ELSE 0 END AS is_next_month
from cte2 join ACCOUNTS acc 
on cte2.acc_id = acc.account_id
where cte2.sum >  acc.max_income 
order by acc_id, TO_CHAR)a
where is_next_month = 1

-- 12)Write an SQL query to get the team_id of each employee that is in a team.
select * 
,dense_rank() over(order by salary) as team_id
from employees
where salary in

(select salary
from employees 
group by salary 
having count(salary) >1)

-- 13) Write a SQL query to find employees who have the highest salary in each of 
--the departments. For the above tables, your SQL query should return
-- the following rows (order of rows does not matter).

-- OPTION 1
with cte as
    (select department.name as Department
    , employee.name as Employee
    , employee.salary as Salary 
    , rank() over(partition by employee.departmentid order by employee.salary desc) as rank
    from employee left join department 
    on employee.DepartmentId = department.id
    ) 
select department as "Department", employee as "Employee"
, Salary as "Salary"
from cte
where cte.rank = 1;

--OPTION 2

select d.name as Department, e.name as Employee, e.salary as Salary
from employee e join department d 
on e.departmentid = d.id
join (select departmentid, max(salary) from employee group by 1) a
on a.departmentid =  e.departmentid and e.salary = a.max

--OPTION 3

SELECT Department.name AS "Department"
, Employee.name AS "Employee"
, Salary
 FROM Employee JOIN Department 
 ON Employee.DepartmentId = Department.Id 
 WHERE (Employee.DepartmentId , Salary) 
 IN 
 ( SELECT DepartmentId, MAX(Salary) FROM Employee GROUP BY DepartmentId ) ;

 -- 14)Write a SQL query that finds out managers with at least 5 direct 
--report. For the above table, your SQL query should return:

  SELECT NAME FROM Employee 
  WHERE Id IN 
      (select managerid
from employee
group by managerid 
having count(managerId) >= 5)

/* 15)Write a query to print the sum of all total investment values in 2016 (TIV_2016), to a scale of 2 decimal places, for all policy holders who meet the following criteria:

Have the same TIV_2015 value as one or more other policyholders.
Are not located in the same city as any other policyholder (i.e.: the (latitude, longitude) attribute pairs must be unique).
Input Format:*/

--OPTION 1

select round(sum(distinct i1.tiv_2016),2) as "TIV_2016" 
from insurance  i1 join insurance i2 
on i1.pid <> i2.pid
where i1.tiv_2015 = i2.tiv_2015 
and i1.lat not in (select lat from insurance group by lat having count(lat)>1)
and i1.lon not in (select lon from insurance group by lon having count(lon)>1)

--OPTION 2

select round(sum(TIV_2016),2) as TIV_2016 from

(select TIV_2016 from insurance 

where TIV_2015 in (select TIV_2015 from insurance group by TIV_2015 having count(*)>1) and 

(lat,lon)not in (select lat,lon from insurance group by lat,lon having count(*)>1) ) as table1;

--16)Write a query to print the node id and the type of the node. Sort your 
--output by the node id

select 
id, case when id not in (select p_id from tree WHERE p_id IS NOT NULL) then 'Leaf'
 WHEN p_id IS NULL THEN 'Root'

        ELSE 'Inner' end as type
from tree
order by id

-- 17) Write an SQL query to find the missing customer IDs. The missing IDs 
--are ones that are not in the Customers table but are in the range 
--between 1 and the maximum customer_id present in the table.

SELECT generate_series(1, (SELECT MAX(customer_id) FROM customers)) AS ids

EXCEPT

SELECT customer_id FROM customers;

/* 18)Write an SQL query to report the statistics of the league. The statistics
should be built using the played matches where the winning team gets three 
points and the losing team gets no points. If a match ends with a draw, 
both teams get one point.*/

select team_name
, count(*) as matches_played 
, sum(case when home > away then 3 
           when home = away then 1
           else 0 end) as points
, sum(home) as goal_for 
, sum(away) as goal_against
, sum(home) - sum(away) as goal_diff
from
(SELECT home_team_id AS home_team_id
, home_team_goals as home, away_team_goals as away 
FROM Matches
UNION ALL
SELECT away_team_id AS home_team_id    
, away_team_goals as home, home_team_goals as away
FROM Matches) 
cte join teams on cte.home_team_id = teams.team_id
group by 1
order by points desc, goal_diff desc, team_name 