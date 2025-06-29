-- Write your MySQL query statement below
WITH ValidVisits AS (
  SELECT * FROM Stadium
  WHERE people >= 100
),
Streaks AS (
  SELECT *, id - ROW_NUMBER() OVER (ORDER BY id) AS grp
  FROM ValidVisits
),
StreakGroups AS (
  SELECT grp
  FROM Streaks
  GROUP BY grp
  HAVING COUNT(*) >= 3
)
SELECT s.id, s.visit_date, s.people
FROM Streaks s
JOIN StreakGroups g ON s.grp = g.grp
ORDER BY s.visit_date;
