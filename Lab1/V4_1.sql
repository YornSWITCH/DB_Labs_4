USE [master];
GO

CREATE DATABASE [Egor_Petrushko];

USE [Egor_Petrushko];
GO

CREATE SCHEMA [sales];
GO

CREATE SCHEMA [persons];
GO

CREATE TABLE [sales.Orders] (OrderNum INT NULL);
GO

BACKUP DATABASE [Egor_Petrushko]
	TO DISK = 'D:\DB_4\Lab1\Egor_Petrushko.bak';
GO

USE [master];
DROP DATABASE [Egor_Petrushko]
GO

RESTORE DATABASE [Egor_Petrushko]
	FROM DISK = 'D:\DB_4\Lab1\Egor_Petrushko.bak';
GO
