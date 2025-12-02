/* =========================================================================================
   STORED PROCEDURES - das_perukai
   ========================================================================================= */

USE das_perukai;
GO

-- Este archivo contiene los stored procedures con CREATE OR ALTER
-- Basado en procs.sql original

CREATE OR ALTER PROCEDURE dbo.get_restaurantes
  @q NVARCHAR(150) = NULL   -- búsqueda opcional (razón social o CUIT)
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
      r.nro_restaurante,
      r.razon_social,
      r.cuit
  FROM restaurantes r
  WHERE (@q IS NULL
         OR r.razon_social LIKE '%' + @q + '%'
         OR r.cuit LIKE @q + '%')
  ORDER BY r.razon_social;
END
GO


CREATE OR ALTER PROCEDURE dbo.get_sucursales_x_restaurantes
  @nro_restaurante VARCHAR(36) = NULL,
  @cuit            VARCHAR(11) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- Resolver restaurante si pasaron CUIT
  IF @nro_restaurante IS NULL AND @cuit IS NOT NULL
  BEGIN
    SELECT @nro_restaurante = r.nro_restaurante
    FROM restaurantes r
    WHERE r.cuit = @cuit;
  END

  IF @nro_restaurante IS NULL
  BEGIN
    RAISERROR('Debe indicar @nro_restaurante o @cuit.', 16, 1);
    RETURN;
  END

  SELECT
      s.nro_restaurante,
      s.nro_sucursal,
      s.nom_sucursal,
      s.calle, s.nro_calle, s.barrio,
      s.cod_postal,
      s.telefonos,
      s.total_comensales,
      s.min_tolerencia_reserva,
      cp.nom_categoria      AS categoria_precio,
      l.nom_localidad,
      p.nom_provincia
  FROM sucursales s
  JOIN categorias_precios cp ON cp.nro_categoria = s.nro_categoria
  JOIN localidades l         ON l.nro_localidad  = s.nro_localidad
  JOIN provincias p          ON p.cod_provincia  = l.cod_provincia
  WHERE s.nro_restaurante = @nro_restaurante
  ORDER BY s.nom_sucursal;
END
GO


CREATE OR ALTER PROCEDURE dbo.get_zonas_x_sucursales
  @nro_restaurante VARCHAR(36),
  @nro_sucursal    VARCHAR(36)
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
      zs.nro_restaurante,
      zs.nro_sucursal,
      zs.cod_zona,
      z.nom_zona,
      zs.cant_comensales,
      zs.permite_menores,
      zs.habilitada
  FROM zonas_sucursales zs
  JOIN zonas z ON z.cod_zona = zs.cod_zona
  WHERE zs.nro_restaurante = @nro_restaurante
    AND zs.nro_sucursal    = @nro_sucursal
  ORDER BY z.nom_zona;
END
GO

CREATE OR ALTER PROCEDURE dbo.get_horarios_disponibles
  @nro_restaurante VARCHAR(36),
  @nro_sucursal    VARCHAR(36),
  @cod_zona        VARCHAR(36) = NULL,  -- opcional: si es NULL devuelve todas las zonas
  @fecha           DATE,
  @cantidad        INT = NULL,      -- opcional: mínimo de lugares requeridos
  @incluirCero     BIT = 0          -- 1 = incluir turnos con disponibilidad 0
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH base AS (
    -- Turnos habilitados de la sucursal en los que la zona está habilitada
    SELECT
      t.nro_restaurante,
      t.nro_sucursal,
      zts.cod_zona,
      z.nom_zona,                    -- Nombre de la zona
      t.hora_desde,
      t.hora_hasta,
      zs.cant_comensales,
      zs.permite_menores             -- Permite menores
    FROM zonas_turnos_sucursales zts
    JOIN turnos_sucursales t
      ON t.nro_restaurante = zts.nro_restaurante
     AND t.nro_sucursal    = zts.nro_sucursal
     AND t.hora_desde      = zts.hora_desde
    JOIN zonas_sucursales zs
      ON zs.nro_restaurante = zts.nro_restaurante
     AND zs.nro_sucursal    = zts.nro_sucursal
     AND zs.cod_zona        = zts.cod_zona
    JOIN zonas z
      ON z.cod_zona = zs.cod_zona
    WHERE zts.nro_restaurante = @nro_restaurante
      AND zts.nro_sucursal    = @nro_sucursal
      AND (@cod_zona IS NULL OR zts.cod_zona = @cod_zona)  -- Si cod_zona es NULL, todas las zonas
      AND t.habilitado = 1          -- sólo turnos habilitados
      AND zs.habilitada = 1         -- sólo zonas habilitadas
  ),
  res AS (
    -- Reservas no canceladas de ese día para esa zona/turno
    SELECT
      r.hora_desde,
      r.cod_zona,
      SUM(CAST(r.cant_adultos AS INT) + CAST(r.cant_menores AS INT)) AS reservados
    FROM reservas_sucursales r
    WHERE r.nro_restaurante = @nro_restaurante
      AND r.nro_sucursal    = @nro_sucursal
      AND (@cod_zona IS NULL OR r.cod_zona = @cod_zona)  -- Si cod_zona es NULL, todas las zonas
      AND r.fecha_reserva   = @fecha
      AND r.cancelada       = 0
    GROUP BY r.hora_desde, r.cod_zona
  )
  SELECT
      b.cod_zona,
      b.nom_zona,
      b.permite_menores,
      b.hora_desde,
      b.hora_hasta,
      b.cant_comensales               AS capacidad_zona,
      ISNULL(res.reservados, 0)       AS ya_reservados,
      ISNULL(b.cant_comensales, 0) - ISNULL(res.reservados, 0) AS disponibilidad
  FROM base b
  LEFT JOIN res
    ON res.hora_desde = b.hora_desde
   AND res.cod_zona = b.cod_zona
  WHERE
    (@incluirCero = 1 OR (ISNULL(b.cant_comensales, 0) - ISNULL(res.reservados, 0)) > 0)
    AND (@cantidad IS NULL OR (ISNULL(b.cant_comensales, 0) - ISNULL(res.reservados, 0)) >= @cantidad)
  ORDER BY b.nom_zona, b.hora_desde;
END
GO

-- ============================================
-- STORED PROCEDURE: sp_registrar_reserva
-- Registra una reserva con validación de disponibilidad
-- Valida: zona habilitada, capacidad disponible, turno válido, permite menores
-- Usa locks para evitar race conditions
-- ============================================
CREATE OR ALTER PROCEDURE dbo.sp_registrar_reserva
  @nro_cliente VARCHAR(36),
  @nro_restaurante VARCHAR(36),
  @nro_sucursal VARCHAR(36),
  @cod_zona VARCHAR(36),
  @fecha_reserva DATE,
  @hora_desde TIME,
  @cant_adultos INT,
  @cant_menores INT
AS
BEGIN
  SET NOCOUNT ON;
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- Evitar race conditions
  
  BEGIN TRANSACTION;
  
  BEGIN TRY
    DECLARE @cant_total INT = @cant_adultos + @cant_menores;
    
    -- 1. Validar que la zona existe y está habilitada
    DECLARE @zona_existe BIT = 0;
    DECLARE @permite_menores BIT = 0;
    DECLARE @capacidad_zona INT = 0;
    
    SELECT 
      @zona_existe = 1,
      @permite_menores = zs.permite_menores,
      @capacidad_zona = zs.cant_comensales
    FROM zonas_sucursales zs
    WHERE zs.nro_restaurante = @nro_restaurante
      AND zs.nro_sucursal = @nro_sucursal
      AND zs.cod_zona = @cod_zona
      AND zs.habilitada = 1;
    
    IF @zona_existe = 0
    BEGIN
      RAISERROR('La zona especificada no existe o no está habilitada', 16, 1);
      ROLLBACK TRANSACTION;
      RETURN;
    END
    
    -- 2. Validar que permite menores si se solicitan
    IF @cant_menores > 0 AND @permite_menores = 0
    BEGIN
      RAISERROR('La zona seleccionada no permite menores', 16, 1);
      ROLLBACK TRANSACTION;
      RETURN;
    END
    
    -- 3. Validar que el turno existe y está habilitado
    DECLARE @turno_existe BIT = 0;
    
    SELECT @turno_existe = 1
    FROM zonas_turnos_sucursales zts
    JOIN turnos_sucursales t ON t.nro_restaurante = zts.nro_restaurante
      AND t.nro_sucursal = zts.nro_sucursal
      AND t.hora_desde = zts.hora_desde
    WHERE zts.nro_restaurante = @nro_restaurante
      AND zts.nro_sucursal = @nro_sucursal
      AND zts.cod_zona = @cod_zona
      AND zts.hora_desde = @hora_desde
      AND t.habilitado = 1;
    
    IF @turno_existe = 0
    BEGIN
      RAISERROR('El horario seleccionado no está disponible', 16, 1);
      ROLLBACK TRANSACTION;
      RETURN;
    END
    
    -- 4. Calcular disponibilidad actual (con lock para evitar race conditions)
    DECLARE @ya_reservados INT = 0;
    
    SELECT @ya_reservados = ISNULL(SUM(CAST(cant_adultos AS INT) + CAST(cant_menores AS INT)), 0)
    FROM reservas_sucursales WITH (UPDLOCK, HOLDLOCK)
    WHERE nro_restaurante = @nro_restaurante
      AND nro_sucursal = @nro_sucursal
      AND cod_zona = @cod_zona
      AND fecha_reserva = @fecha_reserva
      AND hora_desde = @hora_desde
      AND cancelada = 0;
    
    DECLARE @disponibilidad INT = @capacidad_zona - @ya_reservados;
    
    -- 5. Validar disponibilidad
    IF @disponibilidad < @cant_total
    BEGIN
      RAISERROR('No hay suficiente capacidad disponible. Disponibilidad: %d, Solicitado: %d', 
                16, 1, @disponibilidad, @cant_total);
      ROLLBACK TRANSACTION;
      RETURN;
    END
    
    -- 6. Si todo está bien, insertar la reserva
    DECLARE @cod_reserva VARCHAR(36) = NEWID();
    
    INSERT INTO reservas_sucursales (
      cod_reserva, nro_cliente, fecha_reserva, nro_restaurante, nro_sucursal,
      cod_zona, hora_desde, cant_adultos, cant_menores, cancelada, fecha_hora_registro
    )
    VALUES (
      @cod_reserva, @nro_cliente, @fecha_reserva, @nro_restaurante, @nro_sucursal,
      @cod_zona, @hora_desde, @cant_adultos, @cant_menores, 0, GETDATE()
    );
    
    COMMIT TRANSACTION;
    
    SELECT @cod_reserva AS cod_reserva;
    
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END
GO


CREATE OR ALTER PROCEDURE dbo.sp_registrar_contenido
  @nro_restaurante      VARCHAR(36),
  @nro_sucursal         VARCHAR(36) = NULL,
  @contenido_a_publicar VARCHAR(500),
  @imagen_a_publicar    VARBINARY(MAX) = NULL,
  @costo_click          DECIMAL(10,2) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @nro_contenido VARCHAR(36) = NEWID();
  DECLARE @exitoso BIT = 0;
  DECLARE @mensaje NVARCHAR(200) = '';

  BEGIN TRY
    DECLARE @nro_restaurante_real VARCHAR(36) = @nro_restaurante;

    IF @nro_sucursal IS NOT NULL
    BEGIN
      DECLARE @restaurante_de_sucursal VARCHAR(36);
      SELECT @restaurante_de_sucursal = nro_restaurante
      FROM sucursales
      WHERE nro_sucursal = @nro_sucursal;

      IF @restaurante_de_sucursal IS NOT NULL
      BEGIN
        SET @nro_restaurante_real = @restaurante_de_sucursal;
      END
      ELSE
      BEGIN
        SET @mensaje = 'Sucursal no encontrada';
        SELECT @nro_contenido AS nro_contenido, @exitoso AS exitoso, @mensaje AS mensaje;
        RETURN;
      END
    END

    IF NOT EXISTS (SELECT 1 FROM restaurantes WHERE nro_restaurante = @nro_restaurante_real)
    BEGIN
      SET @mensaje = 'Restaurante no encontrado';
      SELECT @nro_contenido AS nro_contenido, @exitoso AS exitoso, @mensaje AS mensaje;
      RETURN;
    END

    INSERT INTO contenidos (
      nro_restaurante,
      nro_contenido,
      contenido_a_publicar,
      imagen_a_publicar,
      publicado,
      costo_click,
      nro_sucursal
    )
    VALUES (
      @nro_restaurante_real,
      @nro_contenido,
      @contenido_a_publicar,
      @imagen_a_publicar,
      1,
      @costo_click,
      @nro_sucursal
    );

    SET @exitoso = 1;
    SET @mensaje = 'Contenido registrado exitosamente';

  END TRY
  BEGIN CATCH
    SET @mensaje = ERROR_MESSAGE();
  END CATCH

  SELECT @nro_contenido AS nro_contenido, @exitoso AS exitoso, @mensaje AS mensaje;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_registrar_click
  @nro_restaurante      VARCHAR(36),
  @nro_contenido        VARCHAR(36),
  @nro_click            VARCHAR(36),
  @fecha_hora_registro  DATETIME,
  @nro_cliente          VARCHAR(36) = NULL,
  @costo_click          DECIMAL(10,2) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @exitoso BIT = 0;
  DECLARE @mensaje NVARCHAR(200) = '';

  BEGIN TRY
    DECLARE @nro_restaurante_real VARCHAR(36);

    SELECT @nro_restaurante_real = nro_restaurante
    FROM contenidos
    WHERE nro_contenido = @nro_contenido;

    IF @nro_restaurante_real IS NULL
    BEGIN
      SET @mensaje = 'Contenido no encontrado';
      SELECT @exitoso AS exitoso, @mensaje AS mensaje;
      RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM restaurantes WHERE nro_restaurante = @nro_restaurante_real)
    BEGIN
      SET @mensaje = 'Restaurante no encontrado';
      SELECT @exitoso AS exitoso, @mensaje AS mensaje;
      RETURN;
    END

    IF EXISTS (SELECT 1 FROM clicks_contenidos WHERE nro_restaurante = @nro_restaurante_real AND nro_contenido = @nro_contenido AND nro_click = @nro_click)
    BEGIN
      SET @mensaje = 'Click ya registrado';
      SELECT @exitoso AS exitoso, @mensaje AS mensaje;
      RETURN;
    END

    INSERT INTO clicks_contenidos (
      nro_restaurante,
      nro_contenido,
      nro_click,
      fecha_hora_registro,
      nro_cliente,
      costo_click
    )
    VALUES (
      @nro_restaurante_real,
      @nro_contenido,
      @nro_click,
      @fecha_hora_registro,
      @nro_cliente,
      @costo_click
    );

    SET @exitoso = 1;
    SET @mensaje = 'Click registrado exitosamente';

  END TRY
  BEGIN CATCH
    SET @mensaje = ERROR_MESSAGE();
  END CATCH

  SELECT @exitoso AS exitoso, @mensaje AS mensaje;
END
GO

-- ============================================
-- STORED PROCEDURE: sp_ListarContenidos
-- Obtiene el último contenido NO publicado del restaurante.
-- Si todos están publicados, retorna el más nuevo.
-- ============================================
CREATE OR ALTER PROCEDURE dbo.sp_ListarContenidos
  @nro_restaurante VARCHAR(36),
  @nro_sucursal    VARCHAR(36) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- Primero intentar obtener el último contenido NO publicado
  DECLARE @contenido_no_publicado TABLE (
    nro_contenido VARCHAR(36),
    contenido_a_publicar VARCHAR(500),
    costo_click DECIMAL(10,2),
    nro_sucursal VARCHAR(36),
    publicado BIT
  );

  INSERT INTO @contenido_no_publicado
  SELECT TOP 1
    nro_contenido,
    contenido_a_publicar,
    costo_click,
    nro_sucursal,
    publicado
  FROM contenidos
  WHERE nro_restaurante = @nro_restaurante
    AND (@nro_sucursal IS NULL OR nro_sucursal = @nro_sucursal)
    AND publicado = 0
  ORDER BY nro_contenido DESC;

  -- Si hay contenido no publicado, retornarlo
  IF EXISTS (SELECT 1 FROM @contenido_no_publicado)
  BEGIN
    SELECT 
      nro_contenido,
      contenido_a_publicar,
      costo_click,
      nro_sucursal,
      publicado
    FROM @contenido_no_publicado;
    RETURN;
  END

  -- Si no hay contenido no publicado, retornar el más nuevo (último insertado)
  SELECT TOP 1
    nro_contenido,
    contenido_a_publicar,
    costo_click,
    nro_sucursal,
    publicado
  FROM contenidos
  WHERE nro_restaurante = @nro_restaurante
    AND (@nro_sucursal IS NULL OR nro_sucursal = @nro_sucursal)
  ORDER BY nro_contenido DESC;
END
GO

PRINT 'Stored procedures creados/actualizados exitosamente en das_perukai';
GO

