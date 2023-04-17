---------------------------------------------------------------------
-- SET Operators
---------------------------------------------------------------------

---------------------------------------------------------------------
-- The UNION Operator
---------------------------------------------------------------------

-- The UNION ALL Multiset Operator
SELECT country AS MyCol, region, city
FROM HR.Employees

UNION ALL

SELECT country AS ffg, region, city
FROM Sales.Customers;

SELECT country, region, city 
FROM Sales.Customers
UNION ALL
SELECT country, region, city 
FROM HR.Employees;

-- The UNION Distinct Set Operator
SELECT country, region, city 
FROM HR.Employees
UNION
SELECT country, region, city 
FROM Sales.Customers;

SELECT country, region, city 
FROM Sales.Customers
UNION
SELECT country, region, city 
FROM HR.Employees;

---------------------------------------------------------------------
-- The INTERSECT Operator
---------------------------------------------------------------------

-- The INTERSECT Distinct Set Operator
SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city  FROM Sales.Customers;

SELECT country, region, city FROM Sales.Customers
INTERSECT
SELECT country, region, city FROM HR.Employees;

---------------------------------------------------------------------
-- The EXCEPT Operator
---------------------------------------------------------------------

-- The EXCEPT Distinct Set Operator

-- Employees EXCEPT Customers
SELECT country, region, city FROM HR.Employees
EXCEPT
SELECT country, region, city FROM Sales.Customers;

-- Customers EXCEPT Employees
SELECT country, region, city FROM Sales.Customers
EXCEPT
SELECT country, region, city FROM HR.Employees;

---------------------------------------------------------------------
-- Precedence
---------------------------------------------------------------------

-- INTERSECT Precedes EXCEPT
SELECT country, region, city FROM Production.Suppliers
EXCEPT
SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers;

-- Using Parenthesis
(SELECT country, region, city FROM Production.Suppliers
 EXCEPT
 SELECT country, region, city FROM HR.Employees)
INTERSECT
SELECT country, region, city FROM Sales.Customers;

---------------------------------------------------------------------
-- Circumventing Unsupported Logical Phases
---------------------------------------------------------------------

-- Number of distinct locations that are either employee or customer locations in each country
SELECT country, COUNT(*) AS numlocations
FROM (SELECT country, region, city FROM HR.Employees
      UNION
      SELECT country, region, city FROM Sales.Customers) AS U
GROUP BY country
ORDER BY numlocations DESC;

-- Class Exercise: Two most recent orders for employees 3 and 5

SELECT empid, orderid, orderdate
FROM (SELECT TOP (2) empid, orderid, orderdate
      FROM Sales.Orders
      WHERE empid = 3
      ORDER BY orderdate DESC, orderid DESC) AS D1

UNION ALL

SELECT empid, orderid, orderdate
FROM (SELECT TOP (2) empid, orderid, orderdate
      FROM Sales.Orders
      WHERE empid = 5
      ORDER BY orderdate DESC, orderid DESC) AS D2;

SELECT TOP 4 orderid, empid, orderdate 
FROM Sales.Orders 
WHERE empid IN(3, 5)
ORDER BY orderdate DESC, orderid DESC

-- Class Exercise: کوئری بنویسید که زوج مشتری و کارمندی که هم در ژانویه و هم در فوریه 2016 سفارش داشته اند
-- اما در سال 2015 سفارشی نداشته اند را برگرداند
-- Tables involved: TSQLV4 database, Orders table

--Desired output
custid      empid
----------- -----------
67          1
46          5

(2 row(s) affected)

-- Solution
SELECT custid,
       empid
FROM Sales.Orders
WHERE orderdate >= '20160101'
      AND orderdate < '20160201'
INTERSECT
SELECT custid,
       empid
FROM Sales.Orders
WHERE orderdate >= '20160201'
      AND orderdate < '20160301'
EXCEPT
SELECT custid,
       empid
FROM Sales.Orders
WHERE orderdate >= '20150101'
      AND orderdate < '20160101';

-- With parentheses
(SELECT custid,
        empid
 FROM Sales.Orders
 WHERE orderdate >= '20160101'
       AND orderdate < '20160201'
 INTERSECT
 SELECT custid,
        empid
 FROM Sales.Orders
 WHERE orderdate >= '20160201'
       AND orderdate < '20160301')
EXCEPT
SELECT custid,
       empid
FROM Sales.Orders
WHERE orderdate >= '20150101'
      AND orderdate < '20160101';
---------------------------------------------------------------------
-- Window Functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Window Functions, Described
---------------------------------------------------------------------

--	Partitioning
--	Ordering
--	Framing

--function_name(<arguments>) OVER(
--[ <window partition clause> ]
--[ <window order clause> [ <window frame clause> ] ] )

USE TSQLV4;

SELECT orderid,
       custid,
       val,
       SUM(val) OVER () AS sumall,
       SUM(val) OVER (PARTITION BY custid) AS sumcust
FROM Sales.OrderValues AS O1;

SELECT orderid,
       custid,
       val, 
	   SUM(val) 
FROM Sales.OrderValues
GROUP BY orderid,
       custid,
       val

SELECT orderid,
       custid,
       val,
	   --100 * val / SUM(val) OVER () AS pctallC,
       CAST(100 * val / SUM(val) OVER () AS DECIMAL(5, 2)) AS pctall,
       CAST(100 * val / SUM(val) OVER (PARTITION BY custid) AS DECIMAL(5, 2)) AS pctcust,
       SUM(val) OVER () AS sumall,
       SUM(val) OVER (PARTITION BY custid) AS sumcust
FROM Sales.OrderValues AS O1;

---------------------------------------------------------------------
--Framing
---------------------------------------------------------------------

--ROWS BETWEEN UNBOUNDED PRECEDING |
--<n> PRECEDING |
--<n> FOLLOWING |
--CURRENT ROW
--AND
--UNBOUNDED FOLLOWING |
--<n> PRECEDING |
--<n> FOLLOWING |
--CURRENT ROW

SELECT empid,
       ordermonth,
       qty,
       SUM(qty) OVER (PARTITION BY empid
                      ORDER BY ordermonth
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                     ) AS runqty
FROM Sales.EmpOrders;

SELECT * FROM Sales.EmpOrders
ORDER BY empid

SELECT empid,
       ordermonth,
       qty,
       SUM(qty) OVER (PARTITION BY empid
                      ORDER BY ordermonth --DESC
                     ROWS BETWEEN CURRENT ROW --UNBOUNDED PRECEDING
					 AND UNBOUNDED FOLLOWING -- CURRENT ROW
                     ) AS runqty
FROM Sales.EmpOrders
ORDER BY empid, ordermonth;

SELECT empid,
       ordermonth,
	   qty AS curqty,
       MAX(qty) OVER (PARTITION BY empid
                      ORDER BY ordermonth
                      ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING
                     ) AS prvqty,
       MAX(qty) OVER (PARTITION BY empid
                      ORDER BY ordermonth
                      ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING
                     ) AS nxtqty,
       AVG(qty) OVER (PARTITION BY empid
                      ORDER BY ordermonth
                      ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
                     ) AS avgqty
FROM Sales.EmpOrders;

WITH cte AS(
SELECT orderdate,
       orderid,
       empid,
	   custid,
       val,
	   ROW_NUMBER() OVER (PARTITION BY empid, custid ORDER BY orderdate) AS rownum
FROM Sales.OrderValues)
SELECT cte.custid,
       cte.empid,
       cte.orderdate,
       cte.orderid,
       --cte.rownum,
       cte.val 
FROM cte WHERE cte.rownum = 1;

WITH cte AS(
SELECT orderdate,
       orderid,
       empid,
	   custid,
       val,
       CASE
           WHEN ROW_NUMBER() OVER (PARTITION BY empid, custid ORDER BY orderdate) = 1 THEN
               custid
       END AS distinct_custid
FROM Sales.OrderValues)
SELECT cte.custid,
       --cte.distinct_custid,
       cte.empid,
       cte.orderdate,
       cte.orderid,
       cte.val 
FROM cte WHERE cte.distinct_custid IS NOT NULL

---------------------------------------------------------------------
--Nested Aggregates
---------------------------------------------------------------------

SELECT empid,
       SUM(val) AS emptotal,
	   SUM(SUM(val)) OVER () AS TotalVal,
	   SUM(val) / SUM(SUM(val)) OVER () * 100. AS pct
FROM Sales.OrderValues
GROUP BY empid
ORDER BY pct DESC;

WITH C
AS (SELECT empid,
           SUM(val) AS emptotal
    FROM Sales.OrderValues
    GROUP BY empid)
SELECT empid,
       emptotal,
       emptotal / SUM(emptotal) OVER () * 100. AS pct
FROM C;
