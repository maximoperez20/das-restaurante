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
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/restaurantes/{nroRestaurante}/contenidos/{nroContenido}/clicks")
public class ClickController {

    private static final Logger logger = LoggerFactory.getLogger(ClickController.class);
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    private final ClickRepository clickRepository;
    
    public ClickController(ClickRepository clickRepository) {
        this.clickRepository = clickRepository;
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> notificarClick(
            @PathVariable String nroRestaurante,
            @PathVariable String nroContenido,
            @RequestBody Map<String, Object> requestBody) {
        
        try {
            String nroClick = (String) requestBody.get("nroClick");
            String fechaHoraRegistroStr = (String) requestBody.get("fechaHoraRegistro");

            LocalDateTime fechaHoraRegistro;
            if (fechaHoraRegistroStr != null && !fechaHoraRegistroStr.trim().isEmpty()) {
                fechaHoraRegistro = LocalDateTime.parse(fechaHoraRegistroStr, DATE_TIME_FORMATTER);
            } else {
                fechaHoraRegistro = LocalDateTime.now();
            }

            String nroCliente = null;
            if (requestBody.containsKey("nroCliente") && requestBody.get("nroCliente") != null) {
                Object nroClienteObj = requestBody.get("nroCliente");
                if (nroClienteObj instanceof String && !((String) nroClienteObj).trim().isEmpty()) {
                    nroCliente = (String) nroClienteObj;
                }
            }

            BigDecimal costoClick = null;
            if (requestBody.containsKey("costoClick") && requestBody.get("costoClick") != null) {
                Object costoObj = requestBody.get("costoClick");
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

            Map<String, Object> jsonResponse = new HashMap<>();
            jsonResponse.put("exitoso", resultado.isExitoso());
            jsonResponse.put("mensaje", resultado.getMensaje() != null ? resultado.getMensaje() : "");
            
            return ResponseEntity.ok(jsonResponse);

        } catch (Exception e) {
            logger.error("Error al notificar click: {}", e.getMessage(), e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("exitoso", false);
            errorResponse.put("mensaje", "Error al notificar click: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }
}

