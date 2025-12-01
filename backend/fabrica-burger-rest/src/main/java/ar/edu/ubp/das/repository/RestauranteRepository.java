package ar.edu.ubp.das.repository;

import ar.edu.ubp.das.components.SimpleJdbcCallFactory;
import ar.edu.ubp.das.dto.RestauranteDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class RestauranteRepository {

    @Autowired
    private SimpleJdbcCallFactory jdbcCallFactory;

    public List<RestauranteDto> findAll(String query) {
        if (query == null || query.trim().isEmpty()) {
            return jdbcCallFactory.executeQuery("get_restaurantes", "dbo", "restaurantes", RestauranteDto.class);
        } else {
            SqlParameterSource params = new MapSqlParameterSource()
                .addValue("q", query);
            return jdbcCallFactory.executeQuery("get_restaurantes", "dbo", params, "restaurantes", RestauranteDto.class);
        }
    }
}

