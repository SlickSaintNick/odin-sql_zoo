-- url: https://sqlzoo.net/wiki/Window_LAG

-- 1 Modify the query to show data from Spain
SELECT name, DAY(whn), confirmed, deaths, recovered
  FROM covid
 WHERE name = 'Spain'
       AND MONTH(whn) = 3 AND YEAR(whn) = 2020
 ORDER BY whn;

-- 2 Modify the query to show confirmed for the day before.
SELECT name, 
         DAY(whn),
         confirmed,
         LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
  FROM covid
 WHERE name = 'Italy'
       AND MONTH(whn) = 3 AND YEAR(whn) = 2020
 ORDER BY whn;

 -- 3 Show the number of new cases for each day, for Italy, for March.
SELECT name, 
        DAY(whn), 
        confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS new
  FROM covid
 WHERE name = 'Italy'
       AND MONTH(whn) = 3 AND YEAR(whn) = 2020
 ORDER BY whn;

-- 4 Show the number of new cases in Italy for each week in 2020 - show Monday only.
SELECT name, 
        DATE_FORMAT(whn,'%Y-%m-%d'), 
        confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS new
  FROM covid
 WHERE name = 'Italy'
       AND WEEKDAY(whn) = 0 AND YEAR(whn) = 2020
 ORDER BY whn;

 -- 5 Show the number of new cases in Italy for each week - show Monday only.
SELECT tw.name, 
        DATE_FORMAT(tw.whn,'%Y-%m-%d'), 
        tw.confirmed - lw.confirmed AS new
  FROM covid tw LEFT JOIN covid lw 
       ON DATE_ADD(lw.whn, INTERVAL 1 WEEK) = tw.whn
          AND tw.name=lw.name
 WHERE tw.name = 'Italy'
       AND WEEKDAY(tw.whn) = 0 
 ORDER BY tw.whn;

-- 6 Add a column to show the ranking for the number of deaths due to COVID.
SELECT name,
        confirmed,
        RANK() OVER (ORDER BY confirmed DESC) rc,
        deaths,
        RANK() OVER (ORDER BY deaths DESC) rd
  FROM covid
 WHERE whn = '2020-04-20'
 ORDER BY confirmed DESC;

-- 7 Show the infection rate ranking for each country. Only include countries with a population of at least 10 million.
SELECT world.name,
        ROUND(100000*confirmed/population,2),
        RANK() OVER (ORDER BY ROUND(100000*confirmed/population, 4)) rank
  FROM covid JOIN world ON covid.name=world.name
 WHERE whn = '2020-04-20' AND population > 10000000
 ORDER BY population DESC;

-- 8 For each country that has had at last 1000 new cases in a single day, show the date of the peak number of new cases.
-- Unable to solve this one on my own - drawing on solution at 
-- https://stackoverflow.com/questions/62799387/sql-zoo-window-lag-8
/* Here we create a table which lists every day's increase for every country (CTE1)
    e.g. (not real data)
    |Italy | 2020-05-06 | 1000|
    |Italy | 2020-05-07 | 1050|
    |Italy | 2020-05-08 | 998 |
    Then we select only the maximum increases (as numbers) into a new table, limiting to 
    when 1000 or greater (CTE2)
    |Italy | 1050|
    Then we join those two tables on the name and the increase, to extract the 
    date of the max increase
    |Italy | 2020-05-07 | 1050|
*/
  WITH CTE1 as
       (SELECT name, 
                DATE_FORMAT(whn, "%Y-%m-%d") as date,
                confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY DATE(whn)) as increase
          FROM covid
         ORDER BY whn),
       CTE2 AS
       (SELECT name, MAX(increase) as max_increase
          FROM CTE1
         WHERE increase > 999
         GROUP BY name
         ORDER BY date)
SELECT c1.name, c1.date, c2.max_increase as peakNewCases
  FROM CTE1 as c1 
       JOIN CTE2 as c2 ON c1.name     = c2.name 
                      AND c1.increase = c2.max_increase;
-- And for me, SQLZoo refused to evaluate this query although it looks correct,
-- with persistent 'Error: Lost connection to MySQL server during query'.