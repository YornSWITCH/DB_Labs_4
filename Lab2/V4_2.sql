/* a) создайте таблицу dbo.StateProvince с такой же структурой как Person.StateProvince, 
 кроме поля uniqueidentifier, не включая индексы, ограничения и триггеры;*/
 CREATE TABLE [dbo].[StateProvince](
	[StateProvinceID] int identity (1, 1) NOT NULL,
	[StateProvinceCode] nchar(20) NOT NULL,
	[CountryRegionCode] nvarchar(30) NOT NULL,
	[IsOnlyStateProvinceFlag] [dbo].[FLAG]   NOT NULL,
	[Name] [dbo].[Name] NOT NULL, 
	[TerritoryID] int NOT NULL,
	[ModifiedDate] datetime NOT NULL
)

DROP TABLE [dbo].[StateProvince];

/* b) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince ограничение UNIQUE для поля Name;*/
ALTER TABLE [dbo].[StateProvince] 
	ADD CONSTRAINT UniqueName UNIQUE (NAME);
GO

/* c) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince ограничение для поля CountryRegionCode,
 запрещающее заполнение этого поля цифрами;*/
ALTER TABLE [dbo].[StateProvince]
    ADD CONSTRAINT ConstCountryRegionCodeNotNumber CHECK ( CountryRegionCode NOT LIKE '%[0-9]%' );

/* d) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince ограничение 
 DEFAULT для поля ModifiedDate, задайте значение по умолчанию текущую дату и время;*/
ALTER TABLE [dbo].[StateProvince]
	ADD CONSTRAINT DefValueModifiedDate DEFAULT GetDate() FOR ModifiedDate;
GO

/* e) заполните новую таблицу данными из Person.StateProvince.  
  Выберите для вставки только те данные, где имя штата/государства совпадает с именем страны/региона в таблице CountryRegion;*/
SET IDENTITY_INSERT [dbo].[StateProvince] ON;
GO
INSERT INTO [dbo].[StateProvince] (
	[StateProvinceID],
	[StateProvinceCode],
	[CountryRegionCode],
	[IsOnlyStateProvinceFlag],
	[Name],
	[TerritoryID],
	[ModifiedDate]
) SELECT
	[ST].[StateProvinceID],
	[ST].[StateProvinceCode],
	[ST].[CountryRegionCode],
	[ST].[IsOnlyStateProvinceFlag],
	[ST].[Name],
	[ST].[TerritoryID],
	[ST].[ModifiedDate]
FROM [Person].[StateProvince] AS [ST]
JOIN [Person].[CountryRegion] AS [CR] 
ON [CR].[CountryRegionCode] = [ST].[CountryRegionCode]
WHERE [CR].[Name] = [ST].[Name];
GO

/*f) удалите поле IsOnlyStateProvinceFlag, а вместо него создайте новое CountryNum типа int допускающее null значения.*/
ALTER TABLE [dbo].[StateProvince] 
	DROP COLUMN [IsOnlyStateProvinceFlag];
ALTER TABLE [dbo].[StateProvince] 
	ADD [CountryNum] INT NULL;
GO