--Write your MySQL query statement below
WITH trial_stats AS (
    SELECT 
        user_id,
        ROUND(AVG(activity_duration), 2) AS trial_avg_duration
    FROM UserActivity
    WHERE activity_type = 'free_trial'
    GROUP BY user_id
),
paid_stats AS (
    SELECT 
        user_id,
        ROUND(AVG(activity_duration), 2) AS paid_avg_duration
    FROM UserActivity
    WHERE activity_type = 'paid'
    GROUP BY user_id
)
SELECT 
    p.user_id,
    t.trial_avg_duration,
    p.paid_avg_duration
FROM paid_stats p
JOIN trial_stats t ON p.user_id = t.user_id
ORDER BY p.user_id;
