
USE TSQLV4;
-- Default
ALTER TABLE Sales.Orders
  ADD CONSTRAINT DFT_Orders_orderts
  DEFAULT(GETDATE()) FOR orderdate;
GO

DROP TABLE IF EXISTS Sales.MyTable

CREATE TABLE Sales.MyTable
(
	OrderId int not NULL PRIMARY KEY,
	EmpId int NOT NULL,
	qty int not null default 0
);

USE TSQLV4;

---------------------------------------------------------------------
-- The FROM Clause
---------------------------------------------------------------------

SELECT orderid, custid, empid, orderdate, freight
FROM Sales.Orders;

---------------------------------------------------------------------
-- The WHERE Clause
---------------------------------------------------------------------

SELECT orderid, empid, custid, orderdate, freight
FROM Sales.Orders
WHERE custid = 71;

SELECT *
FROM Sales.Customers
WHERE custid = 71;

---------------------------------------------------------------------
-- The GROUP BY Clause
---------------------------------------------------------------------

SELECT empid AS Employee_ID, orderdate, YEAR(orderdate) OrderYear
FROM Sales.Orders
WHERE custid = 71

SELECT empid, /*orderdate,*/ YEAR(orderdate) AS orderyear, COUNT(orderid) AS OrderCount
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate);

SELECT
  empid,
  YEAR(orderdate) AS orderyear,
  SUM(freight) AS totalfreight,
  COUNT(orderid) AS numorders
FROM Sales.Orders
WHERE custid = 71 AND orderdate BETWEEN '2014-07-05' AND '2015-10-09' --AND YEAR(orderdate) = 2015 
GROUP BY empid, YEAR(orderdate)
ORDER BY orderyear, totalfreight DESC

/*SELECT empid, YEAR(orderdate) AS orderyear, freight
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate);*/

SELECT
  YEAR(orderdate) AS orderyear,
  SUM(freight) AS totalfreight,
  AVG(freight) AS AvgFreight,
  MIN(freight) AS MinFreight,
  MAX(freight) AS MaxFreight,
  COUNT(orderid) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY YEAR(orderdate)

SELECT 
  empid, 
  YEAR(orderdate) AS orderyear, 
  COUNT(custid) AS numcusts
FROM Sales.Orders
GROUP BY empid, YEAR(orderdate)
ORDER BY empid, orderyear;

SELECT 
  empid, 
  YEAR(orderdate) AS orderyear, 
  COUNT(custid) AS NumOrders,
  COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY empid, YEAR(orderdate)
ORDER BY empid, orderyear;

SELECT DISTINCT
       custid
FROM Sales.Orders
WHERE empid = 1
      AND orderdate
      BETWEEN '2014-01-01' AND '2014-12-31';

---------------------------------------------------------------------
-- The HAVING Clause
---------------------------------------------------------------------

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(orderid) AS OrderCount
FROM Sales.Orders
WHERE custid = 71 --AND COUNT(orderid) > 1
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(orderid) > 2;

---------------------------------------------------------------------
-- The SELECT Clause
---------------------------------------------------------------------

SELECT orderid AS orderdate
FROM Sales.Orders;

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1;


/*SELECT orderid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE orderyear > 2015;*/


SELECT orderid, YEAR(orderdate) orderyear
FROM Sales.Orders
WHERE orderdate BETWEEN '2015-01-01' AND '2015-12-30' --YEAR(orderdate) > 2015;


/*SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING numorders > 1;*/


SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1;

-- Listing 2-2: Query Returning Duplicate Rows
SELECT empid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71;

-- Listing 2-3: Query With a DISTINCT Clause
SELECT DISTINCT empid, YEAR(orderdate) AS orderyear--, orderdate
FROM Sales.Orders
WHERE custid = 71;


/*SELECT orderid,
  YEAR(orderdate) AS orderyear,
  orderyear + 1 AS nextyear
FROM Sales.Orders;*/


SELECT orderid,
  YEAR(orderdate) AS orderyear,
  YEAR(orderdate) + 1 AS nextyear
FROM Sales.Orders;

---------------------------------------------------------------------
-- The ORDER BY Clause
---------------------------------------------------------------------

-- Listing 2-4: Query Demonstrating the ORDER BY Clause
SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1
ORDER BY empid DESC, orderyear DESC, numorders DESC;

SELECT * FROM Sales.Orders WHERE custid = 71 AND empid = 8

SELECT empid, firstname, lastname, country--, hiredate
FROM HR.Employees
ORDER BY hiredate;


/*SELECT DISTINCT country
FROM HR.Employees
ORDER BY empid;*/


---------------------------------------------------------------------
-- The TOP and OFFSET-FETCH Filters
---------------------------------------------------------------------

---------------------------------------------------------------------
-- The TOP Filter
---------------------------------------------------------------------

-- Listing 2-5: Query Demonstrating the TOP Option

SELECT TOP (500) orderid, orderdate, custid, empid
FROM Sales.Orders 
ORDER BY orderdate DESC;

SELECT TOP (10) PERCENT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

-- Listing 2-6: Query Demonstrating TOP with Unique ORDER BY List

SELECT TOP (5) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC--, empid ASC;

SELECT TOP (5) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, empid ASC;

SELECT TOP (5) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC--, empid ASC;
