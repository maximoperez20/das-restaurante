package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.dto.ClickDto;
import ar.edu.ubp.das.repository.ClickRepository;
import ar.edu.ubp.das.soap.gen.NotificarClickRequest;
import ar.edu.ubp.das.soap.gen.NotificarClickResponse;
import ar.edu.ubp.das.soap.gen.NotificarClicksBatchRequest;
import ar.edu.ubp.das.soap.gen.NotificarClicksBatchResponse;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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
        try {
            // Parsear JSON recibido con GSON
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> jsonData = gson.fromJson(request.getJsonData(), mapType);
            
            String nroRestaurante = (String) jsonData.get("nroRestaurante");
            String nroContenido = (String) jsonData.get("nroContenido");
            String nroClick = (String) jsonData.get("nroClick");
            String fechaHoraRegistroStr = (String) jsonData.get("fechaHoraRegistro");

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

            // Construir respuesta JSON
            Map<String, Object> jsonResponse = new HashMap<>();
            jsonResponse.put("exitoso", resultado.isExitoso());
            jsonResponse.put("mensaje", resultado.getMensaje() != null ? resultado.getMensaje() : "");
            
            String jsonResponseStr = gson.toJson(jsonResponse);

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

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "notificarClicksBatchRequest")
    @ResponsePayload
    public NotificarClicksBatchResponse notificarClicksBatch(@RequestPayload NotificarClicksBatchRequest request) {
        try {
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> jsonData = gson.fromJson(request.getJsonData(), mapType);
            
            String nroRestaurante = (String) jsonData.get("nroRestaurante");
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> clicksList = (List<Map<String, Object>>) jsonData.get("clicks");

            if (clicksList == null || clicksList.isEmpty()) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("exitoso", false);
                errorResponse.put("mensaje", "No se proporcionaron clicks para procesar");
                errorResponse.put("totalClicks", 0);
                errorResponse.put("clicksExitosos", 0);
                errorResponse.put("clicksFallidos", 0);
                errorResponse.put("resultados", new ArrayList<>());
                
                NotificarClicksBatchResponse response = new NotificarClicksBatchResponse();
                response.setJsonResponse(gson.toJson(errorResponse));
                return response;
            }

            List<Map<String, Object>> resultados = new ArrayList<>();
            int clicksExitosos = 0;
            int clicksFallidos = 0;

            for (Map<String, Object> clickData : clicksList) {
                String nroClick = (String) clickData.get("nroClick");
                String nroContenido = (String) clickData.get("nroContenido");
                String fechaHoraRegistroStr = (String) clickData.get("fechaHoraRegistro");
                
                try {
                    LocalDateTime fechaHoraRegistro;
                    if (fechaHoraRegistroStr != null && !fechaHoraRegistroStr.trim().isEmpty()) {
                        fechaHoraRegistro = LocalDateTime.parse(fechaHoraRegistroStr, DATE_TIME_FORMATTER);
                    } else {
                        fechaHoraRegistro = LocalDateTime.now();
                    }

                    String nroCliente = null;
                    if (clickData.containsKey("nroCliente") && clickData.get("nroCliente") != null) {
                        Object nroClienteObj = clickData.get("nroCliente");
                        if (nroClienteObj instanceof String && !((String) nroClienteObj).trim().isEmpty()) {
                            nroCliente = (String) nroClienteObj;
                        }
                    }

                    BigDecimal costoClick = null;
                    if (clickData.containsKey("costoClick") && clickData.get("costoClick") != null) {
                        Object costoObj = clickData.get("costoClick");
                        if (costoObj instanceof Number) {
                            costoClick = BigDecimal.valueOf(((Number) costoObj).doubleValue());
                        } else if (costoObj instanceof String) {
                            costoClick = new BigDecimal((String) costoObj);
                        }
                    }

                    ClickDto resultado = clickRepository.registrarClick(
                            nroRestaurante,
                            nroContenido,
                            nroClick,
                            fechaHoraRegistro,
                            nroCliente,
                            costoClick
                    );

                    Map<String, Object> resultadoClick = new HashMap<>();
                    resultadoClick.put("nroClick", nroClick);
                    resultadoClick.put("exitoso", resultado.isExitoso());
                    resultadoClick.put("mensaje", resultado.getMensaje() != null ? resultado.getMensaje() : "");
                    resultados.add(resultadoClick);

                    if (resultado.isExitoso()) {
                        clicksExitosos++;
                    } else {
                        clicksFallidos++;
                    }

                } catch (Exception e) {
                    logger.error("Error al procesar click {} en batch: {}", nroClick, e.getMessage(), e);
                    clicksFallidos++;
                    
                    Map<String, Object> resultadoClick = new HashMap<>();
                    resultadoClick.put("nroClick", nroClick);
                    resultadoClick.put("exitoso", false);
                    resultadoClick.put("mensaje", "Error al procesar click: " + e.getMessage());
                    resultados.add(resultadoClick);
                }
            }

            Map<String, Object> jsonResponse = new HashMap<>();
            jsonResponse.put("exitoso", clicksFallidos == 0);
            jsonResponse.put("mensaje", String.format("Procesados %d clicks: %d exitosos, %d fallidos", 
                    clicksList.size(), clicksExitosos, clicksFallidos));
            jsonResponse.put("totalClicks", clicksList.size());
            jsonResponse.put("clicksExitosos", clicksExitosos);
            jsonResponse.put("clicksFallidos", clicksFallidos);
            jsonResponse.put("resultados", resultados);
            
            String jsonResponseStr = gson.toJson(jsonResponse);

            NotificarClicksBatchResponse response = new NotificarClicksBatchResponse();
            response.setJsonResponse(jsonResponseStr);

            return response;

        } catch (Exception e) {
            logger.error("Error al notificar clicks en batch: {}", e.getMessage(), e);
            
            try {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("exitoso", false);
                errorResponse.put("mensaje", "Error al procesar batch de clicks: " + e.getMessage());
                errorResponse.put("totalClicks", 0);
                errorResponse.put("clicksExitosos", 0);
                errorResponse.put("clicksFallidos", 0);
                errorResponse.put("resultados", new ArrayList<>());
                
                NotificarClicksBatchResponse response = new NotificarClicksBatchResponse();
                response.setJsonResponse(gson.toJson(errorResponse));
                return response;
            } catch (Exception ex) {
                logger.error("Error al construir respuesta de error", ex);
                NotificarClicksBatchResponse response = new NotificarClicksBatchResponse();
                response.setJsonResponse("{\"exitoso\":false,\"mensaje\":\"Error crítico al procesar respuesta\",\"totalClicks\":0,\"clicksExitosos\":0,\"clicksFallidos\":0,\"resultados\":[]}");
                return response;
            }
        }
    }
}

