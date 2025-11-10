/* =========================================================================================
   INSERT DE DATOS AVANZADOS - das_restaurante_soap
   Incluye: Verificación de zonas sincronizadas y 2 PROMOCIONES para el restaurante compartido
   IMPORTANTE: Este script debe ejecutarse después de 04_insert_datos_avanzados.sql de das_ristorino
   ========================================================================================= */

SET NOCOUNT ON;
GO

USE das_restaurante_soap;
GO

/* =========================================
   1) Verificación de Zonas Sincronizadas
   ========================================= */

-- Restaurante compartido (Los Aroza) - UUID compartido
DECLARE @restaurante_compartido_uuid VARCHAR(36) = '12345678-1234-1234-1234-123456789abc';
DECLARE @nro_sucursal VARCHAR(36);
SELECT @nro_sucursal = nro_sucursal FROM sucursales 
WHERE nro_restaurante = @restaurante_compartido_uuid AND nom_sucursal = 'Los Aroza - Centro';

IF @nro_sucursal IS NULL
BEGIN
    PRINT 'ERROR: No se encontró la sucursal del restaurante compartido. Ejecutar primero 03_insert_datos_basicos.sql';
    RETURN;
END

-- Verificar que las zonas coincidan con das_ristorino
DECLARE @cod_zona_salon VARCHAR(36), @cod_zona_terraza VARCHAR(36);
SELECT @cod_zona_salon = cod_zona FROM zonas WHERE nom_zona = 'Salón Principal';
SELECT @cod_zona_terraza = cod_zona FROM zonas WHERE nom_zona = 'Terraza';

-- Verificar Salón Principal (debe tener 80 comensales)
IF EXISTS (SELECT 1 FROM zonas_sucursales 
           WHERE nro_restaurante = @restaurante_compartido_uuid 
           AND nro_sucursal = @nro_sucursal 
           AND cod_zona = @cod_zona_salon)
BEGIN
    DECLARE @cant_salon INT;
    SELECT @cant_salon = cant_comensales FROM zonas_sucursales 
    WHERE nro_restaurante = @restaurante_compartido_uuid 
    AND nro_sucursal = @nro_sucursal 
    AND cod_zona = @cod_zona_salon;
    
    IF @cant_salon != 80
    BEGIN
        UPDATE zonas_sucursales 
        SET cant_comensales = 80 
        WHERE nro_restaurante = @restaurante_compartido_uuid 
        AND nro_sucursal = @nro_sucursal 
        AND cod_zona = @cod_zona_salon;
        PRINT 'Zona Salón Principal actualizada a 80 comensales (sincronizada con das_ristorino)';
    END
    ELSE
        PRINT 'Zona Salón Principal ya está sincronizada (80 comensales)';
END
ELSE
BEGIN
    -- Insertar si no existe
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@restaurante_compartido_uuid, @nro_sucursal, @cod_zona_salon, 80, 1, 1);
    PRINT 'Zona Salón Principal insertada (80 comensales)';
END

-- Verificar Terraza (debe tener 60 comensales)
IF EXISTS (SELECT 1 FROM zonas_sucursales 
           WHERE nro_restaurante = @restaurante_compartido_uuid 
           AND nro_sucursal = @nro_sucursal 
           AND cod_zona = @cod_zona_terraza)
BEGIN
    DECLARE @cant_terraza INT;
    SELECT @cant_terraza = cant_comensales FROM zonas_sucursales 
    WHERE nro_restaurante = @restaurante_compartido_uuid 
    AND nro_sucursal = @nro_sucursal 
    AND cod_zona = @cod_zona_terraza;
    
    IF @cant_terraza != 60
    BEGIN
        UPDATE zonas_sucursales 
        SET cant_comensales = 60 
        WHERE nro_restaurante = @restaurante_compartido_uuid 
        AND nro_sucursal = @nro_sucursal 
        AND cod_zona = @cod_zona_terraza;
        PRINT 'Zona Terraza actualizada a 60 comensales (sincronizada con das_ristorino)';
    END
    ELSE
        PRINT 'Zona Terraza ya está sincronizada (60 comensales)';
END
ELSE
BEGIN
    -- Insertar si no existe
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@restaurante_compartido_uuid, @nro_sucursal, @cod_zona_terraza, 60, 1, 1);
    PRINT 'Zona Terraza insertada (60 comensales)';
END

PRINT 'Zonas verificadas y sincronizadas con das_ristorino';

/* =========================================
   2) PROMOCIONES para el Restaurante Compartido
   IMPORTANTE: Estas deben coincidir con las de das_ristorino
   ========================================= */

-- Promoción 1: Descuento especial de temporada
-- NOTA: El nro_contenido debe ser el mismo que en das_ristorino para mantener sincronización
-- Por ahora usamos NEWID() pero idealmente debería venir de das_ristorino
DECLARE @nro_contenido_1 VARCHAR(36) = NEWID();
DECLARE @fecha_ini DATE = CAST(GETDATE() AS DATE);
DECLARE @fecha_fin DATE = DATEADD(MONTH, 1, @fecha_ini);

IF NOT EXISTS (SELECT 1 FROM contenidos 
               WHERE nro_restaurante = @restaurante_compartido_uuid 
               AND contenido_a_publicar LIKE '%Descuento especial de temporada%')
BEGIN
    -- Usar el stored procedure para insertar (como lo hace el sistema)
    DECLARE @resultado1 TABLE (
        nro_contenido VARCHAR(36),
        exitoso BIT,
        mensaje NVARCHAR(200)
    );
    
    INSERT INTO @resultado1
    EXEC sp_registrar_contenido
        @nro_restaurante = @restaurante_compartido_uuid,
        @nro_sucursal = @nro_sucursal,
        @contenido_a_publicar = '¡Descuento especial de temporada! 20% OFF en todos los platos principales. Válido de lunes a jueves. Reservá tu mesa ahora.',
        @imagen_a_publicar = NULL,
        @costo_click = 0.50;
    
    SELECT @nro_contenido_1 = nro_contenido FROM @resultado1;
    PRINT 'Promoción 1 insertada en das_restaurante_soap: ' + @nro_contenido_1;
END
ELSE
BEGIN
    SELECT @nro_contenido_1 = nro_contenido FROM contenidos 
    WHERE nro_restaurante = @restaurante_compartido_uuid 
    AND contenido_a_publicar LIKE '%Descuento especial de temporada%';
    PRINT 'Promoción 1 ya existe en das_restaurante_soap: ' + @nro_contenido_1;
END

-- Promoción 2: Menú ejecutivo
DECLARE @nro_contenido_2 VARCHAR(36) = NEWID();

IF NOT EXISTS (SELECT 1 FROM contenidos 
               WHERE nro_restaurante = @restaurante_compartido_uuid 
               AND contenido_a_publicar LIKE '%Menú ejecutivo%')
BEGIN
    DECLARE @resultado2 TABLE (
        nro_contenido VARCHAR(36),
        exitoso BIT,
        mensaje NVARCHAR(200)
    );
    
    INSERT INTO @resultado2
    EXEC sp_registrar_contenido
        @nro_restaurante = @restaurante_compartido_uuid,
        @nro_sucursal = @nro_sucursal,
        @contenido_a_publicar = 'Menú ejecutivo de lunes a viernes. Entrada + plato principal + postre por $3500. Incluye bebida sin alcohol. ¡No te lo pierdas!',
        @imagen_a_publicar = NULL,
        @costo_click = 0.75;
    
    SELECT @nro_contenido_2 = nro_contenido FROM @resultado2;
    PRINT 'Promoción 2 insertada en das_restaurante_soap: ' + @nro_contenido_2;
END
ELSE
BEGIN
    SELECT @nro_contenido_2 = nro_contenido FROM contenidos 
    WHERE nro_restaurante = @restaurante_compartido_uuid 
    AND contenido_a_publicar LIKE '%Menú ejecutivo%';
    PRINT 'Promoción 2 ya existe en das_restaurante_soap: ' + @nro_contenido_2;
END

/* =========================================
   Resumen
   ========================================= */

PRINT '========================================';
PRINT 'Datos avanzados insertados exitosamente en das_restaurante_soap';
PRINT '========================================';
PRINT '- Zonas: Verificadas y sincronizadas con das_ristorino';
PRINT '  * Salón Principal: 80 comensales';
PRINT '  * Terraza: 60 comensales';
PRINT '- Promociones: 2 promociones creadas para el restaurante compartido';
PRINT '  * Promoción 1: Descuento especial de temporada';
PRINT '  * Promoción 2: Menú ejecutivo';
PRINT '========================================';
PRINT 'NOTA: Los nro_contenido pueden diferir entre bases de datos';
PRINT '      pero el contenido debe ser el mismo para mantener sincronización';
PRINT '========================================';
GO

