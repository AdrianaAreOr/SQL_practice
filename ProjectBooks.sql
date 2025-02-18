
CREATE DATABASE bookstore; # Schema
USE bookstore; #

#Create empty tables
CREATE TABLE Books (
	book_id INT AUTO_INCREMENT PRIMARY KEY, 
    title VARCHAR(100),
    author_id INT,
    publish_date date,
    price DECIMAL(10, 2),
    genre VARCHAR(100)
);

CREATE TABLE Authors (
	author_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    bith_date DATE,
    nationality VARCHAR(100)
);

CREATE TABLE Sales (
	sale_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT,
    sale_date DATE,
    quantity INT,
    total_amount DECIMAL(10, 2)
);

# Insert data
-- books

INSERT INTO books (title, author_id, publish_date, price, genre) VALUES
('El Quijote', 1, '1605-01-16', 39.99, 'Novel'),
('Cien Años de Soledad', 2, '1967-05-05', NULL, 'Novel'),
('Don Quijote', 1, '1605-01-16', 40.00, 'Novela'), -- Duplicate
(NULL, 3, '1997-06-26', 25.00, 'Fantasy'),
('The Hobbit', 4, '1937-09-21', 15.99, 'Fantasy'),
('1984', 5, '1949-06-08', -19.84, 'Dystopian'), -- Negative price
('The Catcher in the Rye', 6, '1951-07-16', 10.00, 'Novel'),
('To Kill a Mockingbird', 7, '1960-07-11', 7.99, 'Novel')
;

-- Authors
INSERT INTO Authors (nombre, bith_date, nationality) VALUES
('Miguel de Cervantes', '1547-09-29', 'Spanish'),
('Gabriel Garcia Marquez', '1927-03-06', 'Colombian'),
('J.K. Rowling', '1965-07-31', 'British'),
('J.R.R. Tolkien', '1892-01-03', 'British'),
('George Orwell', '1903-06-25', 'British'),
('J.D. Salinger', '1919-01-01', 'American'),
('Harper Lee', '1926-04-28', 'American');

--  Sales
INSERT INTO Sales (book_id, sale_date, quantity, total_amount) VALUES
(1, '2022-01-01', 3, 119.97),
(2, '2022-02-15', 1, 39.99),
(2, '2022-02-15', 1, 0.00), -- Inconsistent total_amount
(4, '2022-03-10', 2, 50.00),
(5, '2022-03-15', 1, 15.99),
(6, '2022-04-01', -5, 50.00), -- Negative quantity
(7, '2022-05-01', 4, 31.96),
(1, '2022-06-01', 1, 39.99);



SELECT * FROM authors;
SELECT * FROM books;
SELECT * FROM sales;

#Duplicate table 

CREATE TABLE autores
LIKE authors;

CREATE TABLE libros
LIKE books;

CREATE TABLE ventas
LIKE SALES;

-- Insert data
INSERT INTO autores
SELECT * FROM authors;

INSERT INTO libros
SELECT * FROM books;

INSERT INTO ventas
SELECT * FROM sales;


SELECT * FROM autores;
SELECT * FROM libros;
SELECT * FROM ventas;

### Data cleaning
-- Duplicates

SELECT *, ROW_NUMBER() OVER(PARTITION BY 
author_id) AS repeticiones
FROM libros; # Theres duplicate data

-- Delete duplicates from "libros"
WITH duplicados AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY 
author_id) AS repeticiones
FROM libros
)
DELETE FROM libros
WHERE book_id IN (
	SELECT book_id
    FROM duplicados
    WHERE repeticiones = 2
);

SELECT * FROM libros; 

## Search for nulls
 SELECT * FROM libros 
 where book_id IS Null or title IS Null or author_id IS NULL or publish_date IS NUll or price IS NULL or genre IS NULL;
-- There are null data
#let's make the price of book 2 the average of all prices


SET @precio_prom = (SELECT AVG(price) FROM libros WHERE price IS NOT NULL);
#Aqui la @algo almacena el dato


UPDATE libros AS b
JOIN books AS back_up
ON b.book_id = back_up.book_id
SET b.price = back_up.price;
#ahora si

UPDATE libros
SET price = @precio_prom
where price = 13.19;
# there was a neative price, we need to correct it

## corregimos el negativo

SELECT * FROM LIBROS
WHERE price < 0; 

SET @neg_pres = (SELECT ABS(total_amount) FROM ventas WHERE total_amount < 0);

UPDATE ventas
SET total_amount = @neg_pres
WHERE total_amount < 0;

#Now the price has been corrected and the negatives as well
#Now we have to correct the title, which from what we see is the book of
#Jarry Potter and the Philosopher's Stone

UPDATE libros
set title = "Harry Potter and the Philosopher's Stone"
where title is null;


SELECT genre FROM libros
group by genre;

#Now comes the reference validation
-- check that all author ids in books exist in authors

## Recalculation of Totals
-- check that total_amount in Sales matches price*quantity
#price = books and quantity = sales

UPDATE ventas
JOIN libros ON ventas.book_id = libros.book_id
SET ventas.total_amount = ventas.quantity * libros.price;

select * from ventas;

#Export table

SELECT * INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\Libros.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM Libros;








