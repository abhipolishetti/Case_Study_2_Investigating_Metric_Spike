create database Case_Study_2_Investigating_Metric_Spike;
use Case_Study_2_Investigating_Metric_Spike;
show databases;

-- table 1 Users
create table users(
user_id int,
created_at varchar(100),
company_id int,
language varchar(50),
activated_at varchar(100),
state varchar(50)
);

show variables like 'secure_file_priv';

Load Data Infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv"
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- converted varchar to datetime col_created_at(users)
alter table users add column temp_created_at datetime;
update users set temp_created_at = str_to_date(created_at, '%d-%m-%Y %H:%i');
alter table users drop column created_at;
ALTER TABLE users CHANGE temp_created_at created_at datetime;

-- converted varchar to datetime col_activited_at(users)
alter table users add column temp_activated_at datetime;
update users set temp_activated_at = str_to_date(activated_at, '%d-%m-%Y %H:%i');
alter table users drop column activated_at;
ALTER TABLE users CHANGE temp_activated_at activated_at datetime;


-- table 2 events
  create table events (
  user_id int,
  occurred_at varchar(100),
  event_type varchar(50),
  event_name varchar(100),
  location varchar(100),
  device varchar(100),
  user_type int
  );
  
  Load Data Infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv"
into table events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- converted varchar to datetime col_occurred_at(events)
alter table events add column temp_occurred_at datetime;
update events set temp_occurred_at = str_to_date(occurred_at, '%d-%m-%Y %H:%i');
alter table events drop column occurred_at;
ALTER TABLE events CHANGE temp_occurred_at occurred_at datetime;


-- table 3 email events
create table email_events(
user_id int,
occurred_at varchar(100),
action varchar(100),
user_type int
);

Load Data Infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/email_events.csv"
into table email_events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- converted varchar to datetime col_occurred_at(email_events)
alter table email_events add column temp_occurred_at datetime;
update email_events set temp_occurred_at = str_to_date(occurred_at, '%d-%m-%Y %H:%i');
alter table email_events drop column occurred_at;
ALTER TABLE email_events CHANGE temp_occurred_at occurred_at datetime;

-- Weekly User Engagement:
-- Objective: Measure the activeness of users on a weekly basis.
-- Your Task: Write an SQL query to calculate the weekly user engagement.

select extract(week from occurred_at) as week_num, count(distinct user_id) as users_engagement from events 
 group by week_num order by week_num;
 
-- User Growth Analysis:
-- Objective: Analyze the growth of users over time for a product.
-- Your Task: Write an SQL query to calculate the user growth for the product.

SELECT year_num, month_num, week_num, num_active_users,
    SUM(num_active_users)OVER(ORDER BY year_num ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS user_growth 
    FROM(
select extract(year from created_at) as year_num, extract(month from created_at) as month_num, extract(week from created_at) as week_num, 
count(distinct user_id) as num_active_users from users group by year_num, month_num, week_num order by year_num, month_num, week_num)a;

-- Weekly Retention Analysis:
-- Objective: Analyze the retention of users on a weekly basis after signing up for a product.
-- Your Task: Write an SQL query to calculate the weekly retention of users based on their sign-up cohort.

SELECT COUNT(user_id) AS total_users, 
SUM(CASE WHEN retention_week = 1 THEN 1 ELSE 0 END ) AS week_1,
       SUM(CASE WHEN retention_week = 2 THEN 1 ELSE 0 END ) AS week_2,
       SUM(CASE WHEN retention_week = 3 THEN 1 ELSE 0 END ) AS week_3,
       SUM(CASE WHEN retention_week = 4 THEN 1 ELSE 0 END ) AS week_4
FROM (
    SELECT a.user_id, a.sign_up_week, b.engagement_week, b.engagement_week - a.sign_up_week AS retention_week
    FROM (
        (SELECT DISTINCT user_id, EXTRACT(week FROM occurred_at) AS sign_up_week
         FROM events
         WHERE event_type = 'signup_flow' AND event_name = 'complete_signup' AND EXTRACT(week FROM occurred_at) = 18) a
        LEFT JOIN
        (SELECT DISTINCT user_id, EXTRACT(week FROM occurred_at) AS engagement_week
         FROM events
         WHERE event_type = 'engagement') b
        ON a.user_id = b.user_id
    )
    GROUP BY a.user_id, a.sign_up_week, b.engagement_week 
    ORDER BY a.user_id, a.sign_up_week 
) subquery;

-- Weekly Engagement Per Device:
-- Objective: Measure the activeness of users on a weekly basis per device.
-- Your Task: Write an SQL query to calculate the weekly engagement per device.

select 
extract(year from occurred_at) as year_num,
extract(week from occurred_at) as week_num,
device,
count(distinct user_id) as no_of_users
from events
where event_type = 'Engagement'
group by 1,2,3
order by 1,2,3;

-- Email Engagement Analysis:
-- Objective: Analyze how users are engaging with the email service.
-- Your Task: Write an SQL query to calculate the email engagement metrics.

  SELECT
    100.0 * SUM(email_cat = 'email_opened') / SUM(email_cat = 'email_sent') AS email_opening_rate,
    100.0 * SUM(email_cat = 'email_clicked') / SUM(email_cat = 'email_sent') AS email_clicking_rate
FROM (
    SELECT *,
    CASE
        WHEN action IN ('sent_weekly_digest', 'sent_reengagement_email') THEN 'email_sent'
        WHEN action IN ('email_open') THEN 'email_opened'
        WHEN action IN ('email_clickthrough') THEN 'email_clicked'
    END AS email_cat
    FROM email_events
) a;




