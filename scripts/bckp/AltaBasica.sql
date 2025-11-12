/* ===========================
   BLOQUE 1: Catálogos base
   =========================== */

-- Provincias (AR)
IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'Córdoba')
    INSERT INTO provincias (nom_provincia) VALUES ('Córdoba');

IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'Buenos Aires')
    INSERT INTO provincias (nom_provincia) VALUES ('Buenos Aires');

IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'Santa Fe')
    INSERT INTO provincias (nom_provincia) VALUES ('Santa Fe');

-- Localidades (ligadas a su provincia)
IF NOT EXISTS (
    SELECT 1
    FROM localidades l
    JOIN provincias p ON p.cod_provincia = l.cod_provincia
    WHERE l.nom_localidad='Córdoba' AND p.nom_provincia='Córdoba'
)
BEGIN
    INSERT INTO localidades (nom_localidad, cod_provincia)
    SELECT 'Córdoba', p.cod_provincia
    FROM provincias p WHERE p.nom_provincia='Córdoba';
END

IF NOT EXISTS (
    SELECT 1
    FROM localidades l JOIN provincias p ON p.cod_provincia = l.cod_provincia
    WHERE l.nom_localidad='Villa Carlos Paz' AND p.nom_provincia='Córdoba'
)
BEGIN
    INSERT INTO localidades (nom_localidad, cod_provincia)
    SELECT 'Villa Carlos Paz', p.cod_provincia
    FROM provincias p WHERE p.nom_provincia='Córdoba';
END

IF NOT EXISTS (
    SELECT 1
    FROM localidades l JOIN provincias p ON p.cod_provincia = l.cod_provincia
    WHERE l.nom_localidad='Río Cuarto' AND p.nom_provincia='Córdoba'
)
BEGIN
    INSERT INTO localidades (nom_localidad, cod_provincia)
    SELECT 'Río Cuarto', p.cod_provincia
    FROM provincias p WHERE p.nom_provincia='Córdoba';
END

IF NOT EXISTS (
    SELECT 1
    FROM localidades l JOIN provincias p ON p.cod_provincia = l.cod_provincia
    WHERE l.nom_localidad='La Plata' AND p.nom_provincia='Buenos Aires'
)
BEGIN
    INSERT INTO localidades (nom_localidad, cod_provincia)
    SELECT 'La Plata', p.cod_provincia
    FROM provincias p WHERE p.nom_provincia='Buenos Aires';
END

IF NOT EXISTS (
    SELECT 1
    FROM localidades l JOIN provincias p ON p.cod_provincia = l.cod_provincia
    WHERE l.nom_localidad='Mar del Plata' AND p.nom_provincia='Buenos Aires'
)
BEGIN
    INSERT INTO localidades (nom_localidad, cod_provincia)
    SELECT 'Mar del Plata', p.cod_provincia
    FROM provincias p WHERE p.nom_provincia='Buenos Aires';
END

IF NOT EXISTS (
    SELECT 1
    FROM localidades l JOIN provincias p ON p.cod_provincia = l.cod_provincia
    WHERE l.nom_localidad='Rosario' AND p.nom_provincia='Santa Fe'
)
BEGIN
    INSERT INTO localidades (nom_localidad, cod_provincia)
    SELECT 'Rosario', p.cod_provincia
    FROM provincias p WHERE p.nom_provincia='Santa Fe';
END

/* Zonas (ámbitos de atención del restaurante) */
IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Salón Principal')
    INSERT INTO zonas (nom_zona) VALUES ('Salón Principal');

IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Terraza')
    INSERT INTO zonas (nom_zona) VALUES ('Terraza');

IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Patio Cubierto')
    INSERT INTO zonas (nom_zona) VALUES ('Patio Cubierto');

/* Categorías de precios */
IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Económica')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Económica');

IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Media')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Media');

IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Premium')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Premium');

/* Tipos de comidas */
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Parrilla')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Parrilla');

IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Pizzería')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Pizzería');

IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Sushi')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Sushi');

IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Vegano')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Vegano');

/* Especialidades / restricciones alimentarias */
IF NOT EXISTS (SELECT 1 FROM especialidades_alimentarias WHERE nom_restriccion='Sin TACC')
    INSERT INTO especialidades_alimentarias (nom_restriccion) VALUES ('Sin TACC');

IF NOT EXISTS (SELECT 1 FROM especialidades_alimentarias WHERE nom_restriccion='Vegetariano')
    INSERT INTO especialidades_alimentarias (nom_restriccion) VALUES ('Vegetariano');

IF NOT EXISTS (SELECT 1 FROM especialidades_alimentarias WHERE nom_restriccion='Apto Vegano')
    INSERT INTO especialidades_alimentarias (nom_restriccion) VALUES ('Apto Vegano');

/* Estilos */
IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Casual')
    INSERT INTO estilos (nom_estilo) VALUES ('Casual');

IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Familiar')
    INSERT INTO estilos (nom_estilo) VALUES ('Familiar');

IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Gourmet')
    INSERT INTO estilos (nom_estilo) VALUES ('Gourmet');

IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Bar / Tragos')
    INSERT INTO estilos (nom_estilo) VALUES ('Bar / Tragos');
