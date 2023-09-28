

--CREATE DATABASE DATAPATH

--USE DATAPATH

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
---PARTE 1: 5 CIUDADES CON MAYORES VENTAS---
SELECT TOP 5 City, SUM(CAST(Total AS numeric)) AS Total_ventas
INTO #TABLA_CITY
FROM [dbo].[supermarket_sales]
GROUP BY City
ORDER BY SUM(CAST(Total AS numeric)) DESC


--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
---PARTE 2: 2 PRODUCTOS MAS VENDIDOS EN CADA CIUDAD---
SELECT A.City,A.[Product line],A.Total_prod_vend
INTO #TABLA_PRODUCTO
FROM (
      SELECT City,[Product line], SUM(CAST(Quantity AS numeric)) AS Total_prod_vend,ROW_NUMBER() OVER(PARTITION BY City ORDER BY SUM(CAST(Quantity AS numeric)) DESC) AS rn
      FROM [dbo].[supermarket_sales]
      GROUP BY City,[Product line]) A
WHERE A.rn IN (1,2)
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
---PARTE 3: MODA POR PAYMENT Y CANT_TRANSACCIONES---
SELECT A.City,A.[Product line],A.Payment,A.Cant_trans
INTO #TABLA_PAGO
FROM (
      SELECT City,[Product line],Payment, COUNT(*) AS Cant_trans, ROW_NUMBER() OVER(PARTITION BY City, [Product line] ORDER BY COUNT(*) DESC) AS rn
      FROM [dbo].[supermarket_sales]
      GROUP BY City,[Product line],Payment) A
WHERE A.rn=1
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--



--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
---PARTE 4: CREAMOS UNA TABLA PARA EL DASHBOARD---
SELECT A.City,A.Total_ventas,B.[Product line],B.Total_prod_vend,C.Payment,C.Cant_trans
INTO [dbo].[supermarket_sales_dashboard]
FROM #TABLA_CITY A
INNER JOIN #TABLA_PRODUCTO B ON A.City=B.City
INNER JOIN #TABLA_PAGO C ON B.City= C.City AND B.[Product line]=C.[Product line]
ORDER BY A.City
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

