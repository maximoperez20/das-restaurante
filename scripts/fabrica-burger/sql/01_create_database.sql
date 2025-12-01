IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'das_fabrica_burger')
BEGIN
    CREATE DATABASE das_fabrica_burger;
    PRINT 'Base de datos das_fabrica_burger creada exitosamente';
END
ELSE
BEGIN
    PRINT 'Base de datos das_fabrica_burger ya existe';
END
GO
