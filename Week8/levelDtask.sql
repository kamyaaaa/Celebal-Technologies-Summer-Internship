USE AdventureWorks2022;
GO

IF OBJECT_ID('dbo.DimDate', 'U') IS NOT NULL
    DROP TABLE dbo.DimDate;
GO

CREATE TABLE dbo.DimDate (
    DateKey DATE PRIMARY KEY,
    FullDate VARCHAR(50),
    Day TINYINT,
    DayName VARCHAR(10),
    DayOfWeek TINYINT,
    WeekOfYear TINYINT,
    Month TINYINT,
    MonthName VARCHAR(20),
    Quarter TINYINT,
    Year INT,
    IsWeekend BIT
);
GO

IF OBJECT_ID('dbo.PopulateDimDate', 'P') IS NOT NULL
    DROP PROCEDURE dbo.PopulateDimDate;
GO

CREATE PROCEDURE dbo.PopulateDimDate
    @InputDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartDate DATE = DATEFROMPARTS(YEAR(@InputDate), 1, 1);
    DECLARE @EndDate DATE = DATEFROMPARTS(YEAR(@InputDate), 12, 31);

    ;WITH DateSeries AS (
        SELECT @StartDate AS DateValue
        UNION ALL
        SELECT DATEADD(DAY, 1, DateValue)
        FROM DateSeries
        WHERE DateValue < @EndDate
    )
    INSERT INTO dbo.DimDate (
        DateKey,
        FullDate,
        Day,
        DayName,
        DayOfWeek,
        WeekOfYear,
        Month,
        MonthName,
        Quarter,
        Year,
        IsWeekend
    )
    SELECT
        DateValue,
        FORMAT(DateValue, 'dddd, MMMM dd, yyyy') AS FullDate,
        DAY(DateValue) AS Day,
        DATENAME(WEEKDAY, DateValue) AS DayName,
        DATEPART(WEEKDAY, DateValue) AS DayOfWeek,
        DATEPART(WEEK, DateValue) AS WeekOfYear,
        MONTH(DateValue) AS Month,
        DATENAME(MONTH, DateValue) AS MonthName,
        DATEPART(QUARTER, DateValue) AS Quarter,
        YEAR(DateValue) AS Year,
        CASE WHEN DATENAME(WEEKDAY, DateValue) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS IsWeekend
    FROM DateSeries
    OPTION (MAXRECURSION 366);
END
GO

EXEC dbo.PopulateDimDate @InputDate = '2020-07-14';
GO

SELECT * FROM dbo.DimDate ORDER BY DateKey;
