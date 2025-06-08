USE AdventureWorks2022;
GO

-- TASK 1: To output the start and end dates of project
DROP TABLE IF EXISTS dbo.Projects;
GO

CREATE TABLE dbo.Projects (
    Task_ID INT PRIMARY KEY,
    Start_Date DATE,
    End_Date DATE
);
GO

INSERT INTO dbo.Projects (Task_ID, Start_Date, End_Date)
VALUES
(1, '2015-10-01', '2015-10-02'),
(2, '2015-10-02', '2015-10-03'),
(3, '2015-10-03', '2015-10-04'),
(4, '2015-10-13', '2015-10-14'),
(5, '2015-10-14', '2015-10-15'),
(6, '2015-10-28', '2015-10-29'),
(7, '2015-10-30', '2015-10-31');
GO

WITH ProjectChains AS (
    SELECT *, DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY Start_Date), Start_Date) AS grp
    FROM dbo.Projects
)
SELECT 
    MIN(Start_Date) AS Project_Start,
    MAX(End_Date) AS Project_End
FROM ProjectChains
GROUP BY grp
ORDER BY 
    DATEDIFF(DAY, MIN(Start_Date), MAX(End_Date)) ASC,
    MIN(Start_Date) ASC;
GO

-- TASK 2: Students Whose Best Friend Has Higher Salary

DROP TABLE IF EXISTS dbo.Students;
GO

CREATE TABLE dbo.Students (
    ID INT PRIMARY KEY,
    Name NVARCHAR(100)
);

DROP TABLE IF EXISTS dbo.Friends;
GO

CREATE TABLE dbo.Friends (
    ID INT PRIMARY KEY,
    Friend_ID INT
);

DROP TABLE IF EXISTS dbo.Packages;
GO

CREATE TABLE dbo.Packages (
    ID INT PRIMARY KEY,
    Salary FLOAT
);
GO

INSERT INTO dbo.Students (ID, Name) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO dbo.Friends (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

INSERT INTO dbo.Packages (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);
GO

SELECT 
    S.Name
FROM dbo.Students S
JOIN dbo.Friends F ON S.ID = F.ID
JOIN dbo.Packages SP ON S.ID = SP.ID
JOIN dbo.Packages FP ON F.Friend_ID = FP.ID
WHERE FP.Salary > SP.Salary
ORDER BY FP.Salary;
GO

--Task 3: To output all pairs in ascending order b the value of X
DROP TABLE IF EXISTS dbo.Functions;
GO

CREATE TABLE dbo.Functions (
    X INT,
    Y INT
);
GO

INSERT INTO dbo.Functions (X, Y)
VALUES 
(20, 20),
(20, 20),
(20, 21),
(23, 22),
(22, 23),
(21, 20);
GO

SELECT DISTINCT f1.X, f1.Y
FROM dbo.Functions f1
JOIN dbo.Functions f2
    ON f1.X = f2.Y AND f1.Y = f2.X
WHERE f1.X <= f1.Y 
ORDER BY f1.X;
GO

--Task 4: Printing queries
DROP TABLE IF EXISTS Contests;
DROP TABLE IF EXISTS Colleges;
DROP TABLE IF EXISTS Challenges;
DROP TABLE IF EXISTS View_Stats;
DROP TABLE IF EXISTS Submission_Stats;
GO

CREATE TABLE Contests (
    contest_id INT PRIMARY KEY,
    hacker_id INT,
    name NVARCHAR(100)
);

CREATE TABLE Colleges (
    college_id INT PRIMARY KEY,
    contest_id INT
);

CREATE TABLE Challenges (
    challenge_id INT PRIMARY KEY,
    college_id INT
);

CREATE TABLE View_Stats (
    challenge_id INT,
    total_views INT,
    total_unique_views INT
);

CREATE TABLE Submission_Stats (
    challenge_id INT,
    total_submissions INT,
    total_accepted_submissions INT
);
GO

INSERT INTO Contests (contest_id, hacker_id, name)
VALUES
(66406, 17973, 'Rose'),
(66556, 79153, 'Angela'),
(94828, 80275, 'Frank');

INSERT INTO Colleges (college_id, contest_id)
VALUES
(11219, 66406),
(32473, 66556),
(56685, 94828);

INSERT INTO Challenges (challenge_id, college_id)
VALUES
(18765, 11219),
(47127, 11219),
(60292, 32473),
(72974, 56685);

INSERT INTO View_Stats (challenge_id, total_views, total_unique_views)
VALUES
(47127, 26, 19),
(47127, 15, 14),
(18765, 43, 10),
(18765, 72, 13),
(75516, 35, 17),
(60292, 11, 10),
(72974, 41, 15),
(75516, 75, 11);

INSERT INTO Submission_Stats (challenge_id, total_submissions, total_accepted_submissions)
VALUES
(75516, 34, 12),
(47127, 27, 10),
(47127, 56, 18),
(75516, 74, 12),
(75516, 83, 8),
(72974, 68, 24),
(72974, 82, 14),
(47127, 28, 11);
GO

SELECT c.contest_id, c.hacker_id, c.name,
    ISNULL(SUM(ss.total_submissions), 0) AS total_submissions,
    ISNULL(SUM(ss.total_accepted_submissions), 0) AS total_accepted_submissions,
    ISNULL(SUM(vs.total_views), 0) AS total_views,
    ISNULL(SUM(vs.total_unique_views), 0) AS total_unique_views
FROM Contests c
JOIN Colleges col ON c.contest_id = col.contest_id
JOIN Challenges ch ON col.college_id = ch.college_id
LEFT JOIN Submission_Stats ss ON ch.challenge_id = ss.challenge_id
LEFT JOIN View_Stats vs ON ch.challenge_id = vs.challenge_id
GROUP BY c.contest_id, c.hacker_id, c.name
HAVING 
    ISNULL(SUM(ss.total_submissions), 0) +
    ISNULL(SUM(ss.total_accepted_submissions), 0) +
    ISNULL(SUM(vs.total_views), 0) +
    ISNULL(SUM(vs.total_unique_views), 0) > 0
ORDER BY c.contest_id;

-- Task 5: Queries for total number of hackers who made submission at least a day and id to find who made maximum submissions each day
DROP TABLE IF EXISTS Hackers;
DROP TABLE IF EXISTS Submissions;
GO

CREATE TABLE Hackers (
    hacker_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE Submissions (
    submission_id INT PRIMARY KEY,
    hacker_id INT,
    submission_date DATE,
    score INT
);
GO

INSERT INTO Hackers (hacker_id, name) VALUES
(20703, 'Rose'),
(30416, 'Angela'),
(22789, 'Frank'),
(85723, 'Louis');

INSERT INTO Submissions (submission_id, hacker_id, submission_date, score) VALUES
(1, 20703, '2016-03-01', 70),
(2, 20703, '2016-03-01', 80),
(3, 30416, '2016-03-01', 90),
(4, 20703, '2016-03-02', 60),
(5, 30416, '2016-03-02', 50),
(6, 30416, '2016-03-02', 60),
(7, 22789, '2016-03-02', 70),
(8, 85723, '2016-03-03', 100),
(9, 85723, '2016-03-03', 95),
(10, 30416, '2016-03-03', 85);

WITH daily_counts AS (
    SELECT submission_date, hacker_id, COUNT(*) AS submission_count
    FROM Submissions
    WHERE submission_date BETWEEN '2016-03-01' AND '2016-03-06'
    GROUP BY submission_date, hacker_id
),
max_subs_per_day AS (
    SELECT
        submission_date,
        MAX(submission_count) AS max_count
    FROM daily_counts
    GROUP BY submission_date
),
top_hackers_per_day AS (
    SELECT dc.submission_date, dc.hacker_id, dc.submission_count
    FROM daily_counts dc
    JOIN max_subs_per_day ms
      ON dc.submission_date = ms.submission_date
     AND dc.submission_count = ms.max_count
),
final_hacker_selection AS (
    SELECT th.submission_date, th.hacker_id, h.name
    FROM top_hackers_per_day th
    JOIN Hackers h
      ON th.hacker_id = h.hacker_id
    WHERE th.hacker_id = (
        SELECT MIN(hacker_id)
        FROM top_hackers_per_day
        WHERE submission_date = th.submission_date
    )
),
unique_hackers_count AS (
    SELECT submission_date, COUNT(DISTINCT hacker_id) AS unique_hackers
    FROM Submissions
    WHERE submission_date BETWEEN '2016-03-01' AND '2016-03-06'
    GROUP BY submission_date
)
SELECT fhs.submission_date, uhc.unique_hackers, fhs.hacker_id, fhs.name
FROM final_hacker_selection fhs
JOIN unique_hackers_count uhc
  ON fhs.submission_date = uhc.submission_date
ORDER BY fhs.submission_date;

--Task 6: Find Manhattan distance 
DROP TABLE IF EXISTS STATION;
GO

CREATE TABLE STATION (
    ID INT,
    CITY VARCHAR(21),
    STATE VARCHAR(2),
    LAT_N DECIMAL(10, 6),
    LONG_W DECIMAL(10, 6)
);
GO

INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W)
VALUES
(1, 'New York', 'NY', 40.712776, 74.005974),
(2, 'Los Angeles', 'CA', 34.052235, 118.243683),
(3, 'Chicago', 'IL', 41.878113, 87.629799),
(4, 'Houston', 'TX', 29.760427, 95.369804),
(5, 'Miami', 'FL', 25.761681, 80.191788);
GO

SELECT ROUND(ABS(MAX(LAT_N) - MIN(LAT_N)) + ABS(MAX(LONG_W) - MIN(LONG_W)), 4 ) AS Manhattan_Distance
FROM STATION;

--Task 7: Prime numbers seperated by &
WITH numbers AS (
    SELECT 2 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n + 1 <= 1000
),
primes AS (
    SELECT n
    FROM numbers num
    WHERE NOT EXISTS (
        SELECT 1
        FROM numbers div
        WHERE div.n > 1 AND div.n < num.n AND num.n % div.n = 0
    )
)
SELECT STRING_AGG(n, '&') AS prime_list
FROM primes
OPTION (MAXRECURSION 1000);

--Task 8: Sort names alphabetically
DROP TABLE IF EXISTS OCCUPATIONS;
GO

CREATE TABLE OCCUPATIONS (
    Name VARCHAR(50),
    Occupation VARCHAR(20)
);
GO

INSERT INTO OCCUPATIONS (Name, Occupation) VALUES
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Professor'),
('Meera', 'Singer'),
('Ashley', 'Professor'),
('Ketty', 'Singer'),
('Christeen', 'Singer'),
('Jane', 'Actor'),
('Jenny', 'Doctor');
GO

WITH Ranked AS (
    SELECT 
        Name,
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS rn
    FROM OCCUPATIONS
)
SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM Ranked
GROUP BY rn
ORDER BY rn;

--Task 9: Find node type of binary tree ordered by the value of node
DROP TABLE IF EXISTS BST;
GO

CREATE TABLE BST (
    N INT,
    P INT
);
GO

INSERT INTO BST (N, P) VALUES
(1, 2),
(3, 2),
(6, 8),
(9, 8),
(2, 5),
(8, 5),
(5, NULL);
GO

SELECT N, CASE
        WHEN P IS NULL THEN 'Root'
        WHEN N NOT IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL) THEN 'Leaf'
        ELSE 'Inner'
    END AS NodeType
FROM BST
ORDER BY N;

--Task 10: Printing queries for Amber's conglomerate corporation
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Manager;
DROP TABLE IF EXISTS Senior_Manager;
DROP TABLE IF EXISTS Lead_Manager;
DROP TABLE IF EXISTS Company;
GO

CREATE TABLE Company (
    company_code VARCHAR(10) PRIMARY KEY,
    founder VARCHAR(100)
);

CREATE TABLE Lead_Manager (
    lead_manager_code VARCHAR(10) PRIMARY KEY,
    company_code VARCHAR(10)
);

CREATE TABLE Senior_Manager (
    senior_manager_code VARCHAR(10) PRIMARY KEY,
    company_code VARCHAR(10)
);

CREATE TABLE Manager (
    manager_code VARCHAR(10) PRIMARY KEY,
    company_code VARCHAR(10)
);

CREATE TABLE Employee (
    employee_code VARCHAR(10) PRIMARY KEY,
    company_code VARCHAR(10)
);
GO

INSERT INTO Company (company_code, founder) VALUES
('C1', 'Monika'),
('C2', 'Samantha');

INSERT INTO Lead_Manager (lead_manager_code, company_code) VALUES
('LM1', 'C1'),
('LM2', 'C1'),
('LM3', 'C2');

INSERT INTO Senior_Manager (senior_manager_code, company_code) VALUES
('SM1', 'C1'),
('SM2', 'C2');

INSERT INTO Manager (manager_code, company_code) VALUES
('M1', 'C1'),
('M2', 'C1'),
('M3', 'C2');

INSERT INTO Employee (employee_code, company_code) VALUES
('E1', 'C1'),
('E2', 'C1'),
('E3', 'C1'),
('E4', 'C2');

SELECT 
    c.company_code,
    c.founder,
    ISNULL(lm.lead_manager_count, 0) AS lead_manager_count,
    ISNULL(sm.senior_manager_count, 0) AS senior_manager_count,
    ISNULL(m.manager_count, 0) AS manager_count,
    ISNULL(e.employee_count, 0) AS employee_count
FROM Company c
LEFT JOIN (
    SELECT company_code, COUNT(DISTINCT lead_manager_code) AS lead_manager_count
    FROM Lead_Manager
    GROUP BY company_code
) lm ON c.company_code = lm.company_code
LEFT JOIN (
    SELECT company_code, COUNT(DISTINCT senior_manager_code) AS senior_manager_count
    FROM Senior_Manager
    GROUP BY company_code
) sm ON c.company_code = sm.company_code
LEFT JOIN (
    SELECT company_code, COUNT(DISTINCT manager_code) AS manager_count
    FROM Manager
    GROUP BY company_code
) m ON c.company_code = m.company_code
LEFT JOIN (
    SELECT company_code, COUNT(DISTINCT employee_code) AS employee_count
    FROM Employee
    GROUP BY company_code
) e ON c.company_code = e.company_code
ORDER BY c.company_code;

--Task 11: Nmae of students whose best friends are hired with higher salaries than them
DROP TABLE IF EXISTS Students_11;
DROP TABLE IF EXISTS Friends_11;
DROP TABLE IF EXISTS Packages;
GO

CREATE TABLE Students_11 (
    ID INTEGER PRIMARY KEY,
    Name VARCHAR(50)
);

CREATE TABLE Friends_11 (
    ID INTEGER,
    Friend_ID INTEGER
);

CREATE TABLE Packages (
    ID INTEGER PRIMARY KEY,
    Salary FLOAT
);

INSERT INTO Students_11 (ID, Name) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO Friends_11 (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

INSERT INTO Packages (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

SELECT s.Name
FROM Students_11 s
JOIN Friends_11 f ON s.ID = f.ID
JOIN Packages p1 ON s.ID = p1.ID            
JOIN Packages p2 ON f.Friend_ID = p2.ID     
WHERE p2.Salary > p1.Salary
ORDER BY p2.Salary;

--Task 12: Ratio of cost of job family by percentage
DROP TABLE IF EXISTS JobCosts;
GO

CREATE TABLE JobCosts (
    JobFamily VARCHAR(50),
    Location VARCHAR(50),
    Cost DECIMAL(10, 2)
);

INSERT INTO JobCosts (JobFamily, Location, Cost) VALUES
('Engineering', 'India', 100000),
('Engineering', 'International', 50000),
('HR', 'India', 30000),
('HR', 'International', 20000),
('Finance', 'India', 25000),
('Finance', 'International', 30000);

SELECT JobFamily, Location,
    ROUND(100.0 * Cost / SUM(Cost) OVER (PARTITION BY JobFamily), 2) AS CostPercentage
FROM JobCosts
ORDER BY JobFamily, Location;

--Task 13: Ratio of cost and revenue of a BU month on month
DROP TABLE IF EXISTS BU_Financials;
GO

CREATE TABLE BU_Financials (
    BU_Name VARCHAR(50),
    Month DATE,  
    Cost DECIMAL(12, 2),
    Revenue DECIMAL(12, 2)
);

INSERT INTO BU_Financials (BU_Name, Month, Cost, Revenue) VALUES
('Tech', '2025-01-01', 100000, 250000),
('Tech', '2025-02-01', 120000, 260000),
('HR', '2025-01-01', 50000, 80000),
('HR', '2025-02-01', 60000, 85000),
('Finance', '2025-01-01', 30000, 70000),
('Finance', '2025-02-01', 35000, 75000);

SELECT 
    BU_Name,
    FORMAT(Month, 'yyyy-MM') AS Month,
    Cost,
    Revenue,
    ROUND(CASE 
        WHEN Revenue = 0 THEN NULL 
        ELSE Cost / Revenue 
    END, 2) AS Cost_Revenue_Ratio
FROM BU_Financials
ORDER BY BU_Name, Month;

--Task 14: Headcounts of sub band and percentage of headcounts
DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE Employees (
    EmployeeID INT,
    EmployeeName VARCHAR(100),
    SubBand VARCHAR(20)
);

INSERT INTO Employees (EmployeeID, EmployeeName, SubBand) VALUES
(1, 'Samantha', 'B1'),
(2, 'Julia', 'B2'),
(3, 'Maria', 'B1'),
(4, 'Meera', 'B2'),
(5, 'Ashley', 'B3'),
(6, 'Ketty', 'B2'),
(7, 'Jane', 'B1');

SELECT COUNT(*) AS TotalHeadcount FROM Employees;

SELECT 
    SubBand,
    COUNT(*) AS Headcount,
    ROUND((COUNT(*) * 100.0) / 7, 2) AS PercentageOfTotal
FROM Employees
GROUP BY SubBand;

--Task 15: Top 5 employees as per their salaries
DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE Employees (
    EmployeeID INT,
    EmployeeName VARCHAR(100),
    SubBand VARCHAR(20),
    Salary DECIMAL(10, 2)
);

INSERT INTO Employees (EmployeeID, EmployeeName, SubBand, Salary) VALUES
(1, 'Ashley', 'B1', 60000),
(2, 'Ketty', 'B1', 70000),
(3, 'Maria', 'B1', 70000),
(4, 'Meera', 'B1', 80000),
(5, 'Samantha', 'B2', 50000),
(6, 'Jane', 'B2', 55000),
(7, 'Julia', 'B2', 60000);

SELECT EmployeeID, EmployeeName, SubBand, Salary
FROM (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY SubBand ORDER BY Salary DESC) AS salary_rank
    FROM Employees
) AS ranked
WHERE salary_rank = 2;

--Task 16: Swap value of two columns in a table
DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE Employees (
    EmployeeID INT,
    EmployeeName VARCHAR(100),
    SubBand VARCHAR(20),
    Age INT,
    Tenure DECIMAL(5,2) 
);

INSERT INTO Employees (EmployeeID, EmployeeName, SubBand, Age, Tenure) VALUES
(1, 'Samantha', 'B1', 30, 3.0),
(2, 'Julia', 'B1', 32, 2.5),
(3, 'Maria', 'B1', 28, 2.0),
(4, 'Meera', 'B2', 40, 5.0),
(5, 'Jane', 'B2', 38, 4.5),
(6, 'Ketty', 'B3', 35, 1.0);

SELECT SubBand,
    ROUND(AVG(Tenure), 2) AS Avg_Tenure,
    ROUND(AVG(Age), 2) AS Avg_Age,
    ROUND(AVG(Tenure) / AVG(Age), 4) AS Tenure_Age_Ratio
FROM Employees
GROUP BY SubBand;

--Task 17: Create login for user
DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE Employees (
    EmployeeID INT,
    EmployeeName VARCHAR(100),
    ManagerID INT,         
    BU VARCHAR(50)         
);

INSERT INTO Employees (EmployeeID, EmployeeName, ManagerID, BU) VALUES
(1, 'Samantha', NULL, 'Tech'),    
(2, 'Julia', 1, 'Tech'),
(3, 'Maria', 1, 'Tech'),
(4, 'Meera', 2, 'Tech'),
(5, 'Jane', 2, 'Tech'),
(6, 'Ketty', NULL, 'HR'),
(7, 'Ashley', 6, 'HR'),
(8, 'Scarlet', 6, 'HR'),
(9, 'Monika', 7, 'HR');

SELECT 
    BU,
    SUM(CASE WHEN ManagerID IS NOT NULL THEN 1 ELSE 0 END) AS Total_Reports,
    COUNT(DISTINCT ManagerID) AS Total_Managers,
    ROUND(
        1.0 * SUM(CASE WHEN ManagerID IS NOT NULL THEN 1 ELSE 0 END)
        / NULLIF(COUNT(DISTINCT ManagerID), 0), 
        2
    ) AS Span_of_Control
FROM Employees
GROUP BY BU;

--Task 18: Weighted avg cost of employeesmonth on month in a BU
DROP TABLE IF EXISTS EmployeeCosts;
GO

CREATE TABLE EmployeeCosts (
    EmployeeID INT,
    BU VARCHAR(50),
    [Month] DATE,
    Salary FLOAT,         
    WorkingDays INT       
);

INSERT INTO EmployeeCosts (EmployeeID, BU, [Month], Salary, WorkingDays) VALUES
(1, 'HR', '2025-01-01', 50000, 20),
(2, 'HR', '2025-01-01', 60000, 22),
(3, 'IT', '2025-01-01', 70000, 21),
(4, 'IT', '2025-02-01', 70000, 20),
(5, 'HR', '2025-02-01', 55000, 19);

SELECT BU,
    FORMAT([Month], 'yyyy-MM') AS MonthYear,
    ROUND(
        SUM(Salary * WorkingDays * 1.0) / NULLIF(SUM(WorkingDays), 0),
        2
    ) AS Weighted_Avg_Cost
FROM EmployeeCosts
GROUP BY BU, FORMAT([Month], 'yyyy-MM')
ORDER BY BU, MonthYear;

--Task 19: Finding miscalculation
SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Employees';

DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE Employees (
    EmployeeID INT,
    EmployeeName VARCHAR(100),
    Salary INT
);

INSERT INTO Employees (EmployeeID, EmployeeName, Salary) VALUES
(1, 'Samantha', 50000),
(2, 'Julia', 40000),
(3, 'Maria', 35000),
(4, 'Meera', 42000),
(5, 'Jane', 32000);

SELECT 
    CEILING(
        AVG(CAST(Rate AS FLOAT)) -
        AVG(CAST(REPLACE(CAST(Rate AS VARCHAR), '0', '') AS FLOAT))
    ) AS Rounded_Error
FROM HumanResources.EmployeePayHistory;

--Task 20: copy new data of one table into another table
DROP TABLE IF EXISTS SourceTable;
DROP TABLE IF EXISTS TargetTable;
GO
CREATE TABLE SourceTable (
    ID INT,
    Name VARCHAR(100),
    Salary INT
);

CREATE TABLE TargetTable (
    ID INT,
    Name VARCHAR(100),
    Salary INT
);

INSERT INTO SourceTable (ID, Name, Salary) VALUES
(1, 'Samantha', 5000),
(2, 'Julia', 6000),
(3, 'Maria', 7000); 

INSERT INTO TargetTable (ID, Name, Salary) VALUES
(1, 'Samantha', 5000),
(2, 'Julia', 6000);

INSERT INTO TargetTable (ID, Name, Salary)
SELECT ID, Name, Salary
FROM SourceTable
EXCEPT
SELECT ID, Name, Salary
FROM TargetTable;

SELECT * FROM TargetTable;

