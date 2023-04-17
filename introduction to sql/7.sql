USE TSQLV4;

SELECT empid, ordermonth, val,
  SUM(val) OVER(PARTITION BY empid
                ORDER BY ordermonth DESC
				ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
                /*ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW*/) AS runval
FROM Sales.EmpOrders
ORDER BY empid, ordermonth DESC;

SELECT empid, ordermonth, val,
  SUM(val) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN CURRENT ROW
                         AND UNBOUNDED FOLLOWING) AS runval
FROM Sales.EmpOrders
ORDER BY empid, ordermonth

SELECT empid, ordermonth, val,
  SUM(val) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND UNBOUNDED FOLLOWING) AS runval
FROM Sales.EmpOrders;

-- Class Exrcise: Return customers whose order Value difference between Average orders 
-- value is less than 1000.

WITH DiffVal
AS (SELECT custid,
           orderid,
           empid,
           val,
           AVG(val) OVER (PARTITION BY custid) AS ValAVG,
           val - AVG(val) OVER (PARTITION BY custid) AS ValDiff
    FROM Sales.OrderValues)
SELECT *
FROM DiffVal
WHERE DiffVal.ValDiff < -1000;

-- Class Exrcise: Return Employees whose order Value difference between Average orders 
-- value is more than 1000.

WITH DiffVal
AS (SELECT custid,
           orderid,
           empid,
           val,
           AVG(val) OVER (PARTITION BY empid) AS ValAVG,
           val - AVG(val) OVER (PARTITION BY empid) AS ValDiff
    FROM Sales.OrderValues)
SELECT *
FROM DiffVal
WHERE ABS(DiffVal.ValDiff) > 1000 ;

SELECT AVG(val),
       empid,
       val
FROM Sales.OrderValues
GROUP BY empid,
         val;

---------------------------------------------------------------------
-- Ranking Window Functions
---------------------------------------------------------------------

SELECT orderid,
       custid,
       val,
       ROW_NUMBER() OVER (ORDER BY val) AS rownum,
       RANK() OVER (ORDER BY val) AS rank,
       DENSE_RANK() OVER (ORDER BY val) AS dense_rank,
       NTILE(10) OVER (ORDER BY val) AS ntile
FROM Sales.OrderValues
ORDER BY val;


WITH cte AS (SELECT orderid,
       custid,
       val,
       ROW_NUMBER() OVER (PARTITION BY custid ORDER BY val DESC) AS rownum
FROM Sales.OrderValues)
--WHERE ROW_NUMBER() OVER (PARTITION BY custid ORDER BY val DESC) <= 3
SELECT * FROM cte
WHERE cte.rownum <= 3 AND cte.val >= 2500
ORDER BY custid,
         val DESC;

SELECT DISTINCT
       val,
       ROW_NUMBER() OVER (ORDER BY val) AS rownum
FROM Sales.OrderValues;

SELECT val,
       ROW_NUMBER() OVER (ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;

SELECT orderid,
       val,
       (
           SELECT COUNT(*)
           FROM Sales.OrderValues AS O2
           WHERE O2.orderid <= O1.orderid
       ) AS rownum
FROM Sales.OrderValues AS O1;

SELECT orderid,
       val,
       COUNT(*) OVER (ORDER BY orderid) AS rownum
FROM Sales.OrderValues;

SELECT orderid,
       val,
       ROW_NUMBER() OVER (ORDER BY orderid) AS rownum
FROM Sales.OrderValues;

---------------------------------------------------------------------
--Determinism
---------------------------------------------------------------------

SELECT orderid,
       orderdate,
       val,
       ROW_NUMBER() OVER (ORDER BY orderdate DESC) AS rownum
FROM Sales.OrderValues;

SELECT orderid,
       orderdate,
       val,
       ROW_NUMBER() OVER (ORDER BY orderdate DESC, orderid DESC) AS rownum
FROM Sales.OrderValues;

--without order

SELECT orderid,
       orderdate,
       val,
       ROW_NUMBER() OVER () AS rownum
FROM Sales.OrderValues;

SELECT orderid,
       orderdate,
       val,
       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rownum
FROM Sales.OrderValues;

---------------------------------------------------------------------
-- Offset Window Functions
---------------------------------------------------------------------

-- LAG and LEAD
SELECT custid,
	   orderdate,
       orderid,
       val,
       LAG(val)  OVER (PARTITION BY custid ORDER BY orderdate, orderid) AS prevval,
       LEAD(val) OVER (PARTITION BY custid ORDER BY orderdate, orderid) AS nextval
FROM Sales.OrderValues
ORDER BY custid,
         orderdate,
         orderid;

SELECT custid,
	   orderdate,
       orderid,
       val,
       LAG(val)  OVER (PARTITION BY custid 
					   ORDER BY orderdate, orderid 
					   ROWS BETWEEN CURRENT ROW 
					   AND UNBOUNDED FOLLOWING) AS prevval,
       LEAD(val) OVER (PARTITION BY custid ORDER BY orderdate, orderid) AS nextval
FROM Sales.OrderValues
ORDER BY custid,
         orderdate,
         orderid;

DECLARE @x INT = 3;
SELECT custid,
       orderdate,
       orderid,
	   val,
       LAG(val, @x) OVER (PARTITION BY custid ORDER BY orderdate, orderid) AS prev3val,
	   LEAD(val, 3) OVER (PARTITION BY custid ORDER BY orderdate, orderid) AS next3val
FROM Sales.OrderValues;

-- FIRST_VALUE and LAST_VALUE
SELECT custid,
	   orderdate,
       orderid,
       val,
       FIRST_VALUE(val) OVER (PARTITION BY custid
                              ORDER BY orderdate,
                                       orderid
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                             ) AS firstval,
       LAST_VALUE(val) OVER (PARTITION BY custid
                             ORDER BY orderdate,
                                      orderid
                             ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
                            ) AS lastval
FROM Sales.OrderValues
ORDER BY custid,
         orderdate,
         orderid;

SELECT custid,
       orderdate,
       orderid,
       val,
       val - FIRST_VALUE(val) OVER (PARTITION BY custid ORDER BY orderdate, orderid) AS difffirst,
       val - LAST_VALUE(val) OVER  (PARTITION BY custid ORDER BY orderdate, orderid
                                   ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
                                  ) AS difflast
FROM Sales.OrderValues
ORDER BY custid,
         orderdate,
         orderid;


-- Class Exercise:
-- Write a query against the Sales.OrderValues View that computes for each
-- customer order:
-- * the difference between the current order quantity
--   and the customer's previous order quantity
-- * the difference between the current order quantity
--   and the customer's next order quantity.
-- * Moving Average for 5 Order's Value

-- Desired output:
custid orderid     qty         diffprev    diffnext	   val		   MovingAVG
------ ----------- ----------- ----------- ----------- ----------- -----------
1		10643		38			NULL		18			814.50		674.17
1		10692		20			-18			-1			878.00		717.08
1		10702		21			1			4			330.00		667.90
1		10835		17			-4			-1			845.80		691.70
1		10952		18			1			-42			471.20		645.13
1		11011		60			42			NULL		933.50		750.17
2		10308		6			NULL		-12			88.80		296.18
2		10625		18			12			8			479.75		350.74
2		10759		10			-8			-19			320.00		350.74
2		10926		29			19			NULL		514.40		438.05
3		10365		24			NULL		-6			403.20		1031.04
3		10507		30			6			-50			749.06		1293.78

-- Solution
SELECT custid, orderid, qty,
  qty - LAG(qty) OVER(PARTITION BY custid
                      ORDER BY orderdate, orderid) AS diffprev,
  qty - LEAD(qty) OVER(PARTITION BY custid
                       ORDER BY orderdate, orderid) AS diffnext,
val,
CAST(AVG(val) OVER(PARTITION BY custid ORDER BY orderdate, orderid
ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS DECIMAL(10, 2)) AS MovingAVG
FROM Sales.OrderValues;

---------------------------------------------------------------------
-- Removing Duplicates
---------------------------------------------------------------------

IF OBJECT_ID('Sales.MyOrders') IS NOT NULL
    DROP TABLE Sales.MyOrders;
GO

SELECT O.orderid, O.orderdate, OD.productid, OD.unitprice
INTO Sales.MyOrders
FROM Sales.Orders O
INNER JOIN Sales.OrderDetails OD ON OD.orderid = O.orderid
GO

SELECT * FROM Sales.MyOrders
GO

SELECT *
INTO Sales.MyOrders
FROM Sales.Orders
UNION ALL
SELECT *
FROM Sales.Orders
UNION ALL
SELECT *
FROM Sales.Orders;

SELECT * FROM Sales.MyOrders WHERE orderid = 10248

EXEC sp_help 'Sales.MyOrders'

SELECT orderid,
       ROW_NUMBER() OVER (PARTITION BY orderid ORDER BY (SELECT NULL)) AS n
FROM Sales.MyOrders;

WITH C
AS (SELECT orderid,
           ROW_NUMBER() OVER (PARTITION BY orderid ORDER BY (SELECT NULL)) AS n
    FROM Sales.MyOrders)
DELETE FROM C
WHERE n > 1;

---------------------------------------------------------------------
-- Pivoting Data
---------------------------------------------------------------------

-- Listing 1: Code to Create and Populate the Orders Table
USE TSQLV4;

DROP TABLE IF EXISTS dbo.OrderDetails
DROP TABLE IF EXISTS dbo.Orders;
GO

CREATE TABLE dbo.Orders
(
  orderid   INT        NOT NULL,
  orderdate DATE       NOT NULL,
  empid     INT        NOT NULL,
  custid    VARCHAR(5) NOT NULL,
  qty       INT        NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
VALUES
  (30001, '20140802', 3, 'A', 10),
  (10001, '20141224', 2, 'A', 12),
  (10005, '20141224', 1, 'B', 20),
  (40001, '20150109', 2, 'A', 40),
  (10006, '20150118', 1, 'C', 14),
  (20001, '20150212', 2, 'B', 12),
  (40005, '20160212', 3, 'A', 10),
  (20002, '20160216', 1, 'C', 20),
  (30003, '20160418', 2, 'B', 15),
  (30004, '20140418', 3, 'C', 22),
  (30007, '20160907', 3, 'D', 30);

SELECT * FROM dbo.Orders;

-- Query against Orders, grouping by employee and customer
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid;

---------------------------------------------------------------------
-- Pivoting with a Grouped Query
---------------------------------------------------------------------

-- Query against Orders, grouping by employee, pivoting customers,
-- aggregating sum of quantity
SELECT empid,
  SUM(qty) AS TotalQty,
  SUM(CASE WHEN custid = 'A' THEN qty END) AS A,
  SUM(CASE WHEN custid = 'B' THEN qty END) AS B,
  SUM(CASE WHEN custid = 'C' THEN qty END) AS C,
  SUM(CASE WHEN custid = 'D' THEN qty END) AS D  
FROM dbo.Orders
GROUP BY empid;

---------------------------------------------------------------------
-- Pivoting with the PIVOT Operator
---------------------------------------------------------------------

-- Logical equivalent of previous query using the native PIVOT operator
SELECT /*empid,*/ *--, A, B, C, D
FROM (SELECT empid, custid, qty
      FROM dbo.Orders) AS D
  PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

-- Query demonstrating the problem with implicit grouping
SELECT * --empid, A, B, C, D
FROM dbo.Orders
  PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

-- Logical equivalent of previous query
SELECT orderid, orderdate, empid,
  SUM(CASE WHEN custid = 'A' THEN qty END) AS A,
  SUM(CASE WHEN custid = 'B' THEN qty END) AS B,
  SUM(CASE WHEN custid = 'C' THEN qty END) AS C,
  SUM(CASE WHEN custid = 'D' THEN qty END) AS D  
FROM dbo.Orders
GROUP BY orderid, orderdate, empid;

-- Query against Orders, grouping by customer, pivoting employees,
-- aggregating sum of quantity
SELECT custid, [1], [2], [3]
FROM (SELECT empid, custid, qty
      FROM dbo.Orders) AS D
  PIVOT(SUM(qty) FOR empid IN([1], [2], [3])) AS P;

---------------------------------------------------------------------
-- Unpivoting Data
---------------------------------------------------------------------

-- Code to create and populate the EmpCustOrders table
USE TSQLV4;

DROP TABLE IF EXISTS dbo.EmpCustOrders;

CREATE TABLE dbo.EmpCustOrders
(
  empid INT NOT NULL
    CONSTRAINT PK_EmpCustOrders PRIMARY KEY,
  A VARCHAR(5) NULL,
  B VARCHAR(5) NULL,
  C VARCHAR(5) NULL,
  D VARCHAR(5) NULL
);

INSERT INTO dbo.EmpCustOrders(empid, A, B, C, D)
  SELECT empid, A, B, C, D
  FROM (SELECT empid, custid, qty
        FROM dbo.Orders) AS D
    PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

SELECT * FROM dbo.EmpCustOrders;

--SELECT * FROM dbo.Orders

---------------------------------------------------------------------
-- Unpivoting with the UNPIVOT Operator
---------------------------------------------------------------------

-- Query using the native UNPIVOT operator
SELECT empid, custid, qty
FROM dbo.EmpCustOrders
  UNPIVOT(qty FOR custid IN(A, B, C, D)) AS U;
  

-- Class Exercise: 
-- کوئری بنویسید که تعداد سفارشات هر کارمند را به تفکیک هر سال به شکل های زیر محاسبه کند

SELECT empid, A, B, C, D
  FROM (SELECT empid, custid, qty
        FROM dbo.Orders) AS D
    PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;
-- Desired output:
FullName			2014		  2015			  2016
--------------- --------------- --------------- ---------------
Patricia Doyle		5				19				19
Judy Lew			18				71				38
Paul Suurs			15				33				19
Russell King		11				36				25
Sara Davis			26				55				42
Yael Peled			31				81				44
Sven Mortensen		11				18				13
Don Funk			16				41				39
Maria Cameron		19				54				31

(9 row(s) affected)


OrderYear		Sara Davis		Don Funk		Judy Lew		Yael Peled		Sven Mortensen	Paul Suurs		Russell King	Maria Cameron	Patricia Doyle
--------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- 
2014				26				16				18				31				11				15				11				19				5
2015				55				41				71				81				18				33				36				54				19
2016				42				39				38				44				13				19				25				31				19

(3 row(s) affected)

-- Solution:
SELECT P.empid,
       P.EmployeeName,
       [2014],
       [2015],
       [2016]
FROM
(
    SELECT O.empid,
           O.orderid,
           CAST(E.firstname + N' ' + E.lastname AS NVARCHAR(32)) AS EmployeeName,
           YEAR(O.orderdate) AS OrderYear
    FROM Sales.Orders O
        INNER JOIN HR.Employees E
            ON E.empid = O.empid
) AS D
PIVOT
(
    COUNT(orderid)
    FOR OrderYear IN ([2014], [2015], [2016])
) AS P
ORDER BY P.empid;
GO

WITH cte AS (
SELECT empid, [2014], [2015], [2016]
FROM (SELECT O.empid,
           O.orderid,
           YEAR(O.orderdate) AS OrderYear
    FROM Sales.Orders O) AS D
	PIVOT
(
    COUNT(orderid)
    FOR OrderYear IN ([2014], [2015], [2016])
) AS P)
SELECT E.firstname + ' ' + E.lastname AS FullName, cte.[2014], [cte].[2015], [cte].[2016]
FROM cte
INNER JOIN HR.Employees E ON E.empid = cte.empid;
GO

SELECT P.OrderYear,
       [Sara Davis],
       [Don Funk],
       [Judy Lew],
       [Yael Peled],
       [Sven Mortensen],
       [Paul Suurs],
       [Russell King],
       [Maria Cameron],
       [Patricia Doyle]
FROM
(
    SELECT --O.empid,
           O.orderid,
           CAST(E.firstname + N' ' + E.lastname AS NVARCHAR(32)) AS EmployeeName,
           YEAR(O.orderdate) AS OrderYear
    FROM Sales.Orders O
        INNER JOIN HR.Employees E
            ON E.empid = O.empid
) AS D
PIVOT
(
    COUNT(orderid)
    FOR EmployeeName IN ([Sara Davis], [Don Funk], [Judy Lew], [Yael Peled], [Sven Mortensen], [Paul Suurs],
                         [Russell King], [Maria Cameron], [Patricia Doyle]
                        )
) AS P
ORDER BY P.OrderYear;
GO

---------------------------------------------------------------------
-- Data Modification
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Inserting Data
---------------------------------------------------------------------

---------------------------------------------------------------------
-- INSERT VALUES
---------------------------------------------------------------------

USE TSQLV4;

DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid   INT         NOT NULL
    CONSTRAINT PK_Orders PRIMARY KEY,
  orderdate DATE        NOT NULL
    CONSTRAINT DFT_orderdate DEFAULT(SYSDATETIME()),
  empid     INT         NOT NULL,
  custid    VARCHAR(10) NULL
);

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
  VALUES(10001, '20160212', 3, 'A');

INSERT INTO dbo.Orders(orderid, empid, custid)
  VALUES(10002, 5, 'B');

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
VALUES(10003, '20160213', 4, 'B'),
	  (10004, '20160214', 1, 'A'),
	  (10005, '20160213', 1, 'C'),
	  (10006, '20160215', 3, 'C');

INSERT INTO dbo.Orders
VALUES(10007, '20160213', 4, 'B');

EXEC sp_help 'Orders'

INSERT INTO dbo.Orders
VALUES(10008, '20160213', 4);

INSERT INTO dbo.Orders(orderid, orderdate, empid)
VALUES(10008, '20160213', 4);

INSERT INTO dbo.Orders(orderid, empid)
VALUES(10009, 6);

SELECT * FROM dbo.Orders

SELECT *
FROM ( VALUES
         (10003, '20160213', 4, 'B'),
         (10004, '20160214', 1, 'A'),
         (10005, '20160213', 1, 'C'),
         (10006, '20160215', 3, 'C') )
     AS O(orderid, orderdate, empid, custid);

---------------------------------------------------------------------
-- INSERT SELECT
---------------------------------------------------------------------

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
  SELECT orderid, orderdate, empid, custid--, shipcountry
  FROM Sales.Orders
  WHERE shipcountry = N'Germany';

SELECT * FROM dbo.Orders

---------------------------------------------------------------------
-- INSERT EXEC
---------------------------------------------------------------------

DROP PROCEDURE IF EXISTS Sales.GetOrders;
GO

CREATE OR ALTER PROCEDURE Sales.GetOrders
  @country AS NVARCHAR(15)
AS
BEGIN

SELECT orderid, orderdate, empid, custid--, shipcountry
FROM Sales.Orders
WHERE shipcountry = @country;

END
GO

EXECUTE Sales.GetOrders @country = N'France';

INSERT INTO dbo.Orders
(
    orderid,
    orderdate,
    empid,
    custid
)
EXEC Sales.GetOrders @country = N'Belgium';

SELECT * FROM dbo.Orders
