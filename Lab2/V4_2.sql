/* a) �������� ������� dbo.StateProvince � ����� �� ���������� ��� Person.StateProvince, 
 ����� ���� uniqueidentifier, �� ������� �������, ����������� � ��������;*/
 CREATE TABLE [dbo].[StateProvince](
	[StateProvinceID] int identity (1, 1) NOT NULL,
	[StateProvinceCode] nchar(2) NOT NULL,
	[CountryRegionCode] nvarchar(3) NOT NULL,
	[IsOnlyStateProvinceFlag] Flag NOT NULL,
	[Name] [dbo].[Name] NOT NULL, 
	[TerritoryID] int NOT NULL,
	[ModifiedDate] datetime NOT NULL
)

DROP TABLE [dbo].[StateProvince];

/* b) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince ����������� UNIQUE ��� ���� Name;*/
ALTER TABLE [dbo].[StateProvince] 
	ADD CONSTRAINT UniqueName UNIQUE (NAME);
GO

/* c) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince ����������� ��� ���� CountryRegionCode,
 ����������� ���������� ����� ���� �������;*/
ALTER TABLE [dbo].[StateProvince]
    ADD CONSTRAINT ConstCountryRegionCodeNotNumber CHECK ( CountryRegionCode NOT LIKE '%[0-9]%' );

/* d) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince ����������� 
 DEFAULT ��� ���� ModifiedDate, ������� �������� �� ��������� ������� ���� � �����;*/
ALTER TABLE [dbo].[StateProvince]
	ADD CONSTRAINT DefValueModifiedDate DEFAULT GetDate() FOR ModifiedDate;
GO

/* e) ��������� ����� ������� ������� �� Person.StateProvince.  
  �������� ��� ������� ������ �� ������, ��� ��� �����/����������� ��������� � ������ ������/������� � ������� CountryRegion;*/
SET IDENTITY_INSERT [dbo].[StateProvince] ON;
GO
INSERT INTO [dbo].[StateProvince] SELECT
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

/*f) ������� ���� IsOnlyStateProvinceFlag, � ������ ���� �������� ����� CountryNum ���� int ����������� null ��������.*/
ALTER TABLE [dbo].[StateProvince] 
	DROP COLUMN [IsOnlyStateProvinceFlag];
ALTER TABLE [dbo].[StateProvince] 
	ADD [CountryNum] INT NULL;
GO