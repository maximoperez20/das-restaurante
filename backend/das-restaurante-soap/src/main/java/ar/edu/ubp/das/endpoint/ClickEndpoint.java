package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.dto.ClickDto;
import ar.edu.ubp.das.repository.ClickRepository;
import ar.edu.ubp.das.soap.gen.NotificarClickRequest;
import ar.edu.ubp.das.soap.gen.NotificarClickResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZonedDateTime;
import java.util.GregorianCalendar;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;

@Endpoint
public class ClickEndpoint {

    private static final Logger logger = LoggerFactory.getLogger(ClickEndpoint.class);
    private static final String NAMESPACE_URI = "http://das.ubp.edu.ar/restaurante";

    @Autowired
    private ClickRepository clickRepository;

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "notificarClickRequest")
    @ResponsePayload
    public NotificarClickResponse notificarClick(@RequestPayload NotificarClickRequest request) {
        logger.info("SOAP - Notificar click");
        logger.info("  nroRestaurante: [{}]", request.getNroRestaurante());
        logger.info("  nroContenido: [{}]", request.getNroContenido());
        logger.info("  nroClick: [{}]", request.getNroClick());

        try {
            LocalDateTime fechaHoraRegistro = convertToLocalDateTime(request.getFechaHoraRegistro());

            String nroCliente = null;
            if (request.getNroCliente() != null && !request.getNroCliente().trim().isEmpty()) {
                nroCliente = request.getNroCliente();
            }

            BigDecimal costoClick = null;
            if (request.getCostoClick() != null) {
                costoClick = request.getCostoClick();
            }

            ClickDto resultado = clickRepository.registrarClick(
                    request.getNroRestaurante(),
                    request.getNroContenido(),
                    request.getNroClick(),
                    fechaHoraRegistro,
                    nroCliente,
                    costoClick
            );

            logger.info("Resultado SP - exitoso: {}, mensaje: {}", 
                resultado.isExitoso(), resultado.getMensaje());

            NotificarClickResponse response = new NotificarClickResponse();
            response.setExitoso(resultado.isExitoso());
            response.setMensaje(resultado.getMensaje());

            return response;

        } catch (Exception e) {
            logger.error("Error al notificar click: {}", e.getMessage(), e);
            
            NotificarClickResponse response = new NotificarClickResponse();
            response.setExitoso(false);
            response.setMensaje("Error al notificar click: " + e.getMessage());
            return response;
        }
    }

    private LocalDateTime convertToLocalDateTime(XMLGregorianCalendar xmlCalendar) {
        if (xmlCalendar == null) {
            return LocalDateTime.now();
        }
        return xmlCalendar.toGregorianCalendar().toZonedDateTime().toLocalDateTime();
    }
}

