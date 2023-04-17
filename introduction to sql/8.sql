---------------------------------------------------------------------
-- SELECT INTO
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Orders;

SELECT orderid, orderdate, empid, custid
INTO dbo.Orders
FROM Sales.Orders;

SELECT * FROM dbo.Orders

EXEC sp_help 'dbo.Orders'

-- SELECT INTO with Set Operations
DROP TABLE IF EXISTS dbo.Locations;

SELECT country, region, city
INTO dbo.Locations
FROM Sales.Customers

EXCEPT

SELECT country, region, city
FROM HR.Employees;
GO

SELECT * FROM dbo.Locations

---------------------------------------------------------------------
-- BULK INSERT
---------------------------------------------------------------------

BULK INSERT dbo.Orders FROM 'c:\temp\orders.txt'
  WITH 
    (
       DATAFILETYPE    = 'char',
       FIELDTERMINATOR = ',',
       ROWTERMINATOR   = '\n'
    );
GO

SELECT * FROM dbo.Orders 

-- Class Exercise:
-- 1
-- Run the following code to create the dbo.Customers table
USE TSQLV4;

DROP TABLE IF EXISTS dbo.Customers;

CREATE TABLE dbo.Customers
(
    custid INT NOT NULL PRIMARY KEY,
    companyname NVARCHAR(40) NOT NULL,
    country NVARCHAR(15) NOT NULL,
    region NVARCHAR(15) NULL,
    city NVARCHAR(15) NOT NULL
);

-- 1-1
-- Insert into the dbo.Customers table a row with:
-- custid:		100
-- companyname: Coho Winery
-- country:     USA
-- region:      WA
-- city:        Redmond

-- 1-2
-- Insert into the dbo.Customers table 
-- all customers from Sales.Customers
-- who placed orders

-- 1-3
-- Use a SELECT INTO statement to create and populate the dbo.Orders table
-- with orders from the Sales.Orders
-- that were placed in the years 2014 through 2016

-- Solution:

-- 1-1
INSERT INTO dbo.Customers(custid, companyname, country, region, city)
  VALUES(100, N'Coho Winery', N'USA', N'WA', N'Redmond');

-- 1-2
INSERT INTO dbo.Customers(custid, companyname, country, region, city)
  SELECT custid, companyname, country, region, city
  FROM Sales.Customers AS C
  WHERE EXISTS
    (SELECT TOP 1 1 FROM Sales.Orders AS O
     WHERE O.custid = C.custid);

-- 1-3

DROP TABLE IF EXISTS dbo.Orders

SELECT *
INTO dbo.Orders
FROM Sales.Orders
WHERE orderdate >= '20140101'
  AND orderdate < '20170101';

---------------------------------------------------------------------
-- Deleting Data
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Orders, dbo.Customers, dbo.OrderDetails;

CREATE TABLE dbo.Customers
(
  custid       INT          NOT NULL,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

CREATE TABLE dbo.Orders
(
  orderid        INT IDENTITY NOT NULL,
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
  CONSTRAINT PK_Orders PRIMARY KEY(orderid),
  CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid)
    REFERENCES dbo.Customers(custid)
);
GO

INSERT INTO dbo.Customers
SELECT *
FROM Sales.Customers;

INSERT INTO dbo.Orders
(
    custid,
    empid,
    orderdate,
    requireddate,
    shippeddate,
    shipperid,
    freight,
    shipname,
    shipaddress,
    shipcity,
    shipregion,
    shippostalcode,
    shipcountry
)
SELECT custid,
       empid,
       orderdate,
       requireddate,
       shippeddate,
       shipperid,
       freight,
       shipname,
       shipaddress,
       shipcity,
       shipregion,
       shippostalcode,
       shipcountry
FROM Sales.Orders;
GO 20

SELECT * FROM dbo.Orders
GO

sp_spaceused 'Orders'
GO

---------------------------------------------------------------------
-- DELETE Statement
---------------------------------------------------------------------

BEGIN TRANSACTION
TRUNCATE TABLE dbo.Orders
--ROLLBACK
COMMIT

BEGIN TRAN
DELETE FROM dbo.Orders
WHERE orderdate < '20150101';
ROLLBACK
--COMMIT

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT TOP (100) * FROM Sales.Orders --WITH(NOLOCK)
WHERE orderid = 10248
---------------------------------------------------------------------
-- DELETE Based on Join
---------------------------------------------------------------------

SELECT * FROM dbo.Orders

-- Using a join
DELETE FROM O
FROM dbo.Orders AS O
  INNER JOIN dbo.Customers AS C
    ON O.custid = C.custid
WHERE C.country = N'USA';

-- Using a subquery
BEGIN TRAN
DELETE FROM dbo.Orders
WHERE EXISTS
  (SELECT *
   FROM dbo.Customers AS C
   WHERE Orders.custid = C.custid
     AND C.country = N'UK');
ROLLBACK

-- cleanup
DROP TABLE IF EXISTS dbo.Orders, dbo.Customers;

---------------------------------------------------------------------
-- Updating Data
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders;

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
  CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
    REFERENCES dbo.Orders(orderid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO

INSERT INTO dbo.Orders 
SELECT * FROM Sales.Orders;

INSERT INTO dbo.OrderDetails 
SELECT * FROM Sales.OrderDetails;

---------------------------------------------------------------------
-- UPDATE Statement
---------------------------------------------------------------------

-- Code to create tables T1 and T2 if you want to run the examples that follow
DROP TABLE IF EXISTS dbo.T1, dbo.T2;

CREATE TABLE dbo.T1
(
  keycol INT NOT NULL
    CONSTRAINT PK_T1 PRIMARY KEY,
  col1 INT NOT NULL,
  col2 INT NOT NULL,
  col3 INT NOT NULL,
  col4 VARCHAR(10) NOT NULL
);

CREATE TABLE dbo.T2
(
  keycol INT NOT NULL
    CONSTRAINT PK_T2 PRIMARY KEY,
  col1 INT NOT NULL,
  col2 INT NOT NULL,
  col3 INT NOT NULL,
  col4 VARCHAR(10) NOT NULL
);
GO

INSERT INTO T1(keycol, col1, col2, col3, col4)
VALUES(1, 10, 20, 30, 'A'),
(2, 11, 21, 31, 'B'),
(3, 12, 22, 32, 'C'),
(4, 13, 23, 33, 'ABC');

INSERT INTO T2(keycol, col1, col2, col3, col4)
VALUES(1, 40, 50, 60, 'A'),
(2, 41, 51, 61, 'B'),
(3, 42, 52, 62, 'C'),
(4, 43, 53, 63, 'ABC');

SELECT * FROM dbo.OrderDetails 
WHERE productid = 51

-- UPDATE examples
UPDATE dbo.OrderDetails
  SET discount = discount + 0.05--, qty = qty + 2
WHERE productid = 51;

SELECT * FROM dbo.OrderDetails 
WHERE productid = 51

-- Compound assignment operators
UPDATE dbo.OrderDetails
  SET discount += 0.05
WHERE productid = 51;
GO

SELECT * FROM dbo.T1

UPDATE dbo.T1
  SET col1 += 10, col2 = col1 + 10;
GO

UPDATE dbo.T1
  SET col1 = col3, col3 = col1;
GO

---------------------------------------------------------------------
-- UPDATE Based on Join
---------------------------------------------------------------------

UPDATE OD
  SET discount += 0.05
FROM dbo.OrderDetails AS OD
  INNER JOIN dbo.Orders AS O
    ON OD.orderid = O.orderid
WHERE O.custid = 1;

UPDATE dbo.OrderDetails
  SET discount += 0.05
WHERE EXISTS
  (SELECT * FROM dbo.Orders AS O
   WHERE O.orderid = OrderDetails.orderid
     AND custid = 1);
GO

SELECT * FROM dbo.T1
SELECT * FROM dbo.T2

UPDATE T1
  SET col1 = T2.col1,
      col2 = T2.col2,
      col3 = T2.col3,
	  col4 = T2.col4 + 'EFG'
FROM dbo.T1 
INNER JOIN dbo.T2
 ON T2.keycol = T1.keycol
WHERE T2.col4 = 'ABC';
GO

UPDATE dbo.T1
  SET col1 = (SELECT col1
              FROM dbo.T2
              WHERE T2.keycol = T1.keycol),
              
      col2 = (SELECT col2
              FROM dbo.T2
              WHERE T2.keycol = T1.keycol),
      
      col3 = (SELECT col3
              FROM dbo.T2
              WHERE T2.keycol = T1.keycol)
WHERE EXISTS
  (SELECT *
   FROM dbo.T2
   WHERE T2.keycol = T1.keycol
     AND T2.col4 = 'ABC');

GO


/*UPDATE dbo.T1

  SET (col1, col2, col3) =

      (SELECT col1, col2, col3
       FROM dbo.T2
       WHERE T2.keycol = T1.keycol)
       
WHERE EXISTS
  (SELECT *
   FROM dbo.T2
   WHERE T2.keycol = T1.keycol
     AND T2.col4 = 'ABC');*/

GO

-- Cleanup
DROP TABLE IF EXISTS dbo.T1, dbo.T2;

---------------------------------------------------------------------
-- Merging Data
---------------------------------------------------------------------

-- Listing 8-2 Code that Creates and Populates Customers and CustomersStage
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

-- Query tables
SELECT * FROM dbo.Customers;

SELECT * FROM dbo.CustomersStage;

-- MERGE Example 1: Update existing, add missing
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
  VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address);

-- Query table
SELECT * FROM dbo.Customers; 

-- MERGE Example 2: Update existing, add missing, delete missing in source
MERGE dbo.Customers AS TGT
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
WHEN NOT MATCHED BY SOURCE THEN
  DELETE;

-- Query table
SELECT * FROM dbo.Customers; 

SELECT * FROM dbo.CustomersStage

-- MERGE Example 3: Update existing that changed, add missing
MERGE dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
  ON TGT.custid = SRC.custid
WHEN MATCHED AND 
       (   TGT.companyname <> SRC.companyname
        OR TGT.phone       <> SRC.phone
        OR TGT.address     <> SRC.address) THEN
  UPDATE SET
    TGT.companyname = SRC.companyname,
    TGT.phone = SRC.phone,
    TGT.address = SRC.address
WHEN NOT MATCHED THEN 
  INSERT (custid, companyname, phone, address)
  VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address);


-- Class Exercise:
-- Delete from the dbo.Orders table orders placed by customers from Brazil
-- Using EXISTS, JOINS, MERGE

DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Customers, dbo.Orders
GO

SELECT *
INTO dbo.Customers
FROM Sales.Customers;
GO

SELECT *
INTO dbo.Orders
FROM Sales.Orders;

-- Solution:
BEGIN TRAN
DELETE FROM dbo.Orders
WHERE EXISTS
  (SELECT TOP 1 1
   FROM dbo.Customers AS C
   WHERE dbo.Orders.custid = C.custid
     AND C.country = N'Brazil');
ROLLBACK

BEGIN TRAN
DELETE FROM O
FROM dbo.Orders AS O
  INNER JOIN dbo.Customers AS C
    ON O.custid = C.custid
WHERE country = N'Brazil';
ROLLBACK

BEGIN TRAN
MERGE INTO dbo.Orders AS O
USING (SELECT custid FROM dbo.Customers WHERE country = N'Brazil') AS C
  ON O.custid = C.custid
WHEN MATCHED THEN 
DELETE;
ROLLBACK
