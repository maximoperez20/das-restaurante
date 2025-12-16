package ar.edu.ubp.das.controller;

import ar.edu.ubp.das.repository.ReservaRepository;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/restaurantes/{nroRestaurante}/reservas")
public class ReservaController {

    private final ReservaRepository reservaRepository;
    
    public ReservaController(ReservaRepository reservaRepository) {
        this.reservaRepository = reservaRepository;
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> registrarReserva(
            @PathVariable String nroRestaurante,
            @RequestBody Map<String, Object> requestBody) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> datosCliente = (Map<String, Object>) requestBody.get("datosCliente");
            
            String nroCliente = reservaRepository.buscarOCrearCliente(
                (String) datosCliente.get("apellido"),
                (String) datosCliente.get("nombre"),
                (String) datosCliente.get("correo"),
                (String) datosCliente.get("telefonos")
            );
            
            String fechaStr = (String) requestBody.get("fechaReserva");
            LocalDate fechaReserva = LocalDate.parse(fechaStr);
            
            String horaStr = (String) requestBody.get("horaDesde");
            LocalTime horaLocal = LocalTime.parse(horaStr);
            Time horaDesde = Time.valueOf(horaLocal);
            
            String codReserva = reservaRepository.registrarReserva(
                nroCliente,
                nroRestaurante,
                (String) requestBody.get("nroSucursal"),
                (String) requestBody.get("codZona"),
                fechaReserva,
                horaDesde,
                ((Number) requestBody.get("cantAdultos")).intValue(),
                requestBody.containsKey("cantMenores") && requestBody.get("cantMenores") != null
                    ? ((Number) requestBody.get("cantMenores")).intValue() : 0
                    , requestBody.containsKey("observaciones") && requestBody.get("observaciones") != null
                    ? (String) requestBody.get("observaciones") : null
            );
            
            response.put("codReserva", codReserva);
            response.put("confirmada", true);
            response.put("mensaje", "Reserva registrada exitosamente");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("confirmada", false);
            response.put("mensaje", "Error al registrar reserva: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }

    @PostMapping("/{codReserva}/cancelar")
    public ResponseEntity<Map<String, Object>> cancelarReserva(
        @PathVariable String codReserva,
        @RequestBody(required = false) Map<String, Object> requestBody) {
        Map<String, Object> response = new HashMap<>();

        try {
            
            String motivoCancelacion = null;
            if (requestBody != null && requestBody.containsKey("motivoCancelacion")) {
                Object motivoObj = requestBody.get("motivoCancelacion");
                
                // Extraer solo el string, sin importar si viene como String o como objeto
                if (motivoObj instanceof String) {
                    motivoCancelacion = (String) motivoObj;
                } else if (motivoObj != null) {
                    motivoCancelacion = String.valueOf(motivoObj);
                }
            }
            

            boolean cancelada = reservaRepository.cancelarReserva(codReserva, motivoCancelacion);
            response.put("actualizados", cancelada ? 1 : 0);
            response.put("mensaje", cancelada ? "Reserva cancelada exitosamente" : "Reserva no encontrada");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("actualizados", 0);
            response.put("mensaje", "Error al cancelar reserva: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
}

