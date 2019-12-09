-- just hit 'tab' on an incomplete column name, it finishes it for you
-- also works on table names 

-- count is like sum() but the difference is it gets non-null summation of
-- data points, rather than data values

-- SQL SERVER documentation of order
-- https://blog.jooq.org/2016/12/09/a-beginners-guide-to-the-true-order-of-sql-operations/ 

FROM -> ON -> JOIN 

WHERE -> GROUP BY -> 'aggregations' (count, sum, etc.) -> HAVING 

SELECT 

DISTINCT -> ORDER BY -> TOP 

-- bigquery.cloud.google.com vs console.cloud.google.com/bigquery   (old vs new)
-- old site has the google analytics data  defining table names 

-- note difference between ` and ' when






-- find number of rows in table
SELECT
  COUNT(*)
FROM
  `bigquery-public-data.usa_names.usa_1910_2013`
LIMIT
  1000

-- find number of distinct columns
SELECT
  COUNT(DISTINCT gender) gender,
  COUNT(DISTINCT year)  as year
FROM
  `bigquery-public-data.usa_names.usa_1910_2013`
LIMIT
  1000 

-- Each possible distinct combination (useful for cateogorical variables)

SELECT 
  DISTINCT 
  borough, 
  major_category 
FROM `bigquery-public-data.london_crime.crime_by_lsoa` 
LIMIT 1000

-- keep in mind that it applies DISTINCT to all columns, not just borough



-- same results utilizing just GROUP BY 
SELECT
  borough,
  major_category
FROM
  `bigquery-public-data.london_crime.crime_by_lsoa`
GROUP BY
  borough,
  major_category
LIMIT
  1000
 
 
-- where clauses, nuisance of IN vs OR 
SELECT tripduration
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration in (10,50,100)
LIMIT 10

-- same thing as: 
SELECT tripduration
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration = 10 OR tripduration = 50 OR tripduration = 100 
LIMIT 10


-- 
SELECT distinct minor_category
FROM
  `bigquery-public-data.london_crime.crime_by_lsoa`
  
WHERE 
  minor_category like '%Dru%' or minor_category != 'Harassment'
  
LIMIT
  10

-- Select how many bike rides started at the station  Zilker Park West? Most minutes ridden there?
SELECT
  count (*), max(duration_minutes)       -- note * & bike_rides are interchangable here
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE
  start_station_name = 'Zilker Park West'
LIMIT
  10

-- Select number of rides that started at Metro and ended at ACC
SELECT
  count(bikeid) as num_rides
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE
  start_station_name = 'Capital Metro HQ - East 5th at Broadway'
  AND
  end_station_name = 'ACC - West & 12th Street' 
LIMIT
  10

-- Number of bike rides that started at same location?
-- Select number of rides that started at Metro and ended at ACC
SELECT
  count(bikeid) as num_rides
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE
  start_station_name = end_station_name
LIMIT
  10

-- Use WHERE to select rides that lasted between 1 and 2 hour
SELECT
  COUNT(*) AS num_rides
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE
  duration_minutes >= 60
  AND duration_minutes <= 120



-- Consider the following two types of bike rides:

-- 1. Started at  "ACC - West & 12th Street" and ended at "Zilker Park West"

-- 2. Started at "Nueces @ 3rd" and ended at "Toomey Rd @ South Lamar"

-- Of all these types of bike rides, what was the shortest trip duration in minutes?

SELECT
  duration_minutes
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE
  (start_station_name = "ACC - West & 12th Street"
    AND end_station_name = "Zilker Park West")
  OR (start_station_name = "Nueces @ 3rd"
    AND end_station_name = "Toomey Rd @ South Lamar")
ORDER BY
  duration_minutes ASC
LIMIT
  10


-- How many of distinct strings contain pattern "B-cycle" in subscriber type?
-- You could count them manually but that is not a scalable solution.
-- You can answer this question using a LIKE statement.

SELECT
  count(distinct(subscriber_type))
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE subscriber_type like '%B-cycle%'




-- 3.14  Working with time stamp, using CAST (datetime, date, etc.) and EXTRACT
SELECT
  start_time AS start_time_timestamp,
  CAST(start_time AS date) AS start_time_date
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE
  CAST(start_time AS date) = '2018-03-03'
  -- note it must be cast first to date datatype, since we're looking
  -- for a direct match with no time elements (e.g 17:00:00 UTC)
  -- SQL does NOT see 2015-12-25 and 2015-12-25 00:00:00 as the same thing. 
  -- which is tricky for equal conditions. 
  -- https://stackoverflow.com/questions/57634597/figuring-out-difference-between-these-two-queries-involving-datetime
  -- O.W. it produces no query. 
  -- it would be acceptable if condition was > or < 
  -- it would not work if you used start_time_timestamp,
  -- WHERE does not recognize it due to lexical ordering

  /*Yes it will be different due to how casting works. If you use the 2nd query, it views '2015-12-23 00:00:02 UTC' from trip_start_timestamp as equal to '2015-12-23' due to casting. It will include a lot of data like e.g '2015-12-27 00:00:05' as being part of the equal condition. That's why the 2nd query returns more results than the first one. */
LIMIT
  20

-- 4.1 how many Chicago taxi trips started on 2015-12-31? 
-- utilize unique key present in the dataset
-- primary key does not accept duplicates or NULL values,
-- unique or unique keys can accept one null value per column
SELECT
  COUNT(DISTINCT unique_key) AS num_trips
FROM
  `bigquery-public-data.chicago_taxi_trips.taxi_trips`
WHERE
  CAST(trip_start_timestamp AS date) = '2015-12-31'

-- 4.2 How many taxi trips between 2015-12-23 and 2015-12-27? Include these two dates in your query. 

SELECT
  COUNT(DISTINCT unique_key) AS num_trips
FROM
  `bigquery-public-data.chicago_taxi_trips.taxi_trips`
WHERE  
trip_start_timestamp >= '2015-12-23'
and 
trip_start_timestamp <= '2015-12-27'

SELECT
  COUNT(DISTINCT unique_key) AS num_trips
FROM
  `bigquery-public-data.chicago_taxi_trips.taxi_trips`
WHERE  
cast(trip_start_timestamp as date) >= '2015-12-23'
and 
cast(trip_start_timestamp as date) <= '2015-12-27'

-- Why do these two produce different results? 





-- 4.3 Find number of trips that took place in the hours 9,10,11,12 and in every 
-- year that's not 2016. 

SELECT
  count(distinct unique_key) as num_trips,
  
FROM
  `bigquery-public-data.chicago_taxi_trips.taxi_trips` 
WHERE
  extract(HOUR from trip_start_timestamp) in (9,10,11,12)
  AND
  extract(year from trip_start_timestamp) != 2016 


-- 4.4a  Find number of trips that exists before October 31st, 2017 at the hour of 9. 
SELECT
  count(distinct unique_key) as num_trips
FROM
  `bigquery-public-data.chicago_taxi_trips.taxi_trips` 
WHERE
  cast(trip_start_timestamp as DATE) < '2017-10-31'
  AND 
  extract(HOUR from trip_start_timestamp) = 9 

-- 4.4b  Find number of trips that exists at the hour of 9, on October 31st, before the year 2017. 
SELECT
  COUNT(DISTINCT unique_key) AS num_trips
FROM
  `bigquery-public-data.chicago_taxi_trips.taxi_trips`
WHERE
  EXTRACT(hour FROM trip_start_timestamp) = 9
  AND 
  EXTRACT(day FROM trip_start_timestamp) = 31
  AND 
  EXTRACT(month FROM trip_start_timestamp) = 10
  AND 
  EXTRACT(year FROM trip_start_timestamp) < 2017

-- 4.5 Using only the years 2014 and 2016, how many trips started in the 16th week all
-- together from both these two years?
SELECT
  COUNT(DISTINCT unique_key) AS num_trips
FROM
  `bigquery-public-data.chicago_taxi_trips.taxi_trips`
WHERE
  EXTRACT(week FROM trip_start_timestamp) = 16
  AND
  EXTRACT(year FROM trip_start_timestamp) in (2014,2016)

-- JOINS 
SELECT 

-- 5.3 

SELECT
  sidewalk,
  COUNT(DISTINCT tree_id) AS num_trees
FROM
  `bigquery-public-data.new_york_trees.tree_census_2015`
WHERE
  health = 'Poor'
  AND tree_dbh > 10
GROUP BY
  sidewalk