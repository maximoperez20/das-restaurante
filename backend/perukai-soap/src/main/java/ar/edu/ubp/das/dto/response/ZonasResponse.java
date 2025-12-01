package ar.edu.ubp.das.dto.response;

import ar.edu.ubp.das.dto.ZonaDto;
import java.util.List;

/**
 * DTO para respuesta de lista de zonas.
 */
public class ZonasResponse {
    
    private final List<ZonaDto> zonas;
    
    public ZonasResponse(List<ZonaDto> zonas) {
        this.zonas = zonas;
    }
    
    public List<ZonaDto> getZonas() {
        return zonas;
    }
}
