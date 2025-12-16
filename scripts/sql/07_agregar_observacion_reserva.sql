alter table reservas_sucursales
add observaciones varchar(400)

CREATE OR ALTER PROCEDURE dbo.sp_registrar_reserva
  @nro_cliente VARCHAR(36),
  @nro_restaurante VARCHAR(36),
  @nro_sucursal VARCHAR(36),
  @cod_zona VARCHAR(36),
  @fecha_reserva DATE,
  @hora_desde TIME,
  @cant_adultos INT,
  @cant_menores INT,
  @observaciones VARCHAR(400)
AS
BEGIN
  SET NOCOUNT ON;
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- Evitar race conditions

  BEGIN TRANSACTION;

  BEGIN TRY
    DECLARE @cant_total INT = @cant_adultos + @cant_menores;

    -- 1. Validar que la zona existe y está habilitada
    DECLARE @zona_existe BIT = 0;
    DECLARE @permite_menores BIT = 0;
    DECLARE @capacidad_zona INT = 0;

    SELECT
      @zona_existe = 1,
      @permite_menores = zs.permite_menores,
      @capacidad_zona = zs.cant_comensales
    FROM zonas_sucursales zs
    WHERE zs.nro_restaurante = @nro_restaurante
      AND zs.nro_sucursal = @nro_sucursal
      AND zs.cod_zona = @cod_zona
      AND zs.habilitada = 1;

    IF @zona_existe = 0
    BEGIN
      RAISERROR('La zona especificada no existe o no está habilitada', 16, 1);
      ROLLBACK TRANSACTION;
      RETURN;
    END

    -- 2. Validar que permite menores si se solicitan
    IF @cant_menores > 0 AND @permite_menores = 0
    BEGIN
      RAISERROR('La zona seleccionada no permite menores', 16, 1);
      ROLLBACK TRANSACTION;
      RETURN;
    END

    -- 3. Validar que el turno existe y está habilitado
    DECLARE @turno_existe BIT = 0;

    SELECT @turno_existe = 1
    FROM zonas_turnos_sucursales zts
    JOIN turnos_sucursales t ON t.nro_restaurante = zts.nro_restaurante
      AND t.nro_sucursal = zts.nro_sucursal
      AND t.hora_desde = zts.hora_desde
    WHERE zts.nro_restaurante = @nro_restaurante
      AND zts.nro_sucursal = @nro_sucursal
      AND zts.cod_zona = @cod_zona
      AND zts.hora_desde = @hora_desde
      AND t.habilitado = 1;

    IF @turno_existe = 0
    BEGIN
      RAISERROR('El horario seleccionado no está disponible', 16, 1);
      ROLLBACK TRANSACTION;
      RETURN;
    END

    -- 4. Calcular disponibilidad actual (con lock para evitar race conditions)
    DECLARE @ya_reservados INT = 0;

    SELECT @ya_reservados = ISNULL(SUM(CAST(cant_adultos AS INT) + CAST(cant_menores AS INT)), 0)
    FROM reservas_sucursales WITH (UPDLOCK, HOLDLOCK)
    WHERE nro_restaurante = @nro_restaurante
      AND nro_sucursal = @nro_sucursal
      AND cod_zona = @cod_zona
      AND fecha_reserva = @fecha_reserva
      AND hora_desde = @hora_desde
      AND cancelada = 0;

    DECLARE @disponibilidad INT = @capacidad_zona - @ya_reservados;

    -- 5. Validar disponibilidad
    IF @disponibilidad < @cant_total
    BEGIN
      RAISERROR('No hay suficiente capacidad disponible. Disponibilidad: %d, Solicitado: %d',
                16, 1, @disponibilidad, @cant_total);
      ROLLBACK TRANSACTION;
      RETURN;
    END

    -- 6. Si todo está bien, insertar la reserva
    DECLARE @cod_reserva VARCHAR(36) = NEWID();

    INSERT INTO reservas_sucursales (
      cod_reserva, nro_cliente, fecha_reserva, nro_restaurante, nro_sucursal,
      cod_zona, hora_desde, cant_adultos, cant_menores, cancelada, fecha_hora_registro, observaciones
    )
    VALUES (
      @cod_reserva, @nro_cliente, @fecha_reserva, @nro_restaurante, @nro_sucursal,
      @cod_zona, @hora_desde, @cant_adultos, @cant_menores, 0, GETDATE(), @observaciones
    );

    COMMIT TRANSACTION;

    SELECT @cod_reserva AS cod_reserva;

  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
  END CATCH
END
GO

