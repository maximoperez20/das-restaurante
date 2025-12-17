
ALTER TABLE contenidos
    ADD proposito_corto VARCHAR(20) NULL;


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
    publicado BIT,
    proposito_corto VARCHAR(20)
  );

  INSERT INTO @contenido_no_publicado
  SELECT TOP 1
    nro_contenido,
    contenido_a_publicar,
    costo_click,
    nro_sucursal,
    publicado,
    proposito_corto
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
      publicado,
      proposito_corto
    FROM @contenido_no_publicado;
    RETURN;
  END

  -- Si no hay contenido no publicado, retornar el más nuevo (último insertado)
  SELECT TOP 1
    nro_contenido,
    contenido_a_publicar,
    costo_click,
    nro_sucursal,
    publicado,
    proposito_corto
  FROM contenidos
  WHERE nro_restaurante = @nro_restaurante
    AND (@nro_sucursal IS NULL OR nro_sucursal = @nro_sucursal)
  ORDER BY nro_contenido DESC;
END
GO