CREATE DATABASE IF NOT EXISTS dbms51;
USE dbms51;
CREATE TABLE IF NOT EXISTS CUSTOMER (
    CUSTOMER_ID INT NOT NULL AUTO_INCREMENT,
    CUSTOMER_NAME VARCHAR(25) NOT NULL,
    CUSTOMER_PASSWORD VARCHAR(25) NOT NULL,
    CUSTOMER_EMAIL VARCHAR(25) NOT NULL,
    PRIMARY KEY(CUSTOMER_ID)
);
CREATE TABLE IF NOT EXISTS admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL, 
    password VARCHAR(50) NOT NULL
);
select* from admin;
CREATE TABLE login_attempts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    success INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PRODUCT_CATEGORY (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    image_data LONGBLOB
);
CREATE TABLE IF NOT EXISTS CUSTOMER_CARE (
    id INT AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    subject TEXT NOT NULL
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    image_data LONGBLOB,
    category_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES PRODUCT_CATEGORY(id)
);

CREATE TABLE IF NOT EXISTS CART(
    CART_ID INT NOT NULL,
    QUANTITY INT NOT NULL,
    PRODUCT_ID INT NOT NULL,
    PRIMARY KEY (CART_ID, PRODUCT_ID),
    FOREIGN KEY(CART_ID) REFERENCES CUSTOMER(CUSTOMER_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PRODUCT_ID) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO PRODUCT_CATEGORY (name, image_data) VALUES
('Paan_Corner', 'paan-corner_web.avif'),
('VEGETABLES', 'Slice-3_9.avif'),
('Breads', 'Slice-2_10.avif'),
('ColDrinks', 'Slice-4_9.avif');

INSERT INTO products (PRODUCT_NAME, PRICE, IMAGE_DATA, CATEGORY_ID) VALUES
('BROWN_BREAD', 35.0, 'BROWN_BREAD.jpg', 3),
('CHEESE', 75.0, 'CHEESE.jpg', 3),
('DAHI', 25.0, 'DAHI.avif', 3),
('EGGS', 180.0, 'EGGS.jpg', 3),
('PANEER', 250.0, 'PANEER.jpg', 3),
('MILKMAID', 55.0, 'MILKMAID.jpg', 3);

ALTER TABLE CUSTOMER ADD COLUMN CUSTOMER_STATUS VARCHAR(255);



DELIMITER //

CREATE TRIGGER  login_failed_trigger
AFTER INSERT ON login_attempts
FOR EACH ROW
BEGIN
    DECLARE attempts INT;
    DECLARE is_blocked INT;
    
    -- Count the number of failed attempts for this user
    SELECT COUNT(*) INTO attempts FROM login_attempts WHERE user_id = NEW.user_id AND success = 0;
    
    -- Check if the number of attempts exceeds the threshold
    IF attempts >= 3 THEN
        -- Set the user's status to blocked
        UPDATE CUSTOMER SET CUSTOMER_STATUS = 'Blocked' WHERE CUSTOMER_ID = NEW.user_id;
    END IF;
END;
//
DELIMITER ;
-- Insert successful login attempts
INSERT INTO login_attempts (user_id, success) VALUES
(1, 1),  -- Successful login for user_id = 1
(2, 1),  -- Successful login for user_id = 2

-- Insert unsuccessful login attempts
(3, 0),  -- Unsuccessful login for user_id = 3
(4, 0),  -- Unsuccessful login for user_id = 4
(5, 0);  -- Unsuccessful login for user_id = 5 

-- Check the CUSTOMER_STATUS for user_id = 3 after 3 unsuccessful login attempts
-- SELECT CUSTOMER_ID, CUSTOMER_STATUS FROM CUSTOMER WHERE CUSTOMER_ID = 3;

-- Check the CUSTOMER_STATUS for user_id = 1 after successful login
-- SELECT CUSTOMER_ID, CUSTOMER_STATUS FROM CUSTOMER WHERE CUSTOMER_ID = 1;


-- select * from customer;
-- ALTER TABLE products ADD COLUMN category_id INT NOT NULL;

INSERT INTO PRODUCT_CATEGORY (name, image_data) VALUES
('Grocery', 'grocery_image.jpg'),
('Electronics', 'electronics_image.jpg'),
('Clothing', 'clothing_image.jpg');


INSERT INTO products (product_name, price, image_data, category_id) VALUES
('Samsung', 100010.0 ,'laptop2.webp',6),
('Acer', 101000.0 ,'laptop3.webp',6),
('HP', 110000.0 ,'laptop4.webp',6),
('Pavilion', 101000.0 ,'laptop5.webp',6),
('CHAD PREMIUM', 101000.0 ,'laptop6.webp',6),
('Possible', 101000.0 ,'laptop7.webp',6),
('Apple', 101000.0 ,'laptop8.webp',6),
('Manga', 101000.0 ,'laptop9.webp',6),
('Alien', 101000.0 ,'laptop10.webp',6);

INSERT INTO products (product_name, price, image_data, category_id) VALUES
('Giga1', 100010.0, 'clothes1.webp', 7),
('Giga2', 101000.0, 'clothes2.webp', 7),
('Giga3', 110000.0, 'clothes3.webp', 7),
('Giga4', 101000.0, 'clothes4.webp', 7),
('Giga5', 101000.0, 'clothes5.webp', 7),
('Giga6', 101000.0, 'clothes6.webp', 7),
('Giga7', 101000.0, 'clothes7.webp', 7),
('Giga8', 101000.0, 'clothes8.webp', 7),
('Giga9', 101000.0, 'clothes9.webp', 7),
('Giga10', 101000.0, 'clothes10.webp', 7);

INSERT INTO PRODUCT_CATEGORY (name, image_data) VALUES
('TV', 'TV_image.jpg');

INSERT INTO products (product_name, price, image_data, category_id) VALUES
('TV1', 100999.0, 'TV1.webp', 8),
('TV2', 101999.0, 'TV2.webp', 8),
('TV3', 110999.0, 'TV3.webp', 8),
('TV4', 101999.0, 'TV4.webp', 8),
('TV5', 101999.0, 'TV5.webp', 8),
('TV6', 101999.0, 'TV6.webp', 8),
('TV7', 101999.0, 'TV7.webp', 8),
('TV8', 101999.0, 'TV8.webp', 8),
('TV9', 101999.0, 'TV9.webp', 8),
('TV10', 101999.0, 'TV10.webp', 8);

INSERT INTO PRODUCT_CATEGORY (name, image_data) VALUES
('Watches', 'Watch_image.jpg');

INSERT INTO products (product_name, price, image_data, category_id) VALUES
('Rolex', 100999.0, 'Watch1.webp', 9),
('Omega', 101999.0, 'Watch2.jpg', 9),
('Tag Heuer', 110999.0, 'Watch3.jpg', 9),
('Seiko', 101999.0, 'Watch4.jpg', 9),
('Citizen', 101999.0, 'Watch5.jpg', 9),
('Casio', 101999.0, 'Watch6.jpg', 9),
('Timex', 101999.0, 'Watch7.jpg', 9),
('Bulova', 101999.0, 'Watch8.jpg', 9),
('Fossil', 101999.0, 'Watch9.jpg', 9),
('Tissot', 101999.0, 'Watch10.jpg', 9);




ALTER TABLE admin MODIFY COLUMN password VARCHAR(255);
SELECT * from products;
DELETE FROM products WHERE image_data IS NULL;

-- show triggers;
-- select * from customer_care;


CREATE TABLE IF NOT EXISTS customer_reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    rating INT,
    comment TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(CUSTOMER_ID)
);

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(CUSTOMER_ID)
);

CREATE TABLE IF NOT EXISTS Order_Details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE IF NOT EXISTS Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    transaction_status VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);


DELIMITER //
CREATE TRIGGER UPDATETOTALPROCETIRIGGER
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(price * quantity) INTO total FROM Order_Details WHERE order_id = NEW.order_id;
    SET NEW.total_price = total;
END;
//
DELIMITER ;

DELIMITER //

CREATE TRIGGER customer_status_update_trigger
AFTER UPDATE ON CUSTOMER
FOR EACH ROW
BEGIN
    DECLARE new_status VARCHAR(255);
    SET new_status = NEW.CUSTOMER_STATUS;
    
    -- Check if the customer status is updated to 'Blocked'
    IF new_status = 'Blocked' THEN
        -- Log the block event
        INSERT INTO customer_care (firstname, lastname, email, subject) 
        VALUES ('Admin', 'System', 'admin@gmail.com', CONCAT('Customer ', NEW.CUSTOMER_NAME, ' has been blocked.'));
    END IF;
END;
//
DELIMITER ;


DELIMITER $$
CREATE TRIGGER update_order_status
AFTER INSERT ON Payment
FOR EACH ROW
BEGIN
    IF NEW.transaction_status = 'Successful' THEN
        UPDATE Orders
        SET order_status = 'Confirmed'
        WHERE order_id = NEW.order_id;
    END IF;
END$$
DELIMITER ;
DROP TABLE ORDER_DETAILS;
CREATE TABLE IF NOT EXISTS Order_Details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Scenario 1: Conflicting Transaction

START TRANSACTION;

-- Retrieve the product details
SELECT id, product_name, price
FROM products
WHERE id = 1 -- Let's assume product_id = 1 (e.g., 'BROWN_BREAD')
FOR SHARE; -- Acquire a shared lock

-- Insert a new order
INSERT INTO Orders (customer_id, total_price, order_status)
VALUES (1, 35.0, 'Pending'); -- Assuming customer_id = 1 and price = 35.0 for 'BROWN_BREAD'
SET @order_id = LAST_INSERT_ID();

INSERT INTO Order_Details (order_id, product_id, price)
VALUES (@order_id, 1, 35.0); -- Assuming quantity is not stored explicitly

-- Simulate some delay, e.g., waiting for payment confirmation
DO SLEEP(10);

-- Rollback scenario
-- Let's assume the payment failed or the customer canceled the order
ROLLBACK;

START TRANSACTION;

-- Update the product price
SELECT price FROM products WHERE id = 1 FOR SHARE;
-- Acquire a shared lock on the row (this will be blocked until Transaction 1 commits or rolls back)

UPDATE products SET price = 40.0 WHERE id = 1;

COMMIT;

-- Scenario 2 : 
START TRANSACTION;

-- Retrieve the product details
SELECT id, product_name
FROM products
WHERE id = 1 -- Let's assume product_id = 1 (e.g., 'BROWN_BREAD')
FOR SHARE; -- Acquire a shared lock

-- Insert a new review
INSERT INTO customer_reviews (customer_id, rating, comment)
VALUES (1, 5, 'Great product!'); -- Assuming customer_id = 1

-- Simulate some delay, e.g., processing the review
DO SLEEP(10);

COMMIT;
START TRANSACTION;

-- Update the product name
SELECT product_name FROM products WHERE id = 1 FOR SHARE;
-- Acquire a shared lock on the row (this will be blocked until Transaction 1 commits)

UPDATE products SET product_name = 'Whole Grain Bread' WHERE id = 1;

COMMIT;