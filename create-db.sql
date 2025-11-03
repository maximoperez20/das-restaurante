-- Script para crear la base de datos das_restaurante_soap
-- Ejecutar en SQL Server Management Studio o sqlcmd

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'das_restaurante_soap')
BEGIN
    CREATE DATABASE das_restaurante_soap;
    PRINT 'Base de datos das_restaurante_soap creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La base de datos das_restaurante_soap ya existe';
END
GO

USE das_restaurante_soap;
GO

SELECT 'Base de datos actual: ' + DB_NAME() AS mensaje;
GO



