/* ===========================
   BLOQUE 1: Cat�logos base
   =========================== */

-- Provincias (AR)
IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'C�rdoba')
    INSERT INTO provincias (nom_provincia) VALUES ('C�rdoba');

IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'Buenos Aires')
    INSERT INTO provincias (nom_provincia) VALUES ('Buenos Aires');

IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'Santa Fe')
    INSERT INTO provincias (nom_provincia) VALUES ('Santa Fe');

-- Localidades (ligadas a su provincia)
IF NOT EXISTS (
    SELECT 1
    FROM localidades l
    JOIN provincias p ON p.cod_provincia = l.cod_provincia
    WHERE l.nom_localidad='C�rdoba' AND p.nom_provincia='C�rdoba'
)
BEGIN
    INSERT INTO localidades (nom_localidad, cod_provincia)
    SELECT 'C�rdoba', p.cod_provincia
    FROM provincias p WHERE p.nom_provincia='C�rdoba';
END

IF NOT EXISTS (
    SELECT 1
    FROM localidades l JOIN provincias p ON p.cod_provincia = l.cod_provincia
    WHERE l.nom_localidad='Villa Carlos Paz' AND p.nom_provincia='C�rdoba'
)
BEGIN
    INSERT INTO localidades (nom_localidad, cod_provincia)
    SELECT 'Villa Carlos Paz', p.cod_provincia
    FROM provincias p WHERE p.nom_provincia='C�rdoba';
END

IF NOT EXISTS (
    SELECT 1
    FROM localidades l JOIN provincias p ON p.cod_provincia = l.cod_provincia
    WHERE l.nom_localidad='R�o Cuarto' AND p.nom_provincia='C�rdoba'
)
BEGIN
    INSERT INTO localidades (nom_localidad, cod_provincia)
    SELECT 'R�o Cuarto', p.cod_provincia
    FROM provincias p WHERE p.nom_provincia='C�rdoba';
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

/* Zonas (�mbitos de atenci�n del restaurante) */
IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Sal�n Principal')
    INSERT INTO zonas (nom_zona) VALUES ('Sal�n Principal');

IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Terraza')
    INSERT INTO zonas (nom_zona) VALUES ('Terraza');

IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Patio Cubierto')
    INSERT INTO zonas (nom_zona) VALUES ('Patio Cubierto');

/* Categor�as de precios */
IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Econ�mica')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Econ�mica');

IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Media')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Media');

IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Premium')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Premium');

/* Tipos de comidas */
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Parrilla')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Parrilla');

IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Pizzer�a')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Pizzer�a');

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
