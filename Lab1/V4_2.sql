/* ������� �� ����� ������ �������, ������������� ������ �Executive General and Administration�.*/
SELECT [Name], [GroupName]
FROM [HumanResources].[Department]
WHERE [GroupName] = 'Executive General and Administration';


/* ������� �� ����� ������������ ���������� ���������� ����� �������
 � �����������. �������� ������� � ����������� �MaxVacationHours�.*/
SELECT MAX([VacationHours]) AS MaxVacationHours
FROM [HumanResources].[Employee];

/*������� �� ����� �����������, �������� ������� ������� �������� ����� �Engineer�.*/
SELECT [BusinessEntityID], [JobTitle], [Gender], [BirthDate], [HireDate]
FROM [HumanResources].[Employee]
WHERE [JobTitle] LIKE '%Engineer%';