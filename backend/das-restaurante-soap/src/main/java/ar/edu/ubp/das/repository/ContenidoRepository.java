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

    public java.util.List<java.util.Map<String, Object>> listarContenidos(String nroRestaurante, String nroSucursal) {
        String sql = "SELECT nro_contenido, contenido_a_publicar, imagen_a_publicar, costo_click, nro_sucursal " +
                "FROM contenidos WHERE nro_restaurante = ? AND (? IS NULL OR nro_sucursal = ?) AND publicado = 0";

        return jdbcTemplate.query(
                sql,
                (rs, rowNum) -> {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
                    map.put("nroContenido", rs.getString("nro_contenido"));
                    map.put("contenidoAPublicar", rs.getString("contenido_a_publicar"));
                    byte[] img = rs.getBytes("imagen_a_publicar");
                    if (img != null) {
                        map.put("imagenAPublicar", java.util.Base64.getEncoder().encodeToString(img));
                    } else {
                        map.put("imagenAPublicar", null);
                    }
                    map.put("costoClick", rs.getBigDecimal("costo_click"));
                    map.put("nroSucursal", rs.getString("nro_sucursal"));
                    return map;
                },
                nroRestaurante,
                nroSucursal,
                nroSucursal
        );
    }

    public int marcarPublicado(String nroRestaurante, String nroContenido) {
        String sql = "UPDATE contenidos SET publicado = 1 WHERE nro_restaurante = ? AND nro_contenido = ?";
        return jdbcTemplate.update(sql, nroRestaurante, nroContenido);
    }
}

