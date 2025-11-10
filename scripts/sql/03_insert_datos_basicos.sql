/* =========================================================================================
   INSERT DE DATOS BÁSICOS - das_restaurante_soap
   Incluye: provincias, localidades, zonas, categorías, tipos de comida, y 1 restaurante
   ========================================================================================= */

SET NOCOUNT ON;
GO

USE das_restaurante_soap;
GO

/* =========================================
   1) Catálogos base
   ========================================= */

-- Provincias
IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'Córdoba')
    INSERT INTO provincias (nom_provincia) VALUES ('Córdoba');
IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'Buenos Aires')
    INSERT INTO provincias (nom_provincia) VALUES ('Buenos Aires');
IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'Santa Fe')
    INSERT INTO provincias (nom_provincia) VALUES ('Santa Fe');

-- Localidades
DECLARE @cod_cba VARCHAR(36), @cod_ba VARCHAR(36), @cod_sf VARCHAR(36);
SELECT @cod_cba = cod_provincia FROM provincias WHERE nom_provincia = 'Córdoba';
SELECT @cod_ba = cod_provincia FROM provincias WHERE nom_provincia = 'Buenos Aires';
SELECT @cod_sf = cod_provincia FROM provincias WHERE nom_provincia = 'Santa Fe';

IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Córdoba' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Córdoba', @cod_cba);
IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Villa Carlos Paz' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Villa Carlos Paz', @cod_cba);

IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='La Plata' AND cod_provincia=@cod_ba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('La Plata', @cod_ba);
IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Mar del Plata' AND cod_provincia=@cod_ba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Mar del Plata', @cod_ba);

IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Rosario' AND cod_provincia=@cod_sf)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Rosario', @cod_sf);

-- Zonas
IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Salón Principal')
    INSERT INTO zonas (nom_zona) VALUES ('Salón Principal');
IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Terraza')
    INSERT INTO zonas (nom_zona) VALUES ('Terraza');
IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Patio Cubierto')
    INSERT INTO zonas (nom_zona) VALUES ('Patio Cubierto');

-- Categorías de precios
IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Económica')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Económica');
IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Media')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Media');
IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Premium')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Premium');

-- Tipos de comidas
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Parrilla')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Parrilla');
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Pizzería')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Pizzería');
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Sushi')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Sushi');
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Vegano')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Vegano');

-- Especialidades alimentarias
IF NOT EXISTS (SELECT 1 FROM especialidades_alimentarias WHERE nom_restriccion='Sin TACC')
    INSERT INTO especialidades_alimentarias (nom_restriccion) VALUES ('Sin TACC');
IF NOT EXISTS (SELECT 1 FROM especialidades_alimentarias WHERE nom_restriccion='Vegetariano')
    INSERT INTO especialidades_alimentarias (nom_restriccion) VALUES ('Vegetariano');
IF NOT EXISTS (SELECT 1 FROM especialidades_alimentarias WHERE nom_restriccion='Apto Vegano')
    INSERT INTO especialidades_alimentarias (nom_restriccion) VALUES ('Apto Vegano');

-- Estilos
IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Casual')
    INSERT INTO estilos (nom_estilo) VALUES ('Casual');
IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Familiar')
    INSERT INTO estilos (nom_estilo) VALUES ('Familiar');
IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Gourmet')
    INSERT INTO estilos (nom_estilo) VALUES ('Gourmet');
IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Bar / Tragos')
    INSERT INTO estilos (nom_estilo) VALUES ('Bar / Tragos');

/* =========================================
   2) Restaurante compartido con ristorino
   ========================================= */

-- UUID compartido: Este restaurante debe existir en AMBAS bases de datos
DECLARE @restaurante_compartido_uuid VARCHAR(36) = '12345678-1234-1234-1234-123456789abc';
DECLARE @nro_localidad_cordoba VARCHAR(36);
SELECT @nro_localidad_cordoba = nro_localidad FROM localidades WHERE nom_localidad='Córdoba' AND cod_provincia=@cod_cba;

DECLARE @nro_categoria_media VARCHAR(36);
SELECT @nro_categoria_media = nro_categoria FROM categorias_precios WHERE nom_categoria='Media';

-- Restaurante (mismo UUID que en ristorino)
IF NOT EXISTS (SELECT 1 FROM restaurantes WHERE nro_restaurante = @restaurante_compartido_uuid)
BEGIN
    INSERT INTO restaurantes (nro_restaurante, razon_social, cuit)
    VALUES (@restaurante_compartido_uuid, 'Los Aroza SRL', '30700987654');
    PRINT 'Restaurante compartido insertado: ' + @restaurante_compartido_uuid;
END
ELSE
    PRINT 'Restaurante compartido ya existe: ' + @restaurante_compartido_uuid;

-- Sucursal del restaurante compartido
DECLARE @nro_sucursal VARCHAR(36);
IF NOT EXISTS (SELECT 1 FROM sucursales WHERE nro_restaurante = @restaurante_compartido_uuid AND nom_sucursal = 'Los Aroza - Centro')
BEGIN
    SET @nro_sucursal = NEWID();
    INSERT INTO sucursales (
        nro_restaurante, nro_sucursal, nom_sucursal, calle, nro_calle, barrio,
        nro_localidad, cod_postal, telefonos, total_comensales, min_tolerencia_reserva, nro_categoria
    )
    VALUES (
        @restaurante_compartido_uuid, @nro_sucursal, 'Los Aroza - Centro',
        'Av. Colón', 950, 'Centro',
        @nro_localidad_cordoba, '5000', '351-555-1234', 140, 15, @nro_categoria_media
    );
    PRINT 'Sucursal insertada: ' + @nro_sucursal;
END
ELSE
BEGIN
    SELECT @nro_sucursal = nro_sucursal FROM sucursales WHERE nro_restaurante = @restaurante_compartido_uuid AND nom_sucursal = 'Los Aroza - Centro';
    PRINT 'Sucursal ya existe: ' + @nro_sucursal;
END

-- Zonas de la sucursal
DECLARE @cod_zona_salon VARCHAR(36), @cod_zona_terraza VARCHAR(36);
SELECT @cod_zona_salon = cod_zona FROM zonas WHERE nom_zona='Salón Principal';
SELECT @cod_zona_terraza = cod_zona FROM zonas WHERE nom_zona='Terraza';

IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @restaurante_compartido_uuid AND nro_sucursal = @nro_sucursal AND cod_zona = @cod_zona_salon)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@restaurante_compartido_uuid, @nro_sucursal, @cod_zona_salon, 80, 1, 1);
END

IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @restaurante_compartido_uuid AND nro_sucursal = @nro_sucursal AND cod_zona = @cod_zona_terraza)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@restaurante_compartido_uuid, @nro_sucursal, @cod_zona_terraza, 60, 1, 1);
END

-- Turnos de la sucursal (cada 2 horas desde 16:00)
DECLARE @hora TIME = '16:00';
DECLARE @hora_hasta TIME;
DECLARE @i INT = 0;

WHILE @i < 4
BEGIN
    SET @hora_hasta = CAST(DATEADD(MINUTE, 120, CAST(@hora AS DATETIME)) AS TIME);
    
    IF NOT EXISTS (SELECT 1 FROM turnos_sucursales WHERE nro_restaurante = @restaurante_compartido_uuid AND nro_sucursal = @nro_sucursal AND hora_desde = @hora)
    BEGIN
        INSERT INTO turnos_sucursales (nro_restaurante, nro_sucursal, hora_desde, hora_hasta, habilitado)
        VALUES (@restaurante_compartido_uuid, @nro_sucursal, @hora, @hora_hasta, 1);
        
        -- Zonas por turno
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @restaurante_compartido_uuid AND nro_sucursal = @nro_sucursal AND cod_zona = @cod_zona_salon AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@restaurante_compartido_uuid, @nro_sucursal, @cod_zona_salon, @hora, 1);
            
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @restaurante_compartido_uuid AND nro_sucursal = @nro_sucursal AND cod_zona = @cod_zona_terraza AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@restaurante_compartido_uuid, @nro_sucursal, @cod_zona_terraza, @hora, 1);
    END
    
    SET @hora = @hora_hasta;
    SET @i = @i + 1;
END

PRINT 'Datos básicos insertados exitosamente en das_restaurante_soap';
PRINT 'Restaurante compartido UUID: 12345678-1234-1234-1234-123456789abc';
GO

