package ar.edu.ubp.das.repository;

import ar.edu.ubp.das.components.SimpleJdbcCallFactory;
import ar.edu.ubp.das.dto.HorarioDisponibleDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public class DisponibilidadRepository {

    @Autowired
    private SimpleJdbcCallFactory jdbcCallFactory;

    public List<HorarioDisponibleDto> getHorariosDisponibles(
            String nroRestaurante, 
            String nroSucursal, 
            String codZona, 
            LocalDate fecha, 
            Integer cantidad) {
        
        SqlParameterSource params = new MapSqlParameterSource()
            .addValue("nro_restaurante", nroRestaurante)
            .addValue("nro_sucursal", nroSucursal)
            .addValue("cod_zona", codZona)
            .addValue("fecha", java.sql.Date.valueOf(fecha))
            .addValue("cantidad", cantidad)
            .addValue("incluirCero", false);
        
        return jdbcCallFactory.executeQuery("get_horarios_disponibles", "dbo", params, "horarios", HorarioDisponibleDto.class);
    }
}
