package ar.edu.ubp.das.controller;

import ar.edu.ubp.das.dto.ClickDto;
import ar.edu.ubp.das.repository.ClickRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/restaurantes/{nroRestaurante}/clicks/batch")
public class ClicksBatchController {

    private static final Logger logger = LoggerFactory.getLogger(ClicksBatchController.class);
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    private final ClickRepository clickRepository;
    
    public ClicksBatchController(ClickRepository clickRepository) {
        this.clickRepository = clickRepository;
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> notificarClicksBatch(
            @PathVariable String nroRestaurante,
            @RequestBody Map<String, Object> requestBody) {
        
        try {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> clicksList = (List<Map<String, Object>>) requestBody.get("clicks");

            if (clicksList == null || clicksList.isEmpty()) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("exitoso", false);
                errorResponse.put("mensaje", "No se proporcionaron clicks para procesar");
                errorResponse.put("totalClicks", 0);
                errorResponse.put("clicksExitosos", 0);
                errorResponse.put("clicksFallidos", 0);
                errorResponse.put("resultados", new ArrayList<>());
                
                return ResponseEntity.badRequest().body(errorResponse);
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
            
            return ResponseEntity.ok(jsonResponse);

        } catch (Exception e) {
            logger.error("Error al notificar clicks en batch: {}", e.getMessage(), e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("exitoso", false);
            errorResponse.put("mensaje", "Error al procesar batch de clicks: " + e.getMessage());
            errorResponse.put("totalClicks", 0);
            errorResponse.put("clicksExitosos", 0);
            errorResponse.put("clicksFallidos", 0);
            errorResponse.put("resultados", new ArrayList<>());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }
}

