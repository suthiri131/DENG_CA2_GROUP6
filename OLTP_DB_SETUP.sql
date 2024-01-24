-- Create statements
CREATE DATABASE BikeSalesTeam6;
USE BikeSalesTeam6

CREATE TABLE stores (
store_id varchar(5) PRIMARY KEY,
store_name VARCHAR (255) NOT NULL,
phone VARCHAR (25),
email VARCHAR (255),
street VARCHAR (255),
city VARCHAR (255),
state VARCHAR (10),
zip_code VARCHAR (5)
);

CREATE TABLE staffs (
staff_id varchar(5) PRIMARY KEY,
first_name VARCHAR (50) NOT NULL,
last_name VARCHAR (50) NOT NULL,
email VARCHAR (255) NOT NULL UNIQUE,
phone VARCHAR (25),
active int NOT NULL,
store_id varchar(5) NOT NULL,
manager_id varchar(5),
FOREIGN KEY (store_id) REFERENCES stores (store_id)
ON DELETE CASCADE
ON UPDATE CASCADE,
FOREIGN KEY (manager_id) REFERENCES staffs (staff_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
);

CREATE TABLE categories (
category_id varchar(5) PRIMARY KEY,
category_name VARCHAR (255) NOT NULL
);

CREATE TABLE brands (
brand_id varchar(5) PRIMARY KEY,
brand_name VARCHAR (255) NOT NULL
);

CREATE TABLE products (
product_id varchar(10) PRIMARY KEY,
product_name VARCHAR (255) NOT NULL,
brand_id varchar(5) NOT NULL,
category_id varchar(5) NOT NULL,
model_year int NOT NULL,
list_price DECIMAL (10, 2) NOT NULL,
FOREIGN KEY (category_id) REFERENCES categories (category_id)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (brand_id) REFERENCES brands (brand_id)
ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE customers (
customer_id varchar(10) PRIMARY KEY,
first_name VARCHAR (255) NOT NULL,
last_name VARCHAR (255) NOT NULL,
phone VARCHAR (25),
email VARCHAR (255) NOT NULL,
street VARCHAR (255),
city VARCHAR (50),
state VARCHAR (25),
zip_code VARCHAR (5)
);

CREATE TABLE orders (
order_id varchar(10) PRIMARY KEY,
customer_id varchar(10),
order_status int NOT NULL,
order_date DATE NOT NULL,
required_date DATE NOT NULL,
shipped_date DATE,
store_id varchar(5) NOT NULL,
staff_id varchar(5) NOT NULL,
FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (store_id) REFERENCES stores (store_id)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (staff_id) REFERENCES staffs (staff_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
);

CREATE TABLE order_items(
order_id varchar(10),
item_id INT,
product_id varchar(10) NOT NULL,
quantity INT NOT NULL,
list_price DECIMAL (10, 2) NOT NULL,
discount DECIMAL (4, 2) NOT NULL DEFAULT 0,
PRIMARY KEY (order_id, item_id),
FOREIGN KEY (order_id) REFERENCES orders (order_id)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (product_id) REFERENCES products (product_id)
ON DELETE CASCADE
ON UPDATE CASCADE
);

CREATE TABLE stocks (
store_id varchar(5),
product_id varchar(10),
quantity INT,
PRIMARY KEY (store_id, product_id),
FOREIGN KEY (store_id) REFERENCES stores (store_id)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (product_id) REFERENCES products (product_id)
ON DELETE CASCADE
ON UPDATE CASCADE
 );

-- Insert statements

USE BikeSalesTeam6
INSERT INTO brands (brand_id, brand_name) VALUES 
('BRD1', 'Electra'),
('BRD2', 'Haro'),
('BRD3', 'Heller'),
('BRD4', 'Pure Cycles'),
('BRD5', 'Ritchey'),
('BRD6', 'Strider'),
('BRD7', 'Sun Bicycles'),
('BRD8', 'Surly'),
('BRD9', 'Trek');

INSERT INTO categories (category_id, category_name) VALUES 
('CHB1', 'Children Bicycles'),
('CMB2', 'Comfort Bicycles'),
('CRB3', 'Cruisers Bicycles'),
('CYB4', 'Cyclocross Bicycles'),
('ELB5', 'Electric Bikes'),
('MOB6', 'Mountain Bikes'),
('RDB7', 'Road Bikes');

INSERT INTO stores (store_id, store_name, phone, email, street, city, state, zip_code) VALUES 
('ST1', 'Santa Cruz Bikes', '(831) 476-4321', 'santacruz@bikes.shop', '3700 Portola Drive', 'Santa Cruz', 'CA', '95060'),
('ST2', 'Baldwin Bikes', '(516) 379-8888', 'baldwin@bikes.shop', '4200 Chestnut Lane', 'Baldwin', 'NY', '11432'),
('ST3', 'Rowlett Bikes', '(972) 530-5555', 'rowlett@bikes.shop', '8000 Fairway Avenue', 'Rowlett', 'TX', '75088');	

INSERT INTO staffs (staff_id, first_name, last_name, email, phone, active, store_id, manager_id) VALUES 
('3031', 'Fabiola', 'Jackson', 'fabiola.jackson@bikes.shop', '(831) 555-5554', 1, 'ST1', NULL),
('30310', 'Bernardine', 'Houston', 'bernardine.houston@bikes.shop', '(972) 530-5557', 1, 'ST3', '3037'),
('3032', 'Mireya', 'Copeland', 'mireya.copeland@bikes.shop', '(831) 555-5555', 1, 'ST1', '3031'),
('3033', 'Genna', 'Serrano', 'genna.serrano@bikes.shop', '(831) 555-5556', 1, 'ST1', '3032'),
('3034', 'Virgie', 'Wiggins', 'virgie.wiggins@bikes.shop', '(831) 555-5557', 1, 'ST1', '3032'),
('3035', 'Jannette', 'David', 'jannette.david@bikes.shop', '(516) 379-4444', 1, 'ST2', '3031'),
('3036', 'Marcelene', 'Boyer', 'marcelene.boyer@bikes.shop', '(516) 379-4445', 1, 'ST2', '3035'),
('3037', 'Venita', 'Daniel', 'venita.daniel@bikes.shop', '(516) 379-4446', 1, 'ST2', '3035'),
('3038', 'Kali', 'Vargas', 'kali.vargas@bikes.shop', '(972) 530-5555', 1, 'ST3', '3031'),
('3039', 'Layla', 'Terrell', 'layla.terrell@bikes.shop', '(972) 530-5556', 1, 'ST3', '3037');

BULK INSERT customers
--replace with own path
FROM 'D:\Year2\Sem2\DENG\Assignment\CA2\customers.csv'
WITH (fieldterminator=',', rowterminator='\n')

--orders table
CREATE TABLE staging_orders (
    order_id VARCHAR(10),
    customer_id VARCHAR(10),
    order_status INT,
    order_date VARCHAR(20),
    required_date VARCHAR(20),
    shipped_date VARCHAR(20),
    store_id VARCHAR(5),
    staff_id VARCHAR(5)
);

BULK INSERT staging_orders
--replace with own path
FROM 'D:\Year2\Sem2\DENG\Assignment\CA2\Orders.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    KEEPNULLS
);

INSERT INTO orders (order_id, customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
SELECT
    order_id,
    customer_id,
    order_status,
    -- Convert DD/MM/YYYY to YYYY-MM-DD
    CONVERT(DATE, TRY_CONVERT(DATE, order_date, 103)),
    CONVERT(DATE, TRY_CONVERT(DATE, required_date, 103)),
    CASE 
        WHEN shipped_date IS NOT NULL AND shipped_date != 'NULL' AND LTRIM(RTRIM(shipped_date)) != ''
        THEN CONVERT(DATE, TRY_CONVERT(DATE, shipped_date, 103))
        ELSE NULL
    END,
    store_id,
    staff_id
FROM staging_orders;

DROP TABLE staging_orders;

BULK INSERT order_items
--replace with own path
FROM 'D:\Year2\Sem2\DENG\Assignment\CA2\OrderItems.csv'
WITH (fieldterminator=',', rowterminator='\n')

BULK INSERT stocks
--replace with own path
FROM 'D:\Year2\Sem2\DENG\Assignment\CA2\Stocks.csv'
WITH (fieldterminator=',', rowterminator='\n')

Declare @Product varchar(max)
Select @Product = 
 BulkColumn 
 from OPENROWSET(BULK 'D:\Year2\Sem2\DENG\Assignment\CA2\products.json', SINGLE_BLOB) JSON
Insert into products 
 Select * From OpenJSON(@Product, '$') 
with (
 product_id varchar(10) '$.product_id',
    product_name varchar(255) '$.product_name',
    brand_id varchar(5) '$.brand_id',
    category_id varchar(5) '$.category_id',
    model_year int '$.model_year',
    list_price decimal(10,2) '$.list_price')

