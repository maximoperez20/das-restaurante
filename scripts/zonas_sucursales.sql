/* ==========================================================
   Zonas de la sucursal Los Aroza - Centro
   ========================================================== */
DECLARE @nro_restaurante VARCHAR(36), @nro_sucursal VARCHAR(36),
        @zona_salon VARCHAR(36), @zona_terraza VARCHAR(36);

-- Resolver restaurante y sucursal
SELECT @nro_restaurante = r.nro_restaurante
FROM restaurantes r WHERE r.cuit = '30700987654';

SELECT @nro_sucursal = s.nro_sucursal
FROM sucursales s 
WHERE s.nro_restaurante = @nro_restaurante 
  AND s.nom_sucursal = N'Los Aroza - Centro';

-- Resolver zonas
SELECT @zona_salon = cod_zona FROM zonas WHERE nom_zona = N'Salón Principal';
SELECT @zona_terraza = cod_zona FROM zonas WHERE nom_zona = N'Terraza';

-- Insertar Salón Principal (90 cubiertos)
IF NOT EXISTS (
  SELECT 1 FROM zonas_sucursales
  WHERE nro_restaurante=@nro_restaurante AND nro_sucursal=@nro_sucursal AND cod_zona=@zona_salon
)
  INSERT INTO zonas_sucursales (
    nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada
  )
  VALUES (@nro_restaurante, @nro_sucursal, @zona_salon, 90, 1, 1);

-- Insertar Terraza (50 cubiertos)
IF NOT EXISTS (
  SELECT 1 FROM zonas_sucursales
  WHERE nro_restaurante=@nro_restaurante AND nro_sucursal=@nro_sucursal AND cod_zona=@zona_terraza
)
  INSERT INTO zonas_sucursales (
    nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada
  )
  VALUES (@nro_restaurante, @nro_sucursal, @zona_terraza, 50, 1, 1);

-- Verificar
SELECT z.nom_zona, zs.cant_comensales, zs.permite_menores, zs.habilitada
FROM zonas_sucursales zs
JOIN zonas z ON z.cod_zona = zs.cod_zona
WHERE zs.nro_restaurante=@nro_restaurante AND zs.nro_sucursal=@nro_sucursal;
