CREATE DATABASE shop_ease;

USE shop_ease;

CREATE TABLE sales(
    customer_id INT NOT NULL,
    customer_name VARCHAR(255),
    email VARCHAR(255),
    join_date DATE,
    order_id INT NOT NULL PRIMARY KEY,
    order_date DATE,
    product_id INT,
    quantity INT,
    product_name VARCHAR(255),
    category VARCHAR(255),
    price DECIMAL(10, 2),
    year INT,
    month INT,
    day INT,
    total_revenue DECIMAL(10, 2)
);

SELECT * FROM shop_ease.sales;

CREATE TABLE CUSTOMER(
	customer_id int,
    customer_name varchar(255),
    email varchar(255),
    join_date date);
    
CREATE TABLE INVENTORY(
	product_name varchar(255),
    stock_quantity int,
    stock_date date,
    supplier varchar(50),
    warehouse_location varchar(50)
    );
    
CREATE TABLE ORDER_ITEMS(
order_detail_id int,
  order_id int,
  quantity int,
  product_id int);
  
CREATE TABLE ORDERS(
	 order_id int,
     customer_id int,
     order_date date,
     product_id int,
     quantity int
);

CREATE TABLE PRODUCTS(
	product_id int, 
    product_name varchar(255),
    category varchar(50),
    price int);
    
CREATE TABLE SUPPLIERS(
	id INT,
    supplier_name VARCHAR(255),
    supplier_address VARCHAR(255),
    email VARCHAR(255),
    contact_number VARCHAR(15),
    fax VARCHAR(15),
    account_number VARCHAR(15),
    order_history INT,
    contract VARCHAR(3),
    supplier_country VARCHAR(100),
    supplier_city VARCHAR(100),
    country_code VARCHAR(5)
	);


SELECT * FROM shop_ease.customer;
SELECT * FROM shop_ease.inventory;
SELECT * FROM shop_ease.orders;
SELECT * FROM shop_ease.products;
SELECT * FROM shop_ease.suppliers;
SELECT * FROM shop_ease.order_items;

-- Lab Exercise 2.1
SELECT * 
FROM CUSTOMER
JOIN ORDERS ON CUSTOMER.customer_id = ORDERS.customer_id
JOIN ORDER_ITEMS ON ORDERS.order_id = ORDER_ITEMS.order_id
JOIN PRODUCTS ON ORDER_ITEMS.product_id = PRODUCTS.product_id;

-- Lab 2 exercise 2.2 
SELECT p.product_name, 
       SUM(s.quantity * s.price) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE s.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)  -- Filter for last month
GROUP BY p.product_name
ORDER BY total_sales DESC  
LIMIT 5;  

-- Lab 2 exercise 2.3
SELECT order_id,
       total_revenue,
       CASE
           WHEN total_revenue >= 1000 THEN 'High'   -- High revenue if total revenue is 1000 or more
           WHEN total_revenue >= 500  THEN 'Medium' -- Medium revenue if total revenue is between 500 and 999
           ELSE 'Low'                            -- Low revenue if total revenue is less than 500
       END AS revenue_category
FROM sales;

-- Lab 2 exercise 2.4
EXPLAIN SELECT * 
FROM CUSTOMER
JOIN ORDERS ON CUSTOMER.customer_id = ORDERS.customer_id
JOIN ORDER_ITEMS ON ORDERS.order_id = ORDER_ITEMS.order_id
JOIN PRODUCTS ON ORDER_ITEMS.product_id = PRODUCTS.product_id;

EXPLAIN SELECT p.product_name, 
               SUM(s.quantity * s.price) AS total_sales
        FROM sales s
        JOIN products p ON s.product_id = p.product_id
        WHERE s.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
        GROUP BY p.product_name
        ORDER BY total_sales DESC  
        LIMIT 5;

-- Lab 3 exercise 3.1
SELECT 
    p.product_name, 
    SUM(s.quantity * s.price) AS total_sales,
    ROW_NUMBER() OVER (ORDER BY SUM(s.quantity * s.price) DESC) AS product_rank
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE s.order_date >= CURDATE() - INTERVAL 1 MONTH
GROUP BY p.product_name
ORDER BY product_rank;

SELECT 
    p.product_name, 
    SUM(s.quantity * s.price) AS total_sales,
    RANK() OVER (ORDER BY SUM(s.quantity * s.price) DESC) AS product_rank
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE s.order_date >= CURDATE() - INTERVAL 1 MONTH
GROUP BY p.product_name
ORDER BY product_rank;

SELECT 
    p.product_name, 
    SUM(s.quantity * s.price) AS total_sales,
    DENSE_RANK() OVER (ORDER BY SUM(s.quantity * s.price) DESC) AS product_rank
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE s.order_date >= CURDATE() - INTERVAL 1 MONTH
GROUP BY p.product_name
ORDER BY product_rank;


-- Lab 3 exercise 3.2
SELECT 
    p.category,          
    p.product_name,
    s.order_date,
    SUM(s.quantity * s.price) OVER (PARTITION BY p.category ORDER BY s.order_date) AS running_total
FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY p.category, s.order_date;

-- Lab 3 exercise 3.3
SELECT 
    o.customer_id,
    c.customer_name,
    o.order_id,
    SUM(oi.quantity * p.price) AS total_order_value,   -- Calculate total order value for each order
    AVG(SUM(oi.quantity * p.price)) OVER (PARTITION BY o.customer_id) AS avg_order_value
FROM orders o
JOIN customer c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id  -- Join with order_items to get item details
JOIN products p ON oi.product_id = p.product_id  -- Join with products to get price of each product
GROUP BY o.customer_id, o.order_id, c.customer_name, o.order_date  -- Include order_date in GROUP BY
ORDER BY o.customer_id, o.order_date; 

-- lab 3 exercise 3.4
SELECT 
    year,
    month,
    SUM(total_revenue) AS monthly_sales,   -- Calculate total sales (revenue) for the month
    LAG(SUM(total_revenue), 1) OVER (ORDER BY year, month) AS previous_month_sales,  -- Previous month's sales
    LEAD(SUM(total_revenue), 1) OVER (ORDER BY year, month) AS next_month_sales      -- Next month's sales
FROM sales
GROUP BY year, month  -- Group by year and month to calculate monthly totals
ORDER BY year, month;  -- Order results by year and month

-- lab 3 exercise 3.5
SELECT 
    year,
    month,
    SUM(total_revenue) AS monthly_sales,   
    COALESCE(LAG(SUM(total_revenue), 1) OVER (ORDER BY year, month), 0) AS previous_month_sales,  -- Replace NULL with 0
    COALESCE(LEAD(SUM(total_revenue), 1) OVER (ORDER BY year, month), 0) AS next_month_sales      -- Replace NULL with 0
FROM sales
GROUP BY year, month
ORDER BY year, month;

-- lab 4 exercise 4.1
EXPLAIN 
SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * p.price) AS total_spending  -- Calculate the total revenue for each customer
FROM orders o
JOIN customer c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id  -- Join with order_items to get product details
JOIN products p ON oi.product_id = p.product_id  -- Join with products to get product price
WHERE o.order_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY c.customer_id, c.customer_name;  -- Include customer_name in GROUP BY

-- Lab 4 exercise 4.2
 -- Index on `customer_id` in the `orders` table (for JOIN operations)
CREATE INDEX idx_customer_id ON orders(customer_id);

-- Index on `order_date` in the `orders` table (for filtering by date range)
CREATE INDEX idx_order_date ON orders(order_date);
-- Composite index on `customer_id` and `order_date` in the `orders` table
CREATE INDEX idx_customer_order_date ON orders(customer_id, order_date);

-- Index on `product_name` in the `products` table (for fast searches and sorting)
CREATE INDEX idx_product_name ON products(product_name);
-- Index on `category` in the `products` table (for filtering products by category)
CREATE INDEX idx_category ON products(category);
-- Composite index on `category` and `price` in the `products` table
CREATE INDEX idx_category_price ON products(category, price);
-- Index on `customer_id` for optimizing GROUP BY queries
CREATE INDEX idx_customer_id_group ON orders(customer_id);

-- Index on `order_date` for optimizing ORDER BY operations
CREATE INDEX idx_order_date_group ON orders(order_date);

-- Lab 4 exercise 4.3


-- Lab 5 
DELIMITER $$

CREATE TRIGGER update_inventory
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;

    -- Get the current stock for the ordered product
    SELECT stock_quantity
    INTO current_stock
    FROM Inventories
    WHERE product_id = NEW.product_id;

    -- Check if there is sufficient stock
    IF current_stock >= NEW.quantity THEN
        -- Decrease the stock by the ordered quantity
        UPDATE Inventories
        SET stock_quantity = stock_quantity - NEW.quantity
        WHERE product_id = NEW.product_id;
    ELSE
        -- Raise an exception or log a message if there is insufficient stock
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT('Insufficient stock for product ID: ', NEW.product_id);
    END IF;
END $$

DELIMITER ;


