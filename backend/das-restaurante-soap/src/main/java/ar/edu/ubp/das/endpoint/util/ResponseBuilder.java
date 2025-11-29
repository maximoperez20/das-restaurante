package ar.edu.ubp.das.endpoint.util;

import ar.edu.ubp.das.dto.response.ErrorResponse;
import com.google.gson.Gson;

/**
 * Utilidad para construir respuestas JSON de manera consistente.
 * Encapsula la lógica de serialización y construcción de respuestas.
 * 
 * Principio DRY: Evita duplicación de código en los endpoints.
 */
public class ResponseBuilder {
    
    private final Gson gson;
    
    public ResponseBuilder(Gson gson) {
        this.gson = gson;
    }
    
    /**
     * Construye una respuesta JSON de error.
     * 
     * @param errorMessage Mensaje de error
     * @return JSON string con el error
     */
    public String buildErrorResponse(String errorMessage) {
        ErrorResponse errorResponse = new ErrorResponse(errorMessage);
        return gson.toJson(errorResponse);
    }
    
    /**
     * Construye una respuesta JSON exitosa a partir de un objeto.
     * 
     * @param data Objeto a serializar
     * @return JSON string con los datos
     */
    public String buildSuccessResponse(Object data) {
        return gson.toJson(data);
    }
}
