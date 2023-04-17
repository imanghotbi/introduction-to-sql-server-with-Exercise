---------------------------------------------------------------------
-- Working with Character Data
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Collation
---------------------------------------------------------------------

SELECT name, description
FROM master.sys.fn_helpcollations();

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname = N'davis';

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname COLLATE SQL_Latin1_General_CP1_CS_AS = N'Davis';

EXEC sp_help 'HR.Employees'

---------------------------------------------------------------------
-- Operators and Functions
---------------------------------------------------------------------

-- Concatenation
SELECT empid
      ,mgrid
      ,firstname + N' ' + lastname AS fullname
FROM HR.Employees;

SELECT * FROM HR.Employees

SELECT empid,
       mgrid,
       firstname + N' ' + lastname AS fullname,
       empid + mgrid AS NumericSum,
       CAST(empid AS VARCHAR(2)) + CAST(mgrid AS VARCHAR(2)) AS ConcatInt
FROM HR.Employees;

-- Listing 2-7: Query Demonstrating String Concatenation
SELECT custid, country, region, city,
  country + N',' + region + N',' + city AS location
FROM Sales.Customers;

-- convert NULL to empty string
SELECT custid, country, region, city,
  country + COALESCE( N',' + region, N'') + N',' + city AS location
FROM Sales.Customers;

EXEC sp_help 'Sales.Customers'

SELECT COALESCE(NULL, NULL, NULL, 20)

-- using the CONCAT function
SELECT custid, --country, region, city,
  CONCAT(country, N', ' + region, N', ' + city, N', ' + CAST(custid AS VARCHAR(2))) AS location
FROM Sales.Customers;

-- Class Exercise: Write a query on Sales.Customers that concatenate country, region and city
-- and for NULL Values in region puts 'WA'

SELECT custid,
       country,
       region,
       city,
       country + N',' + CASE
                            WHEN region IS NULL THEN
                                'WA'
                            ELSE
                                region
                        END + N',' + city AS location
FROM Sales.Customers;

SELECT custid,
       country,
       region,
       city,
       CONCAT(country, ISNULL(N', ' + region, ', WA'), N', ' + city, custid) AS location
FROM Sales.Customers;

-- Functions
SELECT SUBSTRING('abcde', 1, 3); -- 'abc'

SELECT custid, phone, SUBSTRING(phone, 6, 5)
FROM Sales.Customers

SELECT RIGHT('abcde', 2); -- 'cde'

SELECT LEFT('abcde', 3); -- abc

SELECT LEN(N'abcde'); -- 5

SELECT phone
      ,LEN(phone) AS lenphone
FROM Sales.Customers
--WHERE ISNUMERIC(phone) = 0
--WHERE LEN(phone)<10;

SELECT DATALENGTH(N'abcde'); -- 10

SELECT CHARINDEX('b', 'Itzik Ben-Gan'); -- 7

SELECT CHARINDEX('b', 'Itzik Ben-Gan' COLLATE SQL_Latin1_General_CP1_CS_AS);

SELECT phone, CHARINDEX('171', phone) 
FROM Sales.Customers
--WHERE CHARINDEX('171', phone) > 0

SELECT PATINDEX('%[g-z]%', 'abcd1235efgh'); -- 6

SELECT REPLACE('1-a 2-b', '-', ''); -- '1:a 2:b'

-- Tricky Example
SELECT empid, lastname, --LEN(lastname), REPLACE(lastname, 'e', ''), LEN(REPLACE(lastname, 'e', '')),
  LEN(lastname) - LEN(REPLACE(lastname, 'e', '')) AS numoccur
FROM HR.Employees;

SELECT REPLICATE('abc', 3); -- 'abcabcabc'

-- Tricky Example
SELECT supplierid,
	REPLICATE('0', 9) + CAST(supplierid AS VARCHAR(10)),
  RIGHT(REPLICATE('0', 9) + CAST(supplierid AS VARCHAR(10)), 10) AS strsupplierid
FROM Production.Suppliers;

SELECT STUFF('wxyz', 2, 2, 'abc'); -- 'wabcz'

SELECT UPPER('Itzik Ben-Gan'); -- 'ITZIK BEN-GAN'

SELECT LOWER('Itzik Ben-Gan'); -- 'itzik ben-gan'

SELECT RTRIM('   abc   '); -- '   abc'

SELECT LTRIM('   abc   '); -- 'abc   '

SELECT RTRIM(LTRIM('   abc   ')); -- 'abc'

SELECT TRIM('   abc   '); -- 'abc'

SELECT FORMAT(1759, '0000000000'); -- '0000001759'

SELECT supplierid, FORMAT(supplierid, '0000000000') AS strsupplierid
FROM Production.Suppliers;

-- STRING_SPLIT
SELECT CAST(S.value AS INT) AS myvalue
FROM STRING_SPLIT('10248-10249-10250', '-') AS S;

/*
myvalue
-----------
10248
10249
10250
*/

---------------------------------------------------------------------
-- LIKE Predicate
---------------------------------------------------------------------

-- Last name starts with D
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';

-- Second character in last name is e
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'_e%';

-- First character in last name is A, B, C or D
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[ABCD]%';

-- First character in last name is A through E
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[A-E]%';

UPDATE HR.Employees
SET lastname = 'doyle'
WHERE empid = 9;

UPDATE HR.Employees
SET lastname = 'Doyle'
WHERE empid = 9;

-- First character in last name is not A through E
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[^A-E]%';

-- Class Exercise: Return customers with companyname ends with '[k-w]' 
-- and contactname containing the letter 'e' twice or more
-- Tables involved: Sales.Customers table

-- Solution
SELECT custid, companyname, contactname
FROM Sales.Customers
WHERE companyname LIKE '%[k-w]' AND contactname LIKE '%e%e%';

---------------------------------------------------------------------
-- Working with Date and Time Data
---------------------------------------------------------------------

-- Literals
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate = '20160212';

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate = CAST('20160212' AS DATE);

SELECT '20160212', CAST('20160212' AS DATE)  AS DateTest

SELECT CONVERT(DATE, '02/12/2016', 101);

SELECT CONVERT(DATE, '02/12/2016', 103);

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE YEAR(orderdate) = 2015;

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20150101' AND orderdate < '20160101';

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE YEAR(orderdate) = 2016 AND MONTH(orderdate) = 2;

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20160201' AND orderdate < '20160301';

-- Persian Calendar Format
SELECT FORMAT(CAST('2016-02-01' AS DATETIME), 'yyyy/MM/dd - HH:mm:ss.ms', 'fa')

SELECT FORMAT(GETDATE(), 'yyyy MMM dd', 'fa')

SELECT FORMAT(GETDATE(), 'yyyy MMM dd ddd', 'fa')

-- Functions

-- Current Date and Time
SELECT
  GETDATE()           AS [GETDATE],
  CURRENT_TIMESTAMP   AS [CURRENT_TIMESTAMP],
  GETUTCDATE()        AS [GETUTCDATE],
  SYSDATETIME()       AS [SYSDATETIME],
  SYSUTCDATETIME()    AS [SYSUTCDATETIME],
  SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];

SELECT
  CAST(SYSDATETIME() AS DATE) AS [current_date],
  CAST(SYSDATETIME() AS TIME) AS [current_time];

-- SWITCHOFFSET
SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '-05:00');
SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '+00:00');

-- AT TIME ZONE

SELECT name, current_utc_offset
FROM sys.time_zone_info;

-- DATEADD
SELECT DATEADD(YEAR, 1, '20160212');

SELECT DATEADD(DAY, -12, '20160212');

SELECT DATEADD(SECOND, 10, GETDATE());

SELECT DATEADD(WEEK, 10, GETDATE());

SELECT FORMAT(DATEADD(WEEK, 10, GETDATE()), 'yyyy/MM/dd - HH:mm:ss.ms', 'fa') 

SELECT GETDATE() + 100

-- DATEDIFF
SELECT DATEDIFF(MONTH, '20150212', '20160212');

SELECT DATEDIFF_BIG(MILLISECOND, '00010101', '20160212');

SELECT DATEDIFF(MILLISECOND, '00010101', '20160212');

SELECT DATEADD(DAY, DATEDIFF(DAY, '19000101', SYSDATETIME()), '19000101');

SELECT CAST(CAST(GETDATE() AS DATE) AS DATETIME)

SELECT DATEADD(MONTH, DATEDIFF(MONTH, '19000101', SYSDATETIME()), '19000101');

SELECT DATEADD(YEAR, DATEDIFF(YEAR, '18991231', SYSDATETIME()), '18991231');

SELECT DATEADD(YEAR, DATEDIFF(YEAR, '18990101', SYSDATETIME()), '18990101');

-- DATEPART

SELECT DATEPART(MONTH, '20160212');

SELECT DATEPART(DAYOFYEAR, GETDATE());

--SELECT DATEPART(DAYOFYEAR, FORMAT(DATEADD(WEEK, 10, GETDATE()), 'yyyy/MM/dd - HH:mm:ss.ms', 'fa')) 

-- DAY, MONTH, YEAR

SELECT
  DAY('20160212') AS theday,
  MONTH('20160212') AS themonth,
  YEAR('20160212') AS theyear;

-- DATENAME
SELECT DATENAME(month, '20160212');

SELECT DATENAME(year, '20160212');

SELECT DATENAME(DAY, '20160212');

SELECT DATENAME(WEEKDAY, '20160212');

SELECT DATENAME(DAYOFYEAR, '20160212');

SELECT DATENAME(QUARTER, '20160812');

SELECT DATENAME(WEEK, '20160912');

-- ISDATE
SELECT ISDATE('20160212');
SELECT ISDATE('20160230');

SELECT *
FROM Sales.Orders
WHERE ISDATE(CAST(orderdate AS DATETIME)) = 0;

-- EOMONTH
SELECT EOMONTH(SYSDATETIME());

SELECT EOMONTH('20160212');

-- orders placed on last day of month
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate);

-- orders placed on 2 days before the last day of month
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = DATEADD(DAY, -2, EOMONTH(orderdate));

---------------------------------------------------------------------
-- Querying Metadata
---------------------------------------------------------------------

-- Catalog Views
USE TSQLV4;

SELECT SCHEMA_NAME(schema_id) AS table_schema_name, name AS table_name
FROM sys.tables;

SELECT 
  name AS column_name,
  TYPE_NAME(system_type_id) AS column_type,
  max_length,
  collation_name,
  is_nullable
FROM sys.columns
WHERE object_id = OBJECT_ID(N'Sales.Orders');

SELECT OBJECT_ID(N'Sales.Orders')

-- Information Schema Views
SELECT *--TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = N'BASE TABLE';

SELECT 
  COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, 
  COLLATION_NAME, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = N'Sales'
  AND TABLE_NAME = N'Orders'

SELECT 'select count(*) from ' + TABLE_SCHEMA + '.' + TABLE_NAME + ' where orderid = 11075'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME = N'orderid';

select count(*) from Sales.Orders where orderid = 11075
select count(*) from Sales.OrderDetails where orderid = 11075
select count(*) from Sales.OrderValues where orderid = 11075
select count(*) from Sales.MyTable where orderid = 11075

SELECT 'delete from ' + T.TABLE_SCHEMA + '.' + T.TABLE_NAME + ' where orderid = 20'
FROM INFORMATION_SCHEMA.COLUMNS C
    INNER JOIN INFORMATION_SCHEMA.TABLES T
        ON T.TABLE_NAME = C.TABLE_NAME
           AND T.TABLE_SCHEMA = C.TABLE_SCHEMA
WHERE C.COLUMN_NAME = N'orderid'
      AND T.TABLE_TYPE = N'BASE TABLE';

delete from Sales.Orders where orderid = 20
delete from Sales.OrderDetails where orderid = 20
delete from Sales.MyTable where orderid = 20

-- System Stored Procedures and Functions
EXECUTE sys.sp_tables;

EXEC sys.sp_help @objname = N'Sales.Orders';

EXEC sp_help 'Sales.Orders'

EXEC sys.sp_columns
  @table_name = N'Orders',
  @table_owner = N'Sales';

EXEC sys.sp_helpconstraint
  @objname = N'Sales.Orders';

EXEC sys.sp_helpindex
  @objname = N'Sales.Orders';

SELECT
  DATABASEPROPERTYEX(N'TSQLV4', 'Collation');

---------------------------------------------------------------------
-- CROSS Joins
---------------------------------------------------------------------

USE TSQLV4;

-- SQL-92
SELECT C.custid, E.empid, *
FROM Sales.Customers AS C
  CROSS JOIN HR.Employees AS E
--WHERE c.custid = 1;

SELECT * FROM Sales.Customers	--91
SELECT * FROM HR.Employees		--9

-- SQL-89
SELECT C.custid, E.empid
FROM Sales.Customers AS C, HR.Employees AS E;

-- Self Cross-Join
SELECT
  E1.empid, E1.firstname, E1.lastname,
  E2.empid, E2.firstname, E2.lastname
FROM HR.Employees AS E1 
  CROSS JOIN HR.Employees AS E2;
GO

-- All numbers from 1 - 1000

-- Auxiliary table of digits
USE TSQLV4;

DROP TABLE IF EXISTS dbo.Digits;

CREATE TABLE dbo.Digits(digit INT NOT NULL PRIMARY KEY);

INSERT INTO dbo.Digits(digit)
  VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

SELECT digit FROM dbo.Digits;
GO

-- All numbers from 1 - 1000
SELECT D1.digit, D2.digit, D3.digit,
D3.digit * 100 + D2.digit * 10 + D1.digit + 1 AS n
FROM         dbo.Digits AS D1
  CROSS JOIN dbo.Digits AS D2
  CROSS JOIN dbo.Digits AS D3
ORDER BY n;

---------------------------------------------------------------------
-- INNER Joins
---------------------------------------------------------------------

USE TSQLV4;

-- SQL-92
SELECT E.empid, O.empid, E.firstname + ' ' + E.lastname AS FullName, 
O.orderid
FROM HR.Employees AS E
  INNER JOIN Sales.Orders AS O
    ON E.empid = O.empid
WHERE E.empid = 5;

SELECT * FROM HR.Employees
SELECT * FROM Sales.Orders

EXEC sp_help 'Sales.Orders'
EXEC sp_help 'HR.Employees'

-- SQL-89
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E, Sales.Orders AS O
WHERE E.empid = O.empid;
GO

SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E, Sales.Orders AS O;
GO

---------------------------------------------------------------------
-- More Join Examples
---------------------------------------------------------------------

-- Return orders placed on the 15 Day of the Month and The Customers are from UK and USA

SELECT O.empid, COUNT(O.orderid) AS OrderCount
FROM Sales.Orders AS O
    INNER JOIN Sales.Customers AS C
        ON C.custid = O.custid
WHERE DAY(O.orderdate) = 15
      AND C.country IN ( 'UK', 'USA' )
GROUP BY O.empid;
GO

SELECT * FROM Sales.Orders
SELECT * FROM Sales.Customers

SELECT DAY(O.orderdate) AS [DayOfMonth], COUNT(O.orderid) AS OrderCount
FROM Sales.Orders AS O
--INNER JOIN HR.Employees E ON E.empid = O.empid
--INNER JOIN Sales.Customers AS C
--    ON C.custid = O.custid
/*WHERE DAY(O.orderdate) = 15
      AND C.country IN ( 'UK', 'USA' )*/
GROUP BY DAY(O.orderdate)
ORDER BY OrderCount DESC
---------------------------------------------------------------------
-- Non-Equi Joins
---------------------------------------------------------------------

-- Unique pairs of employees
SELECT
  E1.empid, E1.firstname, E1.lastname,
  E2.empid, E2.firstname, E2.lastname
FROM HR.Employees AS E1
  INNER JOIN HR.Employees AS E2
    ON E1.empid < E2.empid
ORDER BY E1.empid

---------------------------------------------------------------------
-- Multi-Join Queries
---------------------------------------------------------------------

SELECT 
  C.custid, C.companyname, O.orderid,
  OD.productid, OD.qty
FROM Sales.Customers AS C					--91
  INNER JOIN Sales.Orders AS O				--830
    ON C.custid = O.custid
  INNER JOIN Sales.OrderDetails AS OD		--2155
    ON O.orderid = OD.orderid;

---------------------------------------------------------------------
-- Fundamentals of Outer Joins 
---------------------------------------------------------------------

-- Customers and their orders, including customers with no orders
SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C
  LEFT /*OUTER*/ JOIN Sales.Orders AS O
    ON C.custid = O.custid;

-- Customers with no orders
SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
WHERE O.orderid IS NULL;

-- SELECT * FROM Sales.Orders WHERE custid IN(22, 57)

---------------------------------------------------------------------
-- Beyond the Fundamentals of Outer Joins
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Including Missing Values
---------------------------------------------------------------------

SELECT DATEADD(day, n-1, CAST('20140101' AS DATE)) AS orderdate
FROM dbo.Nums
WHERE n <= DATEDIFF(day, '20140101', '20161231') + 1
ORDER BY orderdate;

SELECT DATEDIFF(day, '20140101', '20161231')

SELECT * FROM dbo.Nums

SELECT DATEADD(day, Nums.n - 1, CAST('20140101' AS DATE)) AS orderdate,
  O.orderid, O.custid, O.empid
FROM dbo.Nums
  LEFT OUTER JOIN Sales.Orders AS O
    ON DATEADD(day, Nums.n - 1, CAST('20140101' AS DATE)) = O.orderdate
WHERE Nums.n <= DATEDIFF(day, '20140101', '20161231') + 1
AND O.orderid IS NULL
ORDER BY orderdate;

---------------------------------------------------------------------
-- Filtering Attributes from Non-Preserved Side of Outer Join
---------------------------------------------------------------------

SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid AND O.orderdate >= '20160101'
WHERE /*O.orderdate >= '20160101' 
	OR*/ o.orderid IS NULL;

---------------------------------------------------------------------
-- Using Outer Joins in a Multi-Join Query
---------------------------------------------------------------------

SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
WHERE o.orderid IS NULL;

-- Option 1: use outer join all along
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
  LEFT OUTER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
WHERE O.orderid IS NULL;

-- Option 2: change join order
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Orders AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
  RIGHT OUTER JOIN Sales.Customers AS C
     ON O.custid = C.custid
WHERE O.orderid IS NULL;

-- Option 3: use parentheses
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
  LEFT OUTER JOIN
      (Sales.Orders AS O
         INNER JOIN Sales.OrderDetails AS OD
           ON O.orderid = OD.orderid)
    ON C.custid = O.custid
WHERE o.orderid IS NULL;

---------------------------------------------------------------------
-- Using the COUNT Aggregate with Outer Joins
---------------------------------------------------------------------

SELECT C.custid, COUNT(*) AS numorders
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
GROUP BY C.custid;

SELECT C.custid, COUNT(O.orderid) AS numorders
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
GROUP BY C.custid;

---------------------------------------------------------------------
-- FULL Outer Joins 
---------------------------------------------------------------------

SELECT E.empid,
       E.firstname + ' ' + E.lastname AS FullName,
       E.postalcode,
       C.custid,
       C.contactname,
       C.postalcode
FROM HR.Employees E
    FULL JOIN Sales.Customers C
        ON C.postalcode = E.postalcode
ORDER BY C.postalcode;

SELECT * FROM Sales.Customers
SELECT * FROM HR.Employees

---------------------------------------------------------------------
-- Self-Contained Subqueries
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Scalar Subqueries
---------------------------------------------------------------------

-- Order with the maximum order ID
USE TSQLV4;

DECLARE @maxid AS INT; /*= (SELECT MAX(orderid)
                         FROM Sales.Orders);*/

SELECT @maxid = MAX(orderid)
FROM Sales.Orders;

--SELECT MAX(orderid) FROM Sales.Orders
--SELECT @maxid

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderid = @maxid;
GO

SELECT orderid, orderdate, empid, custid/*, (SELECT MAX(O.orderid)
                 FROM Sales.Orders AS O) AS MaxOrderId*/
FROM Sales.Orders
WHERE orderid = (SELECT MAX(O.orderid)
                 FROM Sales.Orders AS O);

SELECT TOP (1) * FROM Sales.Orders ORDER BY orderid DESC

-- Scalar subquery expected to return one value
SELECT orderid
FROM Sales.Orders
WHERE empid = 
  (SELECT TOP 1 E.empid
   FROM HR.Employees AS E
   WHERE E.lastname LIKE N'C%');
GO

SELECT orderid
FROM Sales.Orders
WHERE empid = 
  (SELECT E.empid
   FROM HR.Employees AS E
   WHERE E.lastname LIKE N'D%');
GO

SELECT orderid
FROM Sales.Orders
WHERE empid = 
  (SELECT E.empid
   FROM HR.Employees AS E
   WHERE E.lastname LIKE N'A%');

---------------------------------------------------------------------
-- Multi-Valued Subqueries
---------------------------------------------------------------------

SELECT orderid, empid
FROM Sales.Orders
WHERE empid IN
  (SELECT E.empid
   FROM HR.Employees AS E
   WHERE E.lastname LIKE N'D%');

SELECT O.orderid, e.lastname
FROM HR.Employees AS E
  INNER JOIN Sales.Orders AS O
    ON E.empid = O.empid --AND E.lastname LIKE N'D%'
WHERE E.lastname LIKE N'D%';

-- Orders placed by US customers
SELECT custid, orderid, orderdate, empid--, C.country
FROM Sales.Orders
WHERE custid IN
  (SELECT C.custid
   FROM Sales.Customers AS C
   WHERE C.country = N'USA') 
AND orderdate >= '2016-01-01';

-- Customers who placed no orders
SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN
  (SELECT DISTINCT O.custid
   FROM Sales.Orders AS O);

SELECT C.custid, C.companyname
FROM Sales.Customers C
LEFT JOIN Sales.Orders O ON O.custid = C.custid
WHERE O.orderid IS NULL

EXEC sp_help 'Sales.Orders'

-- Class Exercise: Return orders of 3 newly hired employees
-- Then Calculate Top 10 Order Value

SELECT O.orderid, O.empid, E.firstname + ' ' + E.lastname AS FullName
FROM Sales.Orders O
INNER JOIN HR.Employees E ON E.empid = O.empid
--ORDER BY E.hiredate DESC--, E.empid
WHERE O.empid IN
      (
          SELECT TOP 3 empid FROM HR.Employees ORDER BY hiredate DESC
      );

SELECT TOP 10 O.orderid, O.empid, SUM(OD.qty*OD.unitprice*(1 - OD.discount)) AS OrderVal
FROM Sales.Orders O
INNER JOIN Sales.OrderDetails OD ON OD.orderid = O.orderid
WHERE O.empid IN
      (
          SELECT TOP 3 empid FROM HR.Employees ORDER BY hiredate DESC
      )
GROUP BY O.orderid, O.empid
ORDER BY OrderVal DESC

SELECT TOP 10 O.empid, p.productname, SUM(OD.qty*OD.unitprice*(1 - OD.discount)) AS OrderVal
FROM Sales.Orders O
INNER JOIN Sales.OrderDetails OD ON OD.orderid = O.orderid
INNER JOIN Production.Products P ON P.productid = OD.productid
WHERE empid IN
      (
          SELECT TOP 3 empid FROM HR.Employees ORDER BY hiredate DESC
      )
GROUP BY O.empid, p.productname
ORDER BY OrderVal DESC

SELECT O.empid, COUNT(O.orderid) AS OrderCount
FROM Sales.Orders O
WHERE empid IN
      (
          SELECT TOP 3 empid FROM HR.Employees ORDER BY hiredate DESC
      )
GROUP BY O.empid
ORDER BY OrderCount DESC
