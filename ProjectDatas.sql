-- This is a practice I'm going to do with values ​​that chatGPT is giving me

-- create a table
CREATE TABLE Clientes (
	ClientID INT PRIMARY KEY, #HAY QUE CHECAR ESO DE PRIMARY KEY
    Nombre VARCHAR(100),
    Email VARCHAR(100),
    Telefono VARCHAR(100),
    Direccion VARCHAR(100),
    FechaRegistro VARCHAR(100)
);

-- INCERT data
INSERT INTO Clientes (ClientID, Nombre, Email, Telefono, Direccion, FechaRegistro) VALUES
(1, 'Juan Pérez', 'juan.perez@@correo.com', '555-1234', 'Calle Falsa 123', '2021-03-15'),
(2, 'María López', 'maria.lopez@correo.com', '555-5678', 'Avenida Siempreviva 742', '15/03/2021'),
(3, 'Pedro García', NULL, '555-8765', NULL, '2021/03/16'),
(4, 'Ana Sánchez', 'ana.sanchez@correo.com', '555-4321', 'Boulevard de los Sueños Rotos', '20210317'),
(5, 'Carlos Méndez', 'carlos.mendez@correo', '555-9999', 'Plaza Principal s/n', '17/03/21'),
(6, 'Luis Fernández', 'luis.fernandez@correo.com', '555-1111', 'Calle 456', '2021-03-18'),
(7, 'Juana Martínez', 'juana.martinez@correo.', '555-2222', 'Calle 789', '2021.03.19'),
(8, 'Sofía González', 'sofia.gonzalez@correo.com', '555-3333', 'Calle 012', '19-03-2021'),
(9, 'Miguel Rodríguez', 'miguel.rodriguez@@correo.com', '555-4444', '', '2021-03-20'),
(10, 'Laura Hernández', 'laura.hernandez@correo.com', '555-5555', 'Calle Principal', '21/03/2021'),
(11, 'Laura Hernández', 'laura.hernandez@correo.com', '555-5555', 'Calle Principal', '2021-03-21'),
(12, 'David Jiménez', 'david.jimenez@correo.com', '555-6666', NULL, '2021-03-22'),
(13, 'Marta Ruiz', 'marta.ruiz@correo', '555-7777', 'Calle Secundaria', '22-03-2021'),
(14, 'Carlos Méndez', 'carlos.mendez@correo.com', '555-9999', 'Plaza Principal s/n', '2021-03-23'),
(15, 'Ana Sánchez', 'ana.sanchez@correo.com', '555-4321', 'Boulevard de los Sueños Rotos', '2021-03-24');

-- 
SELECT *
FROM clientesres3
where ClientID = 5 ;

-- duplicate the table for work
CREATE TABLE clientesRespaldo
LIKE clientes;
-- 
INSERT INTO clientesrespaldo
SELECT *
FROM clientes;

SELECT *
FROM clientesrespaldo;

#Steps
-- 1. Remove Duplicates
-- 2. Standarize the Data
-- 3. Null Values or blank values
-- 4. Remove any columns

# 1. 
SELECT *, ROW_NUMBER() OVER(PARTITION BY nombre, email, telefono, direccion, fecharegistro) AS repeticiones
from clientesrespaldo
;
#con esto de arriba vimos que hay duplicado de nombre pero que hay otros valores que no coinciden, como la fecha
#Y TAMBIEN QUE LA COLUMNA DE REPETICIONES NO SE AGREGA AUTOMATICAMENTE A LA TABLA 
WITH duplicados AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY nombre) AS repeticiones
from clientesrespaldo
)
SELECT * # acá intenté borrar pero no lo permite, tengo que rehacer la tabla
FROM duplicados
where repeticiones = 2;


# there are duplicates names, email, phone and address, no ID and no registration date

-- Here we make the table again so that it allows me to delete things

CREATE TABLE `clientesres3` (
  `ClientID` int NOT NULL,
  `Nombre` varchar(100) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Telefono` varchar(100) DEFAULT NULL,
  `Direccion` varchar(100) DEFAULT NULL,
  `FechaRegistro` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`ClientID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM clientesres3
ORDER BY Nombre;

ALTER TABLE clientesres3 
ADD COLUMN repeticiones INT;

INSERT INTO clientesres3
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY Nombre) AS repeticiones
from clientesrespaldo
;

DELETE
FROM clientesres3
WHERE repeticiones >= 2;
    
-- 2. Standarize data
SELECT * FROM clientesres3
ORDER BY Nombre;
 
SELECT FechaRegistro 
FROM CLIENTESRES3; #están mal las fechas, deben estar en formato mes/dia/año 

#we are going to use CASE
SELECT first_name, last_name, age,
CASE
	WHEN age <= 30 THEN 'Young' #se pueden poner varios
    WHEN age BETWEEN 31 and 50 THEN 'Old'
    WHEN age >= 50 THEN 'On the Death´s Door'
END AS Age_Bracket #Aca se le pone el nombre
FROM employee_demographics
;
#La quiero #Y/%m/%d

SELECT * 
FROM clientesres3;
UPDATE clientesres3
SET FechaRegistro = date_format( 
CASE
	WHEN FechaRegistro LIKE '____-__-__' THEN str_to_date(FechaRegistro, '%Y-%m-%d')
    WHEN FechaRegistro LIKE '__/__/____' THEN str_to_date(FechaRegistro, '%d/%m/%Y')
    WHEN FechaRegistro LIKE '____/__/__' THEN str_to_date(FechaRegistro, '%Y/%m/%d')
    WHEN FechaRegistro LIKE '________' THEN str_to_date(FechaRegistro, '%Y%m%d')
    WHEN FechaRegistro LIKE '____.__.__' THEN str_to_date(FechaRegistro, '%Y.%m.%d')
    WHEN FechaRegistro LIKE '__-__-____' THEN str_to_date(FechaRegistro, '%d-%m-%Y')
    ELSE NULL
END,
'%Y-%m-%d'
);

SELECT *
from clientesres3;

# Email format

SELECT Email
FROM clientesres3
WHERE Email NOT LIKE '%@correo%'; #Todos tienen al menos @correo

SELECT *
FROM clientesres3
WHERE Email IS NULL; 

# standarize email

WITH CTE_Email AS
(
	SELECT ClientID, Email,
		   SUBSTRING_INDEX(Email, '@',1) AS CorreoInc
	FROM clientesres3
)
UPDATE clientesres3
JOIN CTE_Email ON clientesres3.ClientID = CTE_Email.ClientID
SET clientesres3.Email = CONCAT(CTE_Email.CorreoInc, '@correo.com');
#SELECT CorreoInc,
#CONCAT(CorreoInc, '@correo.com') AS EmailCompleto
#FROM CTE_Email;

SELECT *
FROM clientesres3;
#We need to remove the column for FechaRegistroTem because it is of no use to us
-- To do this we need to use ALTER TABLE DROP COLUMN

ALTER TABLE clientesres3
DROP COLUMN FechaRegistroTemp;

--  remove repeticiones
ALTER TABLE clientesres3
DROP COLUMN repeticiones;

# asing an email to whoever is missing it

SELECT Nombre, Email
FROM clientesres3
WHERE Email IS NULL;

WITH CTE_Nombre AS
(
	SELECT ClientID,
    Nombre, 
    SUBSTRING_INDEX(Nombre, ' ',1) AS PrimerNombre,
    SUBSTRING_INDEX(Nombre, ' ',-1) As Apellido
    FROM clientesres3
)
# update table
UPDATE clientesres3
JOIN CTE_Nombre ON clientesres3.ClientID = CTE_Nombre.ClientID
SET clientesres3.Email = CONCAT(CTE_Nombre.PrimerNombre, '.', CTE_Nombre.Apellido, '@correo.com')
WHERE clientesres3.Email IS NULL;


SELECT *
FROM clientesres3
WHERE Email IS NULL;

-- we are going to assign the value 'no address' to the data without values

UPDATE clientesres3 
SET Direccion = 'Sin dato'
where Direccion IS NULL;

UPDATE clientesres3
SET Direccion = TRIM(Direccion);

SELECT *
FROM CLIENTESRES3;

DELETE
from clientesres3
where ClientID = 9;

INSERT INTO clientesres3 (ClientID, Nombre, Email, Telefono, Direccion, FechaRegistro) VALUES
(9, 'Miguel Rodríguez', 'miguel.rodriguez@correo', '555-9999', 'Sin dato', '2021-03-17') 
;

SELECT DIRECCION
FROM CLIENTESRES3;
#IF IT DOES NOT HAVE A NUMBER, IT HAS TO PUT Y/N

WITH CTE_direccion AS 
(
SELECT ClientID, direccion,
    CASE
        WHEN direccion NOT REGEXP '[0-9]' then direccion
        ELSE NULL
    END AS Sin_numero 
FROM clientesres3
)
UPDATE clientesres3
JOIN CTE_direccion ON clientesres3.ClientID = CTE_direccion.ClientID
SET clientesres3.direccion = CONCAT(CTE_direccion.direccion, ' ', CTE_direccion.Sin_numero)
WHERE CTE_direccion.Sin_numero IS not NULL;
;

SELECT NOMBRE, DIRECCION
FROM clientesres3;







