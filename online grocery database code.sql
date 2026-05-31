------------------------------
-----Creating DataBase--------
------------------------------

CREATE DATABASE OnlineGroceryDB;
GO


USE OnlineGroceryDB;
GO

---------------------------
--Creating Tables----------
---------------------------

-- 1. CITY
CREATE TABLE City (
    CityID          INT IDENTITY(1,1) PRIMARY KEY,
    CityName        NVARCHAR(100) NOT NULL,
    CityAddress     NVARCHAR(200) NULL,
    PostcodePrefix  NVARCHAR(10) NULL,
    Country         NVARCHAR(100) NOT NULL,
    IsActive        BIT NOT NULL DEFAULT 1
);
GO

-- 2. CATEGORY
CREATE TABLE Category (
    CategoryID          INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName        NVARCHAR(100) NOT NULL,
    CategoryDescription NVARCHAR(255) NULL
);
GO


-- 3. CUSTOMER
CREATE TABLE Customer (
    CustomerID    INT IDENTITY(1,1) PRIMARY KEY,
    FirstName     NVARCHAR(100) NOT NULL,
    LastName      NVARCHAR(100) NOT NULL,
    Email         NVARCHAR(150) NOT NULL,
    PhoneNumber   NVARCHAR(50) NULL,
    CityID        INT NOT NULL,
    AddressLine1  NVARCHAR(150) NOT NULL,
    AddressLine2  NVARCHAR(150) NULL,
    Postcode      NVARCHAR(20) NOT NULL,
    DateCreated   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    DateOfBirth   DATE NULL,
    IsActive      BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Customer_City
        FOREIGN KEY (CityID) REFERENCES City(CityID)
);
GO

-- 4. PRODUCT
CREATE TABLE Product (
    ProductID          INT IDENTITY(1,1) PRIMARY KEY,
    ProductName        NVARCHAR(150) NOT NULL,
    ProductDescription NVARCHAR(255) NULL,
    UnitPrice          DECIMAL(10,2) NOT NULL CHECK (UnitPrice > 0),
    UnitOfMeasure      NVARCHAR(50) NOT NULL,  -- e.g. 'kg', 'each'
    SKU                NVARCHAR(50) NULL,
    ImageUrl           NVARCHAR(255) NULL,
    IsActive           BIT NOT NULL DEFAULT 1,
    CategoryID         INT NOT NULL,
    CONSTRAINT FK_Product_Category
        FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);
GO


-- 5. INVENTORY
CREATE TABLE Inventory (
    InventoryID        INT IDENTITY(1,1) PRIMARY KEY,
    ProductID          INT NOT NULL,
    InventoryQuantity  INT NOT NULL CHECK (InventoryQuantity >= 0),
    WarehouseLocation  NVARCHAR(100) NULL,
    SafetyStock        INT NULL,
    ReorderQuantity    INT NULL,
    LastUpdated        DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Inventory_Product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
GO


-- 6. ORDER (Order header)
CREATE TABLE [Order] (
    OrderID       INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID    INT NOT NULL,
    CityID        INT NOT NULL,
    OrderDate     DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    NumberOfItems INT NOT NULL CHECK (NumberOfItems >= 0),
    OrderStatus   NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    TotalAmount   DECIMAL(10,2) NOT NULL CHECK (TotalAmount >= 0),
    OrderName     NVARCHAR(150) NULL,
    CONSTRAINT FK_Order_Customer
        FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT FK_Order_City
        FOREIGN KEY (CityID) REFERENCES City(CityID)
);
GO


-- 7. ORDERITEM (Order lines)
CREATE TABLE OrderItem (
    OrderItemID    INT IDENTITY(1,1) PRIMARY KEY,
    OrderID        INT NOT NULL,
    ProductID      INT NOT NULL,
    Quantity       INT NOT NULL CHECK (Quantity > 0),
    UnitPrice      DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    LineTotal      AS (Quantity * UnitPrice) PERSISTED,
    DiscountAmount DECIMAL(10,2) NULL DEFAULT 0,
    TaxAmount      DECIMAL(10,2) NULL DEFAULT 0,
    CONSTRAINT FK_OrderItem_Order
        FOREIGN KEY (OrderID) REFERENCES [Order](OrderID),
    CONSTRAINT FK_OrderItem_Product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
GO


-- 8. TRANSACTION (Payments)
CREATE TABLE [Transaction] (
    TransactionID     INT IDENTITY(1,1) PRIMARY KEY,
    OrderID           INT NOT NULL,
    TransactionDate   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    TransactionAmount DECIMAL(10,2) NOT NULL CHECK (TransactionAmount >= 0),
    PaymentMethod     NVARCHAR(50) NOT NULL,   -- e.g. 'Card', 'PayPal'
    PaymentStatus     NVARCHAR(50) NOT NULL,   -- e.g. 'Paid', 'Pending'
    PaymentReference  NVARCHAR(100) NULL,
    CONSTRAINT FK_Transaction_Order
        FOREIGN KEY (OrderID) REFERENCES [Order](OrderID)
);
GO


-------------------------
----Inserting Values-----
-------------------------

---City----

INSERT INTO City (CityName, CityAddress, PostcodePrefix, Country)
VALUES
('Mumbai',     'Andheri East',   '400', 'India'),
('Delhi',      'Connaught Place','110', 'India'),
('Bengaluru',  'Koramangala',    '560', 'India'),
('Chennai',    'T Nagar',        '600', 'India'),
('Kolkata',    'Salt Lake',      '700', 'India');
GO

---Category----

INSERT INTO Category (CategoryName, CategoryDescription)
VALUES
('Vegetables',          'Fresh local vegetables'),
('Staples',             'Rice, atta, pulses & sugar'),
('Dairy',               'Milk, curd, paneer & ghee'),
('Snacks & Beverages',  'Namkeen, biscuits, soft drinks & tea');
GO

---Customer---

INSERT INTO Customer (FirstName, LastName, Email, PhoneNumber, CityID,
                      AddressLine1, AddressLine2, Postcode, DateOfBirth)
VALUES
('Ravi',   'Sharma', 'ravi.sharma@mail.in',   '9000000001', 1,
 '12 Palm Residency',   'Andheri East',    '400093', '1991-06-12'),

('Neha',   'Verma',  'neha.verma@mail.in',    '9000000002', 2,
 '44 Raj Niwas Marg',   'Civil Lines',     '110054', '1995-02-19'),

('Arjun',  'Nair',   'arjun.nair@mail.in',    '9000000003', 3,
 '21 Lake View Road',   'Koramangala',     '560047', '1988-11-30'),

('Priya',  'Iyer',   'priya.iyer@mail.in',    '9000000004', 4,
 '9 Sarojini Street',   'T Nagar',         '600017', '1993-03-08'),

('Sanjay', 'Patil',  'sanjay.patil@mail.in',  '9000000005', 1,
 '7 Sea Breeze Apts',   'Juhu',            '400049', '1985-09-22'),

('Aisha',  'Khan',   'aisha.khan@mail.in',    '9000000006', 5,
 '55 Lake Town Road',   'Salt Lake',       '700091', '1997-12-01'),

('Vikram', 'Singh',  'vikram.singh@mail.in',  '9000000007', 2,
 '102 Green Park',      'South Delhi',     '110016', '1990-01-15'),

('Meera',  'Joshi',  'meera.joshi@mail.in',   '9000000008', 3,
 '3 Tech Park Lane',    'Electronic City', '560100', '1994-07-05');
GO

---Product---

INSERT INTO Product (ProductName, ProductDescription, UnitPrice,
                     UnitOfMeasure, SKU, ImageUrl, CategoryID)
VALUES
('Potato',            'Fresh potatoes 1kg',          30.00,  'kg',   'VEG001', NULL, 1),
('Tomato',            'Fresh tomatoes 1kg',          35.00,  'kg',   'VEG002', NULL, 1),
('Onion',             'Red onions 1kg',              28.00,  'kg',   'VEG003', NULL, 1),
('Basmati Rice 5kg',  'Premium basmati rice',       420.00,  'each', 'STP001', NULL, 2),
('Wheat Atta 5kg',    'Whole wheat flour',          260.00,  'each', 'STP002', NULL, 2),
('Toor Dal 1kg',      'Split pigeon peas',          140.00,  'kg',   'STP003', NULL, 2),
('Paneer 200g',       'Fresh paneer block',          85.00,  'each', 'DAI001', NULL, 3),
('Toned Milk 1L',     'Toned milk tetra pack',       54.00,  'each', 'DAI002', NULL, 3),
('Masala Chai 250g',  'Spiced tea blend',            95.00,  'each', 'SNK001', NULL, 4),
('Masala Namkeen 200g','Spicy sev & mixture',        55.00,  'each', 'SNK002', NULL, 4);
GO



---Inventory---

INSERT INTO Inventory (ProductID, InventoryQuantity, WarehouseLocation,
                       SafetyStock, ReorderQuantity)
VALUES
(1, 220, 'Mumbai DC',      30,  80),   -- Potato
(2, 240, 'Delhi DC',       30,  80),   -- Tomato
(3, 260, 'Bengaluru DC',   30,  80),   -- Onion
(4, 180, 'Chennai DC',     20,  60),   -- Basmati Rice
(5, 160, 'Mumbai DC',      20,  60),   -- Wheat Atta
(6, 190, 'Delhi DC',       20,  60),   -- Toor Dal
(7, 140, 'Bengaluru DC',   15,  50),   -- Paneer
(8, 200, 'Chennai DC',     20,  70),   -- Toned Milk
(9, 170, 'Kolkata DC',     15,  50),   -- Masala Chai
(10,210, 'Mumbai DC',      20,  70);   -- Masala Namkeen
GO

---Order---

INSERT INTO [Order] (CustomerID, CityID, OrderDate, NumberOfItems,
                     OrderStatus, TotalAmount, OrderName)
VALUES
-- 15
(1, 1, '2025-03-01', 3, 'Completed', 480.00, 'Order #1 - Ravi'),
(2, 2, '2025-03-02', 4, 'Completed', 398.00, 'Order #2 - Neha'),
(3, 3, '2025-03-03', 5, 'Completed', 342.00, 'Order #3 - Arjun'),
(4, 4, '2025-03-04', 3, 'Completed', 700.00, 'Order #4 - Priya'),
(5, 1, '2025-03-05', 4, 'Completed', 148.00, 'Order #5 - Sanjay'),

-- 610
(6, 5, '2025-03-06', 3, 'Completed', 480.00, 'Order #6 - Aisha'),
(7, 2, '2025-03-07', 4, 'Completed', 398.00, 'Order #7 - Vikram'),
(8, 3, '2025-03-08', 5, 'Completed', 342.00, 'Order #8 - Meera'),
(1, 1, '2025-03-09', 3, 'Completed', 700.00, 'Order #9 - Ravi'),
(2, 2, '2025-03-10', 4, 'Completed', 148.00, 'Order #10 - Neha'),

-- 1115
(3, 3, '2025-03-11', 3, 'Completed', 480.00, 'Order #11 - Arjun'),
(4, 4, '2025-03-12', 4, 'Completed', 398.00, 'Order #12 - Priya'),
(5, 1, '2025-03-13', 5, 'Completed', 342.00, 'Order #13 - Sanjay'),
(6, 5, '2025-03-14', 3, 'Completed', 700.00, 'Order #14 - Aisha'),
(7, 2, '2025-03-15', 4, 'Completed', 148.00, 'Order #15 - Vikram'),

-- 1620
(8, 3, '2025-03-16', 3, 'Completed', 480.00, 'Order #16 - Meera'),
(1, 1, '2025-03-17', 4, 'Pending',   398.00, 'Order #17 - Ravi (Pending)'),
(2, 2, '2025-03-18', 5, 'Pending',   342.00, 'Order #18 - Neha (Pending)'),
(3, 3, '2025-03-19', 3, 'Pending',   700.00, 'Order #19 - Arjun (Pending)'),
(4, 4, '2025-03-20', 4, 'Pending',   148.00, 'Order #20 - Priya (Pending)');
GO

---OrderItem---

INSERT INTO OrderItem (OrderID, ProductID, Quantity, UnitPrice)
VALUES
-- T1 = 2×Potato + 1×Basmati Rice (Orders: 1,6,11,16)
(1, 1, 2, 30.00),   -- Potato
(1, 4, 1, 420.00),

(6, 1, 2, 30.00),
(6, 4, 1, 420.00),

(11, 1, 2, 30.00),
(11, 4, 1, 420.00),

(16, 1, 2, 30.00),
(16, 4, 1, 420.00),

-- T2 = 1×Onion + 1×Wheat Atta + 2×Namkeen (Orders: 2,7,12,17)
(2, 3, 1, 28.00),   -- Onion
(2, 5, 1, 260.00),  -- Wheat Atta
(2,10, 2, 55.00),   -- Namkeen

(7, 3, 1, 28.00),
(7, 5, 1, 260.00),
(7,10, 2, 55.00),

(12,3, 1, 28.00),
(12,5, 1, 260.00),
(12,10,2, 55.00),

(17,3, 1, 28.00),
(17,5, 1, 260.00),
(17,10,2, 55.00),

-- T3 = 3×Milk + 1×Paneer + 1×Masala Chai (Orders: 3,8,13,18)
(3, 8, 3, 54.00),   -- Milk
(3, 7, 1, 85.00),   -- Paneer
(3, 9, 1, 95.00),   -- Masala Chai

(8, 8, 3, 54.00),
(8, 7, 1, 85.00),
(8, 9, 1, 95.00),

(13,8, 3, 54.00),
(13,7, 1, 85.00),
(13,9, 1, 95.00),

(18,8, 3, 54.00),
(18,7, 1, 85.00),
(18,9, 1, 95.00),

-- T4 = 2×Toor Dal + 1×Basmati Rice (Orders: 4,9,14,19)
(4, 6, 2, 140.00),  -- Toor Dal
(4, 4, 1, 420.00),

(9, 6, 2, 140.00),
(9, 4, 1, 420.00),

(14,6, 2, 140.00),
(14,4, 1, 420.00),

(19,6, 2, 140.00),
(19,4, 1, 420.00),

-- T5 = 1×Potato + 1×Tomato + 1×Onion + 1×Namkeen (Orders: 5,10,15,20)
(5, 1, 1, 30.00),   -- Potato
(5, 2, 1, 35.00),   -- Tomato
(5, 3, 1, 28.00),   -- Onion
(5,10, 1, 55.00),   -- Namkeen

(10,1, 1, 30.00),
(10,2, 1, 35.00),
(10,3, 1, 28.00),
(10,10,1, 55.00),

(15,1, 1, 30.00),
(15,2, 1, 35.00),
(15,3, 1, 28.00),
(15,10,1, 55.00),

(20,1, 1, 30.00),
(20,2, 1, 35.00),
(20,3, 1, 28.00),
(20,10,1, 55.00);
GO

---Transaction---

INSERT INTO [Transaction] (OrderID, TransactionAmount,
                           PaymentMethod, PaymentStatus, PaymentReference)
VALUES
(1,  480.00, 'UPI',         'Paid',    'TXN-2025-001'),
(2,  398.00, 'Credit Card', 'Paid',    'TXN-2025-002'),
(3,  342.00, 'Debit Card',  'Paid',    'TXN-2025-003'),
(4,  700.00, 'NetBanking',  'Paid',    'TXN-2025-004'),
(5,  148.00, 'UPI',         'Paid',    'TXN-2025-005'),

(6,  480.00, 'UPI',         'Paid',    'TXN-2025-006'),
(7,  398.00, 'Credit Card', 'Paid',    'TXN-2025-007'),
(8,  342.00, 'Debit Card',  'Paid',    'TXN-2025-008'),
(9,  700.00, 'NetBanking',  'Paid',    'TXN-2025-009'),
(10, 148.00, 'UPI',         'Paid',    'TXN-2025-010'),

(11, 480.00, 'Credit Card', 'Paid',    'TXN-2025-011'),
(12, 398.00, 'Debit Card',  'Paid',    'TXN-2025-012'),
(13, 342.00, 'NetBanking',  'Paid',    'TXN-2025-013'),
(14, 700.00, 'UPI',         'Paid',    'TXN-2025-014'),
(15, 148.00, 'Credit Card', 'Paid',    'TXN-2025-015'),

(16, 480.00, 'Debit Card',  'Paid',    'TXN-2025-016'),
(17, 398.00, 'UPI',         'Pending', 'TXN-2025-017'),
(18, 342.00, 'Credit Card', 'Pending', 'TXN-2025-018'),
(19, 700.00, 'NetBanking',  'Pending', 'TXN-2025-019'),
(20, 148.00, 'COD',         'Pending', 'TXN-2025-020');
GO


---------------------------------------------
--Sales by Product Category------------------
---------------------------------------------

SELECT
    c.CategoryName,
    SUM(oi.Quantity)                        AS TotalQuantitySold,
    COUNT(DISTINCT o.OrderID)               AS NumberOfOrders,
    SUM(oi.Quantity * oi.UnitPrice)         AS TotalSales
FROM [Order] o
JOIN OrderItem oi ON o.OrderID = oi.OrderID
JOIN Product p    ON oi.ProductID = p.ProductID
JOIN Category c   ON p.CategoryID = c.CategoryID
WHERE 
    o.OrderDate BETWEEN '2025-03-01' AND '2025-03-31'
    AND o.OrderStatus = 'Completed'
GROUP BY
    c.CategoryName
ORDER BY
    TotalSales DESC;


---------------------------------------------
--Top 10 Popular Products--------------------
---------------------------------------------



    SELECT
    p.ProductName,
    SUM(oi.Quantity)                        AS TotalQuantitySold,
    COUNT(DISTINCT o.OrderID)               AS NumberOfOrders,
    SUM(oi.Quantity * oi.UnitPrice)         AS TotalSales
FROM [Order] o
JOIN OrderItem oi ON o.OrderID = oi.OrderID
JOIN Product p    ON oi.ProductID = p.ProductID
WHERE
    o.OrderDate BETWEEN '2025-03-01' AND '2025-03-31'
    AND o.OrderStatus = 'Completed'
GROUP BY
    p.ProductName
ORDER BY
    TotalQuantitySold DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


-------------------------------------------
--Customer Order History-------------------
-------------------------------------------


SELECT
    cu.FirstName + ' ' + cu.LastName AS CustomerName,
    o.OrderID,
    o.OrderDate,
    SUM(oi.Quantity)                        AS TotalItems,
    SUM(oi.Quantity * oi.UnitPrice)         AS OrderValue,
    o.OrderStatus
FROM [Order] o
JOIN OrderItem oi ON o.OrderID = oi.OrderID
JOIN Customer cu ON o.CustomerID = cu.CustomerID
WHERE
    o.OrderDate BETWEEN '2025-03-01' AND '2025-03-31'
GROUP BY
    cu.FirstName, cu.LastName, o.OrderID, o.OrderDate, o.OrderStatus
ORDER BY
    cu.LastName, cu.FirstName, o.OrderDate;


------------------------------------------
--Current Inventory Levels----------------
------------------------------------------


    SELECT 
    p.ProductName,
    c.CategoryName,
    i.InventoryQuantity AS CurrentStock,
    i.SafetyStock,
    i.ReorderQuantity,
    CASE 
        WHEN i.InventoryQuantity <= i.SafetyStock THEN 'Reorder Needed'
        ELSE 'Sufficient'
    END AS StockStatus
FROM Inventory i
JOIN Product p   ON i.ProductID = p.ProductID
JOIN Category c  ON p.CategoryID = c.CategoryID
ORDER BY 
    c.CategoryName,
    p.ProductName;


-----------------------------------------
--Revenue by City------------------------
-----------------------------------------


    SELECT
    ci.CityName,
    COUNT(DISTINCT o.OrderID)               AS NumberOfOrders,
    SUM(oi.Quantity * oi.UnitPrice)         AS TotalRevenue
FROM [Order] o
JOIN City ci      ON o.CityID = ci.CityID
JOIN OrderItem oi ON o.OrderID = oi.OrderID
WHERE
    o.OrderDate BETWEEN '2025-01-01' AND '2025-12-31'
    AND o.OrderStatus = 'Completed'
GROUP BY
    ci.CityName
ORDER BY
    TotalRevenue DESC;
