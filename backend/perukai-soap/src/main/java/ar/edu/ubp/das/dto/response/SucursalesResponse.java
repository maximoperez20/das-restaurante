package ar.edu.ubp.das.dto.response;

import ar.edu.ubp.das.dto.SucursalDto;
import java.util.List;

/**
 * DTO para respuesta de lista de sucursales.
 */
public class SucursalesResponse {
    
    private final List<SucursalDto> sucursales;
    
    public SucursalesResponse(List<SucursalDto> sucursales) {
        this.sucursales = sucursales;
    }
    
    public List<SucursalDto> getSucursales() {
        return sucursales;
    }
}
