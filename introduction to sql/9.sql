---------------------------------------------------------------------
-- Modifying Data through Table Expressions
---------------------------------------------------------------------
SELECT * 
INTO dbo.OrderDetails
FROM Sales.OrderDetails

UPDATE OD
  SET discount += 0.05
FROM dbo.OrderDetails AS OD
  INNER JOIN dbo.Orders AS O
    ON OD.orderid = O.orderid
WHERE O.custid = 1;

-- CTE
BEGIN TRAN
;WITH C AS
(
  SELECT O.custid, OD.orderid,
    OD.productid, OD.discount, OD.discount + 0.05 AS newdiscount
  FROM dbo.OrderDetails AS OD
    INNER JOIN dbo.Orders AS O
      ON OD.orderid = O.orderid
  WHERE O.custid = 1
)
UPDATE C
  SET discount = newdiscount, productid = 5;
ROLLBACK

-- Derived Tabl
UPDATE D
  SET discount = newdiscount, D.productid = 5
FROM ( SELECT O.custid, OD.orderid,
         OD.productid, OD.discount, OD.discount + 0.05 AS newdiscount
       FROM dbo.OrderDetails AS OD
         INNER JOIN dbo.Orders AS O
           ON OD.orderid = O.orderid
       WHERE O.custid = 1 ) AS D;

-- Update with row numbers
DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1
(
    id INT NOT NULL IDENTITY PRIMARY KEY
   ,col1 INT
   ,col2 INT
);
GO

INSERT INTO dbo.T1(col1) VALUES(20),(10),(30);

SELECT * FROM dbo.T1

SELECT *, ROW_NUMBER() OVER(ORDER BY col1) FROM dbo.T1;
GO

UPDATE dbo.T1
  SET col2 = ROW_NUMBER() OVER(ORDER BY col1);

/*
Msg 4108, Level 15, State 1, Line 672
Windowed functions can only appear in the SELECT or ORDER BY clauses.
*/
GO
  
WITH C AS
(
  SELECT col1, col2, ROW_NUMBER() OVER(ORDER BY col1) AS rownum
  FROM dbo.T1
)
UPDATE C
  SET col2 = rownum;

SELECT * FROM dbo.T1
ORDER BY col2;

-- Class Exercise:
-- Update in the dbo.Orders table all orders placed by UK customers
-- and set their shipcountry, shipregion, shipcity values
-- to the country, region, city values of the corresponding customers from dbo.Customers
-- Using JOIN, CTE, MERGE

-- Solutions:

SELECT * FROM dbo.Orders

SELECT * FROM dbo.Customers

BEGIN TRAN
UPDATE O
SET shipcountry = C.country,
    shipregion = C.region,
    shipcity = C.city
FROM dbo.Orders AS O
    INNER JOIN dbo.Customers AS C
        ON O.custid = C.custid
WHERE C.country = N'UK'
      AND
      (
          shipcountry != C.country
          OR shipregion != C.region
          OR shipcity != C.city
      );
ROLLBACK

BEGIN TRAN
;WITH CTE_UPD
AS (SELECT O.shipcountry AS ocountry,
           C.country AS ccountry,
           O.shipregion AS oregion,
           C.region AS cregion,
           O.shipcity AS ocity,
           C.city AS ccity
    FROM dbo.Orders AS O
        INNER JOIN dbo.Customers AS C
            ON O.custid = C.custid
    WHERE C.country = N'UK'
          AND
          (
              shipcountry != C.country
              OR shipregion != C.region
              OR shipcity != C.city
          ))
UPDATE CTE_UPD
SET ocountry = ccountry,
    oregion = cregion,
    ocity = ccity;
ROLLBACK

BEGIN TRAN
MERGE INTO dbo.Orders AS O
USING
(SELECT * FROM dbo.Customers WHERE country = N'UK') AS C
ON O.custid = C.custid
WHEN MATCHED AND (
                     shipcountry <> C.country
                     OR shipregion <> C.region
                     OR shipcity != C.city
                 ) THEN
    UPDATE SET shipcountry = C.country,
               shipregion = C.region,
               shipcity = C.city;
ROLLBACK

---------------------------------------------------------------------
-- OUTPUT
---------------------------------------------------------------------

---------------------------------------------------------------------
-- INSERT with OUTPUT
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.T1;
GO

CREATE TABLE dbo.T1
(
  keycol  INT          NOT NULL IDENTITY(1, 1) CONSTRAINT PK_T1 PRIMARY KEY,
  datacol NVARCHAR(40) NOT NULL
);

INSERT INTO dbo.T1(datacol)
  OUTPUT Inserted.* --inserted.keycol, inserted.datacol
    SELECT lastname
    FROM HR.Employees
    WHERE country = N'USA';
GO

SELECT * FROM dbo.T1

DECLARE @NewRows TABLE(keycol INT, datacol NVARCHAR(40));

INSERT INTO dbo.T1(datacol)
  OUTPUT inserted.keycol, inserted.datacol
  INTO @NewRows(keycol, datacol)
    SELECT lastname
    FROM HR.Employees
    WHERE country = N'UK';

SELECT * FROM @NewRows;
GO

---------------------------------------------------------------------
-- DELETE with OUTPUT
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);
GO

INSERT INTO dbo.Orders 
SELECT * FROM Sales.Orders;

BEGIN TRAN --TRANSACTION
DELETE FROM dbo.Orders
  OUTPUT --Deleted.*
    deleted.orderid,
    deleted.orderdate,
    deleted.empid,
    deleted.custid
WHERE orderdate < '20160101'

DELETE FROM dbo.Orders
  OUTPUT --Deleted.*
    deleted.orderid,
    deleted.orderdate,
    deleted.empid,
    deleted.custid
WHERE orderdate > '20160101'
ROLLBACK

---------------------------------------------------------------------
-- UPDATE with OUTPUT
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.OrderDetails;

CREATE TABLE dbo.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO

INSERT INTO dbo.OrderDetails 
SELECT * FROM Sales.OrderDetails;

BEGIN TRAN
UPDATE dbo.OrderDetails
  SET discount += 0.05
OUTPUT 
  inserted.orderid,
  Deleted.orderid,
  inserted.productid,
  Deleted.productid,
  deleted.discount AS OldDiscount,
  inserted.discount AS NewDiscount
WHERE productid = 51;
ROLLBACK

---------------------------------------------------------------------
-- MERGE with OUTPUT
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Customers, dbo.CustomersStage;
GO

CREATE TABLE dbo.Customers
(
  custid      INT         NOT NULL,
  companyname VARCHAR(25) NOT NULL,
  phone       VARCHAR(20) NOT NULL,
  address     VARCHAR(50) NOT NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

INSERT INTO dbo.Customers(custid, companyname, phone, address)
VALUES
  (1, 'cust 1', '(111) 111-1111', 'address 1'),
  (2, 'cust 2', '(222) 222-2222', 'address 2'),
  (3, 'cust 3', '(333) 333-3333', 'address 3'),
  (4, 'cust 4', '(444) 444-4444', 'address 4'),
  (5, 'cust 5', '(555) 555-5555', 'address 5');

CREATE TABLE dbo.CustomersStage
(
  custid      INT         NOT NULL,
  companyname VARCHAR(25) NOT NULL,
  phone       VARCHAR(20) NOT NULL,
  address     VARCHAR(50) NOT NULL,
  CONSTRAINT PK_CustomersStage PRIMARY KEY(custid)
);

INSERT INTO dbo.CustomersStage(custid, companyname, phone, address)
VALUES
  (2, 'AAAAA', '(222) 222-2222', 'address 2'),
  (3, 'cust 3', '(333) 333-3333', 'address 3'),
  (5, 'BBBBB', 'CCCCC', 'DDDDD'),
  (6, 'cust 6 (new)', '(666) 666-6666', 'address 6'),
  (7, 'cust 7 (new)', '(777) 777-7777', 'address 7');

SELECT * FROM dbo.Customers
SELECT * FROM dbo.CustomersStage

BEGIN TRAN
MERGE INTO dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
  ON TGT.custid = SRC.custid
WHEN MATCHED THEN
  UPDATE SET
    TGT.companyname = SRC.companyname,
    TGT.phone = SRC.phone,
    TGT.address = SRC.address
WHEN NOT MATCHED THEN 
  INSERT (custid, companyname, phone, address)
  VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address)
WHEN NOT MATCHED BY SOURCE THEN DELETE
OUTPUT $action AS TheAction, inserted.custid,
  deleted.companyname AS oldcompanyname,
  inserted.companyname AS newcompanyname,
  deleted.phone AS oldphone,
  inserted.phone AS newphone,
  deleted.address AS oldaddress,
  inserted.address AS newaddress;
ROLLBACK

-- cleanup
DROP TABLE IF EXISTS dbo.OrderDetails, dbo.ProductsAudit, dbo.Products,
  dbo.Orders, dbo.Customers, dbo.T1, dbo.MySequences, dbo.CustomersStage;

-- Class Exercise: Run the following query against dbo.Customers,
-- and notice that some rows have a NULL in the region column

DROP TABLE IF EXISTS dbo.Customers
GO

SELECT * INTO dbo.Customers 
FROM Sales.Customers
GO

SELECT custid, companyname, country, region, city 
FROM dbo.Customers;

-- Output:
custid      companyname    country         region     city
----------- -------------- --------------- ---------- --------------- 
1           Customer NRZBB Germany         NULL       Berlin
2           Customer MLTDN Mexico          NULL       México D.F.
3           Customer KBUDE Mexico          NULL       México D.F.
4           Customer HFBZG UK              NULL       London
5           Customer HGVLZ Sweden          NULL       Luleå
6           Customer XHXJV Germany         NULL       Mannheim
7           Customer QXVLA France          NULL       Strasbourg
8           Customer QUHWH Spain           NULL       Madrid
9           Customer RTXGC France          NULL       Marseille
10          Customer EEALV Canada          BC         Tsawassen
...

(91 row(s) affected)

-- Update the dbo.Customers table and change all NULL region values to '<None>'
-- Use the OUTPUT clause to show the custid, old region and new region

-- Desired output:
custid      oldregion       newregion
----------- --------------- ---------------
1           NULL            <None>
2           NULL            <None>
3           NULL            <None>
4           NULL            <None>
5           NULL            <None>
6           NULL            <None>
7           NULL            <None>
8           NULL            <None>
9           NULL            <None>
11          NULL            <None>
12          NULL            <None>
13          NULL            <None>
14          NULL            <None>
16          NULL            <None>
17          NULL            <None>
18          NULL            <None>
19          NULL            <None>
20          NULL            <None>
23          NULL            <None>
24          NULL            <None>
25          NULL            <None>
26          NULL            <None>
27          NULL            <None>
28          NULL            <None>
29          NULL            <None>
30          NULL            <None>
39          NULL            <None>
40          NULL            <None>
41          NULL            <None>
44          NULL            <None>
49          NULL            <None>
50          NULL            <None>
52          NULL            <None>
53          NULL            <None>
54          NULL            <None>
56          NULL            <None>
58          NULL            <None>
59          NULL            <None>
60          NULL            <None>
63          NULL            <None>
64          NULL            <None>
66          NULL            <None>
68          NULL            <None>
69          NULL            <None>
70          NULL            <None>
72          NULL            <None>
73          NULL            <None>
74          NULL            <None>
76          NULL            <None>
79          NULL            <None>
80          NULL            <None>
83          NULL            <None>
84          NULL            <None>
85          NULL            <None>
86          NULL            <None>
87          NULL            <None>
90          NULL            <None>
91          NULL            <None>

(58 row(s) affected)

-- Solution:
BEGIN TRAN
UPDATE dbo.Customers
  SET region = '<None>'
OUTPUT
  deleted.custid,
  deleted.region AS oldregion,
  inserted.region AS newregion
WHERE region IS NULL;
ROLLBACK

SELECT custid, CASE WHEN region IS NULL THEN '<None>' ELSE region END
FROM dbo.Customers 
WHERE region IS NULL
