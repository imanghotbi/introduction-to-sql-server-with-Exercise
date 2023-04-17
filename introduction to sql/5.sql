---------------------------------------------------------------------
-- Derived Tables
---------------------------------------------------------------------

USE TSQLV4;

SELECT *
FROM (SELECT custid, companyname
      FROM Sales.Customers
      WHERE country = N'USA') AS USACusts;
GO

---------------------------------------------------------------------
-- Assigning Column Aliases
---------------------------------------------------------------------

-- Following fails

SELECT
  YEAR(orderdate) AS orderyear,
  COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY orderyear;

GO

-- Listing 5-1 Query with a Derived Table using Inline Aliasing Form
SELECT D.orderyear, COUNT(DISTINCT D.custid) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, custid
      FROM Sales.Orders) AS D
GROUP BY D.orderyear;

SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate);

-- External column aliasing
SELECT D.orderyear, COUNT(DISTINCT D.custid) AS numcusts
FROM (SELECT YEAR(orderdate), custid
      FROM Sales.Orders) AS D(orderyear, custid)
GROUP BY D.orderyear
ORDER BY numcusts;
GO

---------------------------------------------------------------------
-- Using Arguments
---------------------------------------------------------------------

-- Yearly Count of Customers handled by Employee 3
DECLARE @empid AS INT = 3;

SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, custid
      FROM Sales.Orders
      WHERE empid = @empid) AS D
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Nesting
---------------------------------------------------------------------

-- Listing 5-2 Query with Nested Derived Tables
SELECT orderyear, numcusts
FROM (SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
      FROM (SELECT YEAR(orderdate) AS orderyear, custid
            FROM Sales.Orders) AS D1
      GROUP BY orderyear) AS D2
WHERE numcusts > 70;

SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate)
HAVING COUNT(DISTINCT custid) > 70;

---------------------------------------------------------------------
-- Multiple References
---------------------------------------------------------------------

-- Listing 5-3 Multiple Derived Tables Based on the Same Query
SELECT Cur.orderyear, 
  Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
  Cur.numcusts - Prv.numcusts AS growth
FROM (SELECT YEAR(orderdate) AS orderyear,
        COUNT(DISTINCT custid) AS numcusts
      FROM Sales.Orders
      GROUP BY YEAR(orderdate)) AS Cur
  LEFT OUTER JOIN
     (SELECT YEAR(orderdate) AS orderyear,
        COUNT(DISTINCT custid) AS numcusts
      FROM Sales.Orders
      GROUP BY YEAR(orderdate)) AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;

---------------------------------------------------------------------
-- Common Table Expressions
---------------------------------------------------------------------

WITH USACusts AS
(
  SELECT custid, companyname
  FROM Sales.Customers
  WHERE country = N'USA'
)
SELECT * FROM USACusts;
GO

---------------------------------------------------------------------
-- Assigning Column Aliases
---------------------------------------------------------------------

-- Inline column aliasing
WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

-- External column aliasing
WITH C(orderyear, custid) AS
(
  SELECT YEAR(orderdate), custid
  FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Using Arguments
---------------------------------------------------------------------

DECLARE @empid AS INT = 3;

WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
  WHERE empid = @empid
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Defining Multiple CTEs
---------------------------------------------------------------------
--SELECT * FROM Sales.Orders
;WITH C1 AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
  WHERE shipperid = 2
),
C2 AS
(
  SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
  FROM C1
  GROUP BY orderyear
)
SELECT orderyear, numcusts
FROM C2
WHERE numcusts > 70;

---------------------------------------------------------------------
-- Multiple References
---------------------------------------------------------------------

WITH YearlyCount AS
(
  SELECT YEAR(orderdate) AS orderyear,
    COUNT(DISTINCT custid) AS numcusts
  FROM Sales.Orders
  GROUP BY YEAR(orderdate)
)
SELECT Cur.orderyear, 
  Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
  Cur.numcusts - Prv.numcusts AS growth
FROM YearlyCount AS Cur
  LEFT OUTER JOIN YearlyCount AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;
GO

-- Class Exercise: سه کالای پرفروشی که توسط مشتریان کشوری که بیشترین فروش را داشته محاسبه کنید

productname		TotalVal
--------------- ----------
Product QDOMO	41356.33
Product VJXYN	17182.52
Product WUXYK	15648.05

(3 row(s) affected)

--Solution:
;WITH GreatestCountry
AS (SELECT TOP 1
           C.country,
           SUM(OD.qty * OD.unitprice * (1 - OD.discount)) AS TotalVal
    FROM Sales.Customers C
        INNER JOIN Sales.Orders O
            ON O.custid = C.custid
        INNER JOIN Sales.OrderDetails OD
            ON OD.orderid = O.orderid
    GROUP BY C.country
    ORDER BY TotalVal DESC),
     GreatestCountryCusomers
AS (SELECT C.custid, GC.country
    FROM Sales.Customers C
	INNER JOIN GreatestCountry GC ON GC.country = C.country
    /*WHERE country IN (SELECT country FROM GreatestCountry)*/)
SELECT TOP 3 P.productname,
       CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount)) AS DECIMAL(10, 2)) AS TotalVal,
	   GC.country AS Country
FROM GreatestCountryCusomers GC
    INNER JOIN Sales.Orders O
        ON O.custid = GC.custid
    INNER JOIN Sales.OrderDetails OD
        ON OD.orderid = O.orderid
    INNER JOIN Production.Products P
        ON P.productid = OD.productid
GROUP BY P.productname, GC.country
ORDER BY TotalVal DESC;

---------------------------------------------------------------------
-- Recursive CTEs (Optional, Advanced)
---------------------------------------------------------------------

WITH EmpsCTE AS
(
  SELECT empid, mgrid, firstname, lastname
  FROM HR.Employees
  WHERE empid = 2
  
  UNION ALL
  
  SELECT C.empid, C.mgrid, C.firstname, C.lastname
  FROM EmpsCTE AS P
    INNER JOIN HR.Employees AS C
      ON C.mgrid = P.empid
)
SELECT empid, mgrid, firstname, lastname
FROM EmpsCTE
WHERE EmpsCTE.empid <> 2;
GO

SELECT empid, mgrid, * FROM HR.Employees
GO

-- Class Exercise:
-- Write a query that returns managerial hierarchy for employee Sven Mortensen (empid = 5)
-- Tables involved: TSQLV4 database, Orders table

-- Desired output:
empid		mgrid		firstname	lastname
----------- ----------- ---------- -----------
5			2			Sven		Mortensen
2			1			Don			Funk
1			NULL		SARA		Davis

(3 row(s) affected)

-- Solution
;WITH EmpsCTE AS
(
  SELECT empid, mgrid, firstname, lastname
  FROM HR.Employees
  WHERE empid = 5
  
  UNION ALL
  
  SELECT C.empid, C.mgrid, C.firstname, C.lastname
  FROM EmpsCTE AS P
    INNER JOIN HR.Employees AS C
      ON C.empid = P.mgrid
)
SELECT empid, mgrid, firstname, lastname
FROM EmpsCTE;
GO

---------------------------------------------------------------------
-- Views
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Views Described
---------------------------------------------------------------------

-- Named Query
-- Creating USACusts View
DROP VIEW IF EXISTS Sales.USACusts;
GO
CREATE VIEW Sales.USACusts
AS

SELECT
  custid, companyname, contactname, contacttitle, [address],
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

SELECT *
FROM Sales.USACusts;
GO

---------------------------------------------------------------------
-- Views and ORDER BY
---------------------------------------------------------------------

-- ORDER BY in a View is not Allowed

CREATE OR ALTER VIEW Sales.USACusts
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region;
GO


-- Instead, use ORDER BY in Outer Query
SELECT custid, companyname, region
FROM Sales.USACusts
ORDER BY region;
GO

-- Do not Rely on TOP 
ALTER VIEW Sales.USACusts
AS
SELECT TOP (100) PERCENT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region;
GO

-- Query USACusts
SELECT custid, companyname, region
FROM Sales.USACusts;
GO

ALTER VIEW Sales.USACusts
AS
SELECT TOP (60) PERCENT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region;
GO

ALTER VIEW Sales.USACusts
AS
SELECT TOP (50)
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region;
GO

-- DO NOT rely on OFFSET-FETCH, even if for now the engine does return rows in rder
ALTER VIEW Sales.USACusts
AS
SELECT 
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region
OFFSET 0 ROWS;
GO

-- Query USACusts
SELECT custid, companyname, region
FROM Sales.USACusts;
GO

-- Class Exercise: Create a view that returns all customers who have purchased 
-- the most expensive product(s).

-- Class Exercise: Return all Products that not purchased by luxury customers.

--Desired Output
custid	contactname
------- --------------------
5		Higginbotham, Tom
7		Bansal, Dushyant
20		Kane, John
32		Krishnan, Venky
34		Zhang, Frank
39		Song, Lolan
51		Taylor, Maurice
59		Wang, Tony
62		Misiec, Anna
63		Veronesi, Giorgio
64		Gaffney, Lawrie
65		Moore, Michael
70		Makovac, Zrinka
73		Gonzalez, Nuria
74		MacDonald, Scott
75		Downs, Chris
77		Didcock, Cliff
80		Toh, Karen
89		Smith Jr., Ronaldo

(19 rows affected)

--Solution
CREATE OR ALTER VIEW Sales.LuxuryCustomers
AS
SELECT custid, contactname
FROM Sales.Customers
WHERE custid IN
      (
          SELECT O.custid
          FROM Sales.Orders O
              INNER JOIN Sales.OrderDetails OD
                  ON OD.orderid = O.orderid
                     AND OD.productid IN
                         (
                             SELECT TOP 1 WITH TIES
                                    P.productid
                             FROM Production.Products P
                             ORDER BY P.unitprice DESC
                         )
      );
GO

SELECT TOP 1 WITH TIES * FROM Production.Products ORDER BY unitprice DESC
GO

SELECT * FROM Sales.LuxuryCustomers
GO

SELECT P.* FROM Sales.LuxuryCustomers LC
INNER JOIN Sales.Orders O ON LC.custid = O.custid
INNER JOIN Sales.OrderDetails OD ON OD.orderid = O.orderid
RIGHT JOIN Production.Products P ON P.productid = OD.productid
WHERE OD.productid IS NULL
GO

SELECT * FROM Production.Products P
LEFT JOIN (SELECT DISTINCT OD.productid FROM Sales.LuxuryCustomers LC
			INNER JOIN Sales.Orders O ON O.custid = LC.custid
			INNER JOIN Sales.OrderDetails OD ON OD.orderid = O.orderid) AS LCO ON LCO.productid = P.productid
WHERE LCO.productid IS NULL
GO

SELECT * FROM Production.Products P
WHERE P.productid NOT IN (SELECT DISTINCT OD.productid FROM Sales.LuxuryCustomers LC
			INNER JOIN Sales.Orders O ON O.custid = LC.custid
			INNER JOIN Sales.OrderDetails OD ON OD.orderid = O.orderid)

---------------------------------------------------------------------
-- Inline User Defined Functions
---------------------------------------------------------------------

-- Inline Table-Valued Functions (Parameterized Views)

-- Creating GetCustOrders function
USE TSQLV4;
DROP FUNCTION IF EXISTS dbo.GetCustOrders;
GO
CREATE FUNCTION dbo.GetCustOrders(@cid AS INT) RETURNS TABLE
AS
RETURN
  SELECT orderid, custid, empid, orderdate, requireddate,
    shippeddate, shipperid, freight, shipname, shipaddress, shipcity,
    shipregion, shippostalcode, shipcountry
  FROM Sales.Orders
  WHERE custid = @cid;
GO

-- Test Function
SELECT * --orderid, custid
FROM dbo.GetCustOrders(10) AS O;

SELECT O.orderid, O.custid, OD.productid, OD.qty
FROM dbo.GetCustOrders(5) AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid;
GO

-- Cleanup
DROP FUNCTION IF EXISTS dbo.GetCustOrders;
GO
SELECT * FROM Sales.Customers
-- Class Exercise: فانکشنی بنویسید که نام یک مشتری و یک سال را به عنوان ورودی دریافت کند
-- و مجموع سفارشات مشتری (بدون محاسبه تخفیف) و مجموع تخفیفات آن را برگرداند

-- Solution
DROP FUNCTION IF EXISTS dbo.GetCustomerOrderValue;
GO
CREATE OR ALTER FUNCTION dbo.GetCustomerOrderValue
(
    @CName AS NVARCHAR(30),
    @Year INT
	--@DateFrom DATE,
	--@DateTo DATE
)
RETURNS TABLE
AS
RETURN SELECT C.custid, C.contactname,
              CAST(SUM(OD.qty * OD.unitprice) AS DECIMAL(10, 2)) AS TotalValue,
              CAST(SUM(OD.qty * OD.unitprice * OD.discount) AS DECIMAL(10, 2)) AS TotalDiscount,
			  @Year AS OrderYearParameter,
			  YEAR(O.orderdate) AS OrderYear
       FROM Sales.Customers C
           INNER JOIN Sales.Orders O
               ON O.custid = C.custid
           INNER JOIN Sales.OrderDetails OD
               ON OD.orderid = O.orderid
       WHERE C.contactname = @CName
             AND YEAR(O.orderdate) = @Year
       GROUP BY C.custid, C.contactname, YEAR(O.orderdate);
GO

SELECT * FROM dbo.GetCustomerOrderValue(N'Cunningham, Conor', 2014)
SELECT * FROM dbo.GetCustomerOrderValue(N'Ilyina, Julia', 2015)
SELECT * FROM dbo.GetCustomerOrderValue(N'Jaffe, David', 2016)

---------------------------------------------------------------------
-- APPLY
---------------------------------------------------------------------

SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
  CROSS JOIN HR.Employees AS E;

SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
  CROSS APPLY HR.Employees AS E;

-- 3 most recent orders for each customer
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
  CROSS APPLY
    (SELECT TOP (3) orderid, empid, orderdate, requireddate 
     FROM Sales.Orders AS O
     WHERE O.custid = C.custid
     ORDER BY orderdate DESC, orderid DESC) AS A
ORDER BY C.custid;

-- With OFFSET-FETCH
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
  CROSS APPLY
    (SELECT orderid, empid, orderdate, requireddate 
     FROM Sales.Orders AS O
     WHERE O.custid = C.custid
     ORDER BY orderdate DESC, orderid DESC
     OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY) AS A;

-- 3 most recent orders for each customer, preserve customers
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
  OUTER APPLY
    (SELECT TOP (3) orderid, empid, orderdate, requireddate 
     FROM Sales.Orders AS O
     WHERE O.custid = C.custid
     ORDER BY orderdate DESC, orderid DESC) AS A;

-- Creation Script for the Function TopOrders
DROP FUNCTION IF EXISTS dbo.TopOrders;
GO
CREATE FUNCTION dbo.TopOrders
  (@custid AS INT, @n AS INT)
  RETURNS TABLE
AS
RETURN
  SELECT TOP (@n) orderid, empid, orderdate, requireddate 
  FROM Sales.Orders
  WHERE custid = @custid
  ORDER BY orderdate DESC, orderid DESC;
GO

DECLARE @Num INT = 5;
SELECT
  C.custid, C.companyname,
  A.orderid, A.empid, A.orderdate, A.requireddate 
FROM Sales.Customers AS C
CROSS APPLY dbo.TopOrders(C.custid, @Num) AS A
ORDER BY C.custid, A.orderdate;
