package ar.edu.ubp.das.dto.response;

import ar.edu.ubp.das.dto.RestauranteDto;
import java.util.List;

/**
 * DTO para respuesta de lista de restaurantes.
 * Encapsula la estructura de respuesta de manera tipada.
 */
public class RestaurantesResponse {
    
    private final List<RestauranteDto> restaurantes;
    
    public RestaurantesResponse(List<RestauranteDto> restaurantes) {
        this.restaurantes = restaurantes;
    }
    
    public List<RestauranteDto> getRestaurantes() {
        return restaurantes;
    }
}

