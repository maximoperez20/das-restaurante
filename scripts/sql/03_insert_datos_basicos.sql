/* =========================================================================================
   INSERT DE DATOS BÁSICOS - das_restaurante
   Incluye SOLO catálogos base: provincias, localidades, zonas, categorías, tipos de comida, estilos
   NOTA: Los restaurantes se insertan con los scripts individuales
   ========================================================================================= */

SET NOCOUNT ON;
GO

USE das_restaurante;
GO

/* =========================================
   1) Catálogos base
   ========================================= */

-- Provincias
IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'Córdoba')
    INSERT INTO provincias (nom_provincia) VALUES ('Córdoba');

-- Localidades (barrios de Córdoba para los 4 restaurantes del examen final)
DECLARE @cod_cba VARCHAR(36);
SELECT @cod_cba = cod_provincia FROM provincias WHERE nom_provincia = 'Córdoba';

IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Alta Córdoba' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Alta Córdoba', @cod_cba);
IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='General Paz' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('General Paz', @cod_cba);
IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Nueva Córdoba' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Nueva Córdoba', @cod_cba);
IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Güemes' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Güemes', @cod_cba);
IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Cerro de las Rosas' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Cerro de las Rosas', @cod_cba);
IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Centro' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Centro', @cod_cba);

-- Zonas (para los 4 restaurantes del examen final)
IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Salón Principal')
    INSERT INTO zonas (nom_zona) VALUES ('Salón Principal');
IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Terraza')
    INSERT INTO zonas (nom_zona) VALUES ('Terraza');
IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Patio')
    INSERT INTO zonas (nom_zona) VALUES ('Patio');
IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Patio Cubierto')
    INSERT INTO zonas (nom_zona) VALUES ('Patio Cubierto');
IF NOT EXISTS (SELECT 1 FROM zonas WHERE nom_zona='Barra')
    INSERT INTO zonas (nom_zona) VALUES ('Barra');

-- Categorías de precios
IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Económica')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Económica');
IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Media')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Media');
IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Premium')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Premium');

-- Tipos de comidas (para los 4 restaurantes del examen final)
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Italiana')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Italiana');
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Pizzería')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Pizzería');
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Fusión')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Fusión');
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Sushi')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Sushi');
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Americana')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Americana');
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Fast food gourmet')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Fast food gourmet');
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Regional del NOA')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Regional del NOA');

-- Especialidades alimentarias (opcional, para uso futuro)
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

PRINT 'Catálogos base insertados exitosamente en das_restaurante';
PRINT 'Los restaurantes se insertan con los scripts individuales:';
PRINT '  - la-bella-pizza/01_insert_la_bella_pizza.sql';
PRINT '  - perukai/01_insert_perukai.sql';
PRINT '  - la-fabrica-burger/01_insert_la_fabrica_burger.sql';
PRINT '  - sabores-del-norte/01_insert_sabores_del_norte.sql';
GO
