SELECT s1.name, r1.num, r1.company, r2.stop FROM 
       stops s1
  JOIN route r1 ON s1.id  = r1.stop AND s1.name    = 'Craiglockhart'
  JOIN route r2 ON r1.num = r2.num  AND r1.company = r2.company
 ORDER BY r1.num, r1.pos;
 
 SELECT r1.stop, r1.num, .r1.company, s1.name FROM 
       route r1
  JOIN route r2 ON r1.num  = r2.num AND r1.company = r2.company
  JOIN stops s1 ON r2.stop = s1.id  AND s1.name    = 'Lochend'
 ORDER BY r1.num, r1.pos;
 
 
 SELECT r1.num, r1.company, s1.name, r4.num, r4.company
  /* Start with the original route table */
  FROM route r1
  
  /* To find all the destination stops from Craiglockhart,
  join a copy of the table, so that each row has matching 
  route number and company and the stop is Craiglockhart.
  We get a table showing everywhere we can get to from Craiglockhart./*
  JOIN route r2 ON r1.num  = r2.num  
               AND r1.company = r2.company
               AND r1.stop = (SELECT id FROM stops WHERE name = 'Craiglockhart')
               
  /* Now we join the stops table on to the right hand side
  i.e. all the destination stops we currently have.
  This will become our list of transfer stops./*
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
