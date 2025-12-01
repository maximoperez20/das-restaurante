package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.dto.HorarioDisponibleDto;
import ar.edu.ubp.das.repository.DisponibilidadRepository;
import ar.edu.ubp.das.soap.gen.GetHorariosDisponiblesRequest;
import ar.edu.ubp.das.soap.gen.GetHorariosDisponiblesResponse;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

import java.lang.reflect.Type;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Endpoint
public class DisponibilidadEndpoint {

    private static final Logger logger = LoggerFactory.getLogger(DisponibilidadEndpoint.class);
    private static final String NAMESPACE_URI = "http://das.ubp.edu.ar/restaurante";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE;

    @Autowired
    private DisponibilidadRepository disponibilidadRepository;

    private final Gson gson = new Gson();

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "getHorariosDisponiblesRequest")
    @ResponsePayload
    public GetHorariosDisponiblesResponse getHorariosDisponibles(@RequestPayload GetHorariosDisponiblesRequest request) {
        try {
            // Parsear JSON recibido con GSON
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> jsonData = gson.fromJson(request.getJsonData(), mapType);
            
            String nroRestaurante = (String) jsonData.get("nroRestaurante");
            String nroSucursal = (String) jsonData.get("nroSucursal");
            String codZona = jsonData.containsKey("codZona") && jsonData.get("codZona") != null 
                ? (String) jsonData.get("codZona") : null;
            String fechaStr = (String) jsonData.get("fecha");
            Integer cantidad = jsonData.containsKey("cantidad") && jsonData.get("cantidad") != null 
                ? ((Number) jsonData.get("cantidad")).intValue() : null;

            // Parsear fecha
            LocalDate fecha = LocalDate.parse(fechaStr, DATE_FORMATTER);
            
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
            jsonResponse.put("fecha", fechaStr);
            
            String jsonResponseStr = gson.toJson(jsonResponse);

            GetHorariosDisponiblesResponse response = new GetHorariosDisponiblesResponse();
            response.setJsonResponse(jsonResponseStr);
            
            return response;
            
        } catch (Exception e) {
            logger.error("Error al obtener horarios disponibles: {}", e.getMessage(), e);
            
            try {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("zonas", new ArrayList<>());
                errorResponse.put("totalZonas", 0);
                errorResponse.put("error", "Error al obtener horarios disponibles: " + e.getMessage());
                
                String errorJson = gson.toJson(errorResponse);
                
                GetHorariosDisponiblesResponse response = new GetHorariosDisponiblesResponse();
                response.setJsonResponse(errorJson);
                return response;
            } catch (Exception ex) {
                logger.error("Error al construir respuesta de error", ex);
                GetHorariosDisponiblesResponse response = new GetHorariosDisponiblesResponse();
                response.setJsonResponse("{\"zonas\":[],\"totalZonas\":0,\"error\":\"Error crítico al procesar respuesta\"}");
                return response;
            }
        }
    }
}
