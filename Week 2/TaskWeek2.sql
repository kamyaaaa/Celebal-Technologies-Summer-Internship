USE AdventureWorks2022;
GO

DROP PROCEDURE IF EXISTS InsertOrderDetails;
DROP PROCEDURE IF EXISTS UpdateOrderDetails;
DROP PROCEDURE IF EXISTS GetOrderDetails;
DROP PROCEDURE IF EXISTS DeleteOrderDetails;
GO


DROP FUNCTION IF EXISTS FormatDateYYYYMMDD;
DROP FUNCTION IF EXISTS FormatDateMMDDYYYY;
GO

DROP VIEW IF EXISTS vwCustomerOrdersYesterday;
DROP VIEW IF EXISTS vwCustomerOrders;
DROP VIEW IF EXISTS MyProducts;
GO

IF OBJECT_ID('Sales.StockCheckBeforeOrder', 'TR') IS NOT NULL
    DROP TRIGGER Sales.StockCheckBeforeOrder;
GO

--Create a procedure InsertOrderDetails that takes OrderID, ProductID, UnitPrice, Quantiy, Discount as input parameters and inserts that order information in the Order Details table. 
--After each order inserted, check the @@rowcount value to make sure that order was inserted properly. If for any reason the order was not inserted, print the message: Failed to place the order. Please try again. Also your procedure should have these functionalities.
--Make the UnitPrice and Discount parameters optional
--If no UnitPrice is given, then use the UnitPrice value from the product table.
--If no Discount is given, then use a discount of 0.
--Adjust the quantity in stock (UnitsInStock) for the product by subtracting the quantity sold from inventory.
--However, if there is not enough of a product in stock, then abort the stored procedure without making any changes to the database.
--Print a message if the quantity in stock of a product drops below its Reorder Level as a result of the update.

CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(10,2) = NULL,
    @Quantity INT,
    @Discount DECIMAL(5,2) = 0
AS
BEGIN
    DECLARE @Stock INT, @ReorderLevel INT, @ProductUnitPrice DECIMAL(10,2);

    SELECT @Stock = p.SafetyStockLevel, @ReorderLevel = p.ReorderPoint, @ProductUnitPrice = p.ListPrice
    FROM Production.Product p WHERE p.ProductID = @ProductID;

    IF @Stock < @Quantity
    BEGIN
        PRINT 'Failed to place the order. Insufficient stock.';
        RETURN;
    END

    IF @UnitPrice IS NULL
    BEGIN
        SET @UnitPrice = @ProductUnitPrice;
    END

    BEGIN TRANSACTION;

    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice, SpecialOfferID)
    VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice, 1);

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order.';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE Production.Product 
    SET SafetyStockLevel = SafetyStockLevel - @Quantity 
    WHERE ProductID = @ProductID;

    IF @Stock - @Quantity < @ReorderLevel
    BEGIN
        PRINT 'Warning: Stock has dropped below reorder level.';
    END

    COMMIT TRANSACTION;
END;
GO

--Create a procedure UpdateOrderDetails that takes OrderID, ProductID, UnitPrice, Quantity, and discount, and updates these values for that ProductID in that Order. 
--All the parameters except the OrderID and ProductID should be optional so that if the user wants to only update Quantity s/he should be able to do so without providing the rest of the values. 
--Make sure that if any of the values are being passed in as NULL, then you want to retain the original value instead of overwriting it with NULL. 

CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT, @ProductID INT, @UnitPrice DECIMAL(10,2) = NULL, @Quantity INT = NULL, @Discount DECIMAL(5,2) = NULL
AS
BEGIN
    DECLARE @ExistingUnitPrice DECIMAL(10,2), @ExistingQuantity INT;

    SELECT @ExistingUnitPrice = UnitPrice, @ExistingQuantity = OrderQty
    FROM Sales.SalesOrderDetail 
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    BEGIN TRANSACTION;

    UPDATE Sales.SalesOrderDetail
    SET UnitPrice = ISNULL(@UnitPrice, @ExistingUnitPrice),
        OrderQty = ISNULL(@Quantity, @ExistingQuantity)
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    COMMIT TRANSACTION;
END;
GO

--Create a procedure GetOrderDetails that takes OrderID as input parameter and returns all the records for that OrderID. 
--If no records are found in Order Details table, then it should print the line: "The OrderID XXXX does not exits", where XXX should be the OrderID entered by user and the procedure should RETURN the value 1.

CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist.';
        RETURN 1;
    END

    SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID;
END;
GO

--Create a procedure DeleteOrderDetails that takes OrderID and ProductID and deletes that from Order Details table. Your procedure should validate parameters. 
--It should return an error code (-1) and print a message if the parameters are invalid.
--Parameters are valid if the given order ID appears in the table and if the given product ID appears in that order.

CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT, @ProductID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID AND ProductID = @ProductID)
    BEGIN
        PRINT 'Invalid parameters. OrderID or ProductID does not exist.';
        RETURN -1;
    END

    BEGIN TRANSACTION;

    DELETE FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    COMMIT TRANSACTION;
END;
GO

--Create a function that takes an input parameter type datetime and returns the date in the format MM/DD/YYYY.
CREATE FUNCTION FormatDateMMDDYYYY (@DateTime DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN FORMAT(@DateTime, 'MM/dd/yyyy');
END;
GO

--Create a function that takes an input parameter type datetime and returns the date in the format YYYYMMDD
CREATE FUNCTION FormatDateYYYYMMDD (@DateTime DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN FORMAT(@DateTime, 'yyyyMMdd');
END;
GO

CREATE VIEW vwCustomerOrders AS
SELECT 
    p.FirstName + ' ' + p.LastName AS CustomerName,
    soh.SalesOrderID, 
    soh.OrderDate, 
    sod.ProductID, 
    pr.Name AS ProductName, 
    sod.OrderQty, 
    sod.UnitPrice, 
    (sod.OrderQty * sod.UnitPrice) AS TotalAmount
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID;
GO

--
CREATE VIEW vwCustomerOrdersYesterday AS
SELECT * FROM vwCustomerOrders 
WHERE CAST(OrderDate AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE);
GO

--Use a CREATE VIEW statement to create a view called MyProducts. 
--View should contain the ProductID, ProductName, QuantityPerUnit and UnitPrice columns from the Products table. 
--It should also contain the CompanyName column from the Suppliers table and the CategoryName column from the Categories table. 
--View should only contain products that are not discontinued.

CREATE VIEW MyProducts AS
SELECT p.ProductID, p.Name AS ProductName, p.SafetyStockLevel, p.ListPrice, c.Name AS CategoryName
FROM Production.Product p
JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
WHERE p.SellStartDate IS NOT NULL;
GO

--If someone cancels an order in northwind database, then you want to delete that order from the Orders table. 
--But you will not be able to delete that Order before deleting the records from Order Details table for that particular order due to referential integrity constraints. 
--Create an Instead of Delete trigger on Orders table so that if some one tries to delete an Order that trigger gets fired and that trigger should first delete everything in order details table and then delete that order from the Orders table
CREATE TRIGGER StockCheckBeforeOrder
ON Sales.SalesOrderDetail
FOR INSERT
AS
BEGIN
    DECLARE @ProductID INT, @Quantity INT, @Stock INT;

    SELECT @ProductID = i.ProductID, @Quantity = i.OrderQty
    FROM inserted i;

    SELECT @Stock = SafetyStockLevel FROM Production.Product WHERE ProductID = @ProductID;

    IF @Stock < @Quantity
    BEGIN
        PRINT 'Order cannot be placed due to insufficient stock.';
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        UPDATE Production.Product 
        SET SafetyStockLevel = SafetyStockLevel - @Quantity 
        WHERE ProductID = @ProductID;
    END
END;
GO

-- Test Queries
DECLARE @TestCustomerID INT = (SELECT TOP 1 CustomerID FROM Sales.Customer);

INSERT INTO Sales.SalesOrderHeader 
(
    RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, CustomerID, 
    BillToAddressID, ShipToAddressID, ShipMethodID, SubTotal, TaxAmt, Freight
)
VALUES 
(
    1, GETDATE(), DATEADD(DAY, 7, GETDATE()), NULL, 1, 1, @TestCustomerID, 1, 1, 1, 100.00, 10.00, 5.00
);

DECLARE @NewOrderID INT = SCOPE_IDENTITY();

EXEC InsertOrderDetails
    @OrderID = @NewOrderID, @ProductID = 776, @UnitPrice = NULL, @Quantity = 5, @Discount = 0.10;

EXEC UpdateOrderDetails
    @OrderID = @NewOrderID, @ProductID = 776, @UnitPrice = 25.00, @Quantity = 10, @Discount = NULL;

EXEC GetOrderDetails @OrderID = @NewOrderID;

EXEC DeleteOrderDetails
    @OrderID = @NewOrderID, @ProductID = 776;

SELECT dbo.FormatDateMMDDYYYY(GETDATE()) AS MMDDYYYY_Format;
SELECT dbo.FormatDateYYYYMMDD(GETDATE()) AS YYYYMMDD_Format;

SELECT TOP 10 * FROM vwCustomerOrders;
SELECT * FROM vwCustomerOrdersYesterday;
SELECT TOP 10 * FROM MyProducts;

DELETE FROM Sales.SalesOrderHeader WHERE SalesOrderID = @NewOrderID;
GO
