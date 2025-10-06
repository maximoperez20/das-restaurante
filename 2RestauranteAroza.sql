/* ==========================================================
   CARGA BASE: Restaurante + Sucursales + Turnos cada 2 horas
   ========================================================== */

-- Crea/asegura el restaurante, resuelve provincias/localidades/categorías, crea/actualiza sus sucursales y genera turnos habilitados 
--- cada 2 horas desde la hora de apertura hasta 00:00, luego muestra una verificación de turnos por sucursal

SET NOCOUNT ON;

-------------------------------------------------------------
-- Parámetros (podés ajustar los valores de ejemplo)
-------------------------------------------------------------
DECLARE 
  @RazonSocial NVARCHAR(150) = N'Los Aroza SRL',
  @CUIT        VARCHAR(11)   = '30700987654';  -- 11 dígitos, sin guiones

-- Sucursales a crear (podés agregar más filas abajo)
DECLARE @Sucursales TABLE (
  nom_sucursal           NVARCHAR(120),
  calle                  NVARCHAR(120),
  nro_calle              INT,
  barrio                 NVARCHAR(120),
  localidad              NVARCHAR(100),   -- nombre de localidad
  provincia              NVARCHAR(80),    -- nombre de provincia
  cod_postal             VARCHAR(10),
  telefonos              NVARCHAR(120),
  total_comensales       INT,
  min_toler_reserva_min  INT,             -- minutos
  categoria_precio       NVARCHAR(40),    -- nombre de categoría
  hora_apertura          TIME             -- define la grilla: +120 min hasta 00:00
);

INSERT INTO @Sucursales VALUES
(N'Los Aroza - Centro', N'Av. Colón', 950, N'Centro',
 N'Córdoba', N'Córdoba', '5000', N'351-555-1234',
 140, 15, N'Media', '16:00');   -- => 16,18,20,22 → 00:00

-------------------------------------------------------------
-- 1) Resolver/crear referencias mínimas por nombre
-------------------------------------------------------------
DECLARE @nro_restaurante VARCHAR(36);
IF NOT EXISTS (SELECT 1 FROM restaurantes WHERE cuit = @CUIT)
  INSERT INTO restaurantes (razon_social, cuit) VALUES (@RazonSocial, @CUIT);

SELECT @nro_restaurante = nro_restaurante
FROM restaurantes WHERE cuit = @CUIT;

-- Provincias, localidades y categorías según necesite cada sucursal
DECLARE @prov NVARCHAR(80), @loc NVARCHAR(100), @cat NVARCHAR(40);
DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
  SELECT DISTINCT provincia, localidad, categoria_precio FROM @Sucursales;
OPEN cur;
FETCH NEXT FROM cur INTO @prov, @loc, @cat;
WHILE @@FETCH_STATUS = 0
BEGIN
  -- Provincia
  IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = @prov)
    INSERT INTO provincias (nom_provincia) VALUES (@prov);

  DECLARE @cod_provincia VARCHAR(36);
  SELECT @cod_provincia = cod_provincia FROM provincias WHERE nom_provincia = @prov;

  -- Localidad dentro de provincia
  IF NOT EXISTS (
    SELECT 1 FROM localidades WHERE nom_localidad=@loc AND cod_provincia=@cod_provincia
  )
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES (@loc, @cod_provincia);

  -- Categoría de precios
  IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria = @cat)
    INSERT INTO categorias_precios (nom_categoria) VALUES (@cat);

  FETCH NEXT FROM cur INTO @prov, @loc, @cat;
END
CLOSE cur; DEALLOCATE cur;

-------------------------------------------------------------
-- 2) Crear/actualizar sucursales
-------------------------------------------------------------
DECLARE 
  @nom_sucursal NVARCHAR(120), @calle NVARCHAR(120), @nro INT, @barrio NVARCHAR(120),
  @localidad NVARCHAR(100), @provincia NVARCHAR(80), @cp VARCHAR(10), @tel NVARCHAR(120),
  @cap INT, @min_tol INT, @cat_nom NVARCHAR(40), @apertura TIME;

DECLARE curS CURSOR LOCAL FAST_FORWARD FOR
SELECT nom_sucursal, calle, nro_calle, barrio, localidad, provincia, cod_postal,
       telefonos, total_comensales, min_toler_reserva_min, categoria_precio, hora_apertura
FROM @Sucursales;

OPEN curS;
FETCH NEXT FROM curS INTO @nom_sucursal,@calle,@nro,@barrio,@localidad,@provincia,@cp,@tel,
                         @cap,@min_tol,@cat_nom,@apertura;
WHILE @@FETCH_STATUS = 0
BEGIN
  DECLARE @nro_localidad VARCHAR(36), @nro_categoria VARCHAR(36), @nro_sucursal VARCHAR(36);

  SELECT @nro_localidad = l.nro_localidad
  FROM localidades l JOIN provincias p ON p.cod_provincia = l.cod_provincia
  WHERE l.nom_localidad=@localidad AND p.nom_provincia=@provincia;

  SELECT @nro_categoria = nro_categoria
  FROM categorias_precios WHERE nom_categoria=@cat_nom;

  -- Crear la sucursal si no existe
  IF NOT EXISTS (
    SELECT 1 FROM sucursales 
    WHERE nro_restaurante=@nro_restaurante AND nom_sucursal=@nom_sucursal
  )
  BEGIN
    INSERT INTO sucursales (
      nro_restaurante, nom_sucursal, calle, nro_calle, barrio,
      nro_localidad, cod_postal, telefonos, total_comensales,
      min_tolerencia_reserva, nro_categoria
    )
    VALUES (
      @nro_restaurante, @nom_sucursal, @calle, @nro, @barrio,
      @nro_localidad, @cp, @tel, @cap, @min_tol, @nro_categoria
    );
  END

  -- Capturar el ID de la sucursal (PK compuesta)
  SELECT TOP 1 @nro_sucursal = s.nro_sucursal
  FROM sucursales s
  WHERE s.nro_restaurante=@nro_restaurante AND s.nom_sucursal=@nom_sucursal;

  -----------------------------------------------------------
  -- 3) Generar turnos cada 120 min desde @apertura a 00:00
  -----------------------------------------------------------
  DECLARE @t TIME = @apertura, @hHasta TIME, @i INT = 0;
  WHILE (@i < 12)
  BEGIN
    SET @hHasta = CAST(DATEADD(MINUTE, 120, CAST(@t AS datetime2(0))) AS TIME);

    IF NOT EXISTS (
      SELECT 1 FROM turnos_sucursales
      WHERE nro_restaurante=@nro_restaurante AND nro_sucursal=@nro_sucursal AND hora_desde=@t
    )
      INSERT INTO turnos_sucursales (nro_restaurante, nro_sucursal, hora_desde, hora_hasta, habilitado)
      VALUES (@nro_restaurante, @nro_sucursal, @t, @hHasta, 1);

    IF (@hHasta = '00:00') BREAK;  -- último turno del día
    SET @t = @hHasta; SET @i += 1;
  END

  FETCH NEXT FROM curS INTO @nom_sucursal,@calle,@nro,@barrio,@localidad,@provincia,@cp,@tel,
                           @cap,@min_tol,@cat_nom,@apertura;
END
CLOSE curS; DEALLOCATE curS;

-------------------------------------------------------------
-- 4) Comprobación rápida
-------------------------------------------------------------
SELECT r.razon_social as Restaurante, s.nom_sucursal, t.hora_desde, t.hora_hasta, t.habilitado
FROM turnos_sucursales t
JOIN sucursales s ON s.nro_restaurante=t.nro_restaurante AND s.nro_sucursal=t.nro_sucursal
JOIN restaurantes r ON r.nro_restaurante=s.nro_restaurante
ORDER BY s.nom_sucursal, t.hora_desde;
