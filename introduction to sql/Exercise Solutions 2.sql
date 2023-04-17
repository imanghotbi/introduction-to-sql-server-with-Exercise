
-- 1 
-- Return orders placed in August and September 2015
-- Tables involved: Sales.Orders table

--Desired output
orderid		orderdate	custid		empid
----------- ---------- ---------- ----------
10618		2015-08-01	51			1
10619		2015-08-04	51			3
10620		2015-08-05	42			2
10621		2015-08-05	38			4
10622		2015-08-06	67			4
10623		2015-08-07	25			8
10651		2015-09-01	86			8
10652		2015-09-01	31			4
10653		2015-09-02	25			1
10654		2015-09-02	5			5
10655		2015-09-03	66			1
...

-- Solutions
USE TSQLV4;

-- Not recommended
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE YEAR(orderdate) = 2015 AND MONTH(orderdate) IN (8, 9);

-- Recommended
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate >= '20150801' 
  AND orderdate < '20151001';

-- 2
-- Return orders placed on the last day of the month without using EOMONTH() function
-- Tables involved: Sales.Orders table

--Desired output
orderid		orderdate	custid		empid
----------- ---------- ---------- ----------
10269		2014-07-31	89			5
10317		2014-09-30	48			6
10343		2014-10-31	44			4
10399		2014-12-31	83			8
10432		2015-01-31	75			3
10460		2015-02-28	24			8
10461		2015-02-28	46			1
10490		2015-03-31	35			7
...

(26 row(s) affected)

-- Solution

-- With the EOMONTH function
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate);

-- Without the EOMONTH function
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = DATEADD(month, DATEDIFF(month, '18991231', orderdate), '18991231');

-- 3
-- لیست 3 کالای پرفروش (به همراه دسته بندی آنها) در سال 2015 را برگردانید که توسط کارمندان آمریکایی ثبت شده اند
-- Tables involved: Sales.Orders, Sales.OrderDetails, Production.Products, Production.Categories and HR.Employees tables

--Desired output
productname		categoryname		TotalSales
--------------- ------------------- ----------
Product QDOMO	Beverages			37377.48
Product VKCMF	Grains/Cereals		25661.40
Product VJXYN	Meat/Poultry		22958.73

(3 row(s) affected)

-- Solution
SELECT TOP 3
       P.productname,
       PC.categoryname,
       CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount)) AS DECIMAL(8, 2)) AS TotalSales
FROM Sales.Orders O
    INNER JOIN Sales.OrderDetails OD
        ON OD.orderid = O.orderid
    INNER JOIN Production.Products P
        ON P.productid = OD.productid
    INNER JOIN Production.Categories PC
        ON PC.categoryid = P.categoryid
    INNER JOIN HR.Employees E
        ON E.empid = O.empid
WHERE E.country = N'USA'
      AND O.orderdate >= '2015-01-01'
      AND O.orderdate < '2016-01-01'
GROUP BY P.productname,
         PC.categoryname
ORDER BY TotalSales DESC;

-- 4  
-- Write a query that returns a row for each customer and day 
-- in the range July 20, 2015 – July 26 2015.
-- Tables involved: TSQLV4 database, Sales.Customers and Nums tables

--Desired output
custid      dt
----------- -----------
1			2015-07-20
1			2015-07-21
1			2015-07-22
1			2015-07-23
1			2015-07-24
1			2015-07-25
1			2015-07-26
2			2015-07-20
2			2015-07-21
2			2015-07-22
2			2015-07-23
2			2015-07-24
2			2015-07-25
2			2015-07-26 
...

(637 row(s) affected)

-- Solution
SELECT C.custid,
  DATEADD(day, D.n - 1, CAST('20150720' AS DATE)) AS dt
FROM Sales.Customers AS C
  CROSS JOIN Nums AS D
WHERE D.n <= DATEDIFF(day, '20150720', '20150726') + 1
ORDER BY C.custid, dt;

-- 5
-- Explain what’s wrong in the following query and provide a correct alternative
SELECT Customers.custid, Customers.companyname, Orders.orderid, Orders.orderdate
FROM Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON Customers.custid = Orders.custid;

-- Correct solutions
SELECT Customers.custid, Customers.companyname, Orders.orderid, Orders.orderdate
FROM Sales.Customers
  INNER JOIN Sales.Orders
    ON Customers.custid = Orders.custid;

SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON C.custid = O.custid;

-- 6
-- Return customers with orders placed on Feb 12, 2016 and Products in 'Beverages' and 'Condiments' Category along with their orders
-- Tables involved: TSQLV4 database, Customers, Orders, OrderDetails, Products and Categories  tables

-- Desired output
custid      companyname     orderid     orderdate
----------- --------------- ----------- ----------
48          Customer DVFMB  10883       2016-02-12
45          Customer QXPPT  10884       2016-02-12
76          Customer SFOGW  10885       2016-02-12

(3 row(s) affected)

-- Solution
SELECT C.custid,
       C.companyname,
       O.orderid,
       O.orderdate
FROM Sales.Customers AS C
    INNER JOIN Sales.Orders AS O
        ON O.custid = C.custid
WHERE O.orderdate = '20160212'
      AND EXISTS( SELECT TOP 1 1
    FROM Sales.OrderDetails OD
        INNER JOIN Production.Products P
            ON P.productid = OD.productid
        INNER JOIN Production.Categories PC
            ON PC.categoryid = P.categoryid
    WHERE PC.categoryname IN('Beverages', 'Condiments') AND OD.orderid = O.orderid );

--Second Solution
SELECT /*DISTINCT*/ C.custid,
       C.companyname,
       OD.orderid,
       O.orderdate
FROM Sales.Orders O
    INNER JOIN Sales.OrderDetails OD
        ON OD.orderid = O.orderid
    INNER JOIN Sales.Customers C
        ON O.custid = C.custid
    INNER JOIN Production.Products P
        ON P.productid = OD.productid
    INNER JOIN Production.Categories D
        ON P.categoryid = D.categoryid
WHERE O.orderdate = '20160212'
      AND D.categoryname IN ( 'Beverages', 'Condiments' )
GROUP BY C.custid, C.companyname, OD.orderid, O.orderdate;

-- 7
-- Write a query that returns all customers in the output, but matches
-- them with their respective orders only if they were placed on February 12, 2016
-- Tables involved: TSQLV4 database, Customers and Orders tables

-- Desired output
custid      companyname     orderid     orderdate
----------- --------------- ----------- ----------
72          Customer AHPOP  NULL        NULL
58          Customer AHXHT  NULL        NULL
25          Customer AZJED  NULL        NULL
18          Customer BSVAR  NULL        NULL
91          Customer CCFIZ  NULL        NULL
68          Customer CCKOT  NULL        NULL
49          Customer CQRAA  NULL        NULL
24          Customer CYZTN  NULL        NULL
22          Customer DTDMN  NULL        NULL
48          Customer DVFMB  10883       2016-02-12
10          Customer EEALV  NULL        NULL
40          Customer EFFTC  NULL        NULL
85          Customer ENQZT  NULL        NULL
82          Customer EYHKM  NULL        NULL
79          Customer FAPSM  NULL        NULL
...
51          Customer PVDZC  NULL        NULL
52          Customer PZNLA  NULL        NULL
56          Customer QNIVZ  NULL        NULL
8           Customer QUHWH  NULL        NULL
67          Customer QVEPD  NULL        NULL
45          Customer QXPPT  10884       2016-02-12
7           Customer QXVLA  NULL        NULL
60          Customer QZURI  NULL        NULL
19          Customer RFNQC  NULL        NULL
9           Customer RTXGC  NULL        NULL
76          Customer SFOGW  10885       2016-02-12
69          Customer SIUIH  NULL        NULL
86          Customer SNXOJ  NULL        NULL
88          Customer SRQVM  NULL        NULL
54          Customer TDKEG  NULL        NULL
20          Customer THHDP  NULL        NULL
...

(91 row(s) affected)

-- Incorrect Solution
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
WHERE O.orderdate = '20160212'
   OR O.orderid IS NULL;

-- Solution
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
    AND O.orderdate = '20160212';

-- 8
-- Return all customers, and for each return a Yes/No value
-- depending on whether the customer placed an order on Feb 12, 2016
-- Tables involved: TSQLV4 database, Customers and Orders tables

-- Desired output
custid      companyname     HasOrderOn20160212
----------- --------------- ------------------
...
40          Customer EFFTC  No
41          Customer XIIWM  No
42          Customer IAIJK  No
43          Customer UISOJ  No
44          Customer OXFRU  No
45          Customer QXPPT  Yes
46          Customer XPNIK  No
47          Customer PSQUZ  No
48          Customer DVFMB  Yes
49          Customer CQRAA  No
50          Customer JYPSC  No
51          Customer PVDZC  No
52          Customer PZNLA  No
53          Customer GCJSG  No
...

(91 row(s) affected)

-- Solution
SELECT DISTINCT C.custid, C.companyname, 
  CASE WHEN O.orderid IS NOT NULL THEN 'Yes' ELSE 'No' END AS HasOrderOn20160212
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
    AND O.orderdate = '20160212';

-- Second Solution
SELECT C.custid,
       C.companyname,
       CASE
           WHEN
           (
               SELECT TOP 1
                      O.custid
               FROM Sales.Orders O
               WHERE O.orderdate = '20160212'
                     AND C.custid = O.custid
           ) IS NULL THEN
               'NO'
           ELSE
               'YES'
       END AS HasOrderOn20160212
FROM Sales.Customers AS C;
