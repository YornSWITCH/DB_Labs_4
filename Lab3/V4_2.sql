USE AdventureWorks2012;
GO

/* a) выполните код, созданный во втором задании второй лабораторной работы. 
	Добавьте в таблицу dbo.StateProvince поля SalesYTD MONEY и SumSales MONEY. 
	Также создайте в таблице вычисляемое поле SalesPercent, 
	вычисляющее процентное выражение значения в поле SumSales от значения в поле SalesYTD.*/

ALTER TABLE dbo.StateProvince
    ADD SalesYTD MONEY;
GO

ALTER TABLE dbo.StateProvince
    ADD SumSales MONEY;
GO

ALTER TABLE dbo.StateProvince
    ADD SalesPercent AS ROUND(SalesYTD / SumSales * 100, 0) persisted;
GO

/* b) создайте временную таблицу #StateProvince, с первичным ключом по полю StateProvinceID. 
	Временная таблица должна включать все поля таблицы dbo.StateProvince за исключением поля SalesPercent.*/

CREATE TABLE #StateProvince
(
	StateProvinceID [INT] NOT NULL PRIMARY KEY,
	StateProvinceCode [NCHAR](3) COLLATE sql_latin1_general_cp1_ci_as NOT NULL,
	CountryRegionCode [NVARCHAR](3) COLLATE sql_latin1_general_cp1_ci_as NOT NULL,
	Name VARCHAR(50) NOT NULL,
	TerritoryID [INT] NOT NULL,
	ModifiedDate [DATETIME] NOT NULL,
	CountryNum [INT],
	SalesYTD MONEY,
	SumSales MONEY
);

SELECT * FROM #StateProvince;
GO

/* c) заполните временную таблицу данными из dbo.StateProvince. 
	Поле SalesYTD заполните значениями из таблицы Sales.SalesTerritory. 
	Посчитайте сумму продаж (SalesYTD) для каждой территории (TerritoryID) в таблице Sales.SalesPerson 
	и заполните этими значениями поле SumSales. Подсчет суммы продаж осуществите в Common Table Expression (CTE).*/

WITH SumSales_CTE AS (SELECT ST.TerritoryID, SUM(ST.SalesLastYear) AS SumSales
					  FROM dbo.StateProvince AS SP
					  JOIN Sales.SalesTerritory AS ST
					  ON SP.TerritoryID = ST.TerritoryID
					  GROUP BY ST.TerritoryID)
INSERT INTO #StateProvince
(
	StateProvinceID,
	StateProvinceCode,
	CountryRegionCode,
	Name,
	TerritoryID,
	ModifiedDate,
	CountryNum,
	SalesYTD,
	SumSales	
)
SELECT 
	SP.StateProvinceID,
	SP.StateProvinceCode,
	SP.CountryRegionCode,
	SP.Name,
	SP.TerritoryID,
	SP.ModifiedDate,
	SP.CountryNum,
	ST.SalesLastYear,
	SS.SumSales
FROM dbo.StateProvince AS SP
JOIN Sales.SalesTerritory AS ST
ON SP.TerritoryID = ST.TerritoryID
JOIN SumSales_CTE AS SS
ON SS.TerritoryID = SP.TerritoryID;

SELECT * FROM #StateProvince;
GO

/*  d) удалите из таблицы dbo.StateProvince одну строку (где StateProvinceID = 5)*/
DELETE
FROM dbo.StateProvince
WHERE StateProvinceID = 5;

SELECT * FROM dbo.StateProvince;
GO


/* e) напишите Merge выражение, использующее dbo.StateProvince как target, а временную таблицу как source. 
	Для связи target и source используйте StateProvinceID. Обновите поля SalesYTD и SumSales, если запись присутствует в source и target. 
	Если строка присутствует во временной таблице, но не существует в target, добавьте строку в dbo.StateProvince. 
	Если в dbo.StateProvince присутствует такая строка, которой не существует во временной таблице, удалите строку из dbo.StateProvince. */

MERGE dbo.StateProvince AS TARGET 
using #StateProvince AS SOURCE 
ON TARGET.StateProvinceId = source.StateProvinceId
WHEN matched THEN
UPDATE SET TARGET.SalesYTD = SOURCE.SalesYTD,
    TARGET.SumSales = SOURCE.SumSales
    WHEN NOT MATCHED THEN
INSERT VALUES (StateProvinceCode,
               CountryRegionCode,
               NAME,
               TerritoryId,
               ModifiedDate,
               CountryNum,
               SalesYTD,
               SumSales)
    WHEN NOT MATCHED BY SOURCE THEN
DELETE;

SELECT * FROM dbo.StateProvince;
GO