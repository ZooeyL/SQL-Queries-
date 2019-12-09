------- Google Analtyics 
-- go to console.cloud.google.com 
-- open big query on your left hand side 
-- under resources, you can search "ga_sessions"
-- you may not be able to see the table on the laptop for whatever reason 

-- preview shows a very tall dataset per row because it has many nested columns


-- Google Analytics has quietly changed the terminology they use within the reports to change what they call "visits" and "unique visitors." Now, visits is named "sessions" and unique visitors is named "users." ... Technically, nothing seems to have changed outside of the terminology used in the Google Analytics report




-- The sample dataset contains Google Analytics 360 data from the Google Merchandise Store, a real ecommerce store. The Google Merchandise Store sells Google branded merchandise. The data is typical of what you would see for an ecommerce website. It includes the following kinds of information:

-- Traffic source data: information about where website visitors originate. This includes data about organic traffic, paid search traffic, display traffic, etc.
-- Content data: information about the behavior of users on the site. This includes the URLs of pages that visitors look at, how they interact with content, etc.
-- Transactional data: information about the transactions that occur on the Google Merchandise Store website.


-- Users represent individuals that visit your site. If that same User leaves your site and comes back later, Google Analytics will remember therm, and their second visit won’t increase the number of Users (since they have already been accounted for in the past).
-- Sessions represent a single visit to your website. Whether a User lands on one of your web pages and leaves a few seconds later, or spends an hour reading every blog post on your site, it still counts as a single Session. If that User leaves and then comes back later, it wouldn’t count as a new User (see above), but it would count as a new Session.
-- Pageviews represent each individual time a page on your website is loaded by a User. A single Session can include many Pageviews, if a User navigates to any other web pages on your website without leaving. A website can have many pages so this can be useful metric. 

-- For example, many sites make money off of ad impressions, or the number of times an ad is seen on a website. Every time a page on the site loads, ads are displayed, and the site makes a little bit of money. In this case, revenue is tied directly to Pageviews; Users and Sessions are less relevant.

-- Why? Well, whether one User views ten different pages, or ten different Users each view one page each, the number of ad impressions is the same. The more pages that are viewed, the more money the site makes. To increase revenue, you could focus on bringing in more Users, or you could focus on getting the existing group of Users to view more pages (by increasing the length of their Sessions). But either way, your end goal is really to increase the number of Page Views.

-- As a counterpoint, many other sites make money from lead generation. When a User calls or fills out a form, the site makes money. A User can’t sign up twice, so in order to keep making money, this site needs a constant stream of new Users. Page Views and Sessions may be less important (but still not irrelevant).


-- https://support.google.com/analytics/answer/3437719?hl=en
-- look here to understand google analytics' data columns
-- visitNumber: the session number for this user. If this is the first session, then this is set to 1. 
-- totals.hits: number of hits within the session 
-- totals.pageviews: total number of page views 
-- totals.visits: The number of sessions (for convenience). This value is 1 for sessions with interaction events. The value is null if there are no interaction events in the session. (Recommend you change NULL to 0)

-- Total Sessions: The number of sessions a visitor took part in on your website. A session expires if a visitor does not perform an action for 30 minutes. A new session begins if he/she resume action.
-- Bounce Rate: The proportion of users that visited your landing page and then left without accessing any other pages.
-- Session Duration/PageView Duration: The average length of time visitors spend on a specific page or partaking in a session.
-- Pages/Session: The average number of pages visitors visit each session.
-- Conversion Rate (requires setup): The proportion of visitors that successfully perform “conversion actions.” This could be filling out a lead form or making a purchase. This requires goal setup.
-- Total Revenue (requires setup): The total number of purchases made by visitors to your website. Requires e-commerce integration.


-- Direct: Google Analytics defines direct traffic as website visits that arrived on your site either by typing your website URL into a browser or through browser bookmarks. In addition, if Google Analytics can’t recognize the traffic source of a visit, it will also be categorized as Direct in your Analytics report.
-- Traffic from any offline documents, like PDF, MS Word, etc.
-- Traffic from mobile social media apps.
-- Depending on browser issues, sometimes traffic from organic search is also categorized as Direct.


-- Organic Search: this refers to unpaid search results. In contrast, paid search results (pay per click advertising) are populated via an ac

-- device.deviceCategory, device.operatingSystem, device.browser 



SELECT visitNumber, visitid, visitStartTime, date
FROM 
  `bigquery-public-data.google_analytics_sample.ga_sessions_20160801`
LIMIT 100



SELECT
  date,
  channelGrouping AS channel,
  trafficSource.source,
  totals.visits,
  totals.transactions,
  totals.transactionRevenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
WHERE
  channelGrouping in ('Organic Search', 'Direct')
ORDER BY transactionRevenue desc 
LIMIT
  100


-- let's look at youtube as a source and whether there are any transaction revenues (there shouldn't be)
SELECT
  date,
  channelGrouping AS channel,
  trafficSource.source,
  totals.visits,
  totals.transactions,
  totals.transactionRevenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
WHERE 
  trafficSource.source LIKE '%youtube%'

ORDER BY transactionRevenue desc 
LIMIT
  100


-- let's look at which channels have the most revenues in order on August 1st, 2017. 
SELECT
  date,
  channelGrouping AS channel,
  sum(totals.visits) visits, 
  sum(totals.transactions) transaction,
  sum(totals.transactionRevenue) revenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`

GROUP BY date, channel       
-- you need to use 'date', as every column must be aggregated or grouped 
ORDER BY transaction desc 
-- note that ORDER BY runs after SELECT, so you have to use the abbreviated name (transaction vs transactions)
LIMIT
  100



-- Make conversion rate (revenue per customer) and average order value (revenue per order)
SELECT
  PARSE_DATE('%Y%m%d', date) date,  
  -- format string 20170801 into 2017-08-01)
  channelGrouping AS channel,
  sum(totals.visits) visits, 
  CASE WHEN sum(totals.visits) > 0 
  THEN sum(totals.transactions)/ sum(totals.visits)
  ELSE 0 
  END as conversion_rate, 
  sum(totals.transactions) as transaction, 
  sum(totals.transactionRevenue) as revenue, 
  sum(totals.transactionRevenue)/ sum(totals.transactions) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY date, channel
ORDER BY transaction desc 
LIMIT
  100



-- modify date (20170801) into datetime format, as well as creating year and week columns
-- PARSE_DATE, EXTRACT, FORMAT_DATE

SELECT
  date,
  EXTRACT(DAY from date) as day_of_month,
  EXTRACT(WEEK from date) as week_of_year,
  FORMAT_DATE("%Y-%m", date) as date_modified
  -- this gives you month and year together 
FROM (
  SELECT 
  PARSE_DATE('%Y%m%d', date) date,  
  -- format string 20170801 into 2017-08-01) 
  channelGrouping, 
  totals.visits
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
  WHERE channelGrouping in ('Organic Search', 'Direct') 
  ORDER BY totals.visits desc
  LIMIT 100
  )




-- Unnesting (hits, totals, etc. are nests which contain nested rows)
-- we need to flatten the array to unnest the nests (record data type)  
-- to get access to certain informative columns
-- we can't normally do this due to type ARRAY being inaccesible \
-- we can flatten the array by using cross join 
-- unnest hits.page.pagePath, hits.isEntrance 

-- we have to unnest these as it's a 3rd level down (e.g totals.visits is 2 levels)
SELECT
  date,
  channelGrouping,
  isEntrance,
  page.pagePath,
  totals.transactions,
  totals.transactionRevenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
CROSS JOIN
  UNNEST(hits)



-- partition 
-- have to use PARTITION select statements separate from inner query
-- useful for looking at totals or averages or % over time 
-- 
SELECT 
  date, 
  channelGrouping,
  pageviews, 
  sum(pageviews) OVER (PARTITION BY date) total_pageviews,
  avg(pageviews) OVER (PARTITION BY date) avg_pageviews 
FROM 
  (
  SELECT date, channelGrouping, sum(totals.pageViews) as pageViews 
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
  GROUP BY channelGrouping, date
  )

-- compare last partition with this:  
-- last partition gave you flexibility to determine average number of views 
-- over not only channelGrouping, but also over each unique date. 
SELECT date, channelGrouping, sum(totals.pageviews), avg(totals.pageviews)
FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY date, channelGrouping

-- using safe divide over case statement and IFNULL to eliminate null output 
SELECT
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
   
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(sum(totals.transactionRevenue),0) as revenue, 
  IFNULL(sum(totals.transactionRevenue)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY date, channel
ORDER BY transaction desc 
LIMIT
  100


-- 
SELECT
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  device.browser,
  device.deviceCategory,
  device.operatingSystem,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(sum(totals.transactionRevenue),0) as revenue, 
  IFNULL(sum(totals.transactionRevenue)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY date, channel, device.browser, device.deviceCategory, device.operatingSystem
ORDER BY channel, revenue desc 


-- look at data from 2016 September to 2017 August 


-- query most popular channels in decreasing order 
SELECT
  count(*) as count,
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(sum(totals.transactionRevenue),0) as revenue, 
  IFNULL(sum(totals.transactionRevenue)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20160901`
GROUP BY channel
ORDER BY 1 desc 

-- query most popular device cateogry
SELECT
  count(*) as count,
--   device.browser,
   device.deviceCategory,
--   device.operatingSystem,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(sum(totals.transactionRevenue),0) as revenue, 
  IFNULL(sum(totals.transactionRevenue)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20160901`
GROUP BY device.deviceCategory
ORDER BY 1 desc 






-- use union to combine multiple datasets from different years 
SELECT
  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20160901`
GROUP BY channel,date


UNION ALL

SELECT
  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20161001`
GROUP BY channel,date

UNION ALL 
SELECT
  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20161101`
GROUP BY channel,date

UNION ALL 
SELECT
  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20161201`
GROUP BY channel,date

UNION ALL 
SELECT
  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170101`
GROUP BY channel,date

UNION ALL 
SELECT
  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170201`
GROUP BY channel,date

UNION ALL 
SELECT
  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170301`
GROUP BY channel,date

UNION ALL 
SELECT
  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170401`
GROUP BY channel,date
UNION ALL 
SELECT

  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170501`
GROUP BY channel,date

UNION ALL 
SELECT
  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170601`
GROUP BY channel,date

UNION ALL 
SELECT
  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170701`
GROUP BY channel,date

UNION ALL 
SELECT
  count(*) as count,
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  IFNULL(SAFE_DIVIDE(sum(totals.transactions),sum(totals.visits)),0) conversion_rate, 
  IFNULL(sum(totals.transactions),0) as transaction, 
  IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0) as revenue, 
  IFNULL(IFNULL(SAFE_DIVIDE(sum(totals.transactionRevenue),1000000),0)/ sum(totals.transactions),0) as aov
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY channel,date

ORDER BY 2,1 desc 



-- find how long visitor stayed and # of sessions \
-- totals.timeOnScreen = the total time on screen in seconds (not in sample)
-- totals.timeOnSite = total time of the session expressed in seconds 
-- visitNumber = the session number for the user (vs pageviews, which expresses number of pages
-- viewed per session on the website)
-- geoNetwork.latitude, geoNetwork.longitude, geoNetwork.networkLocation 
SELECT
  PARSE_DATE('%Y%m%d', date) date,  
  channelGrouping AS channel,
  sum(totals.visits) visits,
  sum(totals.pageViews) pageviews,
  totals.timeOnScreen, 
  totals.timeOnSite, 
  visitNumber
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY channel, date, visitNumber

ORDER BY  2, 4 desc 

