USE AdventureWorks2012;
GO

/* a) Создайте таблицу Production.ProductModelHst, 
	которая будет хранить информацию об изменениях в таблице Production.ProductModel.
	Обязательные поля, которые должны присутствовать в таблице: 
	ID — первичный ключ IDENTITY(1,1); 
	Action — совершенное действие (insert, update или delete); 
	ModifiedDate — дата и время, когда была совершена операция; 
	SourceID — первичный ключ исходной таблицы; 
	UserName — имя пользователя, совершившего операцию. 
	Создайте другие поля, если считаете их нужными.
	*/

CREATE TABLE Production.ProductModelHst
(
    ID INT IDENTITY(1, 1),
    Action NVARCHAR(6) NOT NULL CHECK (Action IN('insert', 'update', 'delete')),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
    SourceID NCHAR(3) NOT NULL,
    UserName Name NOT NULL
);
GO

/* b) Создайте один AFTER триггер для трех операций INSERT, UPDATE, DELETE для таблицы Production.ProductModel. 
	Триггер должен заполнять таблицу Production.ProductModelHst с указанием типа операции в поле Action 
	в зависимости от оператора, вызвавшего триггер. */

CREATE TRIGGER Production.OnProductModelInsert
ON Production.ProductModel
AFTER
	INSERT
AS
	INSERT INTO Production.ProductModelHst
		(
			Action,
			ModifiedDate,
			SourceID,
			UserName
		)
	SELECT
		'insert',
		INSERTED.ModifiedDate,
		ProductModelID,
		CURRENT_USER
	FROM
		INSERTED;
GO

CREATE TRIGGER Production.OnProductModelUpdate
ON Production.ProductModel
AFTER
	UPDATE
AS
	INSERT INTO Production.ProductModelHst
		(
			Action,
			ModifiedDate,
			SourceID,
			UserName
		)
	SELECT
		'update',
		INSERTED.ModifiedDate,
		ProductModelID,
		CURRENT_USER
	FROM
		INSERTED;
GO

CREATE TRIGGER Production.OnProductModelDelete
ON Production.ProductModel
AFTER
	DELETE
AS
	INSERT INTO Production.ProductModelHst
		(
			Action,
			ModifiedDate,
			SourceID,
			UserName
		)
	SELECT
		'delete',
		DELETED.ModifiedDate,
		ProductModelID,
		CURRENT_USER
	FROM
		DELETED;
GO

/* c) Создайте представление VIEW, отображающее все поля таблицы Production.ProductModel. */

CREATE VIEW
    Production.ProductModelView
AS
    SELECT *
    FROM Production.ProductModel;
GO

/* d) Вставьте новую строку в Production.ProductModel через представление. 
	Обновите вставленную строку. Удалите вставленную строку. 
	Убедитесь, что все три операции отображены в Production.ProductModelHst.  */

INSERT INTO Production.ProductModel (Name)
VALUES ('The Main Man');
GO

UPDATE Production.ProductModel
SET Name = 'Yorn Parsil'
WHERE Name = 'The Main Man';
GO

DELETE FROM Production.ProductModel
WHERE Name = 'Yorn Parsil';
GO

SELECT * FROM Production.ProductModelHst;
GO