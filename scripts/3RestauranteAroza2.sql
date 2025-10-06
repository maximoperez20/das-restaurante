/* ==========================================================
   Carga de zonas_turnos_sucursales
   - Habilita TODAS las zonas de la sucursal en TODOS sus turnos
   - Usa por defecto el permite_menores definido en zonas_sucursales
   - Permite sobrescribir por turno con una lista de excepciones
   ========================================================== */
SET NOCOUNT ON;

-------------------------------------------------------------
-- Parámetros (ajustá estos dos)
-------------------------------------------------------------
DECLARE 
  @CUIT         VARCHAR(11)   = '30700987654',      -- restaurante
  @NomSucursal  NVARCHAR(120) = N'Los Aroza - Centro';  -- sucursal

-------------------------------------------------------------
-- 0) Resolver IDs del restaurante y sucursal
-------------------------------------------------------------
DECLARE @nro_restaurante VARCHAR(36), @nro_sucursal VARCHAR(36);

SELECT @nro_restaurante = r.nro_restaurante
FROM restaurantes r
WHERE r.cuit = @CUIT;

IF @nro_restaurante IS NULL
BEGIN
  RAISERROR('No existe restaurante con ese CUIT.',16,1); RETURN;
END

SELECT @nro_sucursal = s.nro_sucursal
FROM sucursales s
WHERE s.nro_restaurante = @nro_restaurante
  AND s.nom_sucursal    = @NomSucursal;

IF @nro_sucursal IS NULL
BEGIN
  RAISERROR('No existe la sucursal indicada para ese restaurante.',16,1); RETURN;
END

-------------------------------------------------------------
-- 1) Insertar faltantes: TODAS las (zonas_sucursales) × (turnos_sucursales)
--    usa como valor inicial el permite_menores de zonas_sucursales
-------------------------------------------------------------
INSERT INTO zonas_turnos_sucursales
       (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
SELECT  t.nro_restaurante, t.nro_sucursal, zs.cod_zona, t.hora_desde, zs.permite_menores
FROM    turnos_sucursales t
JOIN    zonas_sucursales  zs 
          ON  zs.nro_restaurante = t.nro_restaurante
          AND zs.nro_sucursal    = t.nro_sucursal
LEFT JOIN zonas_turnos_sucursales zts
          ON  zts.nro_restaurante = t.nro_restaurante
          AND zts.nro_sucursal    = t.nro_sucursal
          AND zts.cod_zona        = zs.cod_zona
          AND zts.hora_desde      = t.hora_desde
WHERE   t.nro_restaurante = @nro_restaurante
  AND   t.nro_sucursal    = @nro_sucursal
  AND   zts.nro_restaurante IS NULL;   -- solo faltantes

-------------------------------------------------------------
-- 2) (Opcional) Excepciones por turno: setear permite_menores=0/1
--    Cargá aquí las reglas especiales; ejemplo: Terraza a las 22:00 no permite menores
-------------------------------------------------------------
--DECLARE @Excepciones TABLE (nom_zona NVARCHAR(60), hora_desde TIME, permite_menores BIT);

---- EJEMPLOS (borrá o ajustá):
-- --INSERT INTO @Excepciones VALUES (N'Terraza',       '22:00', 0);
---- INSERT INTO @Excepciones VALUES (N'Salón Principal','20:00', 1);

--UPDATE zts
--   SET zts.permite_menores = e.permite_menores
--FROM zonas_turnos_sucursales zts
--JOIN zonas z     ON z.cod_zona = zts.cod_zona
--JOIN @Excepciones e 
--     ON e.nom_zona = z.nom_zona AND e.hora_desde = zts.hora_desde
--WHERE zts.nro_restaurante = @nro_restaurante
--  AND zts.nro_sucursal    = @nro_sucursal;

-------------------------------------------------------------
-- 3) Comprobación
-------------------------------------------------------------
SELECT z.nom_zona, t.hora_desde, t.hora_hasta, zts.permite_menores
FROM zonas_turnos_sucursales zts
JOIN zonas z           ON z.cod_zona = zts.cod_zona
JOIN turnos_sucursales t
  ON t.nro_restaurante=zts.nro_restaurante AND t.nro_sucursal=zts.nro_sucursal AND t.hora_desde=zts.hora_desde
WHERE zts.nro_restaurante=@nro_restaurante AND zts.nro_sucursal=@nro_sucursal
ORDER BY t.hora_desde, z.nom_zona;

