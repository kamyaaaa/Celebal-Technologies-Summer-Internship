IF OBJECT_ID('dbo.DimCustomer') IS NOT NULL DROP TABLE dbo.DimCustomer;
GO

CREATE TABLE dbo.DimCustomer (
    CustomerID INT,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    PreviousEmail NVARCHAR(100),       
    PreviousPhone NVARCHAR(20),       
    EffectiveStartDate DATETIME2,
    EffectiveEndDate DATETIME2,
    IsCurrent BIT,
    Version INT,
    PRIMARY KEY (CustomerID, EffectiveStartDate)
);
GO

IF OBJECT_ID('dbo.CustomerHistory') IS NOT NULL DROP TABLE dbo.CustomerHistory;
GO

CREATE TABLE dbo.CustomerHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    ChangeDate DATETIME2
);
GO

DROP PROCEDURE IF EXISTS Update_SCD0;
DROP PROCEDURE IF EXISTS Update_SCD1;
DROP PROCEDURE IF EXISTS Update_SCD2;
DROP PROCEDURE IF EXISTS Update_SCD3;
DROP PROCEDURE IF EXISTS Update_SCD4;
DROP PROCEDURE IF EXISTS Update_SCD6;
GO

CREATE PROCEDURE Update_SCD0
    @CustomerID INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    PRINT 'SCD Type 0 - Attributes are static, no updates applied.';
END
GO

CREATE PROCEDURE Update_SCD1
    @CustomerID INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    UPDATE dbo.DimCustomer
    SET FirstName = @FirstName,
        LastName = @LastName,
        Email = @Email,
        Phone = @Phone
    WHERE CustomerID = @CustomerID AND IsCurrent = 1;
END
GO

CREATE PROCEDURE Update_SCD2
    @CustomerID INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    DECLARE @Now DATETIME2 = SYSDATETIME();
    DECLARE @Version INT;

    SELECT @Version = ISNULL(MAX(Version), 0)
    FROM dbo.DimCustomer
    WHERE CustomerID = @CustomerID;

    UPDATE dbo.DimCustomer
    SET EffectiveEndDate = @Now,
        IsCurrent = 0
    WHERE CustomerID = @CustomerID AND IsCurrent = 1;

    INSERT INTO dbo.DimCustomer (
        CustomerID, FirstName, LastName, Email, Phone,
        EffectiveStartDate, EffectiveEndDate, IsCurrent, Version
    )
    VALUES (
        @CustomerID, @FirstName, @LastName, @Email, @Phone,
        @Now, '9999-12-31', 1, @Version + 1
    );
END
GO

CREATE PROCEDURE Update_SCD3
    @CustomerID INT,
    @Email NVARCHAR(100)
AS
BEGIN
    DECLARE @OldEmail NVARCHAR(100);

    SELECT @OldEmail = Email
    FROM dbo.DimCustomer
    WHERE CustomerID = @CustomerID AND IsCurrent = 1;

    UPDATE dbo.DimCustomer
    SET PreviousEmail = @OldEmail,
        Email = @Email
    WHERE CustomerID = @CustomerID AND IsCurrent = 1;
END
GO

CREATE PROCEDURE Update_SCD4
    @CustomerID INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    DECLARE @Now DATETIME2 = SYSDATETIME();

    INSERT INTO dbo.CustomerHistory (
        CustomerID, FirstName, LastName, Email, Phone, ChangeDate
    )
    SELECT CustomerID, FirstName, LastName, Email, Phone, @Now
    FROM dbo.DimCustomer
    WHERE CustomerID = @CustomerID AND IsCurrent = 1;

    UPDATE dbo.DimCustomer
    SET FirstName = @FirstName,
        LastName = @LastName,
        Email = @Email,
        Phone = @Phone
    WHERE CustomerID = @CustomerID AND IsCurrent = 1;
END
GO

CREATE PROCEDURE Update_SCD6
    @CustomerID INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    DECLARE @Now DATETIME2 = SYSDATETIME();
    DECLARE @OldPhone NVARCHAR(20);
    DECLARE @Version INT;

    SELECT @OldPhone = Phone
    FROM dbo.DimCustomer
    WHERE CustomerID = @CustomerID AND IsCurrent = 1;

    SELECT @Version = ISNULL(MAX(Version), 0)
    FROM dbo.DimCustomer
    WHERE CustomerID = @CustomerID;

    UPDATE dbo.DimCustomer
    SET EffectiveEndDate = @Now,
        IsCurrent = 0
    WHERE CustomerID = @CustomerID AND IsCurrent = 1;

    INSERT INTO dbo.DimCustomer (
        CustomerID, FirstName, LastName, Email, Phone, PreviousPhone,
        EffectiveStartDate, EffectiveEndDate, IsCurrent, Version
    )
    VALUES (
        @CustomerID, @FirstName, @LastName, @Email, @Phone, @OldPhone,
        @Now, '9999-12-31', 1, @Version + 1
    );
END
GO

INSERT INTO dbo.DimCustomer (
    CustomerID, FirstName, LastName, Email, Phone,
    PreviousEmail, PreviousPhone,
    EffectiveStartDate, EffectiveEndDate,
    IsCurrent, Version
)
VALUES (
    1, 'Kamya', 'Singh', 'kamya@gmail.com', '9045767423',
    NULL, NULL,
    GETDATE(), '2005-01-13',
    1, 1
);

EXEC Update_SCD1
    @CustomerID = 1,
    @FirstName = 'Kamya',
    @LastName = 'Singh',
    @Email = 'kamya.new@gmail.com',
    @Phone = '9876543210';

SELECT * FROM dbo.DimCustomer WHERE CustomerID = 1 AND IsCurrent = 1;

EXEC Update_SCD2
    @CustomerID = 1,
    @FirstName = 'Kamya',
    @LastName = 'Singh',
    @Email = 'kamya.updated@gmail.com',
    @Phone = '8888888888';

SELECT * FROM dbo.DimCustomer WHERE CustomerID = 1 ORDER BY Version;

EXEC Update_SCD3
    @CustomerID = 1,
    @Email = 'kamya.final@gmail.com';

SELECT Email, PreviousEmail FROM dbo.DimCustomer WHERE CustomerID = 1 AND IsCurrent = 1;

EXEC Update_SCD4
    @CustomerID = 1,
    @FirstName = 'Kamya',
    @LastName = 'Singh',
    @Email = 'kamya.archive@gmail.com',
    @Phone = '7777777777';

SELECT * FROM dbo.CustomerHistory WHERE CustomerID = 1;

EXEC Update_SCD6
    @CustomerID = 1,
    @FirstName = 'Kamya',
    @LastName = 'Singh',
    @Email = 'kamya.hybrid@gmail.com',
    @Phone = '6666666666';

SELECT * FROM dbo.DimCustomer WHERE CustomerID = 1 ORDER BY Version;
SELECT PreviousPhone FROM dbo.DimCustomer WHERE CustomerID = 1 AND IsCurrent = 1;