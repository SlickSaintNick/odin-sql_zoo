-- url: https://sqlzoo.net/wiki/SELECT_within_SELECT_Tutorial

-- 1 Bigger than Russia
SELECT name
  FROM world
 WHERE population > (SELECT population 
                       FROM world
                      WHERE name='Russia'
                    );

-- 2 Richer than UK
SELECT name 
  FROM world
 WHERE continent = 'Europe'
   AND gdp/population > (SELECT gdp/population 
                           FROM world
                          WHERE name = 'United Kingdom'
                        );

-- 3 Neighbours of Argentina and Australia
SELECT name, continent 
  FROM world 
 WHERE continent IN (SELECT continent 
                       FROM world
                      WHERE name IN ('Argentina', 'Australia')
                    )
ORDER BY name;

-- 4 Between Canada and Poland
SELECT name, population 
  FROM world 
 WHERE population > (SELECT population 
                       FROM world 
                      WHERE name = 'United Kingdom'
                    ) 
   AND population < (SELECT population 
                       FROM world
                      WHERE name = 'Germany'
                    );

-- 5 Percentages of Germany
SELECT name, 
        CONCAT
            (ROUND
                (population / (SELECT population 
                                FROM world 
                               WHERE name = 'Germany'
                              ) * 100
                ),
            '%'
            ) 
  FROM world 
 WHERE continent = 'Europe';

-- 6 Bigger than every country in Europe
SELECT name
  FROM world
 WHERE continent <> 'Europe'
   AND gdp >= ALL(SELECT gdp
                    FROM world
                   WHERE gdp > 0
                     AND continent = 'Europe'
                 );

-- 7 Largest in each continent
SELECT continent, name, area 
  FROM world x
  WHERE area >= ALL(SELECT area
                      FROM world y
                     WHERE y.continent = x.continent
                       AND area > 0
                   );

-- 8 First country of each continent (alphabetically)
SELECT continent, name 
  FROM world x
 WHERE name <= ALL(SELECT name 
                     FROM world y
                    WHERE y.continent = x.continent
                  );

-- 9 Difficult Questions That Utilize Techniques Not Covered In Prior Sections
SELECT name, continent, population 
  FROM world 
 WHERE continent = (SELECT continent
                      FROM world x 
                     WHERE 25000000 > ALL(SELECT population 
                                            FROM world y
                                           WHERE y.continent = x.continent
                                         )
                   );

-- 10 Three time bigger
SELECT name, continent 
  FROM world x
 WHERE population >= ALL(SELECT population * 3 
                           FROM world y 
                          WHERE y.continent = x.continent 
                            AND y.name <> x.name
                        );