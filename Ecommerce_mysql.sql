CREATE DATABASE Ecommerce_data;

USE Ecommerce_data;

-- importing dataset via Import Wizard

SELECT * FROM ecommerce_dataset;

-- Creating table for cleaning and adding new column as invoice date requried changing 

CREATE TABLE Cleaned_ecommerce_dataset AS
SELECT *, SUBSTRING_INDEX(InvoiceDate, "/" , 1) AS MonthNo, RIGHT(InvoiceDate,4) AS YearNo,
SUBSTR((
SUBSTRING_INDEX((
SUBSTR(InvoiceDate, POSITION("/" IN SUBSTRING_INDEX(InvoiceDate, "/" , 2)),3)), "/", 2)),2)
AS DayNo
FROM ecommerce_dataset;
 
 --  DEALING WITH INVOICE DATA COLUMN
 SELECT * FROM Cleaned_ecommerce_dataset;
 ALTER TABLE Cleaned_ecommerce_dataset ADD InvoiceDate1 TEXT;
 UPDATE Cleaned_ecommerce_dataset
 SET InvoiceDate1 = CONCAT(YearNo,"-",MonthNo,"-",DayNo);
 ALTER TABLE Cleaned_ecommerce_dataset MODIFY InvoiceDate1 DATE;
 
 SELECT * FROM Cleaned_ecommerce_dataset;
 
 -- REMOVING UNNECESSARY COLUMNS
 
 ALTER TABLE Cleaned_ecommerce_dataset DROP COLUMN InvoiceDate; 
 ALTER TABLE Cleaned_ecommerce_dataset DROP COLUMN MonthNo; 
 ALTER TABLE Cleaned_ecommerce_dataset DROP COLUMN DayNo; 
 ALTER TABLE Cleaned_ecommerce_dataset DROP COLUMN YearNo; 
 
 -- Changing column name 
 
ALTER TABLE Cleaned_ecommerce_dataset RENAME COLUMN InvoiceDate1 TO InvoiceDate;

-- changing datatypes IN OTHER COLUMNS
ALTER TABLE Cleaned_ecommerce_dataset MODIFY CustomerID INT;
ALTER TABLE Cleaned_ecommerce_dataset MODIFY Gender VARCHAR(10);
ALTER TABLE Cleaned_ecommerce_dataset MODIFY InvoiceNumber INT; 
ALTER TABLE Cleaned_ecommerce_dataset MODIFY ProductID INT;
ALTER TABLE Cleaned_ecommerce_dataset MODIFY Quantity INT;
ALTER TABLE Cleaned_ecommerce_dataset MODIFY Price DECIMAL(10,2); 
ALTER TABLE Cleaned_ecommerce_dataset MODIFY Total DECIMAL(10,2);
ALTER TABLE Cleaned_ecommerce_dataset MODIFY OrderStatus VARCHAR(25); 
ALTER TABLE Cleaned_ecommerce_dataset MODIFY Country VARCHAR(25); 
ALTER TABLE Cleaned_ecommerce_dataset MODIFY TrafficSource VARCHAR(25); 
ALTER TABLE Cleaned_ecommerce_dataset MODIFY SessionDuration DECIMAL(10,2);
ALTER TABLE Cleaned_ecommerce_dataset MODIFY DeviceCategory VARCHAR(25);  
ALTER TABLE Cleaned_ecommerce_dataset MODIFY Device VARCHAR(25); 
ALTER TABLE Cleaned_ecommerce_dataset MODIFY OS VARCHAR(25); 
ALTER TABLE Cleaned_ecommerce_dataset MODIFY DeliveryRating INT;
ALTER TABLE Cleaned_ecommerce_dataset MODIFY ProductRating INT;
ALTER TABLE Cleaned_ecommerce_dataset MODIFY Sales DECIMAL(10,2); 


-- Checking and showing duplicates
WITH cte AS (
    SELECT *, 
    ROW_NUMBER () OVER (PARTITION BY CustomerID, InvoiceDate, InvoiceNumber ORDER BY CustomerID) AS number_of_cust_inv
	FROM Cleaned_ecommerce_dataset
    )
    SELECT DISTINCT 
		a.CustomerID, a.Gender, a.InvoiceDate, a.InvoiceNumber, a.ProductID, a.Quantity,
        a.Price, a.Total, a.OrderStatus, a.Country, a.TrafficSource, a.SessionDuration,
        a.DeviceCategory, a.Device, a.OS, a.DeliveryRating, a.ProductRating, a.Sales,
        a.number_of_cust_inv
    FROM cte a
    CROSS JOIN cte b on a.CustomerID = b.CustomerID AND a.InvoiceNumber = b.InvoiceNumber
    AND a.number_of_cust_inv <> b.number_of_cust_inv;
    
    -- Exploring data
-- 1 Number of customers
SELECT COUNT(DISTINCT(CustomerID)) AS NumberOfCustomers FROM Cleaned_ecommerce_dataset;

-- 2 Female ratio %
SELECT Gender, CONCAT(
	ROUND((COUNT(DISTINCT(CustomerID)))/
    (SELECT COUNT(DISTINCT(CustomerID)) FROM Cleaned_ecommerce_dataset)*100,2), " %") AS PctNumberOfCustomers
    FROM Cleaned_ecommerce_dataset
    WHERE Gender = "Female"
    GROUP BY 1;

-- 3 Number of products
SELECT COUNT(DISTINCT(ProductID)) AS NumberOfProducts FROM Cleaned_ecommerce_dataset;

-- 4 Average quantity per order
SELECT ROUND(AVG(Quantity),0) AS AvgQuantityPerOrder FROM Cleaned_ecommerce_dataset;

-- 5 Average order price
SELECT CONCAT("$ ",ROUND(AVG(Total),2)) AS AvgOrderPrice FROM Cleaned_ecommerce_dataset;

-- 6 Min value of order
SELECT CONCAT("$ ",ROUND(MIN(Total),2)) AS MinValueOfOrder FROM Cleaned_ecommerce_dataset;

-- 7 Max value of order
SELECT CONCAT("$ ",ROUND(MAX(Total),2)) AS MaxValueOfOrder FROM Cleaned_ecommerce_dataset;

-- 8 Completed orders ratio%
SELECT OrderStatus, CONCAT(ROUND(
COUNT(OrderStatus)
/ (SELECT COUNT((OrderStatus)) FROM Cleaned_ecommerce_dataset)*100,2), "%") AS PctOfCompletedOrders
FROM
Cleaned_ecommerce_dataset
WHERE OrderStatus = "Completed"
GROUP BY 1;

-- 9 Cancelled and Rejected ratio%
WITH cte AS (
SELECT OrderStatus, CONCAT(ROUND(
COUNT(OrderStatus)
/ (SELECT COUNT((OrderStatus)) FROM Cleaned_ecommerce_dataset)*100,2), "%") AS PctOfUnompletedOrders
FROM
Cleaned_ecommerce_dataset
WHERE OrderStatus = "Rejected" OR OrderStatus = "Cancelled"
GROUP BY 1)
SELECT CONCAT(SUM(PctOfUnompletedOrders)," %") AS PctOfRejectedandCancelledOrders FROM cte;

-- 10 Number of countries
SELECT COUNT(DISTINCT(Country)) AS NumberOfCountries FROM Cleaned_ecommerce_dataset;

-- 11 Traffic source: Social media %
SELECT TrafficSource, CONCAT(ROUND(COUNT(TrafficSource)/
(SELECT COUNT(TrafficSource) FROM Cleaned_ecommerce_dataset)*100,2), " %") AS PctSocialMediaTrafficSource
FROM Cleaned_ecommerce_dataset
WHERE TrafficSource = "Social media"
GROUP BY 1;

-- 12 Traffic source: Organic Search %
SELECT TrafficSource, CONCAT(ROUND(COUNT(TrafficSource)/
(SELECT COUNT(TrafficSource) FROM Cleaned_ecommerce_dataset)*100,2), " %") AS PctOrganicSearchTrafficSource
FROM Cleaned_ecommerce_dataset
WHERE TrafficSource = "Organic Search"
GROUP BY 1;

-- 13 Traffic source: Paid Advertisment %
SELECT TrafficSource, CONCAT(ROUND(COUNT(TrafficSource)/
(SELECT COUNT(TrafficSource) FROM Cleaned_ecommerce_dataset)*100,2), " %") AS PctPaidAdvertismentTrafficSource
FROM Cleaned_ecommerce_dataset
WHERE TrafficSource = "Paid Advertisment"
GROUP BY 1;

-- 11 & 12 & 13 IN ONE
SELECT TrafficSource, CONCAT(ROUND(COUNT(TrafficSource)/
(SELECT COUNT(TrafficSource) FROM Cleaned_ecommerce_dataset)*100,2), " %") AS PctTrafficSource
FROM Cleaned_ecommerce_dataset
GROUP BY 1
ORDER BY 2 DESC;

-- 14 Average session duration [min]
SELECT CONCAT(ROUND(AVG(SessionDuration),0), " minutes") AS AvgSessionDurationMin 
FROM Cleaned_ecommerce_dataset;

-- 15 Average session duration [min]
SELECT CONCAT(ROUND(AVG(SessionDuration*60),0), " sec") AS AvgSessionDurationSec
FROM Cleaned_ecommerce_dataset;

-- 16 Device category: Computer ratio %
SELECT DeviceCategory, CONCAT(ROUND(COUNT(DeviceCategory)
/ (SELECT COUNT(DeviceCategory) FROM Cleaned_ecommerce_dataset)*100,2), "%") AS ComputerRatio
FROM Cleaned_ecommerce_dataset
WHERE DeviceCategory = "Computer"
GROUP BY 1;

-- 17 Device: Laptop ratio%
SELECT Device, CONCAT(ROUND(COUNT(Device)
/ (SELECT COUNT(Device) FROM Cleaned_ecommerce_dataset)*100,2), "%") AS LaptopRatio
FROM Cleaned_ecommerce_dataset
WHERE Device = "Laptop"
GROUP BY 1;

-- 18 Device: Desktop ratio%
SELECT Device, CONCAT(ROUND(COUNT(Device)
/ (SELECT COUNT(Device) FROM Cleaned_ecommerce_dataset)*100,2), "%") AS DesktopRatio
FROM Cleaned_ecommerce_dataset
WHERE Device = "Desktop"
GROUP BY 1;

-- 19 Device: Tablet ratio%
SELECT Device, CONCAT(ROUND(COUNT(Device)
/ (SELECT COUNT(Device) FROM Cleaned_ecommerce_dataset)*100,2), "%") AS TabletRatio
FROM Cleaned_ecommerce_dataset
WHERE Device = "Tablet"
GROUP BY 1;

-- 20 Device: Smart Phone ratio%
SELECT Device, CONCAT(ROUND(COUNT(Device)
/ (SELECT COUNT(Device) FROM Cleaned_ecommerce_dataset)*100,2), "%") AS SmartPhoneRatio
FROM Cleaned_ecommerce_dataset
WHERE Device = "Smart Phone"
GROUP BY 1;

-- 17 & 18 & 19 & 20
SELECT Device, CONCAT(ROUND(COUNT(Device)
/ (SELECT COUNT(Device) FROM Cleaned_ecommerce_dataset)*100,2), "%") AS SmartPhoneRatio
FROM Cleaned_ecommerce_dataset
GROUP BY 1
ORDER BY 2 DESC;

-- 21 Average delivery rating
SELECT ROUND(AVG(DeliveryRating),2) AS AvgDeliveryRating FROM Cleaned_ecommerce_dataset;

-- 22 Average product raiting
SELECT ROUND(AVG(ProductRating),2) AS AvgProductRating FROM Cleaned_ecommerce_dataset;

-- 23 Total value of all orders
SELECT CONCAT("$ ", ROUND(SUM(Total),0)) AS TotalValueOfAllOrders FROM Cleaned_ecommerce_dataset;

-- 24 Value of completed orders
SELECT CONCAT("$ ", ROUND(SUM(Sales),0)) AS TotalValueOfAllOrders FROM Cleaned_ecommerce_dataset;

-- 25 Value of uncompleted orders (our loss) 
SELECT CONCAT("$ ", ROUND(SUM(Total) - SUM(Sales),0)) AS TotalValueOfAllOrders FROM Cleaned_ecommerce_dataset;


-- ADDITIONAL EXPLORING 
-- Popular products (TOP 5)
SELECT ProductID, SUM(Quantity) AS TotalQuantity FROM Cleaned_ecommerce_dataset
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5 ;

-- TOP 10 countires with the highest number of customers
SELECT Country, COUNT(Country) AS NumberOfCustomers
FROM Cleaned_ecommerce_dataset
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Orders each year
SELECT YEAR(InvoiceDate) AS Years, COUNT(InvoiceNumber) AS NumberOfOrders
FROM  Cleaned_ecommerce_dataset
GROUP BY 1
ORDER BY 1 DESC;

-- COMPLETED orders each year
SELECT YEAR(InvoiceDate) AS Years, COUNT(InvoiceNumber) AS NumberOfCompletedOrders
FROM  Cleaned_ecommerce_dataset
WHERE OrderStatus = "Completed"
GROUP BY 1
ORDER BY 1 DESC;

-- Completed vs Rejected & Cancelled Orders each year
SELECT YEAR(InvoiceDate) AS years, CASE WHEN 
OrderStatus = "Rejected" OR OrderStatus = "Cancelled" THEN "Uncompleted"
ELSE "Completed"
END as OrderStatus,
COUNT(InvoiceNumber) AS NumberOfOrders
FROM Cleaned_ecommerce_dataset
WHERE OrderStatus <> "In process"
GROUP BY 1,2;

-- OS VS Session Duration
SELECT OS, CONCAT(ROUND(AVG(SessionDuration)*60,0), " sec") AS AvgSessionDuration
FROM Cleaned_ecommerce_dataset
GROUP BY 1 
ORDER BY 2 DESC;

-- Sales by Country (TOP 10)
WITH cte AS (
SELECT Country, ROUND(IFNULL(SUM(Sales),0),2) as Sales
FROM Cleaned_ecommerce_dataset
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10
) 
SELECT Country, CONCAT("$ ", Sales) AS Sales
FROM cte;

-- Sales by Country (BUTTOM 10)
WITH cte AS (
SELECT Country, ROUND(IFNULL(SUM(Sales),0),2) as Sales
FROM Cleaned_ecommerce_dataset
GROUP BY 1 
ORDER BY 2 ASC
LIMIT 10
) 
SELECT Country, CONCAT("$ ", Sales) AS Sales
FROM cte;

-- month with the highest number of orders
SELECT MONTHNAME(InvoiceDate) AS NameOfMonth, COUNT(InvoiceNumber) as NumberOfOrders
FROM Cleaned_ecommerce_dataset
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- month and year with the highest number of orders
SELECT NameOfMonth, Years, NumberOfOrders 
FROM
	(WITH cte AS (SELECT MONTHNAME(InvoiceDate) AS NameOfMonth, YEAR(InvoiceDate) AS Years, 
	COUNT(InvoiceNumber) as NumberOfOrders
	FROM Cleaned_ecommerce_dataset
	GROUP BY 1,2)
		SELECT *, MAX(NumberOfOrders) OVER (PARTITION BY Years) AS MaxNumberOfOrders
		FROM cte) a
WHERE MaxNumberOfOrders = NumberOfOrders;

SELECT * FROM cleaned_ecommerce_dataset;

-- MOVING COLIMN INOVICE DATE AFTER INVOICE NUMBER
ALTER TABLE cleaned_ecommerce_dataset MODIFY COLUMN InvoiceDate DATE AFTER InvoiceNumber;

-- EXPORTING DATA TO CSV FILE 
SELECT * FROM cleaned_ecommerce_dataset;