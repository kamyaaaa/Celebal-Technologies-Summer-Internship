USE AdventureWorks2022;
GO

/*Problem Statement 1: List of all customer */
SELECT c.CustomerID, p.FirstName, p.LastName,c.AccountNumber,c.ModifiedDate
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE c.PersonID IS NOT NULL;

/*Problem Statement 2: List of all customers where company name ending in N */
SELECT c.CustomerID, s.Name AS CompanyName, c.AccountNumber, c.ModifiedDate
FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%N';

/*Problem Statement 3: List of all customers who live in Berlin and London */
SELECT DISTINCT p.FirstName, p.LastName, a.City
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');

/*Problem Staement 4: List of all customers who live in UK and USA */
SELECT DISTINCT per.FirstName, per.LastName, addr.City, cr.Name AS Country
FROM Sales.Customer cust
JOIN Person.Person per ON cust.PersonID = per.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON cust.PersonID = bea.BusinessEntityID
JOIN Person.Address addr ON bea.AddressID = addr.AddressID
JOIN Person.StateProvince sp ON addr.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States');

/*Problem Staement 5: List of all products sorted by product name */
SELECT p.Name AS ProductName, p.ProductNumber, p.Color, p.ListPrice
FROM Production.Product p
ORDER BY p.Name ASC;

/*Problem Staement 6: List of all products where product name starts with an A*/
SELECT p.Name AS ProductName, p.ProductNumber, p.Color, p.ListPrice
FROM Production.Product p
WHERE p.Name LIKE 'A%'
ORDER BY p.Name ASC;

/*Problem Statement 7: List of all customers who ever placed an order*/
SELECT DISTINCT per.FirstName, per.LastName, cust.CustomerID
FROM Sales.Customer cust
JOIN Person.Person per ON cust.PersonID = per.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON cust.CustomerID = soh.CustomerID
ORDER BY per.FirstName, per.LastName;

/*Problem Statement 8: List of all customers who live in London and have bought chai*/
SELECT DISTINCT p.FirstName, p.LastName, a.City, pr.Name AS ProductName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress ba ON c.PersonID = ba.BusinessEntityID
JOIN Person.Address a ON ba.AddressID = a.AddressID
JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID
JOIN Sales.SalesOrderDetail od ON o.SalesOrderID = od.SalesOrderID
JOIN Production.Product pr ON od.ProductID = pr.ProductID
WHERE a.City = 'London' AND pr.Name = 'Chai';

/*Problem Statement 9: List of customers who never place an order*/
SELECT p.FirstName, p.LastName, c.CustomerID
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID
WHERE o.SalesOrderID IS NULL;

/*Problem Statement 10: List of customers who ordered Tofu*/
SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName, c.AccountNumber, c.ModifiedDate
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
WHERE pr.Name = 'Tofu'
ORDER BY p.LastName, p.FirstName;

/*Problem Statement 11: Details of first order of the system */
SELECT soh.SalesOrderID, soh.OrderDate, soh.CustomerID, p.FirstName, p.LastName, sod.ProductID, pr.Name AS ProductName, sod.OrderQty, SOD.LineTotal
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS pr ON SOD.ProductID = pr.ProductID
ORDER BY soh.OrderDate ASC;

/*Problem Statement 12: Find the details of the most expensive order dates */
SELECT soh.OrderDate, soh.SalesOrderID, c.CustomerID, p.FirstName, p.LastName, SUM(sod.LineTotal) AS TotalOrderCost
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.OrderDate, soh.SalesOrderID, c.CustomerID, p.FirstName, p.LastName
ORDER BY TotalOrderCost DESC;

/*Problem Statement 13: For each order get the OrderID and Average quantity of items in that order */
SELECT sod.SalesOrderID, AVG(sod.OrderQty) AS AvgItemQuantity
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID
ORDER BY AvgItemQuantity DESC;

/*Problem Statement 14: For each order get the OrderID and minimum quantity and maximum quantity for that order */
SELECT sod.SalesOrderID, MIN(sod.OrderQty) AS MinItemQuantity, MAX(sod.OrderQty) AS MaxItemQuantity
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID
ORDER BY sod.SalesOrderID;

/*Problem Statement 15: Get alist of all managers and total number of employees who report to them */
SELECT e.BusinessEntityID AS ManagerID, p.FirstName, p.LastName, COUNT(emp.BusinessEntityID) AS TotalReports
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN HumanResources.Employee AS emp ON emp.OrganizationNode.IsDescendantOf(e.OrganizationNode) = 1
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
ORDER BY TotalReports DESC;

/*Problem Statement 16: Get the OrderID and the total quantity for each order that has a total quantity of greater than 300 */
SELECT sod.SalesOrderID, SUM(sod.OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID
HAVING SUM(sod.OrderQty) > 300
ORDER BY TotalQuantity DESC;

/*Problem Statement 17: List of all orders placed on or after 1996/12/31 */
SELECT soh.SalesOrderID, soh.OrderDate, soh.CustomerID, soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
WHERE soh.OrderDate >= '1996-12-31'
ORDER BY soh.OrderDate ASC;

/*Problem Statement 18: List of all orders shipped to Canada */
SELECT soh.SalesOrderID, soh.OrderDate, soh.ShipDate, soh.ShipToAddressID, addr.City, sp.Name AS StateProvince, cr.Name AS Country
FROM Sales.SalesOrderHeader AS soh
JOIN Person.Address AS addr ON soh.ShipToAddressID = addr.AddressID
JOIN Person.StateProvince AS sp ON addr.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion AS cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada'
ORDER BY soh.OrderDate ASC;

/*Problem Statement 19: List of orders with order total>200 */
SELECT soh.SalesOrderID, soh.OrderDate, soh.CustomerID, soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
WHERE soh.TotalDue > 200
ORDER BY soh.TotalDue DESC;

/*Problem Statement 20: List of all countries and sales made in each country */
SELECT cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader AS soh
JOIN Person.Address AS addr ON soh.ShipToAddressID = addr.AddressID
JOIN Person.StateProvince AS sp ON addr.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion AS cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;

/*Problem Statement 21: List of Customer ContactName and number of orders they placed */
SELECT c.CustomerID, p.FirstName + ' ' + p.LastName AS ContactName, COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer AS c
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY OrderCount DESC;

/*Problem Statement 22: List of customer contactname who have placed more than 3 orders */
SELECT c.CustomerID, p.FirstName + ' ' + p.LastName AS ContactName, COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer AS c
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
HAVING COUNT(soh.SalesOrderID) > 3
ORDER BY OrderCount DESC;

/*Problem Statement 23: List of discontinued products which were ordered between 1/1/1997 and 1/1/1998 */
SELECT DISTINCT pr.ProductID, pr.Name AS ProductName, soh.OrderDate
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS pr ON sod.ProductID = pr.ProductID
WHERE soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01'
AND pr.DiscontinuedDate IS NOT NULL
ORDER BY soh.OrderDate ASC;

/*Problem Statement 24: List of employee firstname, lastName, superviser FirstName, LastName */
SELECT e.BusinessEntityID AS EmployeeID, p.FirstName AS EmployeeFirstName, p.LastName AS EmployeeLastName, s.BusinessEntityID AS SupervisorID, sp.FirstName AS SupervisorFirstName, sp.LastName AS SupervisorLastName
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN HumanResources.Employee AS s ON e.OrganizationNode.IsDescendantOf(s.OrganizationNode) = 1
LEFT JOIN Person.Person AS sp ON s.BusinessEntityID = sp.BusinessEntityID
ORDER BY SupervisorID, EmployeeID;

/*Problem Statement 25: List of Employees id and total sale conducted by employee */
SELECT e.BusinessEntityID AS EmployeeID, p.FirstName, p.LastName, SUM(soh.TotalDue) AS TotalSales
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON e.BusinessEntityID = soh.SalesPersonID
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
ORDER BY TotalSales DESC;

/*Problem Statement 26: List of employees whose FirstName contains character a */
SELECT e.BusinessEntityID AS EmployeeID, p.FirstName, p.LastName
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName LIKE '%a%'
ORDER BY p.FirstName ASC;

/*Problem Statement 27: List of managers who have more than four people reporting to them */
SELECT e.BusinessEntityID AS ManagerID, p.FirstName, p.LastName, COUNT(emp.BusinessEntityID) AS TotalReports
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources.Employee AS emp ON emp.OrganizationNode.IsDescendantOf(e.OrganizationNode) = 1
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(emp.BusinessEntityID) > 4
ORDER BY TotalReports DESC;

/*Problem Statement 28: List of Orders and ProductNames */
SELECT soh.SalesOrderID, soh.OrderDate, pr.Name AS ProductName
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS pr ON sod.ProductID = pr.ProductID
ORDER BY soh.OrderDate ASC;

/*Problem Statement 29: List of orders place by the best customer */
SELECT TOP 1 soh.CustomerID, p.FirstName, p.LastName, COUNT(soh.SalesOrderID) AS TotalOrders
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
GROUP BY soh.CustomerID, p.FirstName, p.LastName
ORDER BY TotalOrders DESC;

/*Problem Statement 30: List of orders placed by customers who do not have a Fax number */
SELECT o.SalesOrderID, o.OrderDate, c.CustomerID, p.FirstName, p.LastName
FROM Sales.SalesOrderHeader o
JOIN Sales.Customer c ON o.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID
LEFT JOIN Person.PhoneNumberType pt ON pp.PhoneNumberTypeID = pt.PhoneNumberTypeID
WHERE pt.Name IS NULL OR pt.Name <> 'Fax';

/*Problem Statement 31: List of Postal codes where the product Tofu was placed */
SELECT DISTINCT addr.PostalCode
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS pr ON sod.ProductID = pr.ProductID
JOIN Person.Address AS addr ON soh.ShipToAddressID = addr.AddressID
WHERE pr.Name = 'Tofu'
ORDER BY addr.PostalCode ASC;

/*Problem Statement 32: List of product Names that were shipped to France */
SELECT DISTINCT pr.Name AS ProductName
FROM Sales.SalesOrderHeader o
JOIN Sales.SalesOrderDetail od ON o.SalesOrderID = od.SalesOrderID
JOIN Production.Product pr ON od.ProductID = pr.ProductID
JOIN Person.Address a ON o.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';

/*Problem Statement 33: List of ProductNames and Categories for the supplier 'Speciality Biscuits, Ltd */
SELECT pr.Name AS ProductName, pc.Name AS CategoryName
FROM Production.Product AS pr
JOIN Production.ProductSubcategory AS psc ON pr.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor AS pv ON pr.ProductID = pv.ProductID
JOIN Purchasing.Vendor AS v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Speciality Biscuits, Ltd'
ORDER BY CategoryName, ProductName;

/*Problem Statement 34: List of products that were never ordered */
SELECT pr.ProductID, pr.Name AS ProductName
FROM Production.Product AS pr
LEFT JOIN Sales.SalesOrderDetail AS sod ON pr.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL
ORDER BY pr.Name;

/*Problem Statement 35: List of products where units in stock is less than 10 and units on order are 0 */
SELECT p.Name AS ProductName, pi.Quantity AS UnitsInStock
FROM Production.Product p
JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
WHERE pi.Quantity < 10
  AND p.ProductID NOT IN (
    SELECT sod.ProductID
    FROM Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE soh.Status < 5 -- assuming statuses < 5 are still open
  );

/*Problem Statement 36: List of top 10 countreies by sales */
SELECT TOP 10 cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.BillToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;

/*Problem Statement 37: Number of orders each employee has taken for CustomerIDs between A and AO */
SELECT 
    e.BusinessEntityID AS EmployeeID,
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name BETWEEN 'A' AND 'AO'
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
ORDER BY OrderCount DESC;

/*Problem Statement 38: Orderdate of most expensive order */
SELECT TOP 1 OrderDate, TotalDue, SalesOrderID
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

/*Problem Statement 39: Product name and total revenue from that product */
SELECT p.Name AS ProductName, SUM(od.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail od
JOIN Production.Product p ON od.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC;

/*Problem Statement 40: Supplierid and number of products offered */
SELECT pv.BusinessEntityID AS SupplierID, COUNT(pv.ProductID) AS TotalProductsOffered
FROM Purchasing.ProductVendor AS pv
GROUP BY pv.BusinessEntityID
ORDER BY TotalProductsOffered DESC;

/*Problem Statement 41: Top ten customers based on their buisness */
SELECT TOP 10 soh.CustomerID, p.FirstName + ' ' + p.LastName AS CustomerName, SUM(soh.TotalDue) AS TotalBusiness
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
GROUP BY soh.CustomerID, p.FirstName, p.LastName
ORDER BY TotalBusiness DESC;

/*Problem Statement 42: What is the total revenue of the company */
SELECT SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader;