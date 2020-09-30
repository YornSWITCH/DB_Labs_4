/* ¬ывести на экран список отделов, принадлежащих группе СExecutive General and AdministrationТ.*/
SELECT [Name], [GroupName]
FROM [HumanResources].[Department]
WHERE [GroupName] = 'Executive General and Administration';


/* ¬ывести на экран максимальное количество оставшихс€ часов отпуска
 у сотрудников. Ќазовите столбец с результатом СMaxVacationHoursТ.*/
SELECT MAX([VacationHours]) AS MaxVacationHours
FROM [HumanResources].[Employee];

/*¬ывести на экран сотрудников, название позиции которых включает слово СEngineerТ.*/
SELECT [BusinessEntityID], [JobTitle], [Gender], [BirthDate], [HireDate]
FROM [HumanResources].[Employee]
WHERE [JobTitle] LIKE '%Engineer%';