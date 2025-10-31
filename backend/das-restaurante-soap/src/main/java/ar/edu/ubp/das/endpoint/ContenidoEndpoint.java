package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.dto.ContenidoDto;
import ar.edu.ubp.das.repository.ContenidoRepository;
import ar.edu.ubp.das.soap.gen.RegistrarContenidoRequest;
import ar.edu.ubp.das.soap.gen.RegistrarContenidoResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

import java.math.BigDecimal;

@Endpoint
public class ContenidoEndpoint {

    private static final Logger logger = LoggerFactory.getLogger(ContenidoEndpoint.class);
    private static final String NAMESPACE_URI = "http://das.ubp.edu.ar/restaurante";

    @Autowired
    private ContenidoRepository contenidoRepository;

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "registrarContenidoRequest")
    @ResponsePayload
    public RegistrarContenidoResponse registrarContenido(@RequestPayload RegistrarContenidoRequest request) {
        logger.info("SOAP - Registrar contenido");
        logger.info("  nroRestaurante: [{}]", request.getNroRestaurante());
        logger.info("  nroSucursal: [{}]", request.getNroSucursal());
        logger.info("  contenidoAPublicar (primeros 50 chars): [{}]", 
            request.getContenidoAPublicar() != null && request.getContenidoAPublicar().length() > 50 
                ? request.getContenidoAPublicar().substring(0, 50) + "..." 
                : request.getContenidoAPublicar());

        try {
            byte[] imagenBytes = null;
            if (request.getImagenAPublicar() != null) {
                imagenBytes = request.getImagenAPublicar();
            }

            BigDecimal costoClick = null;
            if (request.getCostoClick() != null) {
                costoClick = request.getCostoClick();
            }

            ContenidoDto resultado = contenidoRepository.registrarContenido(
                    request.getNroRestaurante(),
                    request.getNroSucursal(),
                    request.getContenidoAPublicar(),
                    imagenBytes,
                    costoClick
            );

            logger.info("Resultado SP - exitoso: {}, mensaje: {}, nroContenido: {}", 
                resultado.isExitoso(), resultado.getMensaje(), resultado.getNroContenido());

            RegistrarContenidoResponse response = new RegistrarContenidoResponse();
            response.setNroContenido(resultado.getNroContenido());
            response.setExitoso(resultado.isExitoso());
            response.setMensaje(resultado.getMensaje());

            logger.info("Contenido registrado exitosamente. ID: {}", resultado.getNroContenido());
            return response;

        } catch (Exception e) {
            logger.error("Error al registrar contenido: {}", e.getMessage(), e);
            
            RegistrarContenidoResponse response = new RegistrarContenidoResponse();
            response.setNroContenido("");
            response.setExitoso(false);
            response.setMensaje("Error al registrar contenido: " + e.getMessage());
            return response;
        }
    }
}

