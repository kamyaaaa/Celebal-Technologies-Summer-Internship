IF OBJECT_ID('ProcessSubjectRequests', 'P') IS NOT NULL
    DROP PROCEDURE ProcessSubjectRequests;

IF OBJECT_ID('SubjectAllotments', 'U') IS NOT NULL
    DROP TABLE SubjectAllotments;

IF OBJECT_ID('SubjectRequest', 'U') IS NOT NULL
    DROP TABLE SubjectRequest;

CREATE TABLE SubjectAllotments (
    StudentID VARCHAR(20),
    SubjectID VARCHAR(20),
    Is_Valid BIT
);

CREATE TABLE SubjectRequest (
    StudentID VARCHAR(20),
    SubjectID VARCHAR(20)
);

INSERT INTO SubjectAllotments VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

INSERT INTO SubjectRequest VALUES
('159103036', 'PO1496');

GO

CREATE PROCEDURE ProcessSubjectRequests
AS
BEGIN
    DECLARE @StudentID VARCHAR(20), 
            @RequestedSubjectID VARCHAR(20), 
            @CurrentSubjectID VARCHAR(20);

    DECLARE request_cursor CURSOR FOR
    SELECT StudentID, SubjectID FROM SubjectRequest;

    OPEN request_cursor;

    FETCH NEXT FROM request_cursor INTO @StudentID, @RequestedSubjectID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @CurrentSubjectID = SubjectID
        FROM SubjectAllotments
        WHERE StudentID = @StudentID AND Is_Valid = 1;

        IF @CurrentSubjectID IS NULL
        BEGIN
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
            VALUES (@StudentID, @RequestedSubjectID, 1);
        END
        ELSE IF @CurrentSubjectID <> @RequestedSubjectID
        BEGIN
            UPDATE SubjectAllotments
            SET Is_Valid = 0
            WHERE StudentID = @StudentID AND Is_Valid = 1;

            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
            VALUES (@StudentID, @RequestedSubjectID, 1);
        END

        FETCH NEXT FROM request_cursor INTO @StudentID, @RequestedSubjectID;
    END;

    CLOSE request_cursor;
    DEALLOCATE request_cursor;
END;

GO

EXEC ProcessSubjectRequests;

SELECT * FROM SubjectAllotments WHERE StudentID = '159103036';