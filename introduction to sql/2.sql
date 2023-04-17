---------------------------------------------------------------------
-- The OFFSET-FETCH Filter
---------------------------------------------------------------------

-- OFFSET-FETCH
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate, orderid
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;

-- Pagination in Aplication
DECLARE @PageCount INT = 50, @PageNumber INT = 2;
--DECLARE @PageNumber INT = 1;
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate, orderid
OFFSET (@PageNumber - 1) * @PageCount ROWS FETCH NEXT @PageCount ROWS ONLY;

---------------------------------------------------------------------
-- A Quick Look at Window Functions
---------------------------------------------------------------------

SELECT orderid, custid, val,
  ROW_NUMBER() OVER(PARTITION BY custid
                    ORDER BY val DESC) AS rownum
,ROW_NUMBER() OVER(ORDER BY val DESC) AS rownum
FROM Sales.OrderValues
ORDER BY custid, val;

SELECT * FROM Sales.OrderValues WHERE orderid = 10248
SELECT * FROM Sales.OrderDetails WHERE orderid = 10248
---------------------------------------------------------------------
-- Predicates and Operators
---------------------------------------------------------------------

-- Predicates: IN, BETWEEN, LIKE
SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderid IN(10248, 10249, 10250);

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate IN('2014-07-05', '2014-07-08');

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate = '2014-07-05' OR orderdate = '2014-07-08';


SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderid BETWEEN 10300 AND 10310;
--orderid >= 10300 AND orderid <= 10310

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate BETWEEN '2014-07-05' AND '2014-07-18';

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE '%a%';

-- Comparison operators: =, >, <, >=, <=, <>, !=, !>, !< 
SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '2016-01-01';

-- Logical operators: AND, OR, NOT
SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20160101'
  AND empid NOT IN(1, 3, 5);

-- Arithmetic operators: +, -, *, /, %
SELECT orderid, productid, qty, unitprice, discount,
  CAST(qty * unitprice * (1 - discount) AS DECIMAL(10,2)) AS val
FROM Sales.OrderDetails;

-- Operator Precedence

-- AND precedes OR
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE
        custid = 1
    AND empid IN(1, 3, 5)
    OR  custid = 85
    AND empid IN(2, 4, 6);

-- Equivalent to
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE
      ( custid = 1
        AND empid IN(1, 3, 5) )
    OR
      ( custid = 85
        AND empid IN(2, 4, 6) );

-- *, / precedes +, -
SELECT 10 + 2 * 3   -- 16

SELECT (10 + 2) * 3 -- 36

---------------------------------------------------------------------
-- CASE Expression
---------------------------------------------------------------------

-- Simple
SELECT productid, productname, categoryid,
  CASE categoryid
    WHEN 1 THEN 'Beverages'
    WHEN 2 THEN 'Condiments'
    WHEN 3 THEN 'Confections'
    WHEN 4 THEN 'Dairy Products'
    WHEN 5 THEN 'Grains/Cereals'
    WHEN 6 THEN 'Meat/Poultry'
    WHEN 7 THEN 'Produce'
    WHEN 8 THEN 'Seafood'
    ELSE N'نامشخص'
  END AS categoryname
FROM Production.Products;

SELECT * FROM Production.Categories
SELECT * FROM Production.Products

-- Searched
SELECT orderid, custid, val,
  CASE 
    WHEN val < 1000.00                   THEN 'Less than 1000'
    WHEN val BETWEEN 1000.00 AND 3000.00 THEN 'Between 1000 and 3000'
    WHEN val > 3000.00 AND custid = 76   THEN 'More than 3000'
    ELSE 'Unknown'
  END AS valuecategory
FROM Sales.OrderValues;

---------------------------------------------------------------------
-- NULLs
---------------------------------------------------------------------

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region = N'WA';

EXECUTE sp_help 'Sales.Customers'

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region <> N'WA';

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region = NULL;

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region IS NULL;

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region <> N'WA'
   OR region IS NULL;
