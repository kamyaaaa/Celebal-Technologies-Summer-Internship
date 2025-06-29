--Write your MySQL query statement below
SELECT ip,
    COUNT(*) AS invalid_count
FROM logs
WHERE 
    (
        LENGTH(ip) - LENGTH(REPLACE(ip, '.', '')) + 1 != 4
        OR REGEXP_LIKE(ip, '\\b0[0-9]+\\b')
        OR EXISTS (
            SELECT 1 FROM (
                SELECT 
                    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 1), '.', -1) AS UNSIGNED) AS part1,
                    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 2), '.', -1) AS UNSIGNED) AS part2,
                    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 3), '.', -1) AS UNSIGNED) AS part3,
                    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 4), '.', -1) AS UNSIGNED) AS part4
                ) AS parts
            WHERE part1 > 255 OR part2 > 255 OR part3 > 255 OR part4 > 255
        )
    )
GROUP BY ip
ORDER BY invalid_count DESC, ip DESC;
