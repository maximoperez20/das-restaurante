/* =========================================================================================
   CREAR BASE DE DATOS: das_bella_pizza
   ========================================================================================= */

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'das_bella_pizza')
BEGIN
    CREATE DATABASE das_bella_pizza;
    PRINT 'Base de datos das_bella_pizza creada exitosamente';
END
ELSE
BEGIN
    PRINT 'Base de datos das_bella_pizza ya existe';
END
GO

