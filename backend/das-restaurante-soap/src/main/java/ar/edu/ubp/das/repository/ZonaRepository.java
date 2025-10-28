package ar.edu.ubp.das.repository;

import ar.edu.ubp.das.components.SimpleJdbcCallFactory;
import ar.edu.ubp.das.dto.ZonaDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class ZonaRepository {

    @Autowired
    private SimpleJdbcCallFactory jdbcCallFactory;

    public List<ZonaDto> findBySucursal(String nroRestaurante, String nroSucursal) {
        SqlParameterSource params = new MapSqlParameterSource()
            .addValue("nro_restaurante", nroRestaurante)
            .addValue("nro_sucursal", nroSucursal);
        return jdbcCallFactory.executeQuery("get_zonas_x_sucursales", "dbo", params, "zonas", ZonaDto.class);
    }
}

