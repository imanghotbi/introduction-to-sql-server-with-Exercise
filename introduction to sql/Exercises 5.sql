-- 1.1
-- CREATE a new table that envlove 2 coloumns EmpId INT, Commission BIGINT
-- and calculate the employees commission by this formula: 
-- SUM(val) BETWEEN 50000  AND 100000 THEN SUM(val) * 0.01
-- SUM(val) BETWEEN 100001 AND 200000 THEN SUM(val) * 0.02
-- SUM(val) BETWEEN 200001 AND 300000 THEN SUM(val) * 0.03
-- SUM(val) BETWEEN 300001 AND 400000 THEN SUM(val) * 0.04
-- Insert this Data into Sales.Commission Table

-- 1.2
-- ADD a new column to Sales.Commission table as CommissionClass CHAR(1) NULL
-- and update CommissionClass with this formula based on All Distinct products that ordered by the employee:
-- ProductCount BETWEEN 50 AND 59 THEN 'C'
-- ProductCount BETWEEN 60 AND 69 THEN 'B'
-- ProductCount BETWEEN 70 AND 79 THEN 'A'

-- 1.3
-- Update Commission with this formula:
-- CommissionClass = 'A' THEN Commission * 1.01 
-- CommissionClass = 'B' THEN Commission * 1.005

-- 1.4
-- Update Commission with this formula:
-- Have sales for at least 20 months
-- Average monthly sales BETWEEN 5000 AND 7999  THEN 5  Percent Increase
-- Average monthly sales BETWEEN 8000 AND 9999  THEN 7  Percent Increase
-- Average monthly sales more than 10000		THEN 10 Percent Increase

