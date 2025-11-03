package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.repository.ReservaRepository;
import ar.edu.ubp.das.soap.gen.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

import javax.xml.datatype.XMLGregorianCalendar;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;

@Endpoint
public class ReservaEndpoint {

    private static final String NAMESPACE_URI = "http://das.ubp.edu.ar/restaurante";

    @Autowired
    private ReservaRepository reservaRepository;

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "registrarReservaRequest")
    @ResponsePayload
    public RegistrarReservaResponse registrarReserva(@RequestPayload RegistrarReservaRequest request) {
        RegistrarReservaResponse response = new RegistrarReservaResponse();
        
        try {
            ClienteType cliente = request.getDatosCliente();
            String nroCliente = reservaRepository.buscarOCrearCliente(
                cliente.getApellido(),
                cliente.getNombre(),
                cliente.getCorreo(),
                cliente.getTelefonos()
            );
            
            XMLGregorianCalendar xmlDate = request.getFechaReserva();
            LocalDate fechaReserva = LocalDate.of(xmlDate.getYear(), xmlDate.getMonth(), xmlDate.getDay());
            
            XMLGregorianCalendar xmlTime = request.getHoraDesde();
            LocalTime horaLocal = LocalTime.of(xmlTime.getHour(), xmlTime.getMinute(), xmlTime.getSecond());
            Time horaDesde = Time.valueOf(horaLocal);
            
            String codReserva = reservaRepository.registrarReserva(
                nroCliente,
                request.getNroRestaurante(),
                request.getNroSucursal(),
                request.getCodZona(),
                fechaReserva,
                horaDesde,
                request.getCantAdultos(),
                request.getCantMenores()
            );
            
            response.setCodReserva(codReserva);
            response.setConfirmada(true);
            response.setMensaje("Reserva registrada exitosamente");
            
        } catch (Exception e) {
            response.setConfirmada(false);
            response.setMensaje("Error al registrar reserva: " + e.getMessage());
        }
        
        return response;
    }

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "cancelarReservaRequest")
    @ResponsePayload
    public CancelarReservaResponse cancelarReserva(@RequestPayload CancelarReservaRequest request) {
        CancelarReservaResponse response = new CancelarReservaResponse();
        
        try {
            boolean cancelada = reservaRepository.cancelarReserva(request.getCodReserva());
            response.setExitosa(cancelada);
            response.setMensaje(cancelada ? "Reserva cancelada exitosamente" : "Reserva no encontrada");
        } catch (Exception e) {
            response.setExitosa(false);
            response.setMensaje("Error al cancelar reserva: " + e.getMessage());
        }
        
        return response;
    }
}
