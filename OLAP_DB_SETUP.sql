CREATE DATABASE BikeSalesDWTeam6;

USE BikeSalesDWTeam6; 

-- Create dimension tables
CREATE TABLE CustomerDIM (
    Customer_Key INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Customer_ID VARCHAR(10) UNIQUE,
    First_Name VARCHAR(255) NOT NULL,
    Last_Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(50),
    Street VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    Zip_Code VARCHAR(20)
);

CREATE TABLE TimeDIM (
    Time_Key INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    Week INT NOT NULL,
    Date DATE NOT NULL,
    Day_of_month INT NOT NULL,
    Day_of_week INT NOT NULL,
    Is_Weekend BIT NOT NULL,
    Is_Holiday BIT NOT NULL 
);

-- Create staging table for holidays
CREATE TABLE staging_holiday (
    raw_date VARCHAR(20),
    holiday VARCHAR(255),
    weekday VARCHAR(255),
    month VARCHAR(20),
    day VARCHAR(20),
    year VARCHAR(20)
);

-- Bulk insert into staging_holidays from a CSV file
BULK INSERT staging_holiday
FROM 'C:\AY202324\AY2023S2\DENG\Assignment2\Us Holiday Dates (2004-2021).csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n');

-- Assuming you have a final table structured like this:
CREATE TABLE holidays (
    date DATE,
    holiday VARCHAR(255),
    weekday VARCHAR(255),
    month VARCHAR(20),
    day VARCHAR(20),
    year VARCHAR(20)
);


-- Insert into the final holidays table with date conversion
INSERT INTO holidays (date, holiday, weekday, month, day, year)
SELECT
    -- Convert DD/MM/YYYY to YYYY-MM-DD
   TRY_CAST(raw_date AS DATE),
    holiday,
    weekday,
    month,
    day,
    year
FROM staging_holiday;

CREATE TABLE StaffDIM (
    Staff_Key INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Staff_ID VARCHAR(10) UNIQUE,
    First_Name VARCHAR(255) NOT NULL,
    Last_Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(50),
    Active INT NOT NULL,
    Manager_ID varchar(5) 
);

CREATE TABLE ProductDIM (
    Product_Key INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Product_ID VARCHAR(10) UNIQUE,
    Product_Name VARCHAR(255) NOT NULL,
    Brand_Name VARCHAR(255) NOT NULL,
    Category_Name VARCHAR(255) NOT NULL,
    Model_Year INT NOT NULL,
    List_Price DECIMAL(10,2) NOT NULL,
	Stocks INT
);

CREATE TABLE StoreDIM (
    Store_Key INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Store_ID VARCHAR(10) UNIQUE,
    Store_Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(50),
    Street VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    Zip_Code VARCHAR(20)
);

Create table OrderDIM(
Order_key  INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
Order_ID VARCHAR(10) UNIQUE,
order_status VARCHAR(255) NULL,
required_date DATE NOT NULL,
shipped_date DATE
)

-- Create the fact table
CREATE TABLE SalesFacts (
    Time_Key INT NOT NULL,
    Customer_Key INT NOT NULL,
    Staff_Key INT NOT NULL,
    Product_Key INT NOT NULL,
    Store_Key INT NOT NULL,
	Order_Key INT NOT NULL,
    Quantity_Sold INT NULL,
    Discount DECIMAL(10,2) NULL,
    Total_Sales DECIMAL(10,2) NULL,
	CONSTRAINT SalesKey PRIMARY KEY (Time_Key, Customer_Key, Staff_Key, Product_Key, Store_Key),
    FOREIGN KEY (Time_Key) REFERENCES TimeDIM(Time_Key),
    FOREIGN KEY (Customer_Key) REFERENCES CustomerDIM(Customer_Key),
    FOREIGN KEY (Staff_Key) REFERENCES StaffDIM(Staff_Key),
    FOREIGN KEY (Product_Key) REFERENCES ProductDIM(Product_Key),
    FOREIGN KEY (Store_Key) REFERENCES StoreDIM(Store_Key),
    FOREIGN KEY (Order_Key) REFERENCES OrderDIM(Order_Key)

);




USE BikeSalesDWTeam6; 
-- Declare start and end dates
SET DATEFIRST 7;
DECLARE @StartDate DATE = '2016-01-01';
DECLARE @EndDate DATE = '2018-12-31';

-- Populate the TimeDIM table
WITH DateCTE AS (
    SELECT @StartDate AS DateValue
    UNION ALL
    SELECT DATEADD(DAY, 1, DateValue)
    FROM DateCTE
    WHERE DateValue < @EndDate
)
INSERT INTO TimeDIM (Year, Quarter, Month, Week, Date, Day_of_month, Day_of_week, Is_Weekend, Is_Holiday)
SELECT 
    YEAR(DateValue) AS Year,
    DATEPART(QUARTER, DateValue) AS Quarter,
    MONTH(DateValue) AS Month,
    DATEPART(WEEK, DateValue) AS Week,
    DateValue AS Date,
    DAY(DateValue) AS Day_of_month,
    (DATEPART(WEEKDAY, DateValue) + @@DATEFIRST - 2) % 7 + 1 AS Day_of_week,
    CASE WHEN DATEPART(WEEKDAY, DateValue) IN (7, 1) THEN 1 ELSE 0 END AS Is_Weekend,
    -- Subquery to determine if the date is a holiday
    CASE WHEN EXISTS (SELECT 1 FROM holidays h WHERE h.date = DateValue) THEN 1 ELSE 0 END AS Is_Holiday
FROM 
    DateCTE
OPTION (MAXRECURSION 0); -- Allows for unlimited recursion


-- Populate the StaffDIM table
INSERT INTO 
	BikeSalesDWTeam6..StaffDIM (Staff_ID, First_Name, Last_Name, Email, Phone, Active, Manager_ID)
SELECT 
	staff_id, first_name, last_name, email, phone, active, manager_id
FROM BikeSalesTeam6..staffs;

-- Populate the StoreDIM table
INSERT INTO 
	BikeSalesDWTeam6..StoreDIM (Store_ID, Store_Name, Email, Phone, Street, City, State, Zip_Code)
SELECT 
	store_id, store_name, email, phone, street, city, state, zip_code
FROM BikeSalesTeam6..stores;

-- Populate the CustomerDIM table
INSERT INTO 
	BikeSalesDWTeam6..CustomerDIM (Customer_ID, First_Name, Last_Name, Email, Phone, Street, City, State, Zip_Code)
SELECT 
	customer_id, first_name, last_name, email, phone, street, city, state, zip_code
FROM BikeSalesTeam6..customers;


-- Populate ProductDIM table
INSERT INTO BikeSalesDWTeam6..ProductDIM (Product_ID, Product_Name, Brand_Name, Category_Name, Model_Year, List_Price, Stocks)
SELECT
    p.product_id,
    p.product_name,
    b.brand_name,
    c.category_name,
    p.model_year,
    p.list_price,
    ISNULL(s.TotalStocks, 0) AS Stocks
FROM
    BikeSalesTeam6..products p
JOIN
    BikeSalesTeam6..brands b ON p.brand_id = b.brand_id
JOIN
    BikeSalesTeam6..categories c ON p.category_id = c.category_id
LEFT JOIN (
    -- Subquery to calculate total stocks for each product
    SELECT
        product_id,
        SUM(quantity) AS TotalStocks
    FROM
        BikeSalesTeam6..stocks
    GROUP BY
        product_id
) s ON p.product_id = s.product_id;

-- Populate the Order table
INSERT INTO OrderDIM(Order_ID, order_status, required_date, shipped_date)
SELECT
 
    o.order_id,
    CASE
        WHEN o.order_status = 1 THEN 'Pending'
        WHEN o.order_status = 2 THEN 'Processing'
        WHEN o.order_status = 3 THEN 'Rejected'
        WHEN o.order_status = 4 THEN 'Completed'
       
    END AS order_status,
    o.required_date,
    o.shipped_date
FROM
    BikeSalesTeam6..orders o;

	Select * from OrderDIM

-- Populate the SalesFacts table
INSERT INTO SalesFacts (Time_Key, Customer_Key, Staff_Key, Product_Key, Store_Key,Order_Key, Quantity_Sold, Discount, Total_Sales)
SELECT
    TD.Time_Key,
    CD.Customer_Key,
    SD.Staff_Key,
    PD.Product_Key,
    STD.Store_Key,
    OD.Order_key,
    OI.quantity AS Quantity_Sold,
    OI.discount AS Discount,
    CAST(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(18, 2)) AS Total_Sales
FROM
    BikeSalesTeam6..orders O
INNER JOIN BikeSalesTeam6..order_items OI ON O.order_id = OI.order_id
INNER JOIN BikeSalesDWTeam6..CustomerDIM CD ON O.customer_id = CD.Customer_ID
INNER JOIN BikeSalesDWTeam6..StaffDIM SD ON O.staff_id = SD.Staff_ID
INNER JOIN BikeSalesDWTeam6..ProductDIM PD ON OI.product_id = PD.Product_ID
INNER JOIN BikeSalesDWTeam6..StoreDIM STD ON O.store_id = STD.Store_ID
INNER JOIN BikeSalesDWTeam6..OrderDIM OD ON O.order_id = OD.Order_ID
INNER JOIN BikeSalesDWTeam6..TimeDIM TD ON TD.Date = O.order_date
GROUP BY
    TD.Time_Key,
    CD.Customer_Key,
    SD.Staff_Key,
    PD.Product_Key,
    STD.Store_Key,
	OD.Order_key,
    OI.quantity,
    OI.discount

DROP TABLE staging_holiday;
DROP TABLE holidays;
