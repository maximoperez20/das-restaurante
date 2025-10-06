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
  @cod_zona        VARCHAR(36),
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
      t.hora_desde,
      t.hora_hasta,
      zs.cant_comensales
    FROM zonas_turnos_sucursales zts
    JOIN turnos_sucursales t
      ON t.nro_restaurante = zts.nro_restaurante
     AND t.nro_sucursal    = zts.nro_sucursal
     AND t.hora_desde      = zts.hora_desde
    JOIN zonas_sucursales zs
      ON zs.nro_restaurante = zts.nro_restaurante
     AND zs.nro_sucursal    = zts.nro_sucursal
     AND zs.cod_zona        = zts.cod_zona
    WHERE zts.nro_restaurante = @nro_restaurante
      AND zts.nro_sucursal    = @nro_sucursal
      AND zts.cod_zona        = @cod_zona
      AND t.habilitado = 1          -- sólo turnos habilitados
      AND zs.habilitada = 1         -- sólo zonas habilitadas
  ),
  res AS (
    -- Reservas no canceladas de ese día para esa zona/turno
    SELECT
      r.hora_desde,
      SUM(CAST(r.cant_adultos AS INT) + CAST(r.cant_menores AS INT)) AS reservados
    FROM reservas_sucursales r
    WHERE r.nro_restaurante = @nro_restaurante
      AND r.nro_sucursal    = @nro_sucursal
      AND r.cod_zona        = @cod_zona
      AND r.fecha_reserva   = @fecha
      AND r.cancelada       = 0
    GROUP BY r.hora_desde
  )
  SELECT
      b.hora_desde,
      b.hora_hasta,
      b.cant_comensales               AS capacidad_zona,
      ISNULL(res.reservados, 0)       AS ya_reservados,
      b.cant_comensales - ISNULL(res.reservados, 0) AS disponibilidad
  FROM base b
  LEFT JOIN res
    ON res.hora_desde = b.hora_desde
  WHERE
    (@incluirCero = 1 OR (b.cant_comensales - ISNULL(res.reservados, 0)) > 0)
    AND (@cantidad IS NULL OR (b.cant_comensales - ISNULL(res.reservados, 0)) >= @cantidad)
  ORDER BY b.hora_desde;
END
GO
