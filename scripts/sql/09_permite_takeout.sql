alter table sucursales
add permite_takeout bit not null default 0;


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
      p.nom_provincia,
      s.permite_takeout
  FROM sucursales s
  JOIN categorias_precios cp ON cp.nro_categoria = s.nro_categoria
  JOIN localidades l         ON l.nro_localidad  = s.nro_localidad
  JOIN provincias p          ON p.cod_provincia  = l.cod_provincia
  WHERE s.nro_restaurante = @nro_restaurante
  ORDER BY s.nom_sucursal;
END
GO
