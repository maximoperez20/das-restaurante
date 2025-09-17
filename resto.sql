/* =========================================================================================
   MODELO: RESTAURANTE - SQL Server (T-SQL) sin IDENTITY y sin esquema 'resto'
   ========================================================================================= */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ===========================
   Limpieza (si existen)
   =========================== */
IF OBJECT_ID('reservas_sucursales','U') IS NOT NULL DROP TABLE reservas_sucursales;
IF OBJECT_ID('estilos_sucursales','U') IS NOT NULL DROP TABLE estilos_sucursales;
IF OBJECT_ID('especialidades_alimentarias_sucursales','U') IS NOT NULL DROP TABLE especialidades_alimentarias_sucursales;
IF OBJECT_ID('tipos_comidas_sucursales','U') IS NOT NULL DROP TABLE tipos_comidas_sucursales;
IF OBJECT_ID('contenidos','U') IS NOT NULL DROP TABLE contenidos;
IF OBJECT_ID('zonas_turnos_sucursales','U') IS NOT NULL DROP TABLE zonas_turnos_sucursales;
IF OBJECT_ID('turnos_sucursales','U') IS NOT NULL DROP TABLE turnos_sucursales;
IF OBJECT_ID('zonas_sucursales','U') IS NOT NULL DROP TABLE zonas_sucursales;
IF OBJECT_ID('sucursales','U') IS NOT NULL DROP TABLE sucursales;
IF OBJECT_ID('restaurantes','U') IS NOT NULL DROP TABLE restaurantes;
IF OBJECT_ID('clientes','U') IS NOT NULL DROP TABLE clientes;
IF OBJECT_ID('categorias_precios','U') IS NOT NULL DROP TABLE categorias_precios;
IF OBJECT_ID('estilos','U') IS NOT NULL DROP TABLE estilos;
IF OBJECT_ID('especialidades_alimentarias','U') IS NOT NULL DROP TABLE especialidades_alimentarias;
IF OBJECT_ID('tipos_comidas','U') IS NOT NULL DROP TABLE tipos_comidas;
IF OBJECT_ID('zonas','U') IS NOT NULL DROP TABLE zonas;
IF OBJECT_ID('localidades','U') IS NOT NULL DROP TABLE localidades;
IF OBJECT_ID('provincias','U') IS NOT NULL DROP TABLE provincias;
GO

/* =========================================
   1) Tablas de referencia
   ========================================= */

CREATE TABLE provincias (
    cod_provincia  VARCHAR(36) NOT NULL DEFAULT NEWID(),
    nom_provincia  VARCHAR(80) NOT NULL,
    CONSTRAINT PK_provincias PRIMARY KEY (cod_provincia),
    CONSTRAINT UQ_provincias_nombre UNIQUE (nom_provincia)
);
GO

CREATE TABLE localidades (
    nro_localidad  VARCHAR(36) NOT NULL DEFAULT NEWID(),
    nom_localidad  VARCHAR(100) NOT NULL,
    cod_provincia  VARCHAR(36)  NOT NULL,
    CONSTRAINT PK_localidades PRIMARY KEY (nro_localidad),
    CONSTRAINT AK_localidades_prov_nom UNIQUE (cod_provincia, nom_localidad),
    CONSTRAINT FK_localidades_provincias
        FOREIGN KEY (cod_provincia)
        REFERENCES provincias (cod_provincia)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

CREATE TABLE zonas (
    cod_zona  VARCHAR(36) NOT NULL DEFAULT NEWID(),
    nom_zona  VARCHAR(60)  NOT NULL,
    CONSTRAINT PK_zonas PRIMARY KEY (cod_zona),
    CONSTRAINT UQ_zonas_nombre UNIQUE (nom_zona)
);
GO

CREATE TABLE tipos_comidas (
    nro_tipo_comida VARCHAR(36) NOT NULL DEFAULT NEWID(),
    nom_tipo_comida VARCHAR(80) NOT NULL,
    CONSTRAINT PK_tipos_comidas PRIMARY KEY (nro_tipo_comida),
    CONSTRAINT UQ_tipos_comidas_nombre UNIQUE (nom_tipo_comida)
);
GO

CREATE TABLE especialidades_alimentarias (
    nro_restriccion VARCHAR(36) NOT NULL DEFAULT NEWID(),
    nom_restriccion VARCHAR(80) NOT NULL,
    CONSTRAINT PK_especialidades PRIMARY KEY (nro_restriccion),
    CONSTRAINT UQ_especialidades_nombre UNIQUE (nom_restriccion)
);
GO

CREATE TABLE estilos (
    nro_estilo VARCHAR(36) NOT NULL DEFAULT NEWID(),
    nom_estilo VARCHAR(80) NOT NULL,
    CONSTRAINT PK_estilos PRIMARY KEY (nro_estilo),
    CONSTRAINT UQ_estilos_nombre UNIQUE (nom_estilo)
);
GO

CREATE TABLE categorias_precios (
    nro_categoria VARCHAR(36) NOT NULL DEFAULT NEWID(),
    nom_categoria VARCHAR(40) NOT NULL,
    CONSTRAINT PK_categorias_precios PRIMARY KEY (nro_categoria),
    CONSTRAINT UQ_categorias_precios_nombre UNIQUE (nom_categoria)
);
GO

CREATE TABLE clientes (
    nro_cliente VARCHAR(36) NOT NULL DEFAULT NEWID(),
    apellido    VARCHAR(80)  NOT NULL,
    nombre      VARCHAR(80)  NOT NULL,
    correo      VARCHAR(254) NOT NULL,
    telefonos   VARCHAR(120) NULL,
    CONSTRAINT PK_clientes PRIMARY KEY (nro_cliente),
    CONSTRAINT UQ_clientes_correo UNIQUE (correo)    
);
GO

CREATE TABLE restaurantes (
    nro_restaurante VARCHAR(36) NOT NULL DEFAULT NEWID(),
    razon_social    VARCHAR(150) NOT NULL,
    cuit            VARCHAR(11)  NOT NULL,  -- sin guiones validar frontend
    CONSTRAINT PK_restaurantes PRIMARY KEY (nro_restaurante),
    CONSTRAINT UQ_restaurantes_cuit UNIQUE (cuit)
);
GO

/* =========================================
   2) Sucursales
   ========================================= */

CREATE TABLE sucursales (
    nro_restaurante         VARCHAR(36) NOT NULL ,
    nro_sucursal            VARCHAR(36) NOT NULL DEFAULT NEWID(),
    nom_sucursal            VARCHAR(120) NOT NULL,
    calle                   VARCHAR(120) NOT NULL,
    nro_calle               INT          NOT NULL,
    barrio                  VARCHAR(120) NULL,
    nro_localidad           VARCHAR(36)  NOT NULL,
    cod_postal              VARCHAR(10)  NOT NULL,
    telefonos               VARCHAR(120) NULL,
    total_comensales        INT          NOT NULL,
    min_tolerencia_reserva  INT          NOT NULL DEFAULT 0,  -- minutos
    nro_categoria           VARCHAR(36)  NOT NULL,
    CONSTRAINT PK_sucursales PRIMARY KEY (nro_restaurante, nro_sucursal),
    CONSTRAINT FK_suc_restaurantes
        FOREIGN KEY (nro_restaurante)
        REFERENCES restaurantes (nro_restaurante)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_suc_localidades
        FOREIGN KEY (nro_localidad)
        REFERENCES localidades (nro_localidad)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_suc_categorias
        FOREIGN KEY (nro_categoria)
        REFERENCES categorias_precios (nro_categoria)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT CK_suc_total_comensales CHECK (total_comensales > 0),
    CONSTRAINT CK_suc_min_toler CHECK (min_tolerencia_reserva BETWEEN 0 AND 240)
);
GO

/* =========================================
   3) Zonas por sucursal
   ========================================= */

CREATE TABLE zonas_sucursales (
    nro_restaurante VARCHAR(36)  NOT NULL,
    nro_sucursal    VARCHAR(36)  NOT NULL,
    cod_zona        VARCHAR(36)  NOT NULL,
    cant_comensales SMALLINT     NOT NULL,
    permite_menores BIT          NOT NULL CONSTRAINT DF_zs_perm_men DEFAULT (1),
    habilitada      BIT          NOT NULL CONSTRAINT DF_zs_hab      DEFAULT (1),
    CONSTRAINT PK_zonas_sucursales PRIMARY KEY (nro_restaurante, nro_sucursal, cod_zona),
    CONSTRAINT FK_zs_sucursales
        FOREIGN KEY (nro_restaurante, nro_sucursal)
        REFERENCES sucursales (nro_restaurante, nro_sucursal)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_zs_zonas
        FOREIGN KEY (cod_zona)
        REFERENCES zonas (cod_zona)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT CK_zs_cant_comensales CHECK (cant_comensales > 0)
);
GO

/* =========================================
   4) Turnos y zonas por turno
   ========================================= */

CREATE TABLE turnos_sucursales (
    nro_restaurante VARCHAR(36) NOT NULL,
    nro_sucursal    VARCHAR(36) NOT NULL,
    hora_desde      TIME        NOT NULL,
    hora_hasta      TIME        NOT NULL,
    habilitado      BIT         NOT NULL CONSTRAINT DF_ts_hab DEFAULT (1),
    CONSTRAINT PK_turnos_sucursales PRIMARY KEY (nro_restaurante, nro_sucursal, hora_desde),
    CONSTRAINT FK_ts_sucursales
        FOREIGN KEY (nro_restaurante, nro_sucursal)
        REFERENCES sucursales (nro_restaurante, nro_sucursal)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

CREATE TABLE zonas_turnos_sucursales (
    nro_restaurante VARCHAR(36) NOT NULL,
    nro_sucursal    VARCHAR(36) NOT NULL,
    cod_zona        VARCHAR(36) NOT NULL,
    hora_desde      TIME        NOT NULL,
    permite_menores BIT         NOT NULL CONSTRAINT DF_zts_perm_men DEFAULT (1),
    CONSTRAINT PK_zonas_turnos_sucursales
        PRIMARY KEY (nro_restaurante, nro_sucursal, cod_zona, hora_desde),
    CONSTRAINT FK_zts_zonas_sucursales
        FOREIGN KEY (nro_restaurante, nro_sucursal, cod_zona)
        REFERENCES zonas_sucursales (nro_restaurante, nro_sucursal, cod_zona)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_zts_turnos_sucursales
        FOREIGN KEY (nro_restaurante, nro_sucursal, hora_desde)
        REFERENCES turnos_sucursales (nro_restaurante, nro_sucursal, hora_desde)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

/* =========================================
   5) Contenidos por restaurante/sucursal
   ========================================= */

CREATE TABLE contenidos (
    nro_restaurante       VARCHAR(36)   NOT NULL,
    nro_contenido         VARCHAR(36)   NOT NULL DEFAULT NEWID(),
    contenido_a_publicar  VARCHAR(500)  NOT NULL,
    imagen_a_publicar     VARBINARY(MAX) NULL,
    publicado             BIT           NOT NULL CONSTRAINT DF_cont_publicado DEFAULT (0),
    costo_click           DECIMAL(10,2) NULL,
    nro_sucursal          VARCHAR(36)   NULL,
    CONSTRAINT PK_contenidos PRIMARY KEY (nro_restaurante, nro_contenido),
    CONSTRAINT FK_contenidos_sucursales
        FOREIGN KEY (nro_restaurante, nro_sucursal)
        REFERENCES sucursales (nro_restaurante, nro_sucursal)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT CK_contenidos_costo CHECK (costo_click IS NULL OR costo_click >= 0)
);
GO

/* =========================================
   6) Clasificaciones por sucursal
   ========================================= */

CREATE TABLE tipos_comidas_sucursales (
    nro_restaurante VARCHAR(36) NOT NULL,
    nro_sucursal    VARCHAR(36) NOT NULL,
    nro_tipo_comida VARCHAR(36) NOT NULL,
    habilitado      BIT NOT NULL CONSTRAINT DF_tcs_hab DEFAULT (1),
    CONSTRAINT PK_tipos_comidas_sucursales
        PRIMARY KEY (nro_restaurante, nro_sucursal, nro_tipo_comida),
    CONSTRAINT FK_tcs_sucursales
        FOREIGN KEY (nro_restaurante, nro_sucursal)
        REFERENCES sucursales (nro_restaurante, nro_sucursal)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_tcs_tipos_comidas
        FOREIGN KEY (nro_tipo_comida)
        REFERENCES tipos_comidas (nro_tipo_comida)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

CREATE TABLE especialidades_alimentarias_sucursales (
    nro_restaurante VARCHAR(36) NOT NULL,
    nro_sucursal    VARCHAR(36) NOT NULL,
    nro_restriccion VARCHAR(36) NOT NULL,
    habilitada      BIT NOT NULL CONSTRAINT DF_eas_hab DEFAULT (1),
    CONSTRAINT PK_especialidades_alimentarias_sucursales
        PRIMARY KEY (nro_restaurante, nro_sucursal, nro_restriccion),
    CONSTRAINT FK_eas_sucursales
        FOREIGN KEY (nro_restaurante, nro_sucursal)
        REFERENCES sucursales (nro_restaurante, nro_sucursal)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_eas_especialidades
        FOREIGN KEY (nro_restriccion)
        REFERENCES especialidades_alimentarias (nro_restriccion)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

CREATE TABLE estilos_sucursales (
    nro_restaurante VARCHAR(36) NOT NULL,
    nro_sucursal    VARCHAR(36) NOT NULL,
    nro_estilo      VARCHAR(36) NOT NULL,
    habilitado      BIT NOT NULL CONSTRAINT DF_es_hab DEFAULT (1),
    CONSTRAINT PK_estilos_sucursales
        PRIMARY KEY (nro_restaurante, nro_sucursal, nro_estilo),
    CONSTRAINT FK_es_sucursales
        FOREIGN KEY (nro_restaurante, nro_sucursal)
        REFERENCES sucursales (nro_restaurante, nro_sucursal)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_es_estilos
        FOREIGN KEY (nro_estilo)
        REFERENCES estilos (nro_estilo)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

/* =========================================
   7) Reservas
   ========================================= */

CREATE TABLE reservas_sucursales (
    cod_reserva             VARCHAR(36) NOT NULL DEFAULT NEWID(),
    nro_cliente             VARCHAR(36) NOT NULL,
    fecha_reserva           DATE        NOT NULL,
    nro_restaurante         VARCHAR(36) NOT NULL,
    nro_sucursal            VARCHAR(36) NOT NULL,
    cod_zona                VARCHAR(36) NOT NULL,
    hora_desde              TIME        NOT NULL,  -- hora del turno reservado
    cant_adultos            TINYINT     NOT NULL,
    cant_menores            TINYINT     NOT NULL CONSTRAINT DF_res_menores DEFAULT (0),
    costo_reserva           DECIMAL(10,2) NULL,
    cancelada               BIT         NOT NULL CONSTRAINT DF_res_cancelada DEFAULT (0),
    fecha_hora_cancelacion  DATETIME    NULL,
    fecha_hora_registro     DATETIME    NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_reservas_sucursales PRIMARY KEY (cod_reserva),
    CONSTRAINT FK_res_clientes
        FOREIGN KEY (nro_cliente)
        REFERENCES clientes (nro_cliente)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_res_zona_turno_sucursal
        FOREIGN KEY (nro_restaurante, nro_sucursal, cod_zona, hora_desde)
        REFERENCES zonas_turnos_sucursales (nro_restaurante, nro_sucursal, cod_zona, hora_desde)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT CK_res_cantidades CHECK (cant_adultos > 0 AND cant_menores >= 0),
    CONSTRAINT CK_res_costos CHECK (costo_reserva IS NULL OR costo_reserva >= 0),
    CONSTRAINT CK_res_cancelacion
        CHECK (
            (cancelada = 0 AND fecha_hora_cancelacion IS NULL) OR
            (cancelada = 1 AND fecha_hora_cancelacion IS NOT NULL)
        )
);
GO

/* =========================================
   8) Índices recomendados
   ========================================= */

CREATE INDEX IX_localidades_prov_nom
    ON localidades (cod_provincia, nom_localidad);

CREATE INDEX IX_sucursales_localidad
    ON sucursales (nro_localidad);

CREATE INDEX IX_turnos_sucursales_busq
    ON turnos_sucursales (nro_restaurante, nro_sucursal, hora_desde)
    INCLUDE (hora_hasta, habilitado);

CREATE INDEX IX_reservas_busqueda
    ON reservas_sucursales (nro_restaurante, nro_sucursal, fecha_reserva, hora_desde)
    INCLUDE (cod_reserva, cant_adultos, cant_menores, cancelada);
GO