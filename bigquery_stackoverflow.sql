-- Here are some tips: 
-- hit 'tab' to fill out an incomplete column or table name
-- bigquery.cloud.google.com vs console.cloud.google.com/bigquery   (old vs new)
-- recommend the new one 
-- note difference between ` and ' when



-- 1.  Find famed Jon Skeet's reputation and views 
SELECT 
  display_name as name, reputation, views
FROM `bigquery-public-data.stackoverflow.users`
WHERE display_name IN ('Jon Skeet')    -- doesn't recognize the use of 'name'


-- 2.  Find top 5 users by reputation, as well as their views 
SELECT 
  display_name as name, reputation, views
FROM `bigquery-public-data.stackoverflow.users`
ORDER by reputation DESC 
LIMIT 5


-- 3.  Find the last date of comments table, printing the id, text, and date column 

SELECT c.text, c.id, date(c.creation_date) date
FROM `bigquery-public-data.stackoverflow.comments` as c
WHERE date(c.creation_date) = (                         
  -- note the WHERE condition has to match typing for BOOLEAN comparison
  -- need date(x) to match the date(y) selection       
  SELECT max(date(creation_date))
  FROM `bigquery-public-data.stackoverflow.comments` as c)

LIMIT 10; 



--  4. Look at which post has the highest score on the lastest day of dataset 
-- while getting rid of null values. Print date, score, view count, etc. 
-- printing the user_id 
-- use the date() method to extract just the date, rather than datetime 
-- learn to join tables with same data column but differently named 
-- requires one subquery for aggregation, then another to select relevant columns 
-- since SELECT limits you to not mix aggregated columns with non-aggregated ones 

SELECT display_name name, score, view_count, title, date 

FROM `bigquery-public-data.stackoverflow.users` as u  
INNER JOIN (
  SELECT owner_user_id, date(creation_date) date, view_count, score, title 
  -- note you need to include owner_user_id for the ON condition, SQL can't read o.w
  FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
  WHERE date(creation_date) = (
    SELECT max(date(creation_date))
    FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
       )
  ) as p
  ON u.id = p.owner_user_id 

WHERE view_count IS NOT NULL and owner_user_id IS NOT NULL and title IS NOT NULL
ORDER by score DESC
LIMIT 50



-- alternative query 
-- This query is already good enough performance and readability wise, but if you wish to use JOIN instead of WHERE - below version should produce same result and be slightly faster:
-- Most inner WHERE transformed into JOIN
-- Most outer WHERE moved inside
SELECT display_name name, score, view_count, title, date
FROM `bigquery-public-data.stackoverflow.users` as u  

INNER JOIN (
  SELECT owner_user_id, DATE(creation_date) date, view_count, score, title 
  FROM `bigquery-public-data.stackoverflow.stackoverflow_posts` a
  JOIN (
    SELECT MAX(DATE(creation_date)) max_date
    FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
  ) b
  ON DATE(creation_date) = max_date    --useful joining condition of two same tables, replaces WHERE cond. 
  WHERE view_count IS NOT NULL AND owner_user_id IS NOT NULL AND title IS NOT NULL
) as p

ON u.id = p.owner_user_id 
ORDER BY score DESC
LIMIT 50  



-- 5. Select user with the highest number of views, displaying their name and reputation as well
SELECT 
  display_name, reputation, views
FROM `bigquery-public-data.stackoverflow.users`
WHERE views = (
  SELECT max(views)
  FROM `bigquery-public-data.stackoverflow.users`
)
LIMIT 5




-- 6. Compare date() vs cast in converting datetime (they're the exact same; date() is more convenient) 
	SELECT c.text, c.id,  c.creation_date, date(c.creation_date) date, cast(c.creation_date AS date) date2
	FROM `bigquery-public-data.stackoverflow.comments` as c
	WHERE date(c.creation_date) = (                         
	  -- note the WHERE condition has to match typing for BOOLEAN comparison
	  -- need date(x) to match the date(y) selection       
	  SELECT max(date(creation_date))
	  FROM `bigquery-public-data.stackoverflow.comments` as c)
	
	LIMIT 1000; 


-- 7. How many distinct users are there on stackoverflow?
SELECT count(distinct(display_name)) number_of_name
FROM `bigquery-public-data.stackoverflow.users` as u  

LIMIT 50