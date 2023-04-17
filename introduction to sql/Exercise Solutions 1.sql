-- 1 
-- Return orders that include productids {24, 31, 56, 59, 60} 
-- WITH total value(qty*unitprice*(1-discount)) greater than 2500
-- sorted by total value
-- Tables involved: Sales.OrderDetails table

-- Incorrect Solution
SELECT orderid,
       CAST(SUM(qty * unitprice * (1 - discount)) AS DECIMAL(8, 2)) AS totalvalue
FROM Sales.OrderDetails
WHERE productid IN ( 24, 31, 56, 59, 60 )
GROUP BY orderid
HAVING CAST(SUM(qty * unitprice * (1 - discount)) AS DECIMAL(8, 2)) > 2500
ORDER BY totalvalue DESC;

-- Correct Solution
SELECT orderid,
       CAST(SUM(qty * unitprice * (1 - discount)) AS DECIMAL(8, 2)) AS totalvalue
FROM Sales.OrderDetails
WHERE orderid IN
      (
          SELECT orderid
          FROM Sales.OrderDetails
          WHERE productid IN ( 24, 31, 56, 59, 60 )
      )
GROUP BY orderid
HAVING CAST(SUM(qty * unitprice * (1 - discount)) AS DECIMAL(8, 2)) > 2500
ORDER BY totalvalue DESC;

-- 2
-- Write a query against the HR.Employees table that returns employees
-- with a last name that starts with a lower case letter.
-- Remember that the collation of the sample database
-- is case insensitive (SQL_Latin1_General_CP1_CI_AS).
-- For simplicity, you can assume that only English letters are used
-- in the employee last names.
-- Tables involved: HR.Employees table

-- Incorrect solution
SELECT empid, lastname
FROM HR.Employees
WHERE lastname COLLATE SQL_Latin1_General_CP1_CS_AS LIKE N'[a-z]%';

-- Correct solution
SELECT empid, lastname
FROM HR.Employees
WHERE lastname COLLATE SQL_Latin1_General_CP1_CS_AS LIKE N'[abcdefghijklmnopqrstuvwxyz]%';

UPDATE HR.Employees
SET lastname = 'Davis'
WHERE empid = 1;

-- 3
-- Explain the difference between the following two queries

-- Query 1
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
WHERE orderdate < '20160501'
GROUP BY empid;

-- Query 2
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY empid
HAVING MAX(orderdate) < '20160501';

-- Answer
-- The WHERE clause is a row filter whereas the HAVING clause is a group filter.
-- Query 1 returns how many orders each employee handled prior to May 2016.
-- Query 2 returns for employees who didn’t handle any orders since May 2016 the total number of orders that they handled. 

-- 4
-- Return the three ship countries with the highest average freight for orders placed in 2015
-- Tables involved: Sales.Orders table

-- Solution
SELECT TOP (3) shipcountry, AVG(freight) AS avgfreight
FROM Sales.Orders
WHERE orderdate >= '20150101' AND orderdate < '20160101'
GROUP BY shipcountry
ORDER BY avgfreight DESC;

-- With OFFSET-FETCH
SELECT shipcountry, AVG(freight) AS avgfreight
FROM Sales.Orders
WHERE orderdate >= '20150101' AND orderdate < '20160101'
GROUP BY shipcountry
ORDER BY avgfreight DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

-- 5 
-- Calculate row numbers for orders
-- based on order date ordering (using order id as tiebreaker)
-- for each customer separately
-- Tables involved: Sales.Orders table

-- Solution
SELECT custid, orderdate, orderid,
  ROW_NUMBER() OVER(PARTITION BY custid ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders
ORDER BY custid, rownum;

/*SELECT custid, orderdate, orderid, freight,
  ROW_NUMBER() OVER(PARTITION BY custid ORDER BY orderdate, orderid) AS rownum,
  RANK() OVER(PARTITION BY custid ORDER BY orderdate) AS rownum2
FROM Sales.Orders
ORDER BY custid, rownum;*/

-- 6
-- Figure out and return for each employee the gender based on the title of courtesy
-- Ms., Mrs. - Female, Mr. - Male, Dr. - Unknown
-- Tables involved: HR.Employees table

-- Solutions
SELECT empid, firstname, lastname, titleofcourtesy,
  CASE titleofcourtesy
    WHEN 'Ms.'  THEN 'Female'
    WHEN 'Mrs.' THEN 'Female'
    WHEN 'Mr.'  THEN 'Male'
    ELSE             'Unknown'
  END AS gender
FROM HR.Employees;

SELECT empid, firstname, lastname, titleofcourtesy,
  CASE 
    WHEN titleofcourtesy IN('Ms.', 'Mrs.') THEN 'Female'
    WHEN titleofcourtesy = 'Mr.'           THEN 'Male'
    ELSE                                        'Unknown'
  END AS gender
FROM HR.Employees;

-- 7
-- Return for each customer the customer ID and region
-- sort the rows in the output by region
-- having NULLs sort last (after non-NULL values)
-- Note that the default in T-SQL is that NULLs sort first
-- Tables involved: Sales.Customers table

-- Incorrect Solution
SELECT custid, region
FROM Sales.Customers
ORDER BY
  region DESC;

-- Solution
SELECT custid, region, CASE WHEN region IS NULL THEN 1 ELSE 0 END
FROM Sales.Customers --WITH(INDEX(PK_Customers))
ORDER BY
  CASE WHEN region IS NOT NULL THEN 0 ELSE 1 END, region;

-- 8
-- Write a query that show the employee names all charachters are upper case
-- Tables involved: HR.Employees table

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE UPPER(firstname) COLLATE SQL_Latin1_General_CP1_CS_AS = firstname;

UPDATE HR.Employees
SET firstname = 'SARA'
WHERE empid = 1;

EXEC sp_help 'HR.Employees'
