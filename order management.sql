CREATE DATABASE IF NOT EXISTS OrderManagementDB;
USE OrderManagementDB;

CREATE TABLE IF NOT EXISTS Customers (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Products (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0)
);

CREATE TABLE IF NOT EXISTS Orders (
    Order_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Total_Amount DECIMAL(10,2) DEFAULT 0
        CHECK (Total_Amount >= 0),
    Order_Status VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (Order_Status IN
        ('Pending','Shipped','Delivered','Cancelled')),
    FOREIGN KEY (Customer_ID)
        REFERENCES Customers(Customer_ID)
);


CREATE TABLE IF NOT EXISTS Order_Details (
    Order_Detail_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    UNIQUE (Order_ID, Product_ID),
    FOREIGN KEY (Order_ID)
        REFERENCES Orders(Order_ID) ON DELETE CASCADE,
    FOREIGN KEY (Product_ID)
        REFERENCES Products(Product_ID)
);


INSERT IGNORE INTO Customers VALUES
(1, 'Aparna', 'aparna@gmail.com'),
(2, 'Priya', 'priya@gmail.com'),
(3, 'Kavin', 'kavin@gmail.com');


INSERT IGNORE INTO Products VALUES
(1, 'Laptop', 50000),
(2, 'Mouse', 500),
(3, 'Keyboard', 1000);


INSERT INTO Orders
(Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES
(1, '2026-10-20', 0, 'Pending'),
(2, '2026-10-21', 0, 'Shipped'),
(1, '2026-10-22', 0, 'Delivered');


INSERT INTO Order_Details
(Order_ID, Product_ID, Quantity, Price)
VALUES
(1, 1, 1, 50000),
(1, 2, 2, 500),
(2, 2, 3, 500),
(2, 3, 1, 1000),
(3, 1, 1, 50000);

UPDATE Orders o
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details d
    WHERE d.Order_ID = o.Order_ID
)
WHERE o.Order_ID > 0;


UPDATE Orders
SET Order_Status = 'Shipped'
WHERE Order_ID = 1;


UPDATE Order_Details
SET Quantity = 3
WHERE Order_ID = 1 AND Product_ID = 2;

SET SQL_SAFE_UPDATES = 0;

UPDATE Orders o
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details d
    WHERE d.Order_ID = o.Order_ID
)
WHERE o.Order_ID > 0;


SELECT o.Order_ID, c.Customer_Name,
       o.Order_Date, p.Product_Name,
       d.Quantity, d.Price,
       d.Quantity * d.Price AS Item_Total,
       o.Total_Amount, o.Order_Status
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
JOIN Order_Details d ON o.Order_ID = d.Order_ID
JOIN Products p ON d.Product_ID = p.Product_ID;

SELECT c.Customer_Name, o.Order_ID,
       o.Order_Date, o.Total_Amount, o.Order_Status
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID;

SELECT p.Product_Name,
       COUNT(DISTINCT d.Order_ID) AS Times_Ordered,
       SUM(d.Quantity) AS Total_Quantity_Sold
FROM Products p
LEFT JOIN Order_Details d ON p.Product_ID = d.Product_ID
GROUP BY p.Product_ID, p.Product_Name;

SELECT c.Customer_Name, COUNT(o.Order_ID) AS Total_Orders
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
HAVING COUNT(o.Order_ID) = (
    SELECT MAX(Order_Count)
    FROM (
        SELECT COUNT(*) AS Order_Count
        FROM Orders
        GROUP BY Customer_ID
    ) AS T
);


SELECT c.Customer_Name,
       SUM(o.Total_Amount) AS Total_Spending
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status <> 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name;


SELECT AVG(Total_Amount) AS Average_Order_Value
FROM Orders
WHERE Order_Status <> 'Cancelled';

SELECT SUM(Total_Amount) AS Total_Sales
FROM Orders
WHERE Order_Status <> 'Cancelled';

DELETE FROM Orders
WHERE Order_Status = 'Cancelled';

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM Order_Details;
