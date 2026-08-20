-- First Creating the required table
CREATE TABLE customers(
	customers_id SERIAL PRIMARY KEY ,
	name VARCHAR(30) NOT NULL ,
	email VARCHAR(30) UNIQUE NOT NULL ,
	phone_no VARCHAR(20) UNIQUE,
	join_date DATE
);

CREATE TABLE categories(
	categories_id SERIAL PRIMARY KEY , 
	category_name VARCHAR(30)
);

CREATE TABLE products(
	products_id SERIAL PRIMARY KEY ,
	product_name VARCHAR(30) NOT NULL,
	price DECIMAL(15,2) CHECK(price > 0) NOT NULL,
	stock_quantity INTEGER CHECK(stock_quantity > 0) NOT NULL ,
	categories_id INTEGER REFERENCES categories(categories_id) ON DELETE RESTRICT
);

CREATE TABLE orders(
	orders_id SERIAL PRIMARY KEY,
	order_date DATE ,
	status VARCHAR(20) CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')) NOT NULL,
	customers_id INTEGER REFERENCES customers(customers_id) ON DELETE RESTRICT
);

CREATE TABLE order_items(
	orderitem_id SERIAL PRIMARY KEY , 
	orders_id INTEGER REFERENCES orders(orders_id) ON DELETE CASCADE,
	products_id INTEGER REFERENCES products(products_id) ON DELETE RESTRICT,
	quantity INTEGER CHECK(quantity > 0) NOT NULL ,
	price_at_purchase DECIMAL(15,2) CHECK(price_at_purchase > 0)  NOT NULL 
);

CREATE TABLE reviews(
	review_id SERIAL PRIMARY KEY ,
	rating INTEGER CHECK(rating IN (1,2,3,4,5,6,7,8,9,10)) NOT NULL ,
	comment VARCHAR(200) ,
	review_date DATE ,
	customers_id INTEGER REFERENCES customers(customers_id) ON DELETE RESTRICT,
	products_id INTEGER REFERENCES products(products_id) ON DELETE CASCADE
);

-- Now Inserting data into the tables
INSERT INTO customers(name , email , phone_no , join_date)
VALUES
('Ankit','ankit123@gmail.com','9801234567','2026-08-15'),
('Shyam','shyam321@gmail.com','9801234367','2026-08-16'),
('Hari','hari333@gmail.com','9801234566','2026-08-17'),
('Krishna','krishnaq11@gmail.com','9805234567','2026-08-18'),
('Spike','Spike00@gmail.com','9801234547','2026-08-19');

INSERT INTO categories(category_name)
VALUES
('Electronics'),
('Clothing'),
('Books'),
('Home & Kitchen'),
('Sports & Fitness');

INSERT INTO products(product_name , price , stock_quantity,categories_id)
VALUES
('Atomic Habits',700,50,3),
('Acer Nitro V15',120000,10,1),
('Shirts',400,20,2),
('Electronic Pan',1000,15,4),
('Football',400,25,5),
('Cricket Bat',500,20,5);

INSERT INTO orders(order_date , status ,customers_id)
VALUES
('2026-08-15','pending',1),
('2026-08-15','processing',1),
('2026-08-16','shipped',1),
('2026-08-18','delivered',2),
('2026-08-16','cancelled',2),
('2026-08-21','pending',3),
('2026-08-20','shipped',5),
('2026-08-19','delivered',4);

INSERT INTO order_items(orders_id,products_id,quantity,price_at_purchase)
VALUES
(1,1,5,600),
(2,2,1,121000),
(3,3,3,400),
(4,4,2,900),
(5,5,1,450),
(5,6,2,500),
(6,6,2,500),
(7,6,2,500),
(8,6,2,500);

INSERT INTO reviews(rating,comment,review_date,customers_id,products_id)
VALUES
(7,'The book was good , not the quality.','2026-08-22',1,1),
(8,'The pan works well, good build quality.','2026-08-25',2,4),
(7,'The shirt was basic','2026-08-25',3,3),
(8,'The pan was actually good!!','2026-08-26',2,4);

-- List Orders overview
SELECT order_date , status , name , email FROM customers
INNER JOIN orders
ON customers.customers_id = orders.customers_id;

-- List Order items detail 
SELECT product_name , category_name , quantity , price_at_purchase FROM order_items
INNER JOIN products
ON order_items.products_id = products.products_id
INNER JOIN categories
ON products.categories_id = categories.categories_id;

-- List Reviews detail
SELECT name , product_name , rating , comment FROM reviews
INNER JOIN products
ON reviews.products_id = products.products_id
INNER JOIN customers
ON reviews.customers_id = customers.customers_id;

-- List Aggregation: Revenue per category
SELECT  category_name ,SUM(quantity * price_at_purchase) AS revenue FROM order_items
INNER JOIN products
ON order_items.products_id = products.products_id
INNER JOIN categories
ON products.categories_id = categories.categories_id
GROUP BY category_name
ORDER BY revenue DESC;

-- List Aggregation: Orders per customer
SELECT name , COUNT(orders_id) AS no_of_orders FROM customers 
LEFT JOIN orders AS O
ON customers.customers_id = O.customers_id
GROUP BY name;

-- List Subquery: Never-ordered products
SELECT product_name FROM products
WHERE products_id NOT IN (SELECT products_id FROM order_items);

-- List Subquery: Customers with no reviews
SELECT name FROM customers
WHERE customers_id NOT IN (SELECT customers_id FROM reviews);

-- CTE: Above-average spenders
WITH calculated_table AS(
	SELECT name , SUM(quantity * price_at_purchase) AS total_spent FROM customers
	INNER JOIN orders
	ON customers.customers_id = orders.customers_id
	INNER JOIN order_items
	ON orders.orders_id = order_items.orders_id
	GROUP BY name)

SELECT * FROM calculated_table
WHERE total_spent > (
SELECT AVG(total_spent) FROM calculated_table
);

-- CTE: Above-average revenue products
WITH c_table AS(
	SELECT product_name ,SUM(quantity * price_at_purchase) AS t_spent  FROM products
	INNER JOIN order_items
	ON products.products_id = order_items.products_id
	GROUP BY product_name)

SELECT * FROM c_table
WHERE t_spent > (
SELECT AVG(t_spent) FROM c_table
);

-- Window function: Rank customers by spend
WITH cl_table AS(
	SELECT name , SUM(quantity * price_at_purchase) AS m_spent FROM customers
	INNER JOIN orders
	ON customers.customers_id = orders.customers_id
	INNER JOIN order_items
	ON orders.orders_id = order_items.orders_id
	GROUP BY name)

SELECT name , m_spent , 
RANK() OVER(ORDER BY m_spent DESC) AS M_Rank
FROM cl_table;

-- Window function: Top-rated product per category
WITH calc AS (
	SELECT category_name , product_name , AVG(rating) AS avg_rating FROM products
	INNER JOIN reviews
	ON products.products_id = reviews.products_id
	INNER JOIN categories
	ON products.categories_id = categories.categories_id
	GROUP BY product_name , category_name)

SELECT category_name , product_name , avg_rating , 
RANK() OVER(PARTITION BY category_name ORDER BY avg_rating DESC) AS category_rank
FROM calc;

-- Conditional aggregation: Rating breakdown per product
SELECT product_name ,
COUNT(CASE WHEN rating >= 8 THEN 1 END) AS highest_rated,
COUNT(CASE WHEN rating <= 5 THEN 1 END) AS lowest_rated
FROM products
INNER JOIN reviews
ON products.products_id = reviews.products_id
GROUP BY product_name;




