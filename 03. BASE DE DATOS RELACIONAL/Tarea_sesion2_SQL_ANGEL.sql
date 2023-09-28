
CREATE PROCEDURE ActualizarVISTA_TABLA_SUPERMARKET
AS
BEGIN

-- Verificar si la vista existe y eliminarla si es necesario
IF OBJECT_ID('dbo.VISTA_TABLA_SUPERMARKET', 'V') IS NOT NULL
DROP VIEW dbo.VISTA_TABLA_SUPERMARKET;

     --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
---PARTE 1: 1 CIUDADES CON MAYORES VENTAS---
WITH TABLA_CIUDAD AS(
       SELECT TOP 1 City, SUM(CAST(Total AS numeric)) AS Total_ventas
       FROM [dbo].[supermarket_sales]
       GROUP BY City
       ORDER BY SUM(CAST(Total AS numeric)) DESC
),
     --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
---PARTE 2: PRODUCTO MAS VENDIDO---
TABLA_PRODUCTO AS(
       SELECT City,[Product line], SUM(CAST(Quantity AS numeric)) AS Prod_vendidos
       FROM [dbo].[supermarket_sales]
	   WHERE City=(SELECT City FROM TABLA_CIUDAD)
       GROUP BY City, [Product line]
       --ORDER BY SUM(CAST(Quantity AS numeric)) DESC
), 
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
---PARTE 3: MODA POR PAYMENT Y CANT_TRANSACCIONES---
TABLA_PAGO AS (
      SELECT TOP 1 City,Payment, COUNT(*) AS Cant_trans, ROW_NUMBER() OVER(PARTITION BY City ORDER BY COUNT(*) DESC) AS rn
      FROM [dbo].[supermarket_sales]
	  WHERE City=(SELECT City FROM TABLA_CIUDAD)
      GROUP BY City,Payment
	  ORDER BY ROW_NUMBER() OVER(PARTITION BY City ORDER BY COUNT(*) DESC)
), 
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
---PARTE 4: PROMEDIO DE RATING---
TABLA_RATING AS (
      SELECT City,AVG(CAST(Rating AS NUMERIC)) AS Rating
      FROM [dbo].[supermarket_sales]
	  WHERE City=(SELECT City FROM TABLA_CIUDAD)
      GROUP BY City
)

-- Crear una vista temporal para el resultado deseado
SELECT TOP 5 *
INTO #VISTA_TEMPORAL
FROM [dbo].[supermarket_sales] A
WHERE City=(SELECT City FROM TABLA_CIUDAD) 
ORDER BY CAST(Total AS FLOAT) DESC;

-- Crear la vista basada en la vista temporal
CREATE VIEW VISTA_TABLA_SUPERMARKET AS
SELECT * FROM #VISTA_TEMPORAL;

-- Eliminar la vista temporal después de crear la vista
DROP TABLE #VISTA_TEMPORAL;

END