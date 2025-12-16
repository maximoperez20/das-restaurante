package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.dto.RestauranteDto;
import ar.edu.ubp.das.dto.SucursalDto;
import ar.edu.ubp.das.dto.ZonaDto;
import ar.edu.ubp.das.dto.request.GetMenusPorSucursalRequest;
import ar.edu.ubp.das.dto.request.GetRestaurantesRequest;
import ar.edu.ubp.das.dto.request.GetSucursalesRequest;
import ar.edu.ubp.das.dto.request.GetZonasRequest;
import ar.edu.ubp.das.dto.response.MenusResponse;
import ar.edu.ubp.das.dto.response.RestaurantesResponse;
import ar.edu.ubp.das.dto.response.SucursalesResponse;
import ar.edu.ubp.das.dto.response.ZonasResponse;
import ar.edu.ubp.das.endpoint.util.JsonParser;
import ar.edu.ubp.das.endpoint.util.ResponseBuilder;
import ar.edu.ubp.das.repository.RestauranteRepository;
import ar.edu.ubp.das.repository.SucursalRepository;
import ar.edu.ubp.das.repository.ZonaRepository;
import ar.edu.ubp.das.soap.gen.*;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Type;
import java.util.Map;

import java.util.List;

import ar.edu.ubp.das.dto.MenuItemDto;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import ar.edu.ubp.das.dto.PlatoDto;

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
    private final Gson gson;
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
        this.gson = gson;
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

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "menusPorSucursalRequest")
    @ResponsePayload
    public MenusPorSucursalResponse getMenusPorSucursal(@RequestPayload MenusPorSucursalRequest request) {
        MenusPorSucursalResponse response = new MenusPorSucursalResponse();
        
        try {
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> jsonData = gson.fromJson(request.getJsonData(), mapType);  // ✅ Cambiar getJsonData() a getJsonResponse()
            
            System.out.println("jsonData: " + jsonData);
            String nroRestaurante = (String) jsonData.get("nroRestaurante");
            String nroSucursal = (String) jsonData.get("nroSucursal");

            GetMenusPorSucursalRequest requestDto = new GetMenusPorSucursalRequest(nroRestaurante, nroSucursal);

            System.out.println("nroRestaurante: " + nroRestaurante);
            System.out.println("nroSucursal: " + nroSucursal);

            // Obtener todos los items de menú (cada fila tiene: nroMenu, nomMenu, nroPlato, nomPlato)
            List<MenuItemDto> menuItems = restauranteRepository.getMenusPorSucursal(
                requestDto.getNroRestaurante(), 
                requestDto.getNroSucursal()
            );

            System.out.println("menuItems: " + menuItems);

            // Agrupar por menú y crear objetos MenusResponse
            Map<String, MenusResponse> menusMap = new LinkedHashMap<>();  // Usar LinkedHashMap para mantener orden
            
            for (MenuItemDto item : menuItems) {
                String nroMenu = item.getNroMenu();
                
                // Si el menú no existe en el mapa, crearlo
                menusMap.putIfAbsent(nroMenu, new MenusResponse(
                    item.getNroMenu(),
                    item.getNomMenu(),
                    new ArrayList<>()  // Inicializar lista vacía de platos
                ));
                
                // Agregar el plato al menú correspondiente
                MenusResponse menu = menusMap.get(nroMenu);
                PlatoDto plato = new PlatoDto(item.getNroPlato(), item.getNomPlato());
                menu.getPlatos().add(plato);
            }
            
            // Convertir el mapa a lista
            List<MenusResponse> menusList = new ArrayList<>(menusMap.values());
            
            // Construir respuesta
            
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("menus", menusList);
            response.setJsonResponse(responseBuilder.buildSuccessResponse(responseData));
            // Sin clave de menus
            // response.setJsonResponse(responseBuilder.buildSuccessResponse(menusList));
            
        } catch (Exception e) {
            response.setJsonResponse(responseBuilder.buildErrorResponse(
                    "Error al obtener menus por sucursal: " + e.getMessage()
            ));
        }
        
        return response;
    }
}
