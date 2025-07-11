-- Write your MySQL query statement below
SELECT 
    p.product_id,
    ROUND(
        COALESCE(SUM(us.units * p.price), 0) * 1.0 /
        COALESCE(SUM(us.units), 1), 
    2) AS average_price
FROM Prices p
LEFT JOIN UnitsSold us
    ON p.product_id = us.product_id
    AND us.purchase_date BETWEEN p.start_date AND p.end_date
GROUP BY p.product_id;
