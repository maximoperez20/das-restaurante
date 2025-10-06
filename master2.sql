:setvar BasePath "C:\Users\Usuario\Desktop\2025\Segundo Cuatrimestre\Diseño Avanzado de Software\Restaurante\das-restaurante"
GO
--Diagrama de base de datos (ELIMINA LAS TABLAS Y VUELVE A CREARLAS)
:r $(BasePath)\resto.sql 
GO
-- Inserta catálogos base: provincias, localidades, zonas, categorías de precios, tipos de comidas, especialidades alimentarias y estilos
:r $(BasePath)\AltaBasica.sql 
GO
-- Crea/asegura el restaurante, resuelve provincias/localidades/categorías, crea/actualiza sus sucursales y genera turnos habilitados 
--- cada 2 horas desde la hora de apertura hasta 00:00, luego muestra una verificación de turnos por sucursal
:r $(BasePath)\2RestauranteAroza.sql
GO
-- Resuelve restaurante y sucursal, obtiene IDs de zonas y crea (si faltan) las zonas de la sucursal (Salón Principal y Terraza) con capacidad, 
--- permite_menores y habilitada; luego muestra una verificación
:r $(BasePath)\zonas_sucursales.sql
GO
-- Habilita todas las zonas de una sucursal en todos sus turnos (cruce zonas_sucursales × turnos_sucursales), inicializa permite_menores desde la zona, 
--- permite excepciones opcionales y lista una verificación final
:r $(BasePath)\3RestauranteAroza2.sql
GO
--- Procedimientos 
:r $(BasePath)\procs.sql


