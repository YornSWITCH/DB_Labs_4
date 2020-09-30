/*Вывести на экран неповторяющийся список должностей в каждом отделе, отсортированный по названию отдела.
 Посчитайте количество сотрудников, работающих в каждом отделе.*/ 
 SELECT DISTINCT [D].[Name], [E].[JobTitle], 
		Count([E].[BusinessEntityID]) OVER (PARTITION BY [D].[Name]) as [EmpCount]
	FROM [HumanResources].[EmployeeDepartmentHistory] AS [EDH]
	JOIN [HumanResources].[Department] AS [D] 
		ON [EDH].[DepartmentID] = [D].[DepartmentID]
	JOIN [HumanResources].[Employee] AS [E]
		ON [EDH].[BusinessEntityID] = [E].[BusinessEntityID]
	WHERE [EDH].[EndDate] IS NULL
	ORDER BY [D].[Name]
GO

/*Вывести на экран сотрудников, которые работают в ночную смену.*/ 
SELECT [E].[BusinessEntityID], [E].[JobTitle], [S].[Name], [S].[StartTime], [S].[EndTime]
	FROM [HumanResources].[EmployeeDepartmentHistory] AS [EDH]
	JOIN [HumanResources].[Shift] AS S
		ON [EDH].[ShiftID] = [S].[ShiftID]
	JOIN [HumanResources].[Employee] AS [E] 
		ON [EDH].[BusinessEntityID] = [E].BusinessEntityID
	WHERE [S].[Name] = 'Night'

/*Вывести на экран почасовые ставки сотрудников. 
Добавить столбец с информацией о предыдущей почасовой 
ставке для каждого сотрудника. Добавить еще один столбец 
с указанием разницы между текущей ставкой и предыдущей ставкой для каждого сотрудника.*/
SELECT [E].[BusinessEntityID], [E].[JobTitle], [P].[Rate], 
		LAG([P].[Rate], 1, 0) OVER (PARTITION BY [P].[BusinessEntityID] ORDER BY [P].[BusinessEntityID]) as [PrevRate],
		[P].[Rate] - LAG([P].[Rate], 1, 0) OVER (PARTITION BY [P].[BusinessEntityID] ORDER BY [P].[BusinessEntityID]) as [Increased]
	FROM [HumanResources].[Employee] as [E]
	JOIN [HumanResources].[EmployeePayHistory] as [P]
		ON [E].[BusinessEntityID] = [P].[BusinessEntityID]
	ORDER BY [P].[BusinessEntityID]