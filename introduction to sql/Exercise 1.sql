
-- 1
-- Return orders that include productids {24, 31, 56, 59, 60} with total value(qty*unitprice*(1-discount)) greater than 2500
-- sorted by total value
-- Tables involved: Sales.OrderDetails table

--Desired output
orderid		totalvalue
----------- ----------
11030		12615.05
10479		10495.60
10515		9921.30
10372		9210.90
11032		8902.50
10514		8623.45
...
10851		2603.00
10393		2556.95
10703		2545.00
10567		2519.00
10465		2518.00

(54 row(s) affected)

-- 2
-- Write a query against the HR.Employees table that returns employees
-- with a last name that starts with a lower case letter.
-- Remember that the collation of the sample database
-- is case insensitive (SQL_Latin1_General_CP1_CI_AS).
-- For simplicity, you can assume that only English letters are used
-- in the employee last names.
-- Tables involved: HR.Employees table

--Desired output
empid		lastname
----------- ----------

(0 row(s) affected)

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

-- 4 
-- Return the three ship countries with the highest average freight for orders placed in 2015
-- Tables involved: Sales.Orders table

--Desired output
shipcountry		avgfreight
-----------		----------
Austria			178.3642
Switzerland		117.1775
Sweden			105.16

(3 row(s) affected)

-- 5 
-- Calculate row numbers for orders
-- based on order date ordering (using order id as tiebreaker)
-- for each customer separately
-- Tables involved: Sales.Orders table

--Desired output
custid		orderdate	orderid		rownum
-----------	----------	----------	----------
1			2015-08-25	10643		1
1			2015-10-03	10692		2
1			2015-10-13	10702		3
1			2016-01-15	10835		4
1			2016-03-16	10952		5
1			2016-04-09	11011		6
2			2014-09-18	10308		1
2			2015-08-08	10625		2
2			2015-11-28	10759		3
2			2016-03-04	10926		4
...
91			2014-12-05	10374		1
91			2015-07-25	10611		2
91			2015-12-23	10792		3
91			2016-02-04	10870		4
91			2016-02-25	10906		5
91			2016-04-03	10998		6
91			2016-04-23	11044		7

(830 row(s) affected)

-- 6
-- Figure out and return for each employee the gender based on the title of courtesy
-- Ms., Mrs. - Female, Mr. - Male, Dr. - Unknown
-- Tables involved: HR.Employees table

--Desired output
empid		firstname	lastname	titleofcourtesy	gender
-----------	-----------	-----------	--------------- -----------
1			Sara		Davis		Ms.				Female
2			Don			Funk		Dr.				Unknown
3			Judy		Lew			Ms.				Female
4			Yael		Peled		Mrs.			Female
5			Sven		Mortensen	Mr.				Male
6			Paul		Suurs		Mr.				Male
7			Russell		King		Mr.				Male
8			Maria		Cameron		Ms.				Female
9			Patricia	Doyle		Ms.				Female

(9 row(s) affected)

-- 7
-- Return for each customer the customer ID and region
-- sort the rows in the output by region
-- having NULLs sort last (after non-NULL values)
-- Note that the default in T-SQL is that NULLs sort first
-- Tables involved: Sales.Customers table

--Desired output
custid		region
-----------	-----------
55			AK
10			BC
42			BC
45			CA
37			Co. Cork
33			DF
71			ID
...
85			NULL
86			NULL
87			NULL
90			NULL
91			NULL

(91 row(s) affected)

-- 8
-- Write a query that show the employee names all charachters are upper case
-- Tables involved: HR.Employees table

--Desired output
empid		firstname	lastname
-----------	-----------	-----------

(0 row(s) affected)
