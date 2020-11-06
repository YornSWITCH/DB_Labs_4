USE AdventureWorks2012;
GO


/* a) добавьте в таблицу dbo.StateProvince поле CountryRegionName типа nvarchar(50);*/
ALTER TABLE [dbo].[StateProvince]
    ADD [CountryRegionName] NVARCHAR(50);
GO

/* b) объявите табличную переменную с такой же структурой как dbo.StateProvince и заполните ее данными из dbo.StateProvince. 
Заполните поле CountryRegionName данными из Person.CountryRegion поля Name;*/
DECLARE @StateProvinceVar TABLE
	(
		StateProvinceId   [INT] NOT NULL,
		StateProvinceCode [NCHAR](3) NOT NULL,
		CountryRegionCode [NVARCHAR](3) NOT NULL,
		Name              [dbo].[NAME] NOT NULL,
		TerritoryId       [INT] NOT NULL,
		ModifiedDate      [DATETIME] NOT NULL,
		CountryRegionName [NVARCHAR](50)
	);
INSERT INTO @StateProvinceVar
	SELECT SP.StateProvinceId,
		   SP.StateProvinceCode,
		   SP.CountryRegionCode,
		   SP.Name,
		   SP.TerritoryId,
		   SP.ModifiedDate,
		   CR.Name AS CountryRegionName
	FROM [dbo].[StateProvince] AS SP
	JOIN person.CountryRegion AS CR
		ON SP.CountryRegionCode = CR.CountryRegionCode;

--SELECT * FROM @StateProvinceVar;

/* c) обновите поле CountryRegionName в dbo.StateProvince данными из табличной переменной;*/

UPDATE dbo.StateProvince
	SET dbo.StateProvince.CountryRegionName = V.CountryRegionName
	FROM @StateProvinceVar AS V
	WHERE StateProvince.StateProvinceId = V.StateProvinceId;
GO

SELECT * FROM dbo.StateProvince;
GO

/* d) удалите штаты из dbo.StateProvince, которые отсутствуют в таблице Person.Address;*/

DELETE
	FROM dbo.StateProvince
	WHERE StateProvinceId NOT IN
		(
			SELECT StateProvinceId
			FROM person.address
		);

SELECT * FROM dbo.StateProvince;
GO

/* e) удалите поле CountryRegionName из таблицы, удалите все созданные ограничения и значения по умолчанию.
Имена ограничений вы можете найти в метаданных.
Имена значений по умолчанию найдите самостоятельно, приведите код, которым пользовались для поиска;*/

SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'StateProvince';
GO

ALTER TABLE dbo.StateProvince
    DROP CONSTRAINT 
		ConstCountryRegionCodeNotNumber, 
		UniqueName, 
		COLUMN CountryRegionName;
GO


/* f) удалите таблицу dbo.StateProvince. */

DROP TABLE dbo.StateProvince;
GO