/* =========================================================================================
   INSERT DE DATOS: La Bella Pizza (REST)
   Base de Datos: das_restaurante
   UUID del Restaurante: BELLA-PIZZA-1111-1111-1111-111111111111
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

IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Alta Córdoba' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Alta Córdoba', @cod_cba);

IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='General Paz' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('General Paz', @cod_cba);

-- Zonas (UUIDs fijos - ya insertadas por 03_insert_datos_basicos.sql)
-- Solo obtener los UUIDs, no insertar (las zonas ya están en el catálogo)
DECLARE @cod_zona_salon_principal VARCHAR(36) = 'ZONA-SALON-PRINCIPAL-0001-0001-0001-0001';
DECLARE @cod_zona_terraza VARCHAR(36) = 'ZONA-TERRAZA-0001-0001-0001-0001';
DECLARE @cod_zona_patio VARCHAR(36) = 'ZONA-PATIO-0001-0001-0001-0001';

-- Verificar que las zonas existan (deben estar insertadas por 03_insert_datos_basicos.sql)
IF NOT EXISTS (SELECT 1 FROM zonas WHERE cod_zona = @cod_zona_salon_principal)
BEGIN
    RAISERROR('Error: La zona "Salón Principal" no existe. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1);
    RETURN;
END

IF NOT EXISTS (SELECT 1 FROM zonas WHERE cod_zona = @cod_zona_terraza)
BEGIN
    RAISERROR('Error: La zona "Terraza" no existe. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1);
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
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Italiana')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Italiana');

IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Pizzería')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Pizzería');

-- Estilos
IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Casual')
    INSERT INTO estilos (nom_estilo) VALUES ('Casual');

IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Familiar')
    INSERT INTO estilos (nom_estilo) VALUES ('Familiar');

PRINT 'Catálogos base verificados/creados';

/* =========================================
   2) Restaurante: La Bella Pizza
   ========================================= */

DECLARE @rest_uuid VARCHAR(36) = 'BELLA-PIZZA-1111-1111-1111-111111111111';

IF NOT EXISTS (SELECT 1 FROM restaurantes WHERE nro_restaurante = @rest_uuid)
BEGIN
    INSERT INTO restaurantes (nro_restaurante, razon_social, cuit)
    VALUES (@rest_uuid, 'La Bella Pizza SRL', '30123456789');
    PRINT 'Restaurante La Bella Pizza insertado';
END
ELSE
BEGIN
    PRINT 'Restaurante La Bella Pizza ya existe';
END

/* =========================================
   3) Sucursal 1: Alta Córdoba
   ========================================= */

DECLARE @nro_localidad_alta_cordoba VARCHAR(36);
SELECT @nro_localidad_alta_cordoba = nro_localidad FROM localidades WHERE nom_localidad='Alta Córdoba' AND cod_provincia=@cod_cba;

DECLARE @nro_categoria_media VARCHAR(36);
SELECT @nro_categoria_media = nro_categoria FROM categorias_precios WHERE nom_categoria='Media';

-- UUID fijo para Sucursal 1: Alta Córdoba
DECLARE @suc_1_uuid VARCHAR(36) = 'BELLA-PIZZA-SUC-0001-0001-0001-0001';
IF NOT EXISTS (SELECT 1 FROM sucursales WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'La Bella Pizza - Alta Córdoba')
BEGIN
    INSERT INTO sucursales (
        nro_restaurante, nro_sucursal, nom_sucursal, calle, nro_calle, barrio,
        nro_localidad, cod_postal, telefonos, total_comensales, min_tolerencia_reserva, nro_categoria
    )
    VALUES (
        @rest_uuid, @suc_1_uuid, 'La Bella Pizza - Alta Córdoba',
        'Av. Colón', 2500, 'Alta Córdoba',
        @nro_localidad_alta_cordoba, '5000', '351-555-1001', 80, 15, @nro_categoria_media
    );
    PRINT 'Sucursal 1 (Alta Córdoba) insertada: ' + @suc_1_uuid;
END
ELSE
BEGIN
    UPDATE sucursales SET nro_sucursal = @suc_1_uuid
    WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'La Bella Pizza - Alta Córdoba' AND nro_sucursal != @suc_1_uuid;
    PRINT 'Sucursal 1 (Alta Córdoba) ya existe: ' + @suc_1_uuid;
END

/* =========================================
   4) Zonas de Sucursal 1: Alta Córdoba
   ========================================= */

-- Usar los UUIDs fijos definidos arriba
-- Salón Principal: 50 comensales
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_salon_principal)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_salon_principal, 50, 1, 1);
    PRINT 'Zona Salón Principal insertada para Sucursal 1';
END

-- Terraza: 30 comensales
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_terraza)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_terraza, 30, 1, 1);
    PRINT 'Zona Terraza insertada para Sucursal 1';
END

/* =========================================
   5) Turnos de Sucursal 1: Alta Córdoba
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
            
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_terraza AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_terraza, @hora, 1);
    END
    
    SET @hora = @hora_hasta;
    SET @i = @i + 1;
END

PRINT 'Turnos y zonas por turno insertados para Sucursal 1';

/* =========================================
   6) Tipos de comida, especialidades y estilos para Sucursal 1
   ========================================= */

DECLARE @nro_tipo_italiana VARCHAR(36), @nro_tipo_pizzeria VARCHAR(36);
SELECT @nro_tipo_italiana = nro_tipo_comida FROM tipos_comidas WHERE nom_tipo_comida='Italiana';
SELECT @nro_tipo_pizzeria = nro_tipo_comida FROM tipos_comidas WHERE nom_tipo_comida='Pizzería';

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_tipo_comida = @nro_tipo_italiana)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_tipo_italiana, 1);

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_tipo_comida = @nro_tipo_pizzeria)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_tipo_pizzeria, 1);

DECLARE @nro_estilo_casual VARCHAR(36), @nro_estilo_familiar VARCHAR(36);
SELECT @nro_estilo_casual = nro_estilo FROM estilos WHERE nom_estilo='Casual';
SELECT @nro_estilo_familiar = nro_estilo FROM estilos WHERE nom_estilo='Familiar';

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_estilo = @nro_estilo_casual)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_estilo_casual, 1);

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_estilo = @nro_estilo_familiar)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_estilo_familiar, 1);

PRINT 'Tipos de comida y estilos insertados para Sucursal 1';

/* =========================================
   7) Sucursal 2: General Paz
   ========================================= */

DECLARE @nro_localidad_general_paz VARCHAR(36);
SELECT @nro_localidad_general_paz = nro_localidad FROM localidades WHERE nom_localidad='General Paz' AND cod_provincia=@cod_cba;

-- UUID fijo para Sucursal 2: General Paz
DECLARE @suc_2_uuid VARCHAR(36) = 'BELLA-PIZZA-SUC-0002-0002-0002-0002';
IF NOT EXISTS (SELECT 1 FROM sucursales WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'La Bella Pizza - General Paz')
BEGIN
    INSERT INTO sucursales (
        nro_restaurante, nro_sucursal, nom_sucursal, calle, nro_calle, barrio,
        nro_localidad, cod_postal, telefonos, total_comensales, min_tolerencia_reserva, nro_categoria
    )
    VALUES (
        @rest_uuid, @suc_2_uuid, 'La Bella Pizza - General Paz',
        'Av. General Paz', 800, 'General Paz',
        @nro_localidad_general_paz, '5000', '351-555-1002', 60, 15, @nro_categoria_media
    );
    PRINT 'Sucursal 2 (General Paz) insertada: ' + @suc_2_uuid;
END
ELSE
BEGIN
    UPDATE sucursales SET nro_sucursal = @suc_2_uuid
    WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'La Bella Pizza - General Paz' AND nro_sucursal != @suc_2_uuid;
    PRINT 'Sucursal 2 (General Paz) ya existe: ' + @suc_2_uuid;
END

/* =========================================
   8) Zonas de Sucursal 2: General Paz
   ========================================= */

-- Salón Principal: 40 comensales (usar UUID fijo de zona compartida)
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND cod_zona = @cod_zona_salon_principal)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_2_uuid, @cod_zona_salon_principal, 40, 1, 1);
    PRINT 'Zona Salón Principal insertada para Sucursal 2';
END

-- Patio: 20 comensales
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND cod_zona = @cod_zona_patio)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_2_uuid, @cod_zona_patio, 20, 1, 1);
    PRINT 'Zona Patio insertada para Sucursal 2';
END

/* =========================================
   9) Turnos de Sucursal 2: General Paz
   ========================================= */

SET @hora = '19:00';
SET @i = 0;

WHILE @i < 3
BEGIN
    SET @hora_hasta = CAST(DATEADD(MINUTE, 120, CAST(@hora AS DATETIME)) AS TIME);
    
    IF NOT EXISTS (SELECT 1 FROM turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND hora_desde = @hora)
    BEGIN
        INSERT INTO turnos_sucursales (nro_restaurante, nro_sucursal, hora_desde, hora_hasta, habilitado)
        VALUES (@rest_uuid, @suc_2_uuid, @hora, @hora_hasta, 1);
        
        -- Zonas por turno
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND cod_zona = @cod_zona_salon_principal AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@rest_uuid, @suc_2_uuid, @cod_zona_salon_principal, @hora, 1);
            
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND cod_zona = @cod_zona_patio AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@rest_uuid, @suc_2_uuid, @cod_zona_patio, @hora, 1);
    END
    
    SET @hora = @hora_hasta;
    SET @i = @i + 1;
END

PRINT 'Turnos y zonas por turno insertados para Sucursal 2';

/* =========================================
   10) Tipos de comida y estilos para Sucursal 2
   ========================================= */

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_tipo_comida = @nro_tipo_italiana)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_tipo_italiana, 1);

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_tipo_comida = @nro_tipo_pizzeria)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_tipo_pizzeria, 1);

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_estilo = @nro_estilo_casual)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_estilo_casual, 1);

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_estilo = @nro_estilo_familiar)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_estilo_familiar, 1);

PRINT 'Tipos de comida y estilos insertados para Sucursal 2';

/* =========================================
   Resumen
   ========================================= */

PRINT '';
PRINT '========================================';
PRINT 'LA BELLA PIZZA INSERTADO EXITOSAMENTE';
PRINT '========================================';
PRINT 'Restaurante UUID: ' + @rest_uuid;
PRINT 'Sucursales: 2 (Alta Córdoba, General Paz)';
PRINT 'Zonas: 4 (2 por sucursal)';
PRINT 'Turnos: 7 (4 en Sucursal 1, 3 en Sucursal 2)';
PRINT 'Zonas por turno: 14';
PRINT '========================================';
GO
