/* =========================================================================================
   INSERT DE DATOS PARA HORARIOS DISPONIBLES - das_restaurante_soap
   Asegura que existan zonas, turnos y su relación para la sucursal de prueba
   ========================================================================================= */

SET NOCOUNT ON;
GO

USE das_restaurante_soap;
GO

/* =========================================
   Parámetros
   ========================================= */
DECLARE @nro_restaurante VARCHAR(36) = '12345678-1234-1234-1234-123456789abc';
DECLARE @nom_sucursal NVARCHAR(120) = N'Los Aroza - Centro';
DECLARE @nro_sucursal VARCHAR(36);

-- Buscar la sucursal por nombre
SELECT @nro_sucursal = nro_sucursal 
FROM sucursales 
WHERE nro_restaurante = @nro_restaurante 
  AND nom_sucursal = @nom_sucursal;

IF @nro_sucursal IS NULL
BEGIN
    RAISERROR('Error: No se encontró la sucursal "%s" para el restaurante. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1, @nom_sucursal);
    RETURN;
END

PRINT '========================================';
PRINT 'INSERTANDO DATOS PARA HORARIOS DISPONIBLES';
PRINT '========================================';
PRINT 'Restaurante: ' + @nro_restaurante;
PRINT 'Sucursal: ' + @nom_sucursal + ' (' + @nro_sucursal + ')';
PRINT '';

/* =========================================
   1) Verificar/crear zonas base si no existen
   ========================================= */
PRINT '1. Verificando zonas base...';
IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona = 'Salón Principal')
BEGIN
    INSERT INTO zonas (nom_zona) VALUES ('Salón Principal');
    PRINT '   ✓ Zona "Salón Principal" creada';
END
ELSE
    PRINT '   ✓ Zona "Salón Principal" ya existe';

IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona = 'Terraza')
BEGIN
    INSERT INTO zonas (nom_zona) VALUES ('Terraza');
    PRINT '   ✓ Zona "Terraza" creada';
END
ELSE
    PRINT '   ✓ Zona "Terraza" ya existe';

/* =========================================
   2) Obtener IDs de zonas
   ========================================= */
DECLARE @cod_zona_salon VARCHAR(36);
DECLARE @cod_zona_terraza VARCHAR(36);
SELECT @cod_zona_salon = cod_zona FROM zonas WHERE nom_zona = 'Salón Principal';
SELECT @cod_zona_terraza = cod_zona FROM zonas WHERE nom_zona = 'Terraza';

IF @cod_zona_salon IS NULL OR @cod_zona_terraza IS NULL
BEGIN
    RAISERROR('Error: No se pudieron obtener los IDs de las zonas', 16, 1);
    RETURN;
END

/* =========================================
   3) Verificar/crear zonas_sucursales
   ========================================= */
PRINT '';
PRINT '2. Verificando zonas de la sucursal...';

-- Verificar que la sucursal existe
IF NOT EXISTS (SELECT 1 FROM sucursales 
               WHERE nro_restaurante = @nro_restaurante 
                 AND nro_sucursal = @nro_sucursal)
BEGIN
    RAISERROR('Error: La sucursal no existe. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1);
    RETURN;
END

-- Salón Principal
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales 
               WHERE nro_restaurante = @nro_restaurante 
                 AND nro_sucursal = @nro_sucursal 
                 AND cod_zona = @cod_zona_salon)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@nro_restaurante, @nro_sucursal, @cod_zona_salon, 80, 1, 1);
    PRINT '   ✓ Zona "Salón Principal" agregada a sucursal (80 comensales)';
END
ELSE
    PRINT '   ✓ Zona "Salón Principal" ya está en la sucursal';

-- Terraza
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales 
               WHERE nro_restaurante = @nro_restaurante 
                 AND nro_sucursal = @nro_sucursal 
                 AND cod_zona = @cod_zona_terraza)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@nro_restaurante, @nro_sucursal, @cod_zona_terraza, 60, 1, 1);
    PRINT '   ✓ Zona "Terraza" agregada a sucursal (60 comensales)';
END
ELSE
    PRINT '   ✓ Zona "Terraza" ya está en la sucursal';

/* =========================================
   4) Crear turnos (cada 2 horas desde 16:00 hasta 22:00)
   ========================================= */
PRINT '';
PRINT '3. Creando turnos...';
DECLARE @hora TIME = '16:00';
DECLARE @hora_hasta TIME;
DECLARE @i INT = 0;

WHILE @i < 4
BEGIN
    SET @hora_hasta = CAST(DATEADD(MINUTE, 120, CAST(@hora AS DATETIME)) AS TIME);
    
    IF NOT EXISTS (SELECT 1 FROM turnos_sucursales 
                   WHERE nro_restaurante = @nro_restaurante 
                     AND nro_sucursal = @nro_sucursal 
                     AND hora_desde = @hora)
    BEGIN
        INSERT INTO turnos_sucursales (nro_restaurante, nro_sucursal, hora_desde, hora_hasta, habilitado)
        VALUES (@nro_restaurante, @nro_sucursal, @hora, @hora_hasta, 1);
        PRINT '   ✓ Turno creado: ' + CAST(@hora AS VARCHAR) + ' - ' + CAST(@hora_hasta AS VARCHAR);
    END
    ELSE
        PRINT '   ✓ Turno ya existe: ' + CAST(@hora AS VARCHAR) + ' - ' + CAST(@hora_hasta AS VARCHAR);
    
    SET @hora = @hora_hasta;
    SET @i = @i + 1;
END

/* =========================================
   5) Crear relación zonas_turnos_sucursales (todas las zonas en todos los turnos)
   ========================================= */
PRINT '';
PRINT '4. Creando relación zonas x turnos...';
DECLARE @hora_turno TIME = '16:00';
DECLARE @j INT = 0;

WHILE @j < 4
BEGIN
    SET @hora_hasta = CAST(DATEADD(MINUTE, 120, CAST(@hora_turno AS DATETIME)) AS TIME);
    
    -- Salón Principal
    IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales 
                   WHERE nro_restaurante = @nro_restaurante 
                     AND nro_sucursal = @nro_sucursal 
                     AND cod_zona = @cod_zona_salon 
                     AND hora_desde = @hora_turno)
    BEGIN
        INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
        VALUES (@nro_restaurante, @nro_sucursal, @cod_zona_salon, @hora_turno, 1);
        PRINT '   ✓ Relación creada: Salón Principal - ' + CAST(@hora_turno AS VARCHAR);
    END
    
    -- Terraza
    IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales 
                   WHERE nro_restaurante = @nro_restaurante 
                     AND nro_sucursal = @nro_sucursal 
                     AND cod_zona = @cod_zona_terraza 
                     AND hora_desde = @hora_turno)
    BEGIN
        INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
        VALUES (@nro_restaurante, @nro_sucursal, @cod_zona_terraza, @hora_turno, 1);
        PRINT '   ✓ Relación creada: Terraza - ' + CAST(@hora_turno AS VARCHAR);
    END
    
    SET @hora_turno = @hora_hasta;
    SET @j = @j + 1;
END

/* =========================================
   6) Verificación final
   ========================================= */
PRINT '';
PRINT '5. Verificación final...';
DECLARE @total_relaciones INT;
SELECT @total_relaciones = COUNT(*)
FROM zonas_turnos_sucursales zts
JOIN zonas_sucursales zs ON zs.nro_restaurante = zts.nro_restaurante 
                         AND zs.nro_sucursal = zts.nro_sucursal 
                         AND zs.cod_zona = zts.cod_zona
JOIN turnos_sucursales t ON t.nro_restaurante = zts.nro_restaurante 
                         AND t.nro_sucursal = zts.nro_sucursal 
                         AND t.hora_desde = zts.hora_desde
WHERE zts.nro_restaurante = @nro_restaurante 
  AND zts.nro_sucursal = @nro_sucursal
  AND t.habilitado = 1
  AND zs.habilitada = 1;

PRINT '   Total relaciones zonas x turnos habilitadas: ' + CAST(@total_relaciones AS VARCHAR);

PRINT '';
PRINT '========================================';
PRINT 'DATOS INSERTADOS EXITOSAMENTE';
PRINT '========================================';
PRINT '';
PRINT 'Ahora puedes probar el endpoint con:';
PRINT 'GET /api/restaurantes/' + @nro_restaurante + '/sucursales/' + @nro_sucursal + '/horarios-disponibles?fecha=2025-11-05';
PRINT '';
GO

