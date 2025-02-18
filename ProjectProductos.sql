
-- Remove Duplicates
-- Normalize product descriptions
-- Make sure cateories are spelled correctly and consistent

CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY,
    Nombre VARCHAR(100),
    Descripcion TEXT,
    Precio DECIMAL(10, 2),
    Categoria VARCHAR(50)
);

-- Insert data into the products table
INSERT INTO Productos (ProductoID, Nombre, Descripcion, Precio, Categoria) VALUES
(1, 'Producto A', 'Un producto genial', 25.00, 'Categoria1'),
(2, 'Producto B', '¡Producto B! El mejor.', 35.50, 'Categoria2'),
(3, 'Producto A', 'Un producto genial', 25.00, 'Categoria1'),
(4, 'Producto C', 'Producto C, simplemente bueno', 45.00, 'categoria3'),
(5, 'Producto D', 'Producto-D, con descuento', 55.00, 'Categoria 4');

--

SELECT *
FROM Productos;

-- duplicate table

CREATE TABLE Productos1
LIKE Productos;

-- Insert values

INSERT INTO productos1
SELECT *
FROM productos;


SELECT *
FROM productos1;


# Search for duplicated columns
SELECT *, ROW_NUMBER() OVER(PARTITION BY nombre, descripcion, precio, categoria) AS repeticiones
FROM productos1;

# e are going to make a CTE to add the repetitions column to the product
ALTER TABLE productos1
ADD COLUMN repeticiones INT; 


WITH CTE_row AS (
    SELECT
        productoID,  
        ROW_NUMBER() OVER (PARTITION BY nombre, descripcion, precio, categoria) AS repeticiones
    FROM productos1
)
UPDATE productos1
JOIN CTE_row ON productos1.productoid = CTE_row.productoid
SET productos1.repeticiones = CTE_row.repeticiones;


SELECT * 
FROM productos1;

-- Delete duplicate column

DELETE
FROM productos1
WHERE repeticiones = 2;

-- borramos la columna de repeticiones

ALTER TABLE productos1
DROP COLUMN repeticiones;

-- how many different products there are, and then count the categories.

SELECT categoria
FROM productos1
GROUP BY categoria;


-- We are going to write the categories uniformly
#we put them all in lowercase

WITH CTE_Cate AS
(
SELECT ProductoID, LOWER(categoria) AS CategoriaMejor
from productos1
)
UPDATE productos1
JOIN CTE_Cate ON productos1.ProductoID = CTE_Cate.ProductoID
SET productos1.categoria = CTE_Cate.CategoriaMejor;
;

--  there is one of the categories that has a space
SELECT REPLACE(categoria, ' ', '') 
from productos1;


UPDATE Productos1
SET categoria = REPLACE(categoria, ' ', '');

-- data is ready



