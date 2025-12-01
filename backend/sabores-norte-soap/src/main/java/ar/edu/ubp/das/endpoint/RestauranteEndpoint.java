package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.dto.RestauranteDto;
import ar.edu.ubp.das.dto.SucursalDto;
import ar.edu.ubp.das.dto.ZonaDto;
import ar.edu.ubp.das.dto.request.GetRestaurantesRequest;
import ar.edu.ubp.das.dto.request.GetSucursalesRequest;
import ar.edu.ubp.das.dto.request.GetZonasRequest;
import ar.edu.ubp.das.dto.response.RestaurantesResponse;
import ar.edu.ubp.das.dto.response.SucursalesResponse;
import ar.edu.ubp.das.dto.response.ZonasResponse;
import ar.edu.ubp.das.endpoint.util.JsonParser;
import ar.edu.ubp.das.endpoint.util.ResponseBuilder;
import ar.edu.ubp.das.repository.RestauranteRepository;
import ar.edu.ubp.das.repository.SucursalRepository;
import ar.edu.ubp.das.repository.ZonaRepository;
import ar.edu.ubp.das.soap.gen.*;
import com.google.gson.Gson;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

import java.util.List;

/**
 * Endpoint SOAP para operaciones relacionadas con restaurantes.
 * 
 * Principios aplicados:
 * - Responsabilidad única: Solo maneja requests/responses SOAP
 * - Encapsulación: Usa DTOs tipados en lugar de Maps genéricos
 * - DRY: Usa utilidades para parsing y construcción de respuestas
 */
@Endpoint
public class RestauranteEndpoint {

    private static final String NAMESPACE_URI = "http://das.ubp.edu.ar/restaurante";

    private final RestauranteRepository restauranteRepository;
    private final SucursalRepository sucursalRepository;
    private final ZonaRepository zonaRepository;
    private final JsonParser jsonParser;
    private final ResponseBuilder responseBuilder;
    
    public RestauranteEndpoint(
            RestauranteRepository restauranteRepository,
            SucursalRepository sucursalRepository,
            ZonaRepository zonaRepository,
            Gson gson) {
        this.restauranteRepository = restauranteRepository;
        this.sucursalRepository = sucursalRepository;
        this.zonaRepository = zonaRepository;
        this.jsonParser = new JsonParser(gson);
        this.responseBuilder = new ResponseBuilder(gson);
    }

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "getRestaurantesRequest")
    @ResponsePayload
    public GetRestaurantesResponse getRestaurantes(@RequestPayload ar.edu.ubp.das.soap.gen.GetRestaurantesRequest request) {
        GetRestaurantesResponse response = new GetRestaurantesResponse();
        
        try {
            GetRestaurantesRequest requestDto = jsonParser.parseToObject(
                    request.getJsonData(), 
                    GetRestaurantesRequest.class
            );
            
            List<RestauranteDto> restaurantes = restauranteRepository.findAll(requestDto.getQuery());
            
            RestaurantesResponse restaurantesResponse = new RestaurantesResponse(restaurantes);
            response.setJsonResponse(responseBuilder.buildSuccessResponse(restaurantesResponse));
            
        } catch (Exception e) {
            response.setJsonResponse(responseBuilder.buildErrorResponse(
                    "Error al obtener restaurantes: " + e.getMessage()
            ));
        }
        
        return response;
    }

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "getSucursalesRequest")
    @ResponsePayload
    public GetSucursalesResponse getSucursales(@RequestPayload ar.edu.ubp.das.soap.gen.GetSucursalesRequest request) {
        GetSucursalesResponse response = new GetSucursalesResponse();
        
        try {
            GetSucursalesRequest requestDto = jsonParser.parseToObject(
                    request.getJsonData(), 
                    GetSucursalesRequest.class
            );
            
            List<SucursalDto> sucursales = sucursalRepository.findByRestaurante(requestDto.getNroRestaurante());
            
            SucursalesResponse sucursalesResponse = new SucursalesResponse(sucursales);
            response.setJsonResponse(responseBuilder.buildSuccessResponse(sucursalesResponse));
            
        } catch (Exception e) {
            response.setJsonResponse(responseBuilder.buildErrorResponse(
                    "Error al obtener sucursales: " + e.getMessage()
            ));
        }
        
        return response;
    }

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "getZonasRequest")
    @ResponsePayload
    public GetZonasResponse getZonas(@RequestPayload ar.edu.ubp.das.soap.gen.GetZonasRequest request) {
        GetZonasResponse response = new GetZonasResponse();
        
        try {
            GetZonasRequest requestDto = jsonParser.parseToObject(
                    request.getJsonData(), 
                    GetZonasRequest.class
            );
            
            List<ZonaDto> zonas = zonaRepository.findBySucursal(
                    requestDto.getNroRestaurante(), 
                    requestDto.getNroSucursal()
            );
            
            ZonasResponse zonasResponse = new ZonasResponse(zonas);
            response.setJsonResponse(responseBuilder.buildSuccessResponse(zonasResponse));
            
        } catch (Exception e) {
            response.setJsonResponse(responseBuilder.buildErrorResponse(
                    "Error al obtener zonas: " + e.getMessage()
            ));
        }
        
        return response;
    }
}
