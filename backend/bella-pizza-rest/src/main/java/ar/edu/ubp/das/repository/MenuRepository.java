package ar.edu.ubp.das.repository;

import ar.edu.ubp.das.components.SimpleJdbcCallFactory;
import ar.edu.ubp.das.dto.MenuDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class MenuRepository {

    @Autowired
    private SimpleJdbcCallFactory jdbcCallFactory;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public Long subirMenu(MenuDto menu) {
        
        String sql = "EXEC dbo.sp_menu_subir ?, ?, ?, ?, ?, ?, ?";
    
         try {
            Map<String, Object> result = jdbcTemplate.queryForMap(sql, 
                menu.getNroRestaurante(), 
                menu.getNroSucursal(), 
                menu.getNombreArchivo(), 
                menu.getTipoMime(), 
                menu.getTamanoBytes(), 
                null, 
                menu.getDatosArchivo()
            );
            
            return (Long) result.get("nro_menu");
            
        } catch (DataAccessException e) {
            // El SP lanzará un error si no hay disponibilidad o alguna validación falla
            throw new RuntimeException("Error al registrar menu: " + e.getMessage(), e);
        }
        
    }

    public void activarMenu(Long nroMenu) {
        String sql = "EXEC dbo.sp_menu_activar ?";
        
        try {
            jdbcTemplate.update(sql, nroMenu);
        } catch (DataAccessException e) {
            throw new RuntimeException("Error al activar menu: " + e.getMessage(), e);
        }
    }

    public MenuDto obtenerActivo(String nroRestaurante, String nroSucursal) {
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("nro_restaurante", nroRestaurante)
                .addValue("nro_sucursal", nroSucursal);

        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcCallFactory.getJdbcTemplate())
                .withSchemaName("dbo")
                .withProcedureName("sp_menu_obtener_activo")
                .returningResultSet("result", (rs, rowNum) -> {
                    MenuDto dto = new MenuDto();
                    dto.setNroMenu(rs.getLong("nro_menu"));
                    dto.setNroRestaurante(nroRestaurante);
                    dto.setNroSucursal(nroSucursal);
                    dto.setNombreArchivo(rs.getString("nombre_archivo"));
                    dto.setTipoMime(rs.getString("tipo_mime"));
                    dto.setTamanoBytes(rs.getLong("tamano_bytes"));
                    dto.setHashSha256(rs.getString("hash_sha256"));
                    dto.setDatosArchivo(rs.getBytes("datos_archivo"));
                    dto.setFechaCreacion(rs.getTimestamp("fecha_creacion").toLocalDateTime());
                    dto.setActivo(Boolean.TRUE);
                    return dto;
                });

        Map<String, Object> out = jdbcCall.execute(params);

        @SuppressWarnings("unchecked")
        List<MenuDto> list = (List<MenuDto>) out.values().stream()
                .filter(v -> v instanceof List<?>)
                .findFirst()
                .orElse(List.of());

        return list.isEmpty() ? null : list.get(0);
    }

}