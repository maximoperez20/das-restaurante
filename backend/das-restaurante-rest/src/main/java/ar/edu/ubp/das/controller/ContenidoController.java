package ar.edu.ubp.das.controller;

import ar.edu.ubp.das.dto.ContenidoDto;
import ar.edu.ubp.das.repository.ContenidoRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/restaurantes/{nroRestaurante}/contenidos")
public class ContenidoController {

    private static final Logger logger = LoggerFactory.getLogger(ContenidoController.class);

    private final ContenidoRepository contenidoRepository;
    
    public ContenidoController(ContenidoRepository contenidoRepository) {
        this.contenidoRepository = contenidoRepository;
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> registrarContenido(
            @PathVariable String nroRestaurante,
            @RequestBody Map<String, Object> requestBody) {
        
        try {
            String nroSucursal = requestBody.containsKey("nroSucursal") && requestBody.get("nroSucursal") != null 
                ? (String) requestBody.get("nroSucursal") : null;
            String contenidoAPublicar = (String) requestBody.get("contenidoAPublicar");

            // Procesar imagen (puede venir como base64 string o null)
            byte[] imagenBytes = null;
            if (requestBody.containsKey("imagenAPublicar") && requestBody.get("imagenAPublicar") != null) {
                Object imagenObj = requestBody.get("imagenAPublicar");
                if (imagenObj instanceof String) {
                    // Si viene como base64 string
                    imagenBytes = Base64.getDecoder().decode((String) imagenObj);
                } else if (imagenObj instanceof byte[]) {
                    imagenBytes = (byte[]) imagenObj;
                }
            }

            // Procesar costoClick
            BigDecimal costoClick = null;
            if (requestBody.containsKey("costoClick") && requestBody.get("costoClick") != null) {
                Object costoObj = requestBody.get("costoClick");
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
            
            return ResponseEntity.ok(jsonResponse);

        } catch (Exception e) {
            logger.error("Error al registrar contenido: {}", e.getMessage(), e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("nroContenido", "");
            errorResponse.put("exitoso", false);
            errorResponse.put("mensaje", "Error al registrar contenido: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> listarContenidos(
            @PathVariable String nroRestaurante,
            @RequestParam(required = false) String nroSucursal) {
        
        try {
            // Llamar al repository
            Map<String, Object> contenido = contenidoRepository.listarContenidos(nroRestaurante, nroSucursal);

            // Construir respuesta JSON
            if (contenido != null) {
                return ResponseEntity.ok(contenido);
            } else {
                // Si no hay contenido, retornar objeto vacío
                return ResponseEntity.ok(new HashMap<>());
            }

        } catch (Exception e) {
            logger.error("Error al listar contenidos: {}", e.getMessage(), e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Error al listar contenidos: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }
}

