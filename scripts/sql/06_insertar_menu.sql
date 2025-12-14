DECLARE @nro_restaurante VARCHAR(36) = 'BELLA-PIZZA-1111-1111-1111-111111111'; -- GUID real
DECLARE @nro_sucursal    VARCHAR(36) = 'BELLA-PIZZA-SUC-0001-0001-0001-0001'; -- GUID real
DECLARE @ruta_literal    NVARCHAR(4000) = N'C:\Users\Usuario\Desktop\2025\menuBellaPizza.pdf';-- ruta en el servidor
DECLARE @nombre_archivo  NVARCHAR(255) = N'menuBellaPizza.pdf';
DECLARE @tipo_mime       NVARCHAR(100) = N'application/pdf';

-- Variables de carga
DECLARE @datos_archivo  VARBINARY(MAX);
DECLARE @tamano_bytes   BIGINT;

-- 1) Crear tabla temporal para el BLOB
IF OBJECT_ID('tempdb..#tmp_blob') IS NOT NULL DROP TABLE #tmp_blob;
CREATE TABLE #tmp_blob (BulkColumn VARBINARY(MAX));

-- 2) Armar SQL dinámico con la ruta literal (doble comilla simple para escapar)
DECLARE @sql NVARCHAR(MAX) =
    N'INSERT INTO #tmp_blob(BulkColumn)
      SELECT BulkColumn
      FROM OPENROWSET(BULK ''' + REPLACE(@ruta_literal,'''','''''') + N''', SINGLE_BLOB) AS archivo;';

EXEC (@sql);

-- 3) Pasar a variable y calcular tamaño
SELECT @datos_archivo = BulkColumn FROM #tmp_blob;
SET @tamano_bytes = DATALENGTH(@datos_archivo);

-- 4) Subir menú (devuelve nro_menu)
EXEC dbo.sp_menu_subir
     @nro_restaurante = @nro_restaurante,
     @nro_sucursal    = @nro_sucursal,
     @nombre_archivo  = @nombre_archivo,
     @tipo_mime       = @tipo_mime,
     @tamano_bytes    = @tamano_bytes,
     @hash_sha256     = NULL,
     @datos_archivo   = @datos_archivo;

-- 5) Activar el último subido
DECLARE @nro_menu BIGINT;

SELECT TOP 1 @nro_menu = nro_menu
FROM dbo.archivos_menu
WHERE nro_restaurante = @nro_restaurante
  AND nro_sucursal    = @nro_sucursal
ORDER BY fecha_creacion DESC;

EXEC dbo.sp_menu_activar @nro_menu = @nro_menu;

-- 6) Verificar activo
EXEC dbo.sp_menu_obtener_activo
     @nro_restaurante = @nro_restaurante,
     @nro_sucursal    = @nro_sucursal;

-- 7) Listar todos
EXEC dbo.sp_menu_listar
     @nro_restaurante = @nro_restaurante,
     @nro_sucursal    = @nro_sucursal;