/* =========================================================================================
   INSERT DE DATOS: La Fábrica Burger (REST)
   Base de Datos: das_restaurante
   UUID del Restaurante: FABRICA-BURGER-3333-3333-3333-333333333333
   Protocolo: REST
   ========================================================================================= */

SET NOCOUNT ON;
GO

USE das_restaurante;
GO

/* =========================================
   1) Verificar/crear catálogos base
   ========================================= */

-- Provincias
IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'Córdoba')
    INSERT INTO provincias (nom_provincia) VALUES ('Córdoba');

-- Localidades
DECLARE @cod_cba VARCHAR(36);
SELECT @cod_cba = cod_provincia FROM provincias WHERE nom_provincia = 'Córdoba';

IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Cerro de las Rosas' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Cerro de las Rosas', @cod_cba);

-- Zonas (UUIDs fijos - ya insertadas por 03_insert_datos_basicos.sql)
-- Solo obtener los UUIDs, no insertar (las zonas ya están en el catálogo)
DECLARE @cod_zona_salon_principal VARCHAR(36) = 'ZONA-SALON-PRINCIPAL-0001-0001-0001-0001';
DECLARE @cod_zona_patio VARCHAR(36) = 'ZONA-PATIO-0001-0001-0001-0001';

-- Verificar que las zonas existan (deben estar insertadas por 03_insert_datos_basicos.sql)
IF NOT EXISTS (SELECT 1 FROM zonas WHERE cod_zona = @cod_zona_salon_principal)
BEGIN
    RAISERROR('Error: La zona "Salón Principal" no existe. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1);
    RETURN;
END

IF NOT EXISTS (SELECT 1 FROM zonas WHERE cod_zona = @cod_zona_patio)
BEGIN
    RAISERROR('Error: La zona "Patio" no existe. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1);
    RETURN;
END

-- Categorías de precios
IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Media')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Media');

-- Tipos de comidas
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Americana')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Americana');

IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Fast food gourmet')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Fast food gourmet');

-- Estilos
IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Casual')
    INSERT INTO estilos (nom_estilo) VALUES ('Casual');

PRINT 'Catálogos base verificados/creados';

/* =========================================
   2) Restaurante: La Fábrica Burger
   ========================================= */

DECLARE @rest_uuid VARCHAR(36) = 'FABRICA-BURGER-3333-3333-3333-333333333333';

IF NOT EXISTS (SELECT 1 FROM restaurantes WHERE nro_restaurante = @rest_uuid)
BEGIN
    INSERT INTO restaurantes (nro_restaurante, razon_social, cuit)
    VALUES (@rest_uuid, 'La Fábrica Burger SRL', '30345678901');
    PRINT 'Restaurante La Fábrica Burger insertado';
END
ELSE
BEGIN
    PRINT 'Restaurante La Fábrica Burger ya existe';
END

/* =========================================
   3) Sucursal 1: Cerro de las Rosas
   ========================================= */

DECLARE @nro_localidad_cerro VARCHAR(36);
SELECT @nro_localidad_cerro = nro_localidad FROM localidades WHERE nom_localidad='Cerro de las Rosas' AND cod_provincia=@cod_cba;

DECLARE @nro_categoria_media VARCHAR(36);
SELECT @nro_categoria_media = nro_categoria FROM categorias_precios WHERE nom_categoria='Media';

-- UUID fijo para Sucursal 1: Cerro de las Rosas
DECLARE @suc_1_uuid VARCHAR(36) = 'FABRICA-BURGER-SUC-0001-0001-0001-0001';
IF NOT EXISTS (SELECT 1 FROM sucursales WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'La Fábrica Burger - Cerro de las Rosas')
BEGIN
    INSERT INTO sucursales (
        nro_restaurante, nro_sucursal, nom_sucursal, calle, nro_calle, barrio,
        nro_localidad, cod_postal, telefonos, total_comensales, min_tolerencia_reserva, nro_categoria
    )
    VALUES (
        @rest_uuid, @suc_1_uuid, 'La Fábrica Burger - Cerro de las Rosas',
        'Av. Rafael Núñez', 3500, 'Cerro de las Rosas',
        @nro_localidad_cerro, '5009', '351-555-3001', 90, 10, @nro_categoria_media
    );
    PRINT 'Sucursal 1 (Cerro de las Rosas) insertada: ' + @suc_1_uuid;
END
ELSE
BEGIN
    UPDATE sucursales SET nro_sucursal = @suc_1_uuid
    WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'La Fábrica Burger - Cerro de las Rosas' AND nro_sucursal != @suc_1_uuid;
    PRINT 'Sucursal 1 (Cerro de las Rosas) ya existe: ' + @suc_1_uuid;
END

/* =========================================
   4) Zonas de Sucursal 1: Cerro de las Rosas
   ========================================= */

-- Usar los UUIDs fijos definidos arriba
-- Salón Principal: 60 comensales
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_salon_principal)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_salon_principal, 60, 1, 1);
    PRINT 'Zona Salón Principal insertada para Sucursal 1';
END

-- Patio: 30 comensales
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_patio)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_patio, 30, 1, 1);
    PRINT 'Zona Patio insertada para Sucursal 1';
END

/* =========================================
   5) Turnos de Sucursal 1: Cerro de las Rosas
   ========================================= */

DECLARE @hora TIME = '19:00';
DECLARE @hora_hasta TIME;
DECLARE @i INT = 0;

WHILE @i < 4
BEGIN
    SET @hora_hasta = CAST(DATEADD(MINUTE, 120, CAST(@hora AS DATETIME)) AS TIME);
    
    IF NOT EXISTS (SELECT 1 FROM turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND hora_desde = @hora)
    BEGIN
        INSERT INTO turnos_sucursales (nro_restaurante, nro_sucursal, hora_desde, hora_hasta, habilitado)
        VALUES (@rest_uuid, @suc_1_uuid, @hora, @hora_hasta, 1);
        
        -- Zonas por turno
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_salon_principal AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_salon_principal, @hora, 1);
            
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_patio AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_patio, @hora, 1);
    END
    
    SET @hora = @hora_hasta;
    SET @i = @i + 1;
END

PRINT 'Turnos y zonas por turno insertados para Sucursal 1';

/* =========================================
   6) Tipos de comida, especialidades y estilos para Sucursal 1
   ========================================= */

DECLARE @nro_tipo_americana VARCHAR(36), @nro_tipo_fastfood VARCHAR(36);
SELECT @nro_tipo_americana = nro_tipo_comida FROM tipos_comidas WHERE nom_tipo_comida='Americana';
SELECT @nro_tipo_fastfood = nro_tipo_comida FROM tipos_comidas WHERE nom_tipo_comida='Fast food gourmet';

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_tipo_comida = @nro_tipo_americana)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_tipo_americana, 1);

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_tipo_comida = @nro_tipo_fastfood)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_tipo_fastfood, 1);

DECLARE @nro_estilo_casual VARCHAR(36);
SELECT @nro_estilo_casual = nro_estilo FROM estilos WHERE nom_estilo='Casual';

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_estilo = @nro_estilo_casual)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_estilo_casual, 1);

PRINT 'Tipos de comida y estilos insertados para Sucursal 1';

/* =========================================
   Resumen
   ========================================= */

PRINT '';
PRINT '========================================';
PRINT 'LA FÁBRICA BURGER INSERTADO EXITOSAMENTE';
PRINT '========================================';
PRINT 'Restaurante UUID: ' + @rest_uuid;
PRINT 'Sucursales: 1 (Cerro de las Rosas)';
PRINT 'Zonas: 2 (Salón Principal, Patio)';
PRINT 'Turnos: 4';
PRINT 'Zonas por turno: 8';
PRINT '========================================';
GO

