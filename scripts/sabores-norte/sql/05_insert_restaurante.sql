/* =========================================================================================
   INSERT DE DATOS: Sabores del Norte (SOAP)
   Base de Datos: das_restaurante
   UUID del Restaurante: SABORES-NORTE-4444-4444-4444-444444444444
   Protocolo: SOAP
   ========================================================================================= */

SET NOCOUNT ON;
GO

USE das_sabores_norte;
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

IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Centro' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Centro', @cod_cba);

IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Cerro de las Rosas' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Cerro de las Rosas', @cod_cba);

-- Zonas (UUIDs fijos - ya insertadas por 03_insert_datos_basicos.sql)
-- Solo obtener los UUIDs, no insertar (las zonas ya están en el catálogo)
-- NOTA: Estos UUIDs DEBEN coincidir exactamente con los usados en das_ristorino/scripts/sql/12_insert_restaurantes_examen_final.sql
DECLARE @cod_zona_salon_principal VARCHAR(36) = 'ZONA-SALON-PRINCIPAL-0001-0001-0001-0001';
DECLARE @cod_zona_patio_cubierto VARCHAR(36) = 'ZONA-PATIO-CUBIERTO-0001-0001-0001-0001';
DECLARE @cod_zona_terraza VARCHAR(36) = 'ZONA-TERRAZA-0001-0001-0001-0001';

-- Verificar que las zonas existan (deben estar insertadas por 03_insert_datos_basicos.sql)
IF NOT EXISTS (SELECT 1 FROM zonas WHERE cod_zona = @cod_zona_salon_principal)
BEGIN
    RAISERROR('Error: La zona "Salón Principal" no existe. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1);
    RETURN;
END

IF NOT EXISTS (SELECT 1 FROM zonas WHERE cod_zona = @cod_zona_patio_cubierto)
BEGIN
    RAISERROR('Error: La zona "Patio Cubierto" no existe. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1);
    RETURN;
END

IF NOT EXISTS (SELECT 1 FROM zonas WHERE cod_zona = @cod_zona_terraza)
BEGIN
    RAISERROR('Error: La zona "Terraza" no existe. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1);
    RETURN;
END

-- Categorías de precios
IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Económica')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Económica');

-- Tipos de comidas
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Regional del NOA')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Regional del NOA');

-- Estilos
IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Familiar')
    INSERT INTO estilos (nom_estilo) VALUES ('Familiar');

IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Casual')
    INSERT INTO estilos (nom_estilo) VALUES ('Casual');

PRINT 'Catálogos base verificados/creados';

/* =========================================
   2) Restaurante: Sabores del Norte
   ========================================= */

DECLARE @rest_uuid VARCHAR(36) = 'SABORES-NORTE-4444-4444-4444-444444444444';

IF NOT EXISTS (SELECT 1 FROM restaurantes WHERE nro_restaurante = @rest_uuid)
BEGIN
    INSERT INTO restaurantes (nro_restaurante, razon_social, cuit)
    VALUES (@rest_uuid, 'Sabores del Norte S.A.', '30456789012');
    PRINT 'Restaurante Sabores del Norte insertado';
END
ELSE
BEGIN
    PRINT 'Restaurante Sabores del Norte ya existe';
END

/* =========================================
   3) Sucursal 1: Centro
   ========================================= */

DECLARE @nro_localidad_centro VARCHAR(36);
SELECT @nro_localidad_centro = nro_localidad FROM localidades WHERE nom_localidad='Centro' AND cod_provincia=@cod_cba;

DECLARE @nro_categoria_economica VARCHAR(36);
SELECT @nro_categoria_economica = nro_categoria FROM categorias_precios WHERE nom_categoria='Económica';

-- UUID fijo para Sucursal 1: Centro
DECLARE @suc_1_uuid VARCHAR(36) = 'SABORES-NORTE-SUC-0001-0001-0001-0001';
IF NOT EXISTS (SELECT 1 FROM sucursales WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'Sabores del Norte - Centro')
BEGIN
    INSERT INTO sucursales (
        nro_restaurante, nro_sucursal, nom_sucursal, calle, nro_calle, barrio,
        nro_localidad, cod_postal, telefonos, total_comensales, min_tolerencia_reserva, nro_categoria
    )
    VALUES (
        @rest_uuid, @suc_1_uuid, 'Sabores del Norte - Centro',
        'Av. Colón', 1200, 'Centro',
        @nro_localidad_centro, '5000', '351-555-4001', 110, 20, @nro_categoria_economica
    );
    PRINT 'Sucursal 1 (Centro) insertada: ' + @suc_1_uuid;
END
ELSE
BEGIN
    -- Actualizar UUID si existe pero tiene otro UUID
    UPDATE sucursales SET nro_sucursal = @suc_1_uuid
    WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'Sabores del Norte - Centro' AND nro_sucursal != @suc_1_uuid;
    PRINT 'Sucursal 1 (Centro) ya existe: ' + @suc_1_uuid;
END

/* =========================================
   4) Zonas de Sucursal 1: Centro
   ========================================= */

-- Usar los UUIDs fijos definidos arriba
-- Salón Principal: 70 comensales
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_salon_principal)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_salon_principal, 70, 1, 1);
    PRINT 'Zona Salón Principal insertada para Sucursal 1';
END

-- Patio Cubierto: 40 comensales
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_patio_cubierto)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_patio_cubierto, 40, 1, 1);
    PRINT 'Zona Patio Cubierto insertada para Sucursal 1';
END

/* =========================================
   5) Turnos de Sucursal 1: Centro
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
            
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_patio_cubierto AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_patio_cubierto, @hora, 1);
    END
    
    SET @hora = @hora_hasta;
    SET @i = @i + 1;
END

PRINT 'Turnos y zonas por turno insertados para Sucursal 1';

/* =========================================
   6) Tipos de comida, especialidades y estilos para Sucursal 1
   ========================================= */

DECLARE @nro_tipo_regional VARCHAR(36);
SELECT @nro_tipo_regional = nro_tipo_comida FROM tipos_comidas WHERE nom_tipo_comida='Regional del NOA';

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_tipo_comida = @nro_tipo_regional)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_tipo_regional, 1);

DECLARE @nro_estilo_familiar VARCHAR(36), @nro_estilo_casual VARCHAR(36);
SELECT @nro_estilo_familiar = nro_estilo FROM estilos WHERE nom_estilo='Familiar';
SELECT @nro_estilo_casual = nro_estilo FROM estilos WHERE nom_estilo='Casual';

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_estilo = @nro_estilo_familiar)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_estilo_familiar, 1);

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_estilo = @nro_estilo_casual)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_estilo_casual, 1);

PRINT 'Tipos de comida y estilos insertados para Sucursal 1';

/* =========================================
   7) Sucursal 2: Cerro de las Rosas
   ========================================= */

DECLARE @nro_localidad_cerro VARCHAR(36);
SELECT @nro_localidad_cerro = nro_localidad FROM localidades WHERE nom_localidad='Cerro de las Rosas' AND cod_provincia=@cod_cba;

-- UUID fijo para Sucursal 2: Cerro de las Rosas
DECLARE @suc_2_uuid VARCHAR(36) = 'SABORES-NORTE-SUC-0002-0002-0002-0002';
IF NOT EXISTS (SELECT 1 FROM sucursales WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'Sabores del Norte - Cerro de las Rosas')
BEGIN
    INSERT INTO sucursales (
        nro_restaurante, nro_sucursal, nom_sucursal, calle, nro_calle, barrio,
        nro_localidad, cod_postal, telefonos, total_comensales, min_tolerencia_reserva, nro_categoria
    )
    VALUES (
        @rest_uuid, @suc_2_uuid, 'Sabores del Norte - Cerro de las Rosas',
        'Av. Rafael Núñez', 3800, 'Cerro de las Rosas',
        @nro_localidad_cerro, '5009', '351-555-4002', 85, 20, @nro_categoria_economica
    );
    PRINT 'Sucursal 2 (Cerro de las Rosas) insertada: ' + @suc_2_uuid;
END
ELSE
BEGIN
    -- Actualizar UUID si existe pero tiene otro UUID
    UPDATE sucursales SET nro_sucursal = @suc_2_uuid
    WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'Sabores del Norte - Cerro de las Rosas' AND nro_sucursal != @suc_2_uuid;
    PRINT 'Sucursal 2 (Cerro de las Rosas) ya existe: ' + @suc_2_uuid;
END

/* =========================================
   8) Zonas de Sucursal 2: Cerro de las Rosas
   ========================================= */

-- Salón Principal: 55 comensales (usar UUID fijo de zona compartida)
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND cod_zona = @cod_zona_salon_principal)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_2_uuid, @cod_zona_salon_principal, 55, 1, 1);
    PRINT 'Zona Salón Principal insertada para Sucursal 2';
END

-- Terraza: 30 comensales
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND cod_zona = @cod_zona_terraza)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_2_uuid, @cod_zona_terraza, 30, 1, 1);
    PRINT 'Zona Terraza insertada para Sucursal 2';
END

/* =========================================
   9) Turnos de Sucursal 2: Cerro de las Rosas
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
            
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND cod_zona = @cod_zona_terraza AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@rest_uuid, @suc_2_uuid, @cod_zona_terraza, @hora, 1);
    END
    
    SET @hora = @hora_hasta;
    SET @i = @i + 1;
END

PRINT 'Turnos y zonas por turno insertados para Sucursal 2';

/* =========================================
   10) Tipos de comida y estilos para Sucursal 2
   ========================================= */

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_tipo_comida = @nro_tipo_regional)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_tipo_regional, 1);

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_estilo = @nro_estilo_familiar)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_estilo_familiar, 1);

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_estilo = @nro_estilo_casual)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_estilo_casual, 1);

PRINT 'Tipos de comida y estilos insertados para Sucursal 2';

/* =========================================
   Resumen
   ========================================= */

PRINT '';
PRINT '========================================';
PRINT 'SABORES DEL NORTE INSERTADO EXITOSAMENTE';
PRINT '========================================';
PRINT 'Restaurante UUID: ' + @rest_uuid;
PRINT 'Sucursales: 2 (Centro, Cerro de las Rosas)';
PRINT 'Zonas: 4 (2 por sucursal)';
PRINT 'Turnos: 7 (4 en Sucursal 1, 3 en Sucursal 2)';
PRINT 'Zonas por turno: 14';
PRINT '========================================';
GO

