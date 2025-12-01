package ar.edu.ubp.das.repository;

import ar.edu.ubp.das.dto.ContenidoDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementSetter;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.sql.Types;

@Repository
public class ContenidoRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public ContenidoDto registrarContenido(
            String nroRestaurante,
            String nroSucursal,
            String contenidoAPublicar,
            byte[] imagenAPublicar,
            BigDecimal costoClick) {

        String sql = "EXEC sp_registrar_contenido ?, ?, ?, ?, ?";

        return jdbcTemplate.query(
                sql,
                (PreparedStatementSetter) ps -> {
                    ps.setString(1, nroRestaurante);
                    ps.setString(2, nroSucursal);
                    ps.setString(3, contenidoAPublicar);
                    if (imagenAPublicar != null) {
                        ps.setBytes(4, imagenAPublicar);
                    } else {
                        ps.setNull(4, Types.VARBINARY);
                    }
                    if (costoClick != null) {
                        ps.setBigDecimal(5, costoClick);
                    } else {
                        ps.setNull(5, Types.DECIMAL);
                    }
                },
                (rs, rowNum) -> {
                    ContenidoDto dto = new ContenidoDto();
                    dto.setNroContenido(rs.getString("nro_contenido"));
                    dto.setExitoso(rs.getBoolean("exitoso"));
                    dto.setMensaje(rs.getString("mensaje"));
                    return dto;
                }
        ).stream().findFirst().orElse(null);
    }

    public java.util.Map<String, Object> listarContenidos(String nroRestaurante, String nroSucursal) {
        String sql = "EXEC sp_ListarContenidos ?, ?";

        java.util.List<java.util.Map<String, Object>> resultados = jdbcTemplate.query(
                sql,
                (rs, rowNum) -> {
                    java.util.Map<String, Object> contenido = new java.util.HashMap<>();
                    contenido.put("nroContenido", rs.getString("nro_contenido"));
                    contenido.put("contenidoAPublicar", rs.getString("contenido_a_publicar"));
                    contenido.put("costoClick", rs.getBigDecimal("costo_click"));
                    contenido.put("nroSucursal", rs.getString("nro_sucursal"));
                    contenido.put("publicado", rs.getBoolean("publicado"));
                    // Las imágenes se manejan con URL, así que retornamos null
                    contenido.put("imagenAPublicar", null);
                    return contenido;
                },
                nroRestaurante,
                nroSucursal
        );

        return resultados.isEmpty() ? null : resultados.get(0);
    }
}

