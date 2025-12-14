package ar.edu.ubp.das.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import ar.edu.ubp.das.dto.request.ModificarReservaDto;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Repository
public class ReservaRepository {

    private static final Logger logger = LoggerFactory.getLogger(ReservaRepository.class);

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Registra una reserva usando el stored procedure sp_registrar_reserva.
     * El SP valida disponibilidad, capacidad, zona habilitada y turno válido.
     * Lanza excepción si no hay disponibilidad o alguna validación falla.
     */
    public String registrarReserva(
            String nroCliente,
            String nroRestaurante,
            String nroSucursal,
            String codZona,
            LocalDate fechaReserva,
            Time horaDesde,
            int cantAdultos,
            int cantMenores) {
        
        String sql = "EXEC dbo.sp_registrar_reserva ?, ?, ?, ?, ?, ?, ?, ?";
        
        try {
            Map<String, Object> result = jdbcTemplate.queryForMap(sql, 
                nroCliente, 
                nroRestaurante, 
                nroSucursal, 
                codZona, 
                java.sql.Date.valueOf(fechaReserva), 
                horaDesde, 
                cantAdultos, 
                cantMenores
            );
            
            return (String) result.get("cod_reserva");
            
        } catch (DataAccessException e) {
            // El SP lanzará un error si no hay disponibilidad o alguna validación falla
            throw new RuntimeException("Error al registrar reserva: " + e.getMessage(), e);
        }
    }

    public boolean cancelarReserva(String codReserva) {
        String sql = "EXEC dbo.sp_cancelar_reserva ?";
        int rows = jdbcTemplate.update(sql, codReserva);
        return rows > 0;
    }

    public boolean modificarReserva(ModificarReservaDto modificarReservaDto){
        String sql = "EXEC dbo.sp_modificar_reserva ?, ?, ?, ?, ?, ?";
        
        try {
            java.sql.Date fechaSql = java.sql.Date.valueOf(modificarReservaDto.getFechaReserva());
            Time horaSql = Time.valueOf(modificarReservaDto.getHoraDesde());
            
            // Verificar que la reserva existe antes de modificar
            String sqlCheck = "SELECT COUNT(*) FROM reservas_sucursales WHERE cod_reserva = ?";
            Integer count = jdbcTemplate.queryForObject(sqlCheck, Integer.class, modificarReservaDto.getCodReserva());
            
            if (count == null || count == 0) {
                logger.error("Reserva no encontrada en perukai: {}", modificarReservaDto.getCodReserva());
                return false;
            }
            
            // Verificar que la zona existe
            String sqlCheckZona = "SELECT COUNT(*) FROM zonas WHERE cod_zona = ?";
            Integer countZona = jdbcTemplate.queryForObject(sqlCheckZona, Integer.class, modificarReservaDto.getCodZona());
            
            if (countZona == null || countZona == 0) {
                logger.error("Zona no encontrada en perukai: {}", modificarReservaDto.getCodZona());
                throw new RuntimeException("Zona no encontrada: " + modificarReservaDto.getCodZona());
            }
            
            int rows = jdbcTemplate.update(sql, 
                                        modificarReservaDto.getCodReserva(), 
                                        modificarReservaDto.getCodZona(), 
                                        fechaSql, 
                                        horaSql, 
                                        modificarReservaDto.getCantAdultos(), 
                                        modificarReservaDto.getCantMenores());
            
            logger.info("Filas afectadas por UPDATE: {}", rows);
            
            if (rows == 0) {
                logger.warn("No se actualizó ninguna fila. La reserva puede no existir o los datos son idénticos.");
            }
            
            return rows > 0;
        } catch (DataAccessException e) {
            logger.error("Error al modificar reserva en perukai: {}", e.getMessage(), e);
            throw new RuntimeException("Error al modificar reserva: " + e.getMessage(), e);
        } catch (IllegalArgumentException e) {
            logger.error("Error de formato en fecha/hora: {}", e.getMessage(), e);
            throw new RuntimeException("Formato de fecha u hora inválido: " + e.getMessage(), e);
        }
    }

    public String buscarOCrearCliente(String apellido, String nombre, String correo, String telefonos) {
        String sqlBuscar = "SELECT nro_cliente FROM clientes WHERE correo = ?";
        
        try {
            return jdbcTemplate.queryForObject(sqlBuscar, String.class, correo);
        } catch (Exception e) {
            String nroCliente = UUID.randomUUID().toString();
            String sqlInsertar = "INSERT INTO clientes (nro_cliente, apellido, nombre, correo, telefonos) " +
                                 "VALUES (?, ?, ?, ?, ?)";
            jdbcTemplate.update(sqlInsertar, nroCliente, apellido, nombre, correo, telefonos);
            return nroCliente;
        }
    }
}
