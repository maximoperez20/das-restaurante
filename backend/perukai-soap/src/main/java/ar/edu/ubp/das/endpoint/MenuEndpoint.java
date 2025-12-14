package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.dto.MenuDto;
import ar.edu.ubp.das.repository.MenuRepository;
import ar.edu.ubp.das.soap.gen.*;


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

import java.time.format.DateTimeFormatter;
import java.util.Base64;

import java.util.Map;

@Endpoint
public class MenuEndpoint {
    private final Gson gson = new Gson();
    private static final Logger logger = LoggerFactory.getLogger(ClickEndpoint.class);
    private static final String NAMESPACE_URI = "http://das.ubp.edu.ar/restaurante";
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    @Autowired
    private MenuRepository menuRepository;

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "getMenuActivoRequest")
    @ResponsePayload
    public GetMenuActivoResponse obtenerMenuActivoRequest(@RequestPayload GetMenuActivoRequest request) {
        GetMenuActivoResponse response = new GetMenuActivoResponse();
        // Implementación del método para obtener el menú activo        
        try {
            // Parsear JSON recibido con GSON
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> jsonData = gson.fromJson(request.getJsonData(), mapType);
            
            String nroRestaurante = (String) jsonData.get("nroRestaurante");
            String nroSucursal = jsonData.containsKey("nroSucursal") && jsonData.get("nroSucursal") != null 
                ? (String) jsonData.get("nroSucursal") : null;

            // Llamar al repositorio para obtener el menú activo
            MenuDto menu = menuRepository.obtenerActivo(nroRestaurante, nroSucursal);

            if(menu == null || menu.getDatosArchivo() == null) {
                logger.info("No hay menú activo para el restaurante {} sucursal {}", nroRestaurante, nroSucursal);
                response.setExitoso(false);
                response.setMensaje("No hay menú activo para el restaurante y sucursal indicados.");
                return response;
            } 

            String base64 = Base64.getEncoder().encodeToString(menu.getDatosArchivo());
            response.setExitoso(true);
            response.setNroMenu(menu.getNroMenu());
            response.setNombreArchivo(menu.getNombreArchivo());
            response.setTipoMime(menu.getTipoMime());
            response.setTamanoBytes(menu.getTamanoBytes());
            response.setHashSha256(menu.getHashSha256());
            response.setDatosArchivoBase64(base64);

            logger.info("Menú activo obtenido para el restaurante {} sucursal {}", nroRestaurante, nroSucursal);
            
            return response;

        }
        catch (Exception e) {
            logger.error("Error al obtener el menú activo: {}", e.getMessage());
            // Manejo de errores
        }
        return response;
    }

}
