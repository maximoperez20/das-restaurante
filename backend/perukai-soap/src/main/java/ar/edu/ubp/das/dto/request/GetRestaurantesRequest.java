package ar.edu.ubp.das.dto.request;

/**
 * DTO para request de obtener restaurantes.
 * Encapsula los parámetros de entrada de manera tipada.
 */
public class GetRestaurantesRequest {
    
    private String query;
    
    public GetRestaurantesRequest() {}
    
    public GetRestaurantesRequest(String query) {
        this.query = query;
    }
    
    public String getQuery() {
        return query;
    }
    
    public void setQuery(String query) {
        this.query = query;
    }
}
