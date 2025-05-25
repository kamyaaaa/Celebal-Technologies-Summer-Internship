SELECT *
FROM tempdb.INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'counttotalworkinhours';

USE tempdb;  
GO

IF OBJECT_ID('counttotalworkinhours', 'U') IS NOT NULL
    DROP TABLE counttotalworkinhours;

CREATE TABLE counttotalworkinhours (
    START_DATE DATE,
    END_DATE DATE,
    NO_OF_HOURS INT
);

EXEC sp_CalculateWorkingHours '2023-07-01', '2023-07-17';
EXEC sp_CalculateWorkingHours '2023-07-12', '2023-07-13';

SELECT * FROM counttotalworkinhours;


USE tempdb;
GO


IF OBJECT_ID('counttotalworkinhours', 'U') IS NOT NULL
    DROP TABLE counttotalworkinhours;
GO


CREATE TABLE counttotalworkinhours (
    START_DATE DATE,
    END_DATE DATE,
    NO_OF_HOURS INT
);
GO


IF OBJECT_ID('sp_CalculateWorkingHours', 'P') IS NOT NULL
    DROP PROCEDURE sp_CalculateWorkingHours;
GO


CREATE PROCEDURE sp_CalculateWorkingHours
    @Start_Date DATE,
    @End_Date DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalHours INT = 0;
    DECLARE @CurrentDate DATE = @Start_Date;

    WHILE @CurrentDate <= @End_Date
    BEGIN
        DECLARE @IsWeekend BIT = 0;

        
        IF DATENAME(WEEKDAY, @CurrentDate) = 'Sunday'
            SET @IsWeekend = 1;

        
        ELSE IF DATENAME(WEEKDAY, @CurrentDate) = 'Saturday'
        BEGIN
            DECLARE @Count INT = 0;
            DECLARE @i DATE = DATEFROMPARTS(YEAR(@CurrentDate), MONTH(@CurrentDate), 1);

            WHILE @i < @CurrentDate
            BEGIN
                IF DATENAME(WEEKDAY, @i) = 'Saturday'
                    SET @Count += 1;
                SET @i = DATEADD(DAY, 1, @i);
            END

            IF @Count < 2
                SET @IsWeekend = 1;
        END

        IF @IsWeekend = 0 OR @CurrentDate IN (@Start_Date, @End_Date)
            SET @TotalHours += 24;

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END

    INSERT INTO counttotalworkinhours (START_DATE, END_DATE, NO_OF_HOURS)
    VALUES (@Start_Date, @End_Date, @TotalHours);
END;
GO


EXEC sp_CalculateWorkingHours '2023-07-01', '2023-07-17';
EXEC sp_CalculateWorkingHours '2023-07-12', '2023-07-13';

SELECT * FROM counttotalworkinhours;