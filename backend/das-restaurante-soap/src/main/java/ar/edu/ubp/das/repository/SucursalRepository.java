package ar.edu.ubp.das.repository;

import ar.edu.ubp.das.components.SimpleJdbcCallFactory;
import ar.edu.ubp.das.dto.SucursalDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class SucursalRepository {

    @Autowired
    private SimpleJdbcCallFactory jdbcCallFactory;

    public List<SucursalDto> findByRestaurante(String nroRestaurante) {
        SqlParameterSource params = new MapSqlParameterSource()
            .addValue("nro_restaurante", nroRestaurante)
            .addValue("cuit", null);
        return jdbcCallFactory.executeQuery("get_sucursales_x_restaurantes", "dbo", params, "sucursales", SucursalDto.class);
    }
}

