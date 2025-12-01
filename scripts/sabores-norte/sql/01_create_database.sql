IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'das_sabores_norte')
BEGIN
    CREATE DATABASE das_sabores_norte;
    PRINT 'Base de datos das_sabores_norte creada exitosamente';
END
ELSE
BEGIN
    PRINT 'Base de datos das_sabores_norte ya existe';
END
GO
