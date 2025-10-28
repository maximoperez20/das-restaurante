package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.dto.HorarioDisponibleDto;
import ar.edu.ubp.das.repository.DisponibilidadRepository;
import ar.edu.ubp.das.soap.gen.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.GregorianCalendar;
import java.util.List;

@Endpoint
public class DisponibilidadEndpoint {

    private static final String NAMESPACE_URI = "http://das.ubp.edu.ar/restaurante";

    @Autowired
    private DisponibilidadRepository disponibilidadRepository;

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "getHorariosDisponiblesRequest")
    @ResponsePayload
    public GetHorariosDisponiblesResponse getHorariosDisponibles(@RequestPayload GetHorariosDisponiblesRequest request) {
        XMLGregorianCalendar xmlDate = request.getFecha();
        LocalDate fecha = LocalDate.of(xmlDate.getYear(), xmlDate.getMonth(), xmlDate.getDay());
        
        List<HorarioDisponibleDto> horarios = disponibilidadRepository.getHorariosDisponibles(
            request.getNroRestaurante(),
            request.getNroSucursal(),
            request.getCodZona(),
            fecha,
            request.getCantidad()
        );
        
        GetHorariosDisponiblesResponse response = new GetHorariosDisponiblesResponse();
        try {
            DatatypeFactory datatypeFactory = DatatypeFactory.newInstance();
            
            for (HorarioDisponibleDto dto : horarios) {
                TurnoDisponibleType turno = new TurnoDisponibleType();
                
                LocalTime desde = dto.getHoraDesde().toLocalTime();
                turno.setHoraDesde(datatypeFactory.newXMLGregorianCalendarTime(
                    desde.getHour(), desde.getMinute(), desde.getSecond(), 0
                ));
                
                LocalTime hasta = dto.getHoraHasta().toLocalTime();
                turno.setHoraHasta(datatypeFactory.newXMLGregorianCalendarTime(
                    hasta.getHour(), hasta.getMinute(), hasta.getSecond(), 0
                ));
                
                turno.setCapacidadZona(dto.getCapacidadZona());
                turno.setYaReservados(dto.getYaReservados());
                turno.setDisponibilidad(dto.getDisponibilidad());
                
                response.getTurno().add(turno);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error procesando horarios", e);
        }
        
        return response;
    }
}

