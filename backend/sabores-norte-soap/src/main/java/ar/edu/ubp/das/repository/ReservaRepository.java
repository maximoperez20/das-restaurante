package ar.edu.ubp.das.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Time;
import java.time.LocalDate;
import java.util.UUID;

@Repository
public class ReservaRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public String registrarReserva(
            String nroCliente,
            String nroRestaurante,
            String nroSucursal,
            String codZona,
            LocalDate fechaReserva,
            Time horaDesde,
            int cantAdultos,
            int cantMenores) {
        
        String codReserva = UUID.randomUUID().toString();
        
        String sql = "INSERT INTO reservas_sucursales (" +
                     "cod_reserva, nro_cliente, fecha_reserva, nro_restaurante, nro_sucursal, " +
                     "cod_zona, hora_desde, cant_adultos, cant_menores, cancelada, fecha_hora_registro) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, GETDATE())";
        
        jdbcTemplate.update(sql, 
            codReserva, 
            nroCliente, 
            java.sql.Date.valueOf(fechaReserva), 
            nroRestaurante, 
            nroSucursal, 
            codZona, 
            horaDesde, 
            cantAdultos, 
            cantMenores
        );
        
        return codReserva;
    }

    public boolean cancelarReserva(String codReserva) {
        String sql = "UPDATE reservas_sucursales " +
                     "SET cancelada = 1, fecha_hora_cancelacion = GETDATE() " +
                     "WHERE cod_reserva = ?";
        
        int rows = jdbcTemplate.update(sql, codReserva);
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
