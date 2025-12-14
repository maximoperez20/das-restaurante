-- Menu files stored in DB (VARBINARY)

IF OBJECT_ID('dbo.menu_files', 'U') IS NOT NULL
    DROP TABLE dbo.menu_files;
GO

IF OBJECT_ID('dbo.archivos_menu', 'U') IS NOT NULL
    DROP TABLE dbo.archivos_menu;
GO

CREATE TABLE dbo.archivos_menu (
    nro_menu        BIGINT IDENTITY(1,1) PRIMARY KEY,
    nro_restaurante VARCHAR(36) NOT NULL,
    nro_sucursal    VARCHAR(36) NOT NULL,
    nombre_archivo  NVARCHAR(255) NOT NULL,
    tipo_mime       NVARCHAR(100) NOT NULL,
    tamano_bytes    BIGINT NOT NULL,
    hash_sha256     CHAR(64) NULL,
    datos_archivo   VARBINARY(MAX) NOT NULL,
    fecha_creacion  DATETIME2 NOT NULL CONSTRAINT DF_archivos_menu_fecha_creacion DEFAULT SYSUTCDATETIME(),
    activo          BIT NOT NULL CONSTRAINT DF_archivos_menu_activo DEFAULT 0
);
GO

-- Unique active per restaurante+sucursal
CREATE UNIQUE INDEX UX_archivos_menu_activo
ON dbo.archivos_menu (nro_restaurante, nro_sucursal, activo)
WHERE activo = 1;
GO

CREATE INDEX IX_archivos_menu_rest_suc ON dbo.archivos_menu (nro_restaurante, nro_sucursal);
GO

CREATE INDEX IX_archivos_menu_hash ON dbo.archivos_menu (hash_sha256);
GO

------------------------------------------------------------------------------
-- Stored procedures
------------------------------------------------------------------------------

IF OBJECT_ID('dbo.sp_menu_subir', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_menu_subir;
GO

CREATE PROCEDURE dbo.sp_menu_subir
    @nro_restaurante VARCHAR(36),
    @nro_sucursal    VARCHAR(36),
    @nombre_archivo  NVARCHAR(255),
    @tipo_mime       NVARCHAR(100),
    @tamano_bytes    BIGINT,
    @hash_sha256     CHAR(64) = NULL,
    @datos_archivo   VARBINARY(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate MIME type (allow pdf and common images)
    IF @tipo_mime NOT IN ('application/pdf', 'image/png', 'image/jpeg')
    BEGIN
        RAISERROR('Tipo de archivo no permitido', 16, 1);
        RETURN;
    END

    -- Size guardrail: 25 MB (adjust as needed)
    IF @tamano_bytes > 25 * 1024 * 1024
    BEGIN
        RAISERROR('Archivo demasiado grande', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.archivos_menu (nro_restaurante, nro_sucursal, nombre_archivo, tipo_mime, tamano_bytes, hash_sha256, datos_archivo)
    VALUES (@nro_restaurante, @nro_sucursal, @nombre_archivo, @tipo_mime, @tamano_bytes, @hash_sha256, @datos_archivo);

    SELECT SCOPE_IDENTITY() AS nro_menu;
END
GO

IF OBJECT_ID('dbo.sp_menu_activar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_menu_activar;
GO

CREATE PROCEDURE dbo.sp_menu_activar
    @nro_menu BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @rest VARCHAR(36), @suc VARCHAR(36);
    SELECT @rest = nro_restaurante, @suc = nro_sucursal FROM dbo.archivos_menu WHERE nro_menu = @nro_menu;
    IF @rest IS NULL OR @suc IS NULL
    BEGIN
        RAISERROR('Menu no encontrado', 16, 1);
        RETURN;
    END

    BEGIN TRAN;
    UPDATE dbo.archivos_menu
    SET activo = 0
    WHERE nro_restaurante = @rest AND nro_sucursal = @suc AND activo = 1;

    UPDATE dbo.archivos_menu
    SET activo = 1
    WHERE nro_menu = @nro_menu;
    COMMIT TRAN;
END
GO

IF OBJECT_ID('dbo.sp_menu_obtener_activo', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_menu_obtener_activo;
GO

CREATE PROCEDURE dbo.sp_menu_obtener_activo
    @nro_restaurante VARCHAR(36),
    @nro_sucursal    VARCHAR(36)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1 nro_menu, nombre_archivo, tipo_mime, tamano_bytes, hash_sha256, datos_archivo, fecha_creacion
    FROM dbo.archivos_menu
    WHERE nro_restaurante = @nro_restaurante AND nro_sucursal = @nro_sucursal AND activo = 1;
END
GO

IF OBJECT_ID('dbo.sp_menu_listar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_menu_listar;
GO

CREATE PROCEDURE dbo.sp_menu_listar
    @nro_restaurante VARCHAR(36),
    @nro_sucursal    VARCHAR(36)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT nro_menu, nombre_archivo, tipo_mime, tamano_bytes, fecha_creacion, activo
    FROM dbo.archivos_menu
    WHERE nro_restaurante = @nro_restaurante AND nro_sucursal = @nro_sucursal
    ORDER BY fecha_creacion DESC;
END
GO
