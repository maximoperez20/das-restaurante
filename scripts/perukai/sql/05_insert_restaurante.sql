/* =========================================================================================
   INSERT DE DATOS: Perukai (SOAP)
   Base de Datos: das_restaurante
   UUID del Restaurante: PERUKAI-2222-2222-2222-222222222222
   Protocolo: SOAP
   ========================================================================================= */

SET NOCOUNT ON;
GO

USE das_perukai;
GO

/* =========================================
   1) Verificar/crear catálogos base
   ========================================= */

-- Provincias
IF NOT EXISTS (SELECT 1 FROM provincias WHERE nom_provincia = 'Córdoba')
    INSERT INTO provincias (nom_provincia) VALUES ('Córdoba');

-- Localidades
DECLARE @cod_cba VARCHAR(36);
SELECT @cod_cba = cod_provincia FROM provincias WHERE nom_provincia = 'Córdoba';

IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Nueva Córdoba' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Nueva Córdoba', @cod_cba);

IF NOT EXISTS (SELECT 1 FROM localidades WHERE nom_localidad='Güemes' AND cod_provincia=@cod_cba)
    INSERT INTO localidades (nom_localidad, cod_provincia) VALUES ('Güemes', @cod_cba);

-- Zonas (UUIDs fijos - ya insertadas por 03_insert_datos_basicos.sql)
-- Solo obtener los UUIDs, no insertar (las zonas ya están en el catálogo)
DECLARE @cod_zona_salon_principal VARCHAR(36) = 'ZONA-SALON-PRINCIPAL-0001-0001-0001-0001';
DECLARE @cod_zona_barra VARCHAR(36) = 'ZONA-BARRA-0001-0001-0001-0001';
DECLARE @cod_zona_terraza VARCHAR(36) = 'ZONA-TERRAZA-0001-0001-0001-0001';

-- Verificar que las zonas existan (deben estar insertadas por 03_insert_datos_basicos.sql)
IF NOT EXISTS (SELECT 1 FROM zonas WHERE cod_zona = @cod_zona_salon_principal)
BEGIN
    RAISERROR('Error: La zona "Salón Principal" no existe. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1);
    RETURN;
END

IF NOT EXISTS (SELECT 1 FROM zonas WHERE cod_zona = @cod_zona_barra)
BEGIN
    RAISERROR('Error: La zona "Barra" no existe. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1);
    RETURN;
END

IF NOT EXISTS (SELECT 1 FROM zonas WHERE cod_zona = @cod_zona_terraza)
BEGIN
    RAISERROR('Error: La zona "Terraza" no existe. Ejecutar primero 03_insert_datos_basicos.sql', 16, 1);
    RETURN;
END

-- Categorías de precios
IF NOT EXISTS (SELECT 1 FROM categorias_precios WHERE nom_categoria='Premium')
    INSERT INTO categorias_precios (nom_categoria) VALUES ('Premium');

-- Tipos de comidas
IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Fusión')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Fusión');

IF NOT EXISTS (SELECT 1 FROM tipos_comidas WHERE nom_tipo_comida='Sushi')
    INSERT INTO tipos_comidas (nom_tipo_comida) VALUES ('Sushi');

-- Estilos
IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Gourmet')
    INSERT INTO estilos (nom_estilo) VALUES ('Gourmet');

IF NOT EXISTS (SELECT 1 FROM estilos WHERE nom_estilo='Bar / Tragos')
    INSERT INTO estilos (nom_estilo) VALUES ('Bar / Tragos');

PRINT 'Catálogos base verificados/creados';

/* =========================================
   2) Restaurante: Perukai
   ========================================= */

DECLARE @rest_uuid VARCHAR(36) = 'PERUKAI-2222-2222-2222-222222222222';

IF NOT EXISTS (SELECT 1 FROM restaurantes WHERE nro_restaurante = @rest_uuid)
BEGIN
    INSERT INTO restaurantes (nro_restaurante, razon_social, cuit)
    VALUES (@rest_uuid, 'Perukai S.A.', '30234567890');
    PRINT 'Restaurante Perukai insertado';
END
ELSE
BEGIN
    PRINT 'Restaurante Perukai ya existe';
END

/* =========================================
   3) Sucursal 1: Nueva Córdoba
   ========================================= */

DECLARE @nro_localidad_nueva_cordoba VARCHAR(36);
SELECT @nro_localidad_nueva_cordoba = nro_localidad FROM localidades WHERE nom_localidad='Nueva Córdoba' AND cod_provincia=@cod_cba;

DECLARE @nro_categoria_premium VARCHAR(36);
SELECT @nro_categoria_premium = nro_categoria FROM categorias_precios WHERE nom_categoria='Premium';

-- UUID fijo para Sucursal 1: Nueva Córdoba
DECLARE @suc_1_uuid VARCHAR(36) = 'PERUKAI-SUC-0001-0001-0001-0001';
IF NOT EXISTS (SELECT 1 FROM sucursales WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'Perukai - Nueva Córdoba')
BEGIN
    INSERT INTO sucursales (
        nro_restaurante, nro_sucursal, nom_sucursal, calle, nro_calle, barrio,
        nro_localidad, cod_postal, telefonos, total_comensales, min_tolerencia_reserva, nro_categoria
    )
    VALUES (
        @rest_uuid, @suc_1_uuid, 'Perukai - Nueva Córdoba',
        'Av. Humberto Primo', 450, 'Nueva Córdoba',
        @nro_localidad_nueva_cordoba, '5000', '351-555-2001', 100, 20, @nro_categoria_premium
    );
    PRINT 'Sucursal 1 (Nueva Córdoba) insertada: ' + @suc_1_uuid;
END
ELSE
BEGIN
    UPDATE sucursales SET nro_sucursal = @suc_1_uuid
    WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'Perukai - Nueva Córdoba' AND nro_sucursal != @suc_1_uuid;
    PRINT 'Sucursal 1 (Nueva Córdoba) ya existe: ' + @suc_1_uuid;
END

/* =========================================
   4) Zonas de Sucursal 1: Nueva Córdoba
   ========================================= */

-- Usar los UUIDs fijos definidos arriba
-- Salón Principal: 70 comensales
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_salon_principal)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_salon_principal, 70, 1, 1);
    PRINT 'Zona Salón Principal insertada para Sucursal 1';
END

-- Barra: 30 comensales (no permite menores)
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_barra)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_barra, 30, 0, 1);
    PRINT 'Zona Barra insertada para Sucursal 1';
END

/* =========================================
   5) Turnos de Sucursal 1: Nueva Córdoba
   ========================================= */

DECLARE @hora TIME = '20:00';
DECLARE @hora_hasta TIME;
DECLARE @i INT = 0;

WHILE @i < 4
BEGIN
    SET @hora_hasta = CAST(DATEADD(MINUTE, 120, CAST(@hora AS DATETIME)) AS TIME);
    
    IF NOT EXISTS (SELECT 1 FROM turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND hora_desde = @hora)
    BEGIN
        INSERT INTO turnos_sucursales (nro_restaurante, nro_sucursal, hora_desde, hora_hasta, habilitado)
        VALUES (@rest_uuid, @suc_1_uuid, @hora, @hora_hasta, 1);
        
        -- Zonas por turno
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_salon_principal AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_salon_principal, @hora, 1);
            
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND cod_zona = @cod_zona_barra AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@rest_uuid, @suc_1_uuid, @cod_zona_barra, @hora, 0);
    END
    
    SET @hora = @hora_hasta;
    SET @i = @i + 1;
END

PRINT 'Turnos y zonas por turno insertados para Sucursal 1';

/* =========================================
   6) Tipos de comida, especialidades y estilos para Sucursal 1
   ========================================= */

DECLARE @nro_tipo_fusion VARCHAR(36), @nro_tipo_sushi VARCHAR(36);
SELECT @nro_tipo_fusion = nro_tipo_comida FROM tipos_comidas WHERE nom_tipo_comida='Fusión';
SELECT @nro_tipo_sushi = nro_tipo_comida FROM tipos_comidas WHERE nom_tipo_comida='Sushi';

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_tipo_comida = @nro_tipo_fusion)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_tipo_fusion, 1);

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_tipo_comida = @nro_tipo_sushi)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_tipo_sushi, 1);

DECLARE @nro_estilo_gourmet VARCHAR(36), @nro_estilo_bar VARCHAR(36);
SELECT @nro_estilo_gourmet = nro_estilo FROM estilos WHERE nom_estilo='Gourmet';
SELECT @nro_estilo_bar = nro_estilo FROM estilos WHERE nom_estilo='Bar / Tragos';

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_estilo = @nro_estilo_gourmet)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_estilo_gourmet, 1);

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_estilo = @nro_estilo_bar)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_estilo_bar, 1);

PRINT 'Tipos de comida y estilos insertados para Sucursal 1';

/* =========================================
   7) Sucursal 2: Güemes
   ========================================= */

DECLARE @nro_localidad_guemes VARCHAR(36);
SELECT @nro_localidad_guemes = nro_localidad FROM localidades WHERE nom_localidad='Güemes' AND cod_provincia=@cod_cba;

-- UUID fijo para Sucursal 2: Güemes
DECLARE @suc_2_uuid VARCHAR(36) = 'PERUKAI-SUC-0002-0002-0002-0002';
IF NOT EXISTS (SELECT 1 FROM sucursales WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'Perukai - Güemes')
BEGIN
    INSERT INTO sucursales (
        nro_restaurante, nro_sucursal, nom_sucursal, calle, nro_calle, barrio,
        nro_localidad, cod_postal, telefonos, total_comensales, min_tolerencia_reserva, nro_categoria
    )
    VALUES (
        @rest_uuid, @suc_2_uuid, 'Perukai - Güemes',
        'Belgrano', 700, 'Güemes',
        @nro_localidad_guemes, '5000', '351-555-2002', 70, 20, @nro_categoria_premium
    );
    PRINT 'Sucursal 2 (Güemes) insertada: ' + @suc_2_uuid;
END
ELSE
BEGIN
    UPDATE sucursales SET nro_sucursal = @suc_2_uuid
    WHERE nro_restaurante = @rest_uuid AND nom_sucursal = 'Perukai - Güemes' AND nro_sucursal != @suc_2_uuid;
    PRINT 'Sucursal 2 (Güemes) ya existe: ' + @suc_2_uuid;
END

/* =========================================
   8) Zonas de Sucursal 2: Güemes
   ========================================= */

-- Salón Principal: 50 comensales (usar UUID fijo de zona compartida)
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND cod_zona = @cod_zona_salon_principal)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_2_uuid, @cod_zona_salon_principal, 50, 1, 1);
    PRINT 'Zona Salón Principal insertada para Sucursal 2';
END

-- Terraza: 20 comensales
IF NOT EXISTS (SELECT 1 FROM zonas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND cod_zona = @cod_zona_terraza)
BEGIN
    INSERT INTO zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
    VALUES (@rest_uuid, @suc_2_uuid, @cod_zona_terraza, 20, 1, 1);
    PRINT 'Zona Terraza insertada para Sucursal 2';
END

/* =========================================
   9) Turnos de Sucursal 2: Güemes
   ========================================= */

SET @hora = '20:00';
SET @i = 0;

WHILE @i < 3
BEGIN
    SET @hora_hasta = CAST(DATEADD(MINUTE, 120, CAST(@hora AS DATETIME)) AS TIME);
    
    IF NOT EXISTS (SELECT 1 FROM turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND hora_desde = @hora)
    BEGIN
        INSERT INTO turnos_sucursales (nro_restaurante, nro_sucursal, hora_desde, hora_hasta, habilitado)
        VALUES (@rest_uuid, @suc_2_uuid, @hora, @hora_hasta, 1);
        
        -- Zonas por turno
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND cod_zona = @cod_zona_salon_principal AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@rest_uuid, @suc_2_uuid, @cod_zona_salon_principal, @hora, 1);
            
        IF NOT EXISTS (SELECT 1 FROM zonas_turnos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND cod_zona = @cod_zona_terraza AND hora_desde = @hora)
            INSERT INTO zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde, permite_menores)
            VALUES (@rest_uuid, @suc_2_uuid, @cod_zona_terraza, @hora, 1);
    END
    
    SET @hora = @hora_hasta;
    SET @i = @i + 1;
END

PRINT 'Turnos y zonas por turno insertados para Sucursal 2';

/* =========================================
   10) Tipos de comida y estilos para Sucursal 2
   ========================================= */

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_tipo_comida = @nro_tipo_fusion)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_tipo_fusion, 1);

IF NOT EXISTS (SELECT 1 FROM tipos_comidas_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_tipo_comida = @nro_tipo_sushi)
    INSERT INTO tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_tipo_sushi, 1);

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_estilo = @nro_estilo_gourmet)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_estilo_gourmet, 1);

IF NOT EXISTS (SELECT 1 FROM estilos_sucursales WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_estilo = @nro_estilo_bar)
    INSERT INTO estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_estilo_bar, 1);

PRINT 'Tipos de comida y estilos insertados para Sucursal 2';



/* =========================================
   11) Menus para Sucursal 1: Nueva Córdoba
   ========================================= */

-- Menu 1: Menu Principal
DECLARE @nro_menu_1_uuid VARCHAR(36) = 'PERUKAI-MENU-0001-0001-0001-0001';
IF NOT EXISTS (SELECT 1 FROM menus WHERE nro_menu = @nro_menu_1_uuid)
BEGIN
    INSERT INTO menus (nro_menu, nom_menu)
    VALUES (@nro_menu_1_uuid, 'Menu Principal');
    PRINT 'Menu Principal insertado';
END
ELSE
BEGIN
    PRINT 'Menu Principal ya existe';
END

-- Asociar Menu 1 a Sucursal 1
IF NOT EXISTS (SELECT 1 FROM sucursales_menus WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_menu = @nro_menu_1_uuid)
BEGIN
    INSERT INTO sucursales_menus (nro_restaurante, nro_sucursal, nro_menu)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_menu_1_uuid);
    PRINT 'Menu Principal asociado a Sucursal 1';
END

-- Platos para Menu 1
DECLARE @nro_plato_1_uuid VARCHAR(36) = 'PERUKAI-PLATO-0001-0001-0001-0001';
IF NOT EXISTS (SELECT 1 FROM platos WHERE nro_plato = @nro_plato_1_uuid)
BEGIN
    INSERT INTO platos (nro_plato, nom_plato)
    VALUES (@nro_plato_1_uuid, 'Sushi Roll Clásico');
    PRINT 'Plato 1 (Sushi Roll Clásico) insertado';
END

DECLARE @nro_plato_2_uuid VARCHAR(36) = 'PERUKAI-PLATO-0001-0001-0001-0002';
IF NOT EXISTS (SELECT 1 FROM platos WHERE nro_plato = @nro_plato_2_uuid)
BEGIN
    INSERT INTO platos (nro_plato, nom_plato)
    VALUES (@nro_plato_2_uuid, 'Sashimi de Salmón');
    PRINT 'Plato 2 (Sashimi de Salmón) insertado';
END

DECLARE @nro_plato_3_uuid VARCHAR(36) = 'PERUKAI-PLATO-0001-0001-0001-0003';
IF NOT EXISTS (SELECT 1 FROM platos WHERE nro_plato = @nro_plato_3_uuid)
BEGIN
    INSERT INTO platos (nro_plato, nom_plato)
    VALUES (@nro_plato_3_uuid, 'Tempura de Camarones');
    PRINT 'Plato 3 (Tempura de Camarones) insertado';
END

DECLARE @nro_plato_4_uuid VARCHAR(36) = 'PERUKAI-PLATO-0001-0001-0001-0004';
IF NOT EXISTS (SELECT 1 FROM platos WHERE nro_plato = @nro_plato_4_uuid)
BEGIN
    INSERT INTO platos (nro_plato, nom_plato)
    VALUES (@nro_plato_4_uuid, 'Ramen de Cerdo');
    PRINT 'Plato 4 (Ramen de Cerdo) insertado';
END

-- Asociar platos al Menu 1
IF NOT EXISTS (SELECT 1 FROM platos_menus WHERE nro_menu = @nro_menu_1_uuid AND nro_plato = @nro_plato_1_uuid)
BEGIN
    INSERT INTO platos_menus (nro_menu, nro_plato)
    VALUES (@nro_menu_1_uuid, @nro_plato_1_uuid);
END

IF NOT EXISTS (SELECT 1 FROM platos_menus WHERE nro_menu = @nro_menu_1_uuid AND nro_plato = @nro_plato_2_uuid)
BEGIN
    INSERT INTO platos_menus (nro_menu, nro_plato)
    VALUES (@nro_menu_1_uuid, @nro_plato_2_uuid);
END

IF NOT EXISTS (SELECT 1 FROM platos_menus WHERE nro_menu = @nro_menu_1_uuid AND nro_plato = @nro_plato_3_uuid)
BEGIN
    INSERT INTO platos_menus (nro_menu, nro_plato)
    VALUES (@nro_menu_1_uuid, @nro_plato_3_uuid);
END

IF NOT EXISTS (SELECT 1 FROM platos_menus WHERE nro_menu = @nro_menu_1_uuid AND nro_plato = @nro_plato_4_uuid)
BEGIN
    INSERT INTO platos_menus (nro_menu, nro_plato)
    VALUES (@nro_menu_1_uuid, @nro_plato_4_uuid);
END

PRINT 'Platos asociados al Menu Principal';

-- Menu 2: Menu de Degustación
DECLARE @nro_menu_2_uuid VARCHAR(36) = 'PERUKAI-MENU-0001-0001-0001-0002';
IF NOT EXISTS (SELECT 1 FROM menus WHERE nro_menu = @nro_menu_2_uuid)
BEGIN
    INSERT INTO menus (nro_menu, nom_menu)
    VALUES (@nro_menu_2_uuid, 'Menu de Degustación');
    PRINT 'Menu de Degustación insertado';
END

-- Asociar Menu 2 a Sucursal 1
IF NOT EXISTS (SELECT 1 FROM sucursales_menus WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_1_uuid AND nro_menu = @nro_menu_2_uuid)
BEGIN
    INSERT INTO sucursales_menus (nro_restaurante, nro_sucursal, nro_menu)
    VALUES (@rest_uuid, @suc_1_uuid, @nro_menu_2_uuid);
    PRINT 'Menu de Degustación asociado a Sucursal 1';
END

-- Platos adicionales para Menu 2
DECLARE @nro_plato_5_uuid VARCHAR(36) = 'PERUKAI-PLATO-0001-0001-0001-0005';
IF NOT EXISTS (SELECT 1 FROM platos WHERE nro_plato = @nro_plato_5_uuid)
BEGIN
    INSERT INTO platos (nro_plato, nom_plato)
    VALUES (@nro_plato_5_uuid, 'Nigiri Variado');
    PRINT 'Plato 5 (Nigiri Variado) insertado';
END

DECLARE @nro_plato_6_uuid VARCHAR(36) = 'PERUKAI-PLATO-0001-0001-0001-0006';
IF NOT EXISTS (SELECT 1 FROM platos WHERE nro_plato = @nro_plato_6_uuid)
BEGIN
    INSERT INTO platos (nro_plato, nom_plato)
    VALUES (@nro_plato_6_uuid, 'Tataki de Atún');
    PRINT 'Plato 6 (Tataki de Atún) insertado';
END

-- Asociar platos al Menu 2
IF NOT EXISTS (SELECT 1 FROM platos_menus WHERE nro_menu = @nro_menu_2_uuid AND nro_plato = @nro_plato_5_uuid)
BEGIN
    INSERT INTO platos_menus (nro_menu, nro_plato)
    VALUES (@nro_menu_2_uuid, @nro_plato_5_uuid);
END

IF NOT EXISTS (SELECT 1 FROM platos_menus WHERE nro_menu = @nro_menu_2_uuid AND nro_plato = @nro_plato_6_uuid)
BEGIN
    INSERT INTO platos_menus (nro_menu, nro_plato)
    VALUES (@nro_menu_2_uuid, @nro_plato_6_uuid);
END

-- También agregar algunos platos del Menu 1 al Menu 2
IF NOT EXISTS (SELECT 1 FROM platos_menus WHERE nro_menu = @nro_menu_2_uuid AND nro_plato = @nro_plato_2_uuid)
BEGIN
    INSERT INTO platos_menus (nro_menu, nro_plato)
    VALUES (@nro_menu_2_uuid, @nro_plato_2_uuid);
END

PRINT 'Platos asociados al Menu de Degustación';

/* =========================================
   12) Menus para Sucursal 2: Güemes
   ========================================= */

-- Menu 3: Menu Terraza (específico para Sucursal 2)
DECLARE @nro_menu_3_uuid VARCHAR(36) = 'PERUKAI-MENU-0002-0002-0002-0001';
IF NOT EXISTS (SELECT 1 FROM menus WHERE nro_menu = @nro_menu_3_uuid)
BEGIN
    INSERT INTO menus (nro_menu, nom_menu)
    VALUES (@nro_menu_3_uuid, 'Menu Terraza');
    PRINT 'Menu Terraza insertado';
END

-- Asociar Menu 3 a Sucursal 2
IF NOT EXISTS (SELECT 1 FROM sucursales_menus WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_menu = @nro_menu_3_uuid)
BEGIN
    INSERT INTO sucursales_menus (nro_restaurante, nro_sucursal, nro_menu)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_menu_3_uuid);
    PRINT 'Menu Terraza asociado a Sucursal 2';
END

-- Platos para Menu 3
DECLARE @nro_plato_7_uuid VARCHAR(36) = 'PERUKAI-PLATO-0002-0002-0002-0001';
IF NOT EXISTS (SELECT 1 FROM platos WHERE nro_plato = @nro_plato_7_uuid)
BEGIN
    INSERT INTO platos (nro_plato, nom_plato)
    VALUES (@nro_plato_7_uuid, 'Ceviche de Pescado');
    PRINT 'Plato 7 (Ceviche de Pescado) insertado';
END

DECLARE @nro_plato_8_uuid VARCHAR(36) = 'PERUKAI-PLATO-0002-0002-0002-0002';
IF NOT EXISTS (SELECT 1 FROM platos WHERE nro_plato = @nro_plato_8_uuid)
BEGIN
    INSERT INTO platos (nro_plato, nom_plato)
    VALUES (@nro_plato_8_uuid, 'Ensalada de Algas');
    PRINT 'Plato 8 (Ensalada de Algas) insertado';
END

-- Asociar platos al Menu 3
IF NOT EXISTS (SELECT 1 FROM platos_menus WHERE nro_menu = @nro_menu_3_uuid AND nro_plato = @nro_plato_7_uuid)
BEGIN
    INSERT INTO platos_menus (nro_menu, nro_plato)
    VALUES (@nro_menu_3_uuid, @nro_plato_7_uuid);
END

IF NOT EXISTS (SELECT 1 FROM platos_menus WHERE nro_menu = @nro_menu_3_uuid AND nro_plato = @nro_plato_8_uuid)
BEGIN
    INSERT INTO platos_menus (nro_menu, nro_plato)
    VALUES (@nro_menu_3_uuid, @nro_plato_8_uuid);
END

-- También asociar algunos platos del Menu 1 al Menu 3
IF NOT EXISTS (SELECT 1 FROM platos_menus WHERE nro_menu = @nro_menu_3_uuid AND nro_plato = @nro_plato_1_uuid)
BEGIN
    INSERT INTO platos_menus (nro_menu, nro_plato)
    VALUES (@nro_menu_3_uuid, @nro_plato_1_uuid);
END

IF NOT EXISTS (SELECT 1 FROM platos_menus WHERE nro_menu = @nro_menu_3_uuid AND nro_plato = @nro_plato_3_uuid)
BEGIN
    INSERT INTO platos_menus (nro_menu, nro_plato)
    VALUES (@nro_menu_3_uuid, @nro_plato_3_uuid);
END

PRINT 'Platos asociados al Menu Terraza';

-- Menu 4: Menu Principal (compartido con Sucursal 1)
-- Asociar Menu 1 también a Sucursal 2
IF NOT EXISTS (SELECT 1 FROM sucursales_menus WHERE nro_restaurante = @rest_uuid AND nro_sucursal = @suc_2_uuid AND nro_menu = @nro_menu_1_uuid)
BEGIN
    INSERT INTO sucursales_menus (nro_restaurante, nro_sucursal, nro_menu)
    VALUES (@rest_uuid, @suc_2_uuid, @nro_menu_1_uuid);
    PRINT 'Menu Principal también asociado a Sucursal 2';
END

PRINT 'Menus y platos insertados exitosamente';

/* =========================================
   Resumen
   ========================================= */

PRINT '';
PRINT '========================================';
PRINT 'PERUKAI INSERTADO EXITOSAMENTE';
PRINT '========================================';
PRINT 'Restaurante UUID: ' + @rest_uuid;
PRINT 'Sucursales: 2 (Nueva Córdoba, Güemes)';
PRINT 'Zonas: 4 (2 por sucursal)';
PRINT 'Turnos: 7 (4 en Sucursal 1, 3 en Sucursal 2)';
PRINT 'Zonas por turno: 14';
PRINT 'Menus: 3 (Menu Principal, Menu de Degustación, Menu Terraza)';
PRINT 'Platos: 8';
PRINT '========================================';
GO

