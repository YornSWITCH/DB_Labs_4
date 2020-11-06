/* Создайте scalar-valued функцию, которая будет принимать в качестве входного параметра id заказа (Sales.SalesOrderHeader.SalesOrderID) 
	и возвращать максимальную цену продукта из заказа (Sales.SalesOrderDetail.UnitPrice). */

CREATE FUNCTION dbo.GetMaxCost(@SalesOrderID [int])
    RETURNS money
    WITH
        EXECUTE AS CALLER
AS
BEGIN
    DECLARE @ResultValue Money;
    SET @ResultValue = (SELECT MAX(SOD.UnitPrice)
                        FROM Sales.SalesOrderHeader AS SOH
                                 JOIN Sales.SalesOrderDetail AS SOD
                                      ON SOH.SalesOrderID = SOD.SalesOrderID
                        WHERE @SalesOrderID = SOH.SalesOrderID);
    RETURN
        (@ResultValue);
END;
GO

/* Создайте inline table-valued функцию, которая будет принимать в качестве входных параметров id продукта (Production.Product.ProductID) 
	и количество строк, которые необходимо вывести.
	Функция должна возвращать определенное количество инвентаризационных записей о продукте 
	с наибольшим его количеством (по Quantity) из Production.ProductInventory. 
	Функция должна возвращать только продукты, хранящиеся в отделе А (Production.ProductInventory.Shelf). */

CREATE FUNCTION dbo.GetCountProductsById(@ProductID [int], @RowCount [int])
    RETURNS TABLE
        AS RETURN
		(
			SELECT 
					ProductID,
					LocationID,
					Shelf,
					Bin,
					MaxQuantity,
					RowGuid,
					ModifiedDate
			FROM (
				SELECT 
						ProductID,
						LocationID,
						Shelf,
						Bin,
						MAX(Quantity) OVER (PARTITION BY ProductID) AS MaxQuantity,
						RowGUID,
						ModifiedDate,
						ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY ProductID) AS RowNumber
					FROM Production.ProductInventory
					WHERE ProductID = @ProductID AND Shelf = 'A'
				) AS Result
			WHERE RowNumber <= @RowCount
        );
GO

/* Вызовите функцию для каждого продукта, применив оператор CROSS APPLY. 
	Вызовите функцию для каждого продукта, применив оператор OUTER APPLY.*/

SELECT *
	FROM Production.Product AS P
	CROSS APPLY dbo.GetCountProductsById(P.ProductID, 2);

SELECT *
	FROM Production.Product AS P
	OUTER APPLY dbo.GetCountProductsById(P.ProductID, 2);

/* Измените созданную inline table-valued функцию, сделав ее multistatement table-valued 
	(предварительно сохранив для проверки код создания inline table-valued функции).*/

IF object_id('GetRowsByIdAndCount', 'FN') IS NOT NULL
    DROP FUNCTION GetRowsById
GO

CREATE FUNCTION dbo.GetRowsById(@ProductID [int],
                                        @rowCount [int])
    RETURNS @ProductInventary TABLE
                              (
                                  ProductID    int,
                                  LocationID   smallint,
                                  Quantity     int,
                                  Bin          tinyint,
                                  Shelf        nvarchar,
                                  rowguid      uniqueidentifier,
                                  ModifiedDate datetime
                              )
AS
BEGIN
    INSERT INTO @ProductInventary
    SELECT ProductID, LocationID, Quantity, Bin, Shelf, rowguid, ModifiedDate
    FROM (
             SELECT ProductID,
                    LocationID,
                    MAX(Quantity) OVER (PARTITION BY ProductID)                   AS Quantity,
                    Bin,
                    Shelf,
                    rowguid,
                    ModifiedDate,
                    ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY ProductID) AS countOfRows
             FROM Production.ProductInventory
             WHERE ProductID = @ProductID
               AND Shelf = 'A'
         ) AS Result
    WHERE countOfRows <= @rowCount
    RETURN;
END;
GO

