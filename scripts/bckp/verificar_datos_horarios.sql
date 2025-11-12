-- Script para verificar y diagnosticar por qué no hay horarios disponibles
-- Ejecutar en la BD das_restaurante_soap

USE das_restaurante_soap;
GO

DECLARE @nro_restaurante VARCHAR(36) = '12345678-1234-1234-1234-123456789abc';
DECLARE @nro_sucursal VARCHAR(36) = '919ABC05-9FEC-4D8B-B380-956D9AD35ACE';
DECLARE @fecha DATE = '2025-11-05';

PRINT '========================================';
PRINT 'VERIFICACIÓN DE DATOS PARA HORARIOS';
PRINT '========================================';
PRINT '';

-- 1. Verificar que el restaurante existe
PRINT '1. Verificando restaurante...';
IF EXISTS (SELECT 1 FROM restaurantes WHERE nro_restaurante = @nro_restaurante)
    PRINT '   ✓ Restaurante existe';
ELSE
    PRINT '   ✗ Restaurante NO existe';

-- 2. Verificar que la sucursal existe
PRINT '2. Verificando sucursal...';
IF EXISTS (SELECT 1 FROM sucursales WHERE nro_restaurante = @nro_restaurante AND nro_sucursal = @nro_sucursal)
BEGIN
    PRINT '   ✓ Sucursal existe';
    SELECT nom_sucursal, total_comensales FROM sucursales 
    WHERE nro_restaurante = @nro_restaurante AND nro_sucursal = @nro_sucursal;
END
ELSE
    PRINT '   ✗ Sucursal NO existe';

-- 3. Verificar zonas de la sucursal
PRINT '3. Verificando zonas de la sucursal...';
SELECT 
    z.nom_zona,
    zs.cant_comensales,
    zs.permite_menores,
    zs.habilitada,
    zs.cod_zona
FROM zonas_sucursales zs
JOIN zonas z ON z.cod_zona = zs.cod_zona
WHERE zs.nro_restaurante = @nro_restaurante 
  AND zs.nro_sucursal = @nro_sucursal;

IF @@ROWCOUNT = 0
    PRINT '   ✗ No hay zonas configuradas para esta sucursal';
ELSE
    PRINT '   ✓ Zonas encontradas: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- 4. Verificar turnos de la sucursal
PRINT '4. Verificando turnos de la sucursal...';
SELECT 
    hora_desde,
    hora_hasta,
    habilitado
FROM turnos_sucursales
WHERE nro_restaurante = @nro_restaurante 
  AND nro_sucursal = @nro_sucursal;

IF @@ROWCOUNT = 0
    PRINT '   ✗ No hay turnos configurados para esta sucursal';
ELSE
    PRINT '   ✓ Turnos encontrados: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- 5. Verificar relación zonas_turnos_sucursales
PRINT '5. Verificando relación zonas x turnos...';
SELECT 
    z.nom_zona,
    zts.hora_desde,
    t.hora_hasta,
    zts.permite_menores
FROM zonas_turnos_sucursales zts
JOIN zonas_sucursales zs ON zs.nro_restaurante = zts.nro_restaurante 
                         AND zs.nro_sucursal = zts.nro_sucursal 
                         AND zs.cod_zona = zts.cod_zona
JOIN zonas z ON z.cod_zona = zts.cod_zona
JOIN turnos_sucursales t ON t.nro_restaurante = zts.nro_restaurante 
                         AND t.nro_sucursal = zts.nro_sucursal 
                         AND t.hora_desde = zts.hora_desde
WHERE zts.nro_restaurante = @nro_restaurante 
  AND zts.nro_sucursal = @nro_sucursal;

IF @@ROWCOUNT = 0
    PRINT '   ✗ No hay relación zonas x turnos configurada';
ELSE
    PRINT '   ✓ Relaciones encontradas: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- 6. Ejecutar el stored procedure directamente
PRINT '';
PRINT '6. Ejecutando stored procedure get_horarios_disponibles...';
EXEC get_horarios_disponibles 
    @nro_restaurante = @nro_restaurante,
    @nro_sucursal = @nro_sucursal,
    @cod_zona = NULL,
    @fecha = @fecha,
    @cantidad = NULL,
    @incluirCero = 0;

PRINT '';
PRINT '========================================';
PRINT 'FIN DE VERIFICACIÓN';
PRINT '========================================';
GO

