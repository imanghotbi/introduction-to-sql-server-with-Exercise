-- 1.1
-- CREATE a new table that envlove 2 coloumns EmpId INT, Commission BIGINT
-- and calculate the employees commission by this formula: 
-- SUM(val) BETWEEN 50000  AND 100000 THEN SUM(val) * 0.01
-- SUM(val) BETWEEN 100001 AND 200000 THEN SUM(val) * 0.02
-- SUM(val) BETWEEN 200001 AND 300000 THEN SUM(val) * 0.03
-- SUM(val) BETWEEN 300001 AND 400000 THEN SUM(val) * 0.04
-- Insert this Data into Sales.Commission Table

-- Solution:
DROP TABLE IF EXISTS Sales.Commission

CREATE TABLE Sales.Commission
(
    EmpId INT PRIMARY KEY CLUSTERED NOT NULL,
	Commission BIGINT NULL
)

INSERT INTO Sales.Commission(EmpId, Commission)
SELECT empid,
       CASE
           WHEN SUM(val) BETWEEN 50000  AND 100000 THEN SUM(val) * 0.01
		   WHEN SUM(val) BETWEEN 100001 AND 200000 THEN SUM(val) * 0.02
		   WHEN SUM(val) BETWEEN 200001 AND 300000 THEN SUM(val) * 0.03
		   WHEN SUM(val) BETWEEN 300001 AND 400000 THEN SUM(val) * 0.04
		   WHEN SUM(val) > 400000 THEN SUM(val) * 0.05
		   ELSE 0
       END
FROM Sales.OrderValues
GROUP BY empid;

SELECT * FROM Sales.OrderValues

SELECT * FROM Sales.Commission

-- 1.2
-- ADD a new column to Sales.Commission table as CommissionClass CHAR(1) NULL
-- and update CommissionClass with this formula based on All Distinct products that ordered by the employee:
-- ProductCount BETWEEN 50 AND 59 THEN 'C'
-- ProductCount BETWEEN 60 AND 69 THEN 'B'
-- ProductCount BETWEEN 70 AND 79 THEN 'A'

-- Solution:
ALTER TABLE Sales.Commission ADD CommissionClass CHAR(1) NULL
GO

UPDATE Sales.Commission 
SET CommissionClass =  CASE WHEN S.ProductCount BETWEEN 50 AND 59 THEN 'C'
							WHEN S.ProductCount BETWEEN 60 AND 69 THEN 'B'
							WHEN S.ProductCount BETWEEN 70 AND 79 THEN 'A'
							ELSE 'U'
					   END
FROM(SELECT O.empid, COUNT(DISTINCT OD.productid) AS ProductCount
	 FROM Sales.Orders O
		INNER JOIN Sales.OrderDetails OD ON OD.orderid = O.orderid
	 GROUP BY O.empid) AS S
WHERE S.empid = Commission.EmpId

-- 1.3
-- Update Commission with this formula:
-- CommissionClass = 'A' THEN Commission * 1.01 
-- CommissionClass = 'B' THEN Commission * 1.005

-- Solution:

UPDATE Sales.Commission 
SET Commission *= CASE  WHEN CommissionClass = 'A' THEN 1.01 
						WHEN CommissionClass = 'B' THEN 1.005
						ELSE 1
				  END
--WHERE CommissionClass IN ('A', 'B')

-- 1.4
-- Update Commission with this formula:
-- Have sales for at least 20 months
-- Average monthly sales BETWEEN 5000 AND 7999  THEN 5  Percent Increase
-- Average monthly sales BETWEEN 8000 AND 9999  THEN 7  Percent Increase
-- Average monthly sales more than 10000		THEN 10 Percent Increase

-- Solution:
UPDATE Sales.Commission 
SET Commission *=	CASE WHEN S.AVGMonthVal BETWEEN 5000 AND 7999 THEN 1.05
						 WHEN S.AVGMonthVal BETWEEN 8000 AND 9999 THEN 1.07
						 WHEN S.AVGMonthVal >= 10000 THEN 1.1 
						 ELSE 1
					END
FROM(SELECT empid, AVG(val) AVGMonthVal, COUNT(ordermonth) CountMonth
		FROM Sales.EmpOrders
		GROUP BY empid
		HAVING (COUNT(ordermonth) > 20 AND AVG(val) >= 5000)) AS S
WHERE S.empid = Commission.EmpId
GO

SELECT * FROM Sales.EmpOrders
ORDER BY empid

-- without view:

;WITH cte
AS (SELECT S.empid,
           AVG(S.MonthVal) AVGMonthVal,
           COUNT(S.OrderMonth) MonthCount
    FROM
    (
        SELECT O.empid,
               CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount)) AS NUMERIC(12, 2)) MonthVal,
               FORMAT(O.orderdate, 'yyyy MM', 'en-US') OrderMonth
			   --, MONTH(O.orderdate), YEAR(O.orderdate)
        FROM Sales.Orders O
            INNER JOIN Sales.OrderDetails OD
                ON OD.orderid = O.orderid
        GROUP BY O.empid,
                 FORMAT(O.orderdate, 'yyyy MM', 'en-US')
				 --, MONTH(O.orderdate), YEAR(O.orderdate)
		--ORDER BY O.empid
    ) AS S
    GROUP BY S.empid
    HAVING (COUNT(S.OrderMonth) > 20 AND AVG(S.MonthVal) >= 5000))
UPDATE Sales.Commission
SET Commission *= CASE WHEN cte.AVGMonthVal BETWEEN 5000 AND 7999 THEN 1.05
                       WHEN cte.AVGMonthVal BETWEEN 8000 AND 9999 THEN 1.07
                       WHEN cte.AVGMonthVal >= 10000 THEN 1.1
                       ELSE 1
                  END
FROM cte
WHERE cte.empid = Commission.EmpId;
