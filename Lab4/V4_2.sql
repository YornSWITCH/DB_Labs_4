USE AdventureWorks2012;
GO

DROP VIEW Production.ProductModelView;
GO

/* a) Создайте представление VIEW, отображающее данные из таблиц Production.ProductModel, 
	Production.ProductModelProductDescriptionCulture, Production.Culture и Production.ProductDescription. 
	Сделайте невозможным просмотр исходного кода представления. 
	Создайте уникальный кластерный индекс в представлении по полям ProductModelID,CultureID. */

CREATE VIEW Production.ProductModelView
    WITH ENCRYPTION, SCHEMABINDING
AS
SELECT
	Cult.CultureID,
	Cult.Name             AS CultureName,
	Cult.ModifiedDate     AS CultureModifiedDate,
	PM.CatalogDescription,
	PM.Instructions,
	PM.Name            AS ProductModelName,
	PM.ProductModelID,
	PM.ModifiedDate    AS ProductModelModifiedDate,
	PD.[Description],
	PD.ProductDescriptionID,
	PD.rowguid,
	PD.ModifiedDate    AS ProductDescriptionModifiedDate,
	PMPDC.ModifiedDate AS PMPDC_ModifiedDate
FROM Production.ProductModel AS PM
JOIN Production.ProductModelProductDescriptionCulture AS PMPDC
	ON PM.ProductModelID = PMPDC.ProductModelID
JOIN Production.Culture AS Cult
	ON Cult.CultureID = PMPDC.CultureID
JOIN Production.ProductDescription AS PD
	ON PD.ProductDescriptionID = PMPDC.ProductDescriptionID;
GO

CREATE UNIQUE CLUSTERED INDEX INDX_ProductModelID_CultureID
	ON Production.ProductModelView(ProductModelID, CultureID);
GO

/* b) Создайте три INSTEAD OF триггера для представления на операции INSERT, UPDATE, DELETE. 
	Каждый триггер должен выполнять соответствующие операции в таблицах Production.ProductModel, 
	Production.ProductModelProductDescriptionCulture, Production.Culture и Production.ProductDescription. 
	Обновление не должно происходить в таблице Production.ProductModelProductDescriptionCulture. 
	Удаление строк из таблиц Production.ProductModel, Production.Culture и Production.ProductDescription 
	производите только в том случае, если удаляемые строки больше не ссылаются на Production.ProductModelProductDescriptionCulture.*/

CREATE TRIGGER Production.OnInsertIntoProductModelVIew
    ON Production.ProductModelView
    INSTEAD OF INSERT 
AS
BEGIN
	INSERT INTO Production.ProductModel(Name)
    SELECT ProductModelName
    FROM INSERTED;

	INSERT INTO Production.Culture(CultureID, Name)
    SELECT CultureID, CultureName
    FROM INSERTED;
	
	INSERT INTO Production.ProductDescription([Description])
    SELECT [Description]
    FROM INSERTED;

	INSERT INTO Production.ProductModelProductDescriptionCulture(CultureID, ProductModelID, ProductDescriptionID)
    VALUES ((SELECT CultureID FROM INSERTED),
            IDENT_CURRENT('Production.ProductModel'),
            IDENT_CURRENT('Production.ProductDescription'));
END;
GO

CREATE TRIGGER Production.OnUpdateIntoProductModelVIew
    ON Production.ProductModelView
    INSTEAD OF UPDATE 
AS
BEGIN
    UPDATE Production.ProductModel
    SET Name = (SELECT ProductModelName FROM INSERTED),
        ModifiedDate = GETDATE()
    WHERE Name = (SELECT ProductModelName FROM DELETED);

	UPDATE Production.Culture
    SET Name = (SELECT CultureName FROM INSERTED),
        ModifiedDate = GETDATE()
    WHERE Name = (SELECT CultureName FROM DELETED);
	
    UPDATE Production.ProductDescription
    SET [Description] = (SELECT [Description] FROM INSERTED),
        ModifiedDate  = GETDATE()
    WHERE [Description] = (SELECT [Description] FROM DELETED);
END;
GO

CREATE TRIGGER Production.OnDeleteIntoProductModelVIew
    ON Production.ProductModelView
    INSTEAD OF DELETE 
AS
BEGIN
	DECLARE @CultureID NCHAR(6);
    DECLARE @ProductDescriptionID [int];
    DECLARE @ProductModelID [int];
    SELECT @CultureID = CultureID,
           @ProductDescriptionID = ProductDescriptionID,
           @ProductModelID = ProductModelID
    FROM DELETED;

    IF @ProductModelID NOT IN (SELECT ProductModelID FROM Production.ProductModelProductDescriptionCulture)
    BEGIN
		DELETE FROM Production.ProductModel
		 WHERE ProductModelID = @ProductModelID;
	END;

    IF @CultureID NOT IN (SELECT CultureID FROM Production.ProductModelProductDescriptionCulture)
    BEGIN
		DELETE FROM Production.Culture
		WHERE CultureID = @CultureID;
    END;

    IF @ProductDescriptionID NOT IN (SELECT ProductDescriptionID FROM Production.ProductModelProductDescriptionCulture)
    BEGIN
		DELETE FROM Production.ProductDescription
		WHERE ProductDescriptionID = @ProductDescriptionID;
    END;
END;
GO

/* c) Вставьте новую строку в представление, указав новые данные для ProductModel, Culture и ProductDescription. 
	Триггер должен добавить новые строки в таблицы Production.ProductModel, Production.ProductModelProductDescriptionCulture, 
	Production.Culture и Production.ProductDescription. Обновите вставленные строки через представление. Удалите строки.*/

INSERT INTO Production.ProductModelView
    (
		ProductModelName,
        CultureID,
        CultureName,
        [Description]
    )
VALUES
	(
		'Taco',
		'me',
		'Mexico',
		'Cheese'
	);
GO

UPDATE Production.ProductModelView
SET
	ProductModelName = 'Burito',
	CultureName = 'Mexican',
	[Description] = 'Mexican Shawarma'
WHERE
	CultureID = 'me'
	AND ProductModelID = IDENT_CURRENT('Production.ProductModel')
	AND ProductDescriptionID = IDENT_CURRENT('Production.ProductDescription');
GO

DELETE FROM Production.ProductModelView
WHERE
	CultureID = 'me'
	AND ProductModelID = IDENT_CURRENT('Production.ProductModel')
	AND ProductDescriptionID = IDENT_CURRENT('Production.ProductDescription');
GO

SELECT * FROM Production.ProductModelView
WHERE
	CultureID = 'me';
GO


