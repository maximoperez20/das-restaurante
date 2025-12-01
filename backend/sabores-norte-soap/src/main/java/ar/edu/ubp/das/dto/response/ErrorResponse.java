package ar.edu.ubp.das.dto.response;

/**
 * DTO para respuestas de error.
 * Encapsula la estructura de errores de manera consistente.
 */
public class ErrorResponse {
    
    private final String error;
    
    public ErrorResponse(String error) {
        this.error = error;
    }
    
    public String getError() {
        return error;
    }
}
