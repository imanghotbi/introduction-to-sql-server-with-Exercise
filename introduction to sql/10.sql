---------------------------------------------------------------------
-- Temporary Tables
---------------------------------------------------------------------

-- Local Temporary Tables

DROP TABLE IF EXISTS #MyOrderTotalsByYear;
GO

CREATE TABLE #MyOrderTotalsByYear
(
  orderyear INT NOT NULL PRIMARY KEY,
  qty       INT NOT NULL
);

INSERT INTO #MyOrderTotalsByYear(orderyear, qty)
  SELECT
    YEAR(O.orderdate) AS orderyear,
    SUM(OD.qty) AS qty
  --INTO #MyOrderTotalsByYear
  FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
      ON OD.orderid = O.orderid
  GROUP BY YEAR(orderdate);

SELECT * FROM #MyOrderTotalsByYear

SELECT Cur.orderyear, Cur.qty AS curyearqty, Prv.qty AS prvyearqty
FROM dbo.#MyOrderTotalsByYear AS Cur
  LEFT OUTER JOIN dbo.#MyOrderTotalsByYear AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;
GO

-- Try accessing the table from another session
SELECT orderyear, qty FROM dbo.#MyOrderTotalsByYear;

-- cleanup from the original session
DROP TABLE IF EXISTS #MyOrderTotalsByYear;

-- Global Temporary Tables
CREATE TABLE ##Globals
(
  id  sysname     NOT NULL PRIMARY KEY,
  val SQL_VARIANT NOT NULL
);

-- Run from any session
INSERT INTO ##Globals(id, val) VALUES(N'i', CAST(10 AS INT));

-- Run from any session
SELECT val FROM ##Globals WHERE id = N'i';

-- Run from any session
DROP TABLE IF EXISTS ##Globals;
GO

USE TSQLV4;
GO

-- Table Variables
DECLARE @MyOrderTotalsByYear TABLE
(
  orderyear INT NOT NULL PRIMARY KEY,
  qty       INT NOT NULL
);

INSERT INTO @MyOrderTotalsByYear(orderyear, qty)
  SELECT
    YEAR(O.orderdate) AS orderyear,
    SUM(OD.qty) AS qty
  FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
      ON OD.orderid = O.orderid
  GROUP BY YEAR(orderdate);

SELECT Cur.orderyear, Cur.qty AS curyearqty, Prv.qty AS prvyearqty
FROM @MyOrderTotalsByYear AS Cur
  LEFT OUTER JOIN @MyOrderTotalsByYear AS Prv
    ON Cur.orderyear = Prv.orderyear + 1
GO

-- with the LAG function
SELECT
  YEAR(O.orderdate) AS orderyear,
  SUM(OD.qty) AS curyearqty,
  LAG(SUM(OD.qty)) OVER(ORDER BY YEAR(orderdate)) AS prvyearqty
FROM Sales.Orders AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
GROUP BY YEAR(orderdate);
GO

-- Class Exercise: 
-- رتبه بندی کالاها از نظر تعداد فروش را در سال 2014 و 2015 مقایسه کنید
-- و به خروجی زیر برسید

-- Desire Output:

productname		TotalQty2014	Rank2014	TotalQty2015	Rank2015	QtyDescription				RankChange
-------------- --------------- ----------- --------------- ----------- --------------------------- --------------
Product XWOXC	444				1			656				4			Qty Has Increased 212		-3
Product WHBYK	370				2			665				3			Qty Has Increased 295		-1
Product PAFRH	252				7			571				8			Qty Has Increased 319		-1
Product BLCAX	234				9			527				10			Qty Has Increased 293		-1
Product UKXRI	231				10			752				2			Qty Has Increased 521		8

(5 rows affected)

--Solution:

DROP TABLE IF EXISTS #TopProductFirst, #TopProductSecond

SELECT TOP 10 P.productname, SUM(OD.qty) TotalQty2014, 
ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) Rank2014
INTO #TopProductFirst
FROM Sales.Orders O
INNER JOIN Sales.OrderDetails OD ON OD.orderid = O.orderid
INNER JOIN Production.Products P ON P.productid = OD.productid
WHERE O.orderdate >= '2014-01-01' AND O.orderdate < '2015-01-01'
GROUP BY P.productname
ORDER BY TotalQty2014 DESC

SELECT TOP 10 P.productname, SUM(OD.qty) TotalQty2015, 
ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) Rank2015
INTO #TopProductSecond
FROM Sales.Orders O
INNER JOIN Sales.OrderDetails OD ON OD.orderid = O.orderid
INNER JOIN Production.Products P ON P.productid = OD.productid
WHERE O.orderdate >= '2015-01-01' AND O.orderdate < '2016-01-01'
GROUP BY P.productname
ORDER BY TotalQty2015 DESC

SELECT F.productname, F.TotalQty2014, F.Rank2014, S.TotalQty2015, S.Rank2015, 
CASE WHEN F.TotalQty2014 - S.TotalQty2015 > 0 THEN 'Qty Has Decreased ' + CAST(F.TotalQty2014 - S.TotalQty2015 AS VARCHAR(10))
WHEN F.TotalQty2014 - S.TotalQty2015 < 0 THEN 'Qty Has Increased ' + CAST(ABS(F.TotalQty2014 - S.TotalQty2015) AS VARCHAR(10))
ELSE 'Qty Not Changed' END AS QtyDescription, F.Rank2014 - S.Rank2015 AS RankChange
FROM #TopProductFirst F
INNER JOIN #TopProductSecond S ON S.productname = F.productname

-- Check Plan for Simplification Order Table

---------------------------------------------------------------------
-- Triggers
---------------------------------------------------------------------

-- Example for a DML audit trigger
DROP TABLE IF EXISTS dbo.T1_Audit, dbo.T1;

CREATE TABLE dbo.T1
(
  keycol  INT         NOT NULL PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
);

CREATE TABLE dbo.T1_Audit
(
  audit_lsn  INT          NOT NULL IDENTITY PRIMARY KEY,
  dt         DATETIME2(3) NOT NULL DEFAULT(SYSDATETIME()),
  login_name sysname      NOT NULL DEFAULT(ORIGINAL_LOGIN()),
  keycol     INT          NOT NULL,
  datacol    VARCHAR(10)  NOT NULL
);
GO

CREATE TRIGGER trg_T1_insert_audit ON dbo.T1 
AFTER INSERT --AFTER\INSTEAD OF (INSERT, UPDATE, DELETE)
AS
SET NOCOUNT ON;

--IF(ORIGINAL_LOGIN() NOT IN('sa', 'Reza'))
INSERT INTO dbo.T1_Audit(keycol, datacol)
  SELECT keycol, datacol 
  FROM Inserted;
GO

SELECT * FROM dbo.T1
SELECT * FROM dbo.T1_Audit

INSERT INTO dbo.T1(keycol, datacol) VALUES(10, 'a');
INSERT INTO dbo.T1(keycol, datacol) VALUES(30, 'x');
INSERT INTO dbo.T1(keycol, datacol) VALUES(20, 'g');

SELECT audit_lsn, dt, login_name, keycol, datacol
FROM dbo.T1_Audit;
GO

-- cleanup
DROP TABLE IF EXISTS dbo.T1_Audit, dbo.T1;

-- The GO n Option

-- Create T1 with identity column
DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1(col1 INT IDENTITY CONSTRAINT PK_T1 PRIMARY KEY);
GO

-- Suppress insert messages
SET NOCOUNT ON;
GO

-- Execute batch 100 times
INSERT INTO dbo.T1 DEFAULT VALUES;
GO 100

SELECT * FROM dbo.T1;

---------------------------------------------------------------------
-- Flow Elements
---------------------------------------------------------------------

-- The IF ... ELSE Flow Element
IF YEAR(SYSDATETIME()) <> YEAR(DATEADD(day, 1, SYSDATETIME()))
  PRINT 'Today is the last day of the year.';
ELSE
  PRINT 'Today is not the last day of the year.';
GO

-- IF ELSE IF
IF YEAR(SYSDATETIME()) <> YEAR(DATEADD(day, 1, SYSDATETIME()))
  PRINT 'Today is the last day of the year.';
ELSE
  IF MONTH(SYSDATETIME()) <> MONTH(DATEADD(day, 1, SYSDATETIME()))
    PRINT 'Today is the last day of the month but not the last day of the year.';
  ELSE 
    PRINT 'Today is not the last day of the month.';
GO

-- Statement Block
IF DAY(SYSDATETIME()) = 1
BEGIN
  PRINT 'Today is the first day of the month.';
  PRINT 'Starting first-of-month-day process.';
  /* ... process code goes here ... */
  PRINT 'Finished first-of-month-day database process.';
END;
ELSE
BEGIN
  PRINT 'Today is not the first day of the month.';
  PRINT 'Starting non-first-of-month-day process.';
  /* ... process code goes here ... */
  PRINT 'Finished non-first-of-month-day process.';
END;
GO

-- Class Exercise: Set the Most Expensive Order Date in a variable
-- and decision with this varibale
-- 'Order is registered in 2023 year'
-- 'Order is registered in 2022 year'
-- 'Order is registered in 5 years ago'

DECLARE @BiggestOrderDate AS DATE

/*SELECT TOP 1 @BiggestOrderDate = orderdate 
FROM Sales.OrderValues 
WHERE val = (SELECT MAX(val) FROM Sales.OrderValues)
ORDER BY orderdate DESC*/

--SELECT @BiggestOrderDate = '2023-04-15' --'2022-04-15', '2021-04-15', '2020-04-15'

SELECT TOP 1 @BiggestOrderDate = orderdate 
FROM Sales.OrderValues 
ORDER BY val DESC, orderdate DESC

IF(DATEDIFF(YEAR, @BiggestOrderDate, GETDATE()) IN (0, 1) )
	BEGIN
		PRINT 'Order is registered in ' + CAST(YEAR(@BiggestOrderDate) AS VARCHAR(4)) + ' year';
	END
ELSE 
	BEGIN
		PRINT 'Order is registered in ' + CAST(YEAR(GETDATE()) - YEAR(@BiggestOrderDate) AS VARCHAR(4)) + ' years ago';
	END

-- The WHILE Flow Element
DECLARE @i AS INT = 1;
WHILE (@i <= 10 /*AND 1 = 1*/)
BEGIN
  PRINT @i;
  --SELECT @i;
  SET @i += 1;
END;
GO

-- BREAK
DECLARE @i AS INT = 1;
WHILE @i <= 10
BEGIN
  IF @i = 6 BREAK;
  PRINT @i;
  SET @i += 1;
END;
GO

-- CONTINUE
DECLARE @i AS INT = 0;
WHILE @i < 10
BEGIN
  SET @i += 1;
  IF @i = 6 CONTINUE;
  PRINT @i;
END;
GO

-- Using a WHILE loop to populate a table of numbers
SET NOCOUNT OFF;
DROP TABLE IF EXISTS dbo.Numbers;
CREATE TABLE dbo.Numbers(n INT NOT NULL PRIMARY KEY);
GO

DECLARE @i AS INT = 1;
WHILE @i <= 1000
BEGIN
  INSERT INTO dbo.Numbers(n) VALUES(@i);
  SET @i += 1;
END;
GO

SELECT * FROM dbo.Numbers

---------------------------------------------------------------------
-- Grouping Sets
---------------------------------------------------------------------

SELECT * FROM dbo.Orders

-- Four queries, each with a different grouping set
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid;

SELECT empid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid;

SELECT custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY custid;

SELECT SUM(qty) AS sumqty
FROM dbo.Orders;

-- Unifying result sets of four queries
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid

UNION ALL

SELECT empid, NULL, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid

UNION ALL

SELECT NULL, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY custid

UNION ALL

SELECT NULL, NULL, SUM(qty) AS sumqty
FROM dbo.Orders;

---------------------------------------------------------------------
-- GROUPING SETS Subclause
---------------------------------------------------------------------

-- Using the GROUPING SETS subclause
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY
  GROUPING SETS
  (
    (empid, custid),
    (empid),
    (custid),
    ()
  );

---------------------------------------------------------------------
-- CUBE Subclause
---------------------------------------------------------------------

-- Using the CUBE subclause
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

---------------------------------------------------------------------
-- ROLLUP Subclause
---------------------------------------------------------------------

-- Using the ROLLUP subclause
SELECT 
  YEAR(orderdate) AS orderyear,
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY --YEAR(orderdate), MONTH(orderdate), DAY(orderdate)
ROLLUP(YEAR(orderdate), MONTH(orderdate), DAY(orderdate));

---------------------------------------------------------------------
-- GROUPING and GROUPING_ID Function
---------------------------------------------------------------------

SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

SELECT
  GROUPING(empid) AS grpemp,
  GROUPING(custid) AS grpcust,
  empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

SELECT
  GROUPING_ID(empid, custid) AS groupingset,
  empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

--For example, the grouping
--set (a, b, c, d) is represented by the integer 0 (0×8 + 0×4 + 0×2 + 0×1). 
--The grouping set (a, c) is represented by the integer 5 (0×8 + 1×4 + 0×2 + 1×1), and so on.
