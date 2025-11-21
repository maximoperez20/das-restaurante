package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.dto.ContenidoDto;
import ar.edu.ubp.das.repository.ContenidoRepository;
import ar.edu.ubp.das.soap.gen.ListarContenidosRequest;
import ar.edu.ubp.das.soap.gen.ListarContenidosResponse;
import ar.edu.ubp.das.soap.gen.RegistrarContenidoRequest;
import ar.edu.ubp.das.soap.gen.RegistrarContenidoResponse;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

import java.math.BigDecimal;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@Endpoint
public class ContenidoEndpoint {

    private static final Logger logger = LoggerFactory.getLogger(ContenidoEndpoint.class);
    private static final String NAMESPACE_URI = "http://das.ubp.edu.ar/restaurante";

    @Autowired
    private ContenidoRepository contenidoRepository;

    private final Gson gson = new Gson();

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "registrarContenidoRequest")
    @ResponsePayload
    public RegistrarContenidoResponse registrarContenido(@RequestPayload RegistrarContenidoRequest request) {
        try {
            // Parsear JSON recibido con GSON
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> jsonData = gson.fromJson(request.getJsonData(), mapType);
            
            String nroRestaurante = (String) jsonData.get("nroRestaurante");
            String nroSucursal = jsonData.containsKey("nroSucursal") && jsonData.get("nroSucursal") != null 
                ? (String) jsonData.get("nroSucursal") : null;
            String contenidoAPublicar = (String) jsonData.get("contenidoAPublicar");

            // Procesar imagen (puede venir como base64 string o null)
            byte[] imagenBytes = null;
            if (jsonData.containsKey("imagenAPublicar") && jsonData.get("imagenAPublicar") != null) {
                Object imagenObj = jsonData.get("imagenAPublicar");
                if (imagenObj instanceof String) {
                    // Si viene como base64 string
                    imagenBytes = Base64.getDecoder().decode((String) imagenObj);
                } else if (imagenObj instanceof byte[]) {
                    imagenBytes = (byte[]) imagenObj;
                }
            }

            // Procesar costoClick
            BigDecimal costoClick = null;
            if (jsonData.containsKey("costoClick") && jsonData.get("costoClick") != null) {
                Object costoObj = jsonData.get("costoClick");
                if (costoObj instanceof Number) {
                    costoClick = BigDecimal.valueOf(((Number) costoObj).doubleValue());
                } else if (costoObj instanceof String) {
                    costoClick = new BigDecimal((String) costoObj);
                }
            }

            // Llamar al stored procedure
            ContenidoDto resultado = contenidoRepository.registrarContenido(
                    nroRestaurante,
                    nroSucursal,
                    contenidoAPublicar,
                    imagenBytes,
                    costoClick
            );

            // Construir respuesta JSON
            Map<String, Object> jsonResponse = new HashMap<>();
            jsonResponse.put("nroContenido", resultado.getNroContenido() != null ? resultado.getNroContenido() : "");
            jsonResponse.put("exitoso", resultado.isExitoso());
            jsonResponse.put("mensaje", resultado.getMensaje() != null ? resultado.getMensaje() : "");
            
            String jsonResponseStr = gson.toJson(jsonResponse);

            RegistrarContenidoResponse response = new RegistrarContenidoResponse();
            response.setJsonResponse(jsonResponseStr);

            return response;

        } catch (Exception e) {
            logger.error("Error al registrar contenido: {}", e.getMessage(), e);
            
            try {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("nroContenido", "");
                errorResponse.put("exitoso", false);
                errorResponse.put("mensaje", "Error al registrar contenido: " + e.getMessage());
                String errorJson = gson.toJson(errorResponse);
                
                RegistrarContenidoResponse response = new RegistrarContenidoResponse();
                response.setJsonResponse(errorJson);
                return response;
            } catch (Exception ex) {
                logger.error("Error al construir respuesta de error", ex);
                RegistrarContenidoResponse response = new RegistrarContenidoResponse();
                response.setJsonResponse("{\"exitoso\":false,\"mensaje\":\"Error crítico al procesar respuesta\"}");
                return response;
            }
        }
    }

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "listarContenidosRequest")
    @ResponsePayload
    public ListarContenidosResponse listarContenidos(@RequestPayload ListarContenidosRequest request) {
        try {
            // Parsear JSON recibido con GSON
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> jsonData = gson.fromJson(request.getJsonData(), mapType);
            
            String nroRestaurante = (String) jsonData.get("nroRestaurante");
            String nroSucursal = jsonData.containsKey("nroSucursal") && jsonData.get("nroSucursal") != null 
                ? (String) jsonData.get("nroSucursal") : null;

            // Llamar al repository
            java.util.Map<String, Object> contenido = contenidoRepository.listarContenidos(nroRestaurante, nroSucursal);

            // Construir respuesta JSON
            String jsonResponseStr;
            if (contenido != null) {
                jsonResponseStr = gson.toJson(contenido);
            } else {
                // Si no hay contenido, retornar objeto vacío
                jsonResponseStr = "{}";
            }

            ListarContenidosResponse response = new ListarContenidosResponse();
            response.setJsonResponse(jsonResponseStr);

            return response;

        } catch (Exception e) {
            logger.error("Error al listar contenidos: {}", e.getMessage(), e);
            
            try {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("error", "Error al listar contenidos: " + e.getMessage());
                String errorJson = gson.toJson(errorResponse);
                
                ListarContenidosResponse response = new ListarContenidosResponse();
                response.setJsonResponse(errorJson);
                return response;
            } catch (Exception ex) {
                logger.error("Error al construir respuesta de error", ex);
                ListarContenidosResponse response = new ListarContenidosResponse();
                response.setJsonResponse("{\"error\":\"Error crítico al procesar respuesta\"}");
                return response;
            }
        }
    }
}

