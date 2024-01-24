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
    Is_Holiday BIT NULL 
);

CREATE TABLE StaffDIM (
    Staff_Key INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Staff_ID VARCHAR(10) UNIQUE,
    First_Name VARCHAR(255) NOT NULL,
    Last_Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(50),
    Active INT NOT NULL,
    Manager_ID varchar(5) -- Assuming this is a reference to another Staff_Key
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

-- Create the fact table
CREATE TABLE SalesFacts (
    Time_Key INT NOT NULL,
    Customer_Key INT NOT NULL,
    Staff_Key INT NOT NULL,
    Product_Key INT NOT NULL,
    Store_Key INT NOT NULL,
    Order_Status VARCHAR(255) NULL,
    Quantity_Sold INT NULL,
    Discount DECIMAL(10,2) NULL,
    Total_Sales DECIMAL(10,2) NULL,
    FOREIGN KEY (Time_Key) REFERENCES TimeDIM(Time_Key),
    FOREIGN KEY (Customer_Key) REFERENCES CustomerDIM(Customer_Key),
    FOREIGN KEY (Staff_Key) REFERENCES StaffDIM(Staff_Key),
    FOREIGN KEY (Product_Key) REFERENCES ProductDIM(Product_Key),
    FOREIGN KEY (Store_Key) REFERENCES StoreDIM(Store_Key)
);


USE BikeSalesDWTeam6; 
-- Declare start and end dates
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
    -- Adjust the +1 if the week starts on a different day
    (DATEPART(WEEKDAY, DateValue) + @@DATEFIRST - 1) % 7 + 1 AS Day_of_week,
    -- Check for Saturday (7) or Sunday (1)
    CASE WHEN (DATEPART(WEEKDAY, DateValue) + @@DATEFIRST - 1) % 7 + 1 IN (1, 7) THEN 1 ELSE 0 END AS Is_Weekend,
    NULL AS Is_Holiday -- Default to NULL
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










