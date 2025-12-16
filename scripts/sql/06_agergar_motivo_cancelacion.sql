
ALTER TABLE reservas_sucursales
ADD motivo_cancelacion NVARCHAR(255) NULL;
GO

-- Modificación del procedimiento almacenado para aceptar el nuevo parámetro opcional
CREATE OR ALTER PROCEDURE sp_CancelarReservaRestaurante
    @cod_reserva NVARCHAR(50),
    @motivo_cancelacion NVARCHAR(255) = NULL  -- Nuevo parámetro opcional
    AS
BEGIN
    UPDATE reservas_sucursales
    SET cancelada = 1,
        fecha_hora_cancelacion = GETDATE(),
        motivo_cancelacion = @motivo_cancelacion  -- Guardar el motivo si se proporciona
    WHERE cod_reserva = @cod_reserva;
END;