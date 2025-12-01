package ar.edu.ubp.das.repository;

import ar.edu.ubp.das.dto.ClickDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementSetter;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;

@Repository
public class ClickRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public ClickDto registrarClick(
            String nroRestaurante,
            String nroContenido,
            String nroClick,
            LocalDateTime fechaHoraRegistro,
            String nroCliente,
            BigDecimal costoClick) {

        String sql = "EXEC sp_registrar_click ?, ?, ?, ?, ?, ?";

        return jdbcTemplate.query(
                sql,
                (PreparedStatementSetter) ps -> {
                    ps.setString(1, nroRestaurante);
                    ps.setString(2, nroContenido);
                    ps.setString(3, nroClick);
                    ps.setTimestamp(4, Timestamp.valueOf(fechaHoraRegistro));
                    if (nroCliente != null) {
                        ps.setString(5, nroCliente);
                    } else {
                        ps.setNull(5, Types.VARCHAR);
                    }
                    if (costoClick != null) {
                        ps.setBigDecimal(6, costoClick);
                    } else {
                        ps.setNull(6, Types.DECIMAL);
                    }
                },
                (rs, rowNum) -> {
                    ClickDto dto = new ClickDto();
                    dto.setExitoso(rs.getBoolean("exitoso"));
                    dto.setMensaje(rs.getString("mensaje"));
                    return dto;
                }
        ).stream().findFirst().orElse(null);
    }
}
