package ar.edu.ubp.das.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Time;
import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;

@Repository
public class ReservaRepository {

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
            int cantMenores,
            String observaciones) {
        
        String sql = "EXEC dbo.sp_registrar_reserva ?, ?, ?, ?, ?, ?, ?, ?, ?";
        
        try {
            Map<String, Object> result = jdbcTemplate.queryForMap(sql, 
                nroCliente, 
                nroRestaurante, 
                nroSucursal, 
                codZona, 
                java.sql.Date.valueOf(fechaReserva), 
                horaDesde, 
                cantAdultos, 
                cantMenores,
                observaciones
            );
            
            return (String) result.get("cod_reserva");
            
        } catch (DataAccessException e) {
            // El SP lanzará un error si no hay disponibilidad o alguna validación falla
            throw new RuntimeException("Error al registrar reserva: " + e.getMessage(), e);
        }
    }

    public boolean cancelarReserva(String codReserva, String motivoCancelacion) {
        String sql = "EXEC dbo.sp_CancelarReservaRestaurante ?,?";
        
        int rows = jdbcTemplate.update(sql, codReserva, motivoCancelacion);
        return rows > 0;
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
