--Write your MySQL query statement below
WITH RECURSIVE hierarchy AS (
    SELECT employee_id, employee_name, manager_id, salary, 1 
    AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id, e.salary, h.level + 1
    FROM Employees e
    JOIN hierarchy h ON e.manager_id = h.employee_id
),

report_tree AS (
    SELECT manager_id AS manager, employee_id AS employee
    FROM Employees
    WHERE manager_id IS NOT NULL

    UNION ALL

    SELECT r.manager, e.employee_id
    FROM report_tree r
    JOIN Employees e ON e.manager_id = r.employee
),

team_info AS (
    SELECT 
        e.employee_id,
        COUNT(r.employee) AS team_size,
        COALESCE(SUM(emp.salary), 0) AS reports_salary
    FROM Employees e
    LEFT JOIN report_tree r ON e.employee_id = r.manager
    LEFT JOIN Employees emp ON r.employee = emp.employee_id
    GROUP BY e.employee_id
)

SELECT h.employee_id, h.employee_name, h.level, t.team_size, h.salary + t.reports_salary 
AS budget
FROM hierarchy h
JOIN team_info t ON h.employee_id = t.employee_id
ORDER BY h.level, budget DESC, h.employee_name;
