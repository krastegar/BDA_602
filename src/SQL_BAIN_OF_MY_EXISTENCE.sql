USE baseball; 

SHOW TABLES;


-- Making My Master Table
DROP TABLE IF EXISTS Master; 
CREATE TABLE Master
SELECT bc.game_id, batter, atBat, Hit, team_id, local_date
FROM batter_counts bc 
JOIN game g 
ON bc.game_id = g.game_id; 
-- Index for Master Table for faster query
ALTER TABLE Master
ADD ID INT NOT NULL AUTO_INCREMENT, 
ADD CONSTRAINT PRIMARY KEY(ID); 

-- Historic AVG
DROP TABLE IF EXISTS Hist_Avg;
CREATE TABLE Hist_Avg
SELECT batter, SUM(Hit)/NULLIF (SUM(atBat),0) as Batting_Avg
FROM Maste
GROUP BY batter; 

-- Annual Avg
DROP TABLE IF EXISTS Annual_Avg;
CREATE TABLE Hist_Avg
SELECT batter, SUM(Hit)/NULLIF (SUM(atBat),0) as Batting_Avg,
YEAR (local_date) as year
FROM Master
GROUP BY batter, year; 

-- Beginning of Rolling AVG

-- Rolling Average
/*DROP TABLE IF EXISTS Rolling_Avg;
CREATE TABLE Rolling_Avg
SELECT
       a.local_date,
       a.atBat,
       a.Hit,
       a.batter,
       Round( ( SELECT SUM(b.Hit)/NULLIF (SUM(b.atBat),0)
                FROM Master AS b
                WHERE DATEDIFF(a.local_date, b.local_date) BETWEEN 0 AND 99
              ), 2 ) AS '100dayMovingAvg'
     FROM Master AS a
     GROUP BY batter
     ORDER BY a.local_date DESC;

*/

-- Intermediate Temp table 
DROP TEMPORARY TABLE IF EXISTS temp; 
CREATE TEMPORARY TABLE temp
SELECT bc.game_id, batter, atBat, Hit, team_id, local_date,
STR_TO_DATE(g.local_date , "%Y-%m-%d %H:%i:%s")
FROM batter_counts bc 
JOIN game g 
ON bc.game_id = g.game_id; 

-- Self Join my final rol_avg
CREATE TABLE Rol_AVG
SELECT t.atBat, t.Hit, t.batter,
SUM(t.Hit)/NULLIF (SUM(t.atBat),0) as average,
STR_TO_DATE(t.local_date , "%Y-%m-%d %H:%i:%s")
from temp as t 
join temp as rolling_avg
on t.local_date
BETWEEN DATE_ADD(t.local_date, INTERVAL -99 DAY) and t.local_date  
GROUP BY rolling_avg.batter
ORDER BY rolling_avg.local_date DESC;


