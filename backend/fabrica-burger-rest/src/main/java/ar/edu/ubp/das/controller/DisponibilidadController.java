package ar.edu.ubp.das.controller;

import ar.edu.ubp.das.dto.HorarioDisponibleDto;
import ar.edu.ubp.das.repository.DisponibilidadRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/restaurantes/{nroRestaurante}/sucursales/{nroSucursal}/horarios-disponibles")
public class DisponibilidadController {

    private static final Logger logger = LoggerFactory.getLogger(DisponibilidadController.class);

    private final DisponibilidadRepository disponibilidadRepository;
    
    public DisponibilidadController(DisponibilidadRepository disponibilidadRepository) {
        this.disponibilidadRepository = disponibilidadRepository;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getHorariosDisponibles(
            @PathVariable String nroRestaurante,
            @PathVariable String nroSucursal,
            @RequestParam(required = false) String codZona,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha,
            @RequestParam(required = false) Integer cantidad) {
        
        try {
            // Obtener horarios disponibles desde BD
            List<HorarioDisponibleDto> horarios = disponibilidadRepository.getHorariosDisponibles(
                nroRestaurante,
                nroSucursal,
                codZona,  // NULL para todas las zonas
                fecha,
                cantidad
            );

            // Agrupar horarios por zona
            Map<String, List<Map<String, Object>>> horariosPorZona = new HashMap<>();
            
            for (HorarioDisponibleDto dto : horarios) {
                String zonaKey = dto.getCodZona();
                
                // Si es la primera vez que vemos esta zona, crear la lista
                if (!horariosPorZona.containsKey(zonaKey)) {
                    horariosPorZona.put(zonaKey, new ArrayList<>());
                }
                
                // Crear objeto de turno disponible
                Map<String, Object> turno = new HashMap<>();
                turno.put("horaDesde", dto.getHoraDesde() != null ? dto.getHoraDesde().toString() : null);
                turno.put("horaHasta", dto.getHoraHasta() != null ? dto.getHoraHasta().toString() : null);
                turno.put("capacidadZona", dto.getCapacidadZona());
                turno.put("permiteMenores", dto.getPermiteMenores());
                turno.put("yaReservados", dto.getYaReservados());
                turno.put("disponibilidad", dto.getDisponibilidad());
                
                horariosPorZona.get(zonaKey).add(turno);
            }

            // Construir respuesta JSON agrupada por zona
            List<Map<String, Object>> zonasConHorarios = new ArrayList<>();
            
            for (Map.Entry<String, List<Map<String, Object>>> entry : horariosPorZona.entrySet()) {
                String codZonaResp = entry.getKey();
                List<Map<String, Object>> turnos = entry.getValue();
                
                // Obtener información de la zona del primer turno (todos tienen la misma zona)
                HorarioDisponibleDto primerTurno = horarios.stream()
                    .filter(h -> h.getCodZona().equals(codZonaResp))
                    .findFirst()
                    .orElse(null);
                
                if (primerTurno != null) {
                    Map<String, Object> zonaInfo = new HashMap<>();
                    zonaInfo.put("codZona", codZonaResp);
                    zonaInfo.put("nomZona", primerTurno.getNomZona());
                    zonaInfo.put("capacidadZona", primerTurno.getCapacidadZona());
                    zonaInfo.put("permiteMenores", primerTurno.getPermiteMenores());
                    zonaInfo.put("horarios", turnos);
                    
                    zonasConHorarios.add(zonaInfo);
                }
            }

            // Construir respuesta JSON final
            Map<String, Object> jsonResponse = new HashMap<>();
            jsonResponse.put("zonas", zonasConHorarios);
            jsonResponse.put("totalZonas", zonasConHorarios.size());
            jsonResponse.put("fecha", fecha.toString());
            
            return ResponseEntity.ok(jsonResponse);
            
        } catch (Exception e) {
            logger.error("Error al obtener horarios disponibles: {}", e.getMessage(), e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("zonas", new ArrayList<>());
            errorResponse.put("totalZonas", 0);
            errorResponse.put("error", "Error al obtener horarios disponibles: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }
}

