package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.dto.ClickDto;
import ar.edu.ubp.das.repository.ClickRepository;
import ar.edu.ubp.das.soap.gen.NotificarClickRequest;
import ar.edu.ubp.das.soap.gen.NotificarClickResponse;
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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Endpoint
public class ClickEndpoint {

    private static final Logger logger = LoggerFactory.getLogger(ClickEndpoint.class);
    private static final String NAMESPACE_URI = "http://das.ubp.edu.ar/restaurante";
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    @Autowired
    private ClickRepository clickRepository;

    private final Gson gson = new Gson();

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "notificarClickRequest")
    @ResponsePayload
    public NotificarClickResponse notificarClick(@RequestPayload NotificarClickRequest request) {
        logger.info("SOAP - Notificar click (JSON)");
        logger.info("  JSON recibido: [{}]", request.getJsonData());

        try {
            // Parsear JSON recibido con GSON
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> jsonData = gson.fromJson(request.getJsonData(), mapType);
            
            String nroRestaurante = (String) jsonData.get("nroRestaurante");
            String nroContenido = (String) jsonData.get("nroContenido");
            String nroClick = (String) jsonData.get("nroClick");
            String fechaHoraRegistroStr = (String) jsonData.get("fechaHoraRegistro");
            
            logger.info("  nroRestaurante: [{}]", nroRestaurante);
            logger.info("  nroContenido: [{}]", nroContenido);
            logger.info("  nroClick: [{}]", nroClick);

            // Parsear fecha
            LocalDateTime fechaHoraRegistro;
            if (fechaHoraRegistroStr != null && !fechaHoraRegistroStr.trim().isEmpty()) {
                fechaHoraRegistro = LocalDateTime.parse(fechaHoraRegistroStr, DATE_TIME_FORMATTER);
            } else {
                fechaHoraRegistro = LocalDateTime.now();
            }

            // Procesar nroCliente (opcional)
            String nroCliente = null;
            if (jsonData.containsKey("nroCliente") && jsonData.get("nroCliente") != null) {
                Object nroClienteObj = jsonData.get("nroCliente");
                if (nroClienteObj instanceof String && !((String) nroClienteObj).trim().isEmpty()) {
                    nroCliente = (String) nroClienteObj;
                }
            }

            // Procesar costoClick (opcional)
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
            ClickDto resultado = clickRepository.registrarClick(
                    nroRestaurante,
                    nroContenido,
                    nroClick,
                    fechaHoraRegistro,
                    nroCliente,
                    costoClick
            );

            logger.info("Resultado SP - exitoso: {}, mensaje: {}", 
                resultado.isExitoso(), resultado.getMensaje());

            // Construir respuesta JSON
            Map<String, Object> jsonResponse = new HashMap<>();
            jsonResponse.put("exitoso", resultado.isExitoso());
            jsonResponse.put("mensaje", resultado.getMensaje() != null ? resultado.getMensaje() : "");
            
            String jsonResponseStr = gson.toJson(jsonResponse);
            logger.info("JSON respuesta: {}", jsonResponseStr);

            NotificarClickResponse response = new NotificarClickResponse();
            response.setJsonResponse(jsonResponseStr);

            return response;

        } catch (Exception e) {
            logger.error("Error al notificar click: {}", e.getMessage(), e);
            
            try {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("exitoso", false);
                errorResponse.put("mensaje", "Error al notificar click: " + e.getMessage());
                String errorJson = gson.toJson(errorResponse);
                
                NotificarClickResponse response = new NotificarClickResponse();
                response.setJsonResponse(errorJson);
                return response;
            } catch (Exception ex) {
                logger.error("Error al construir respuesta de error", ex);
                NotificarClickResponse response = new NotificarClickResponse();
                response.setJsonResponse("{\"exitoso\":false,\"mensaje\":\"Error crítico al procesar respuesta\"}");
                return response;
            }
        }
    }
}

