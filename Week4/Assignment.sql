USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'StudentAllotmentDB')
BEGIN
    ALTER DATABASE StudentAllotmentDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE StudentAllotmentDB;
END
GO

CREATE DATABASE StudentAllotmentDB;
GO
USE StudentAllotmentDB;
GO

CREATE TABLE StudentDetails (
    StudentId BIGINT PRIMARY KEY,
    StudentName VARCHAR(100),
    GPA DECIMAL(3, 2),
    Branch VARCHAR(10),
    Section VARCHAR(5)
);

CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(10) PRIMARY KEY,
    SubjectName VARCHAR(100),
    MaxSeats INT,
    RemainingSeats INT
);

CREATE TABLE StudentPreference (
    StudentId BIGINT,
    SubjectId VARCHAR(10),
    Preference INT,
    PRIMARY KEY (StudentId, Preference),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);

CREATE TABLE Allotments (
    SubjectId VARCHAR(10),
    StudentId BIGINT PRIMARY KEY,
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);

CREATE TABLE UnallotedStudents (
    StudentId BIGINT PRIMARY KEY,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);
GO

INSERT INTO StudentDetails VALUES
(159103036, 'Mohit Agarwal', 9.3, 'CCE', 'A'),     
(159103037, 'Rohit Agarwal', 5.2, 'CCE', 'A'),
(159103038, 'Shohit Garg', 7.1, 'CCE', 'B'),
(159103039, 'Mrinal Malhotra', 7.9, 'CCE', 'A'),
(159103040, 'Mehreet Singh', 5.6, 'CCE', 'A'),
(159103041, 'Arjun Tehlan', 8.9, 'CCE', 'B');

INSERT INTO SubjectDetails VALUES
('PO1491', 'Basics of Political Science', 60, 1),   
('PO1492', 'Basics of Accounting', 120, 0),
('PO1493', 'Basics of Financial Markets', 90, 0),
('PO1494', 'Eco philosophy', 60, 0),
('PO1495', 'Automotive Trends', 60, 0);

INSERT INTO StudentPreference VALUES
(159103036, 'PO1491', 1), (159103036, 'PO1492', 2), (159103036, 'PO1493', 3), (159103036, 'PO1494', 4), (159103036, 'PO1495', 5),
(159103037, 'PO1491', 1), (159103037, 'PO1492', 2), (159103037, 'PO1493', 3), (159103037, 'PO1494', 4), (159103037, 'PO1495', 5),
(159103038, 'PO1491', 1), (159103038, 'PO1492', 2), (159103038, 'PO1493', 3), (159103038, 'PO1494', 4), (159103038, 'PO1495', 5),
(159103039, 'PO1491', 1), (159103039, 'PO1492', 2), (159103039, 'PO1493', 3), (159103039, 'PO1494', 4), (159103039, 'PO1495', 5),
(159103040, 'PO1491', 1), (159103040, 'PO1492', 2), (159103040, 'PO1493', 3), (159103040, 'PO1494', 4), (159103040, 'PO1495', 5),
(159103041, 'PO1491', 1), (159103041, 'PO1492', 2), (159103041, 'PO1493', 3), (159103041, 'PO1494', 4), (159103041, 'PO1495', 5);
GO

IF OBJECT_ID('AllocateSubjects', 'P') IS NOT NULL
    DROP PROCEDURE AllocateSubjects;
GO

CREATE PROCEDURE AllocateSubjects
AS
BEGIN
    DECLARE @sid BIGINT;
    DECLARE @pref INT;
    DECLARE @allocated BIT;
    DECLARE @sub_id VARCHAR(10);
    DECLARE @seats INT;

    DECLARE student_cursor CURSOR FOR
        SELECT StudentId FROM StudentDetails ORDER BY GPA DESC;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @sid;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @pref = 1;
        SET @allocated = 0;

        WHILE @pref <= 5
        BEGIN
            SELECT @sub_id = SubjectId
            FROM StudentPreference
            WHERE StudentId = @sid AND Preference = @pref;

            IF @sub_id IS NOT NULL
            BEGIN
                SELECT @seats = RemainingSeats FROM SubjectDetails WHERE SubjectId = @sub_id;

                IF @seats > 0
                BEGIN
                    INSERT INTO Allotments (SubjectId, StudentId)
                    VALUES (@sub_id, @sid);

                    UPDATE SubjectDetails
                    SET RemainingSeats = RemainingSeats - 1
                    WHERE SubjectId = @sub_id;

                    SET @allocated = 1;
                    BREAK;
                END
            END
            SET @pref = @pref + 1;
        END

        IF @allocated = 0
        BEGIN
            INSERT INTO UnallotedStudents (StudentId)
            VALUES (@sid);
        END

        FETCH NEXT FROM student_cursor INTO @sid;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END;
GO

EXEC AllocateSubjects;
GO

SELECT 'StudentDetails' AS TableName, * FROM StudentDetails;
SELECT 'SubjectDetails' AS TableName, * FROM SubjectDetails;
SELECT 'StudentPreference' AS TableName, * FROM StudentPreference ORDER BY StudentId, Preference;
SELECT 'Allotments' AS TableName, * FROM Allotments;
SELECT 'UnallotedStudents' AS TableName, * FROM UnallotedStudents;