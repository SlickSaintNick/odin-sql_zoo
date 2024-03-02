-- url: https://sqlzoo.net/wiki/Self_join

-- 1 How many stops are in the database.
SELECT COUNT(*) 
  FROM stops;

-- 2 Find the id value for the stop 'Craiglockhart'
SELECT id 
  FROM stops 
 WHERE name = 'Craiglockhart';


-- 3 Give the id and the name for the stops on the '4' 'LRT' service.
SELECT id, name
  FROM stops JOIN route ON id = stop
 WHERE num = 4 AND company = 'LRT'
 ORDER BY pos;


-- 4 The query shown gives the number of routes that visit either London Road (149) or Craiglockhart (53). Run the query and notice the two services that link these stops have a count of 2. Add a HAVING clause to restrict the output to these two routes.
SELECT company, num, COUNT(*)
  FROM route 
 WHERE stop=149 
       OR stop=53
 GROUP BY company, num
HAVING COUNT(*) = 2

-- 5 Execute the self join shown and observe that b.stop gives all the places you can get to from Craiglockhart, without changing routes. Change the query so that it shows the services from Craiglockhart to London Road.
SELECT a.company, a.num, a.stop, b.stop
  FROM route a JOIN route b ON (a.company=b.company AND a.num=b.num)
 WHERE a.stop=53 AND b.stop = 149

-- 6 The query shown is similar to the previous one, however by joining two copies of the stops table we can refer to stops by name rather than by number. Change the query so that the services between 'Craiglockhart' and 'London Road' are shown. If you are tired of these places try 'Fairmilehead' against 'Tollcross'
SELECT a.company, a.num, stopa.name, stopb.name
  FROM route a 
       JOIN route b     ON (a.company = b.company AND a.num = b.num)
       JOIN stops stopa ON (a.stop    = stopa.id)
       JOIN stops stopb ON (b.stop    = stopb.id)
 WHERE stopa.name = 'Craiglockhart' 
       AND stopb.name = 'London Road';

-- 7 Give a list of all the services which connect stops 115 and 137 ('Haymarket' and 'Leith')
SELECT DISTINCT a.company, a.num
  FROM route a 
       JOIN route b     ON (a.company = b.company AND a.num = b.num)
       JOIN stops stopa ON (a.stop    = stopa.id)
       JOIN stops stopb ON (b.stop    = stopb.id)
 WHERE stopa.name = 'Haymarket' 
       AND stopb.name = 'Leith';

-- 8 Give a list of the services which connect the stops 'Craiglockhart' and 'Tollcross'
SELECT DISTINCT a.company, a.num
  FROM route a 
       JOIN route b     ON (a.company = b.company AND a.num = b.num)
       JOIN stops stopa ON (a.stop    = stopa.id)
       JOIN stops stopb ON (b.stop    = stopb.id)
 WHERE stopa.name = 'Craiglockhart' 
       AND stopb.name = 'Tollcross';

-- 9 Give a distinct list of the stops which may be reached from 'Craiglockhart' by taking one bus, including 'Craiglockhart' itself, offered by the LRT company. Include the company and bus no. of the relevant services.
SELECT DISTINCT stopb.name, a.company, a.num
  FROM route a 
       JOIN route b     ON (a.company = b.company AND a.num = b.num)
       JOIN stops stopa ON (a.stop    = stopa.id)
       JOIN stops stopb ON (b.stop    = stopb.id)
 WHERE stopa.name = 'Craiglockhart' 
       AND a.company = 'LRT';

-- 10 Find the routes involving two buses that can go from Craiglockhart to Lochend.
SELECT r1.num, r1.company, s1.name, r4.num, r4.company
  FROM route r1
  JOIN route r2 ON r1.num  = r2.num  AND r1.company = r2.company
       AND r1.stop = (SELECT id FROM stops WHERE name = 'Craiglockhart')
  JOIN stops s1 ON r2.stop = s1.id
  JOIN route r3 ON s1.id   = r3.stop
  JOIN route r4 ON r3.num  = r4.num  AND r3.company = r4.company
       AND r4.stop = (SELECT id FROM stops WHERE name = 'Lochend')
 ORDER BY r1.num, s1.name, r4.num;

/* Explanation of self joins to follow path beginning to end */
/* I find this is the best way to construct as it makes the path
relatively clear */
SELECT r1.num, r1.company, s1.name, r4.num, r4.company
 /* Start with the original route table */
 FROM route r1
 
 /* To find all the destination stops from Craiglockhart,
 join a copy of the table, so that each row has matching 
 route number and company and the stop is Craiglockhart.
 We get a table showing everywhere we can get to from Craiglockhart.*/
 JOIN route r2 ON r1.num  = r2.num  
              AND r1.company = r2.company
              AND r1.stop = (SELECT id FROM stops WHERE name = 'Craiglockhart')
              
 /* Now we join the stops table on to the right hand side
 i.e. all the destination stops we currently have.
 This will become our list of transfer stops.*/
 JOIN stops s1 ON r2.stop = s1.id
 
 /* We have a list of routes from Craiglockhart to every possible
 stop. Now, we want to match our transfer stop on each row to each of its possible
 destinations (very similar to the first step).*/
 JOIN route r3 ON s1.id   = r3.stop
 
 /* Finally we join another copy of the route table to find where the
 destination is Lochend. */
 JOIN route r4 ON r3.num  = r4.num  
              AND r3.company = r4.company
              AND r4.stop = (SELECT id FROM stops WHERE name = 'Lochend')
              
ORDER BY r1.num, s1.name, r4.num;
