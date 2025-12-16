package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.repository.ReservaRepository;
import ar.edu.ubp.das.soap.gen.*;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

import java.lang.reflect.Type;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Endpoint
public class ReservaEndpoint {

    private static final String NAMESPACE_URI = "http://das.ubp.edu.ar/restaurante";

    @Autowired
    private ReservaRepository reservaRepository;

    private final Gson gson = new Gson();
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE;
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ISO_LOCAL_TIME;

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "registrarReservaRequest")
    @ResponsePayload
    public RegistrarReservaResponse registrarReserva(@RequestPayload RegistrarReservaRequest request) {
        RegistrarReservaResponse response = new RegistrarReservaResponse();
        
        try {
            // Parsear JSON recibido
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> jsonData = gson.fromJson(request.getJsonData(), mapType);
            
            // Extraer datos del cliente
            @SuppressWarnings("unchecked")
            Map<String, Object> datosCliente = (Map<String, Object>) jsonData.get("datosCliente");
            String nroCliente = reservaRepository.buscarOCrearCliente(
                (String) datosCliente.get("apellido"),
                (String) datosCliente.get("nombre"),
                (String) datosCliente.get("correo"),
                datosCliente.containsKey("telefonos") && datosCliente.get("telefonos") != null 
                    ? (String) datosCliente.get("telefonos") : null
            );
            
            // Parsear fecha y hora
            String fechaStr = (String) jsonData.get("fechaReserva");
            LocalDate fechaReserva = LocalDate.parse(fechaStr, DATE_FORMATTER);
            
            String horaStr = (String) jsonData.get("horaDesde");
            LocalTime horaLocal = LocalTime.parse(horaStr, TIME_FORMATTER);
            Time horaDesde = Time.valueOf(horaLocal);
            
            String codReserva = reservaRepository.registrarReserva(
                nroCliente,
                (String) jsonData.get("nroRestaurante"),
                (String) jsonData.get("nroSucursal"),
                (String) jsonData.get("codZona"),
                fechaReserva,
                horaDesde,
                ((Number) jsonData.get("cantAdultos")).intValue(),
                jsonData.containsKey("cantMenores") && jsonData.get("cantMenores") != null
                    ? ((Number) jsonData.get("cantMenores")).intValue() : 0,
                    jsonData.containsKey("observaciones") && jsonData.get("observaciones") != null
                    ? (String) jsonData.get("observaciones") : null
            );
            
            // Construir respuesta JSON
            Map<String, Object> jsonResponse = new HashMap<>();
            jsonResponse.put("codReserva", codReserva);
            jsonResponse.put("confirmada", true);
            jsonResponse.put("mensaje", "Reserva registrada exitosamente");
            
            response.setJsonResponse(gson.toJson(jsonResponse));
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("codReserva", "");
            errorResponse.put("confirmada", false);
            errorResponse.put("mensaje", "Error al registrar reserva: " + e.getMessage());
            response.setJsonResponse(gson.toJson(errorResponse));
        }
        
        return response;
    }

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "cancelarReservaRequest")
    @ResponsePayload
    public CancelarReservaResponse cancelarReserva(@RequestPayload CancelarReservaRequest request) {
        CancelarReservaResponse response = new CancelarReservaResponse();
        try {
            // Parsear JSON recibido
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> jsonData = gson.fromJson(request.getJsonData(), mapType);
            
            String codReserva = (String) jsonData.get("nroReserva");
            String motivoCancelacion = (String) jsonData.get("motivoCancelacion");
            boolean cancelada = reservaRepository.cancelarReserva(codReserva, motivoCancelacion);
            
            // Construir respuesta JSON
            Map<String, Object> jsonResponse = new HashMap<>();
            jsonResponse.put("actualizados", cancelada ? 1 : 0);
            jsonResponse.put("mensaje", cancelada ? "Reserva cancelada exitosamente" : "Reserva no encontrada");
            
            response.setJsonResponse(gson.toJson(jsonResponse));
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("actualizados", 0);
            errorResponse.put("mensaje", "Error al cancelar reserva: " + e.getMessage());
            response.setJsonResponse(gson.toJson(errorResponse));
        }
        
        return response;
    }
}
