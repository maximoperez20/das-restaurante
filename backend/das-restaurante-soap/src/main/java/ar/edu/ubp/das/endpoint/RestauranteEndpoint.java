package ar.edu.ubp.das.endpoint;

import ar.edu.ubp.das.dto.RestauranteDto;
import ar.edu.ubp.das.dto.SucursalDto;
import ar.edu.ubp.das.dto.ZonaDto;
import ar.edu.ubp.das.repository.RestauranteRepository;
import ar.edu.ubp.das.repository.SucursalRepository;
import ar.edu.ubp.das.repository.ZonaRepository;
import ar.edu.ubp.das.soap.gen.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

import java.util.List;

@Endpoint
public class RestauranteEndpoint {

    private static final String NAMESPACE_URI = "http://das.ubp.edu.ar/restaurante";

    @Autowired
    private RestauranteRepository restauranteRepository;

    @Autowired
    private SucursalRepository sucursalRepository;

    @Autowired
    private ZonaRepository zonaRepository;

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "getRestaurantesRequest")
    @ResponsePayload
    public GetRestaurantesResponse getRestaurantes(@RequestPayload GetRestaurantesRequest request) {
        List<RestauranteDto> restaurantes = restauranteRepository.findAll(request.getQuery());
        
        GetRestaurantesResponse response = new GetRestaurantesResponse();
        for (RestauranteDto dto : restaurantes) {
            RestauranteType restaurante = new RestauranteType();
            restaurante.setNroRestaurante(dto.getNroRestaurante());
            restaurante.setRazonSocial(dto.getRazonSocial());
            restaurante.setCuit(dto.getCuit());
            response.getRestaurante().add(restaurante);
        }
        return response;
    }

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "getSucursalesRequest")
    @ResponsePayload
    public GetSucursalesResponse getSucursales(@RequestPayload GetSucursalesRequest request) {
        List<SucursalDto> sucursales = sucursalRepository.findByRestaurante(request.getNroRestaurante());
        
        GetSucursalesResponse response = new GetSucursalesResponse();
        for (SucursalDto dto : sucursales) {
            SucursalType sucursal = new SucursalType();
            sucursal.setNroRestaurante(dto.getNroRestaurante());
            sucursal.setNroSucursal(dto.getNroSucursal());
            sucursal.setNomSucursal(dto.getNomSucursal());
            sucursal.setCalle(dto.getCalle());
            sucursal.setNroCalle(dto.getNroCalle());
            sucursal.setBarrio(dto.getBarrio());
            sucursal.setCodPostal(dto.getCodPostal());
            sucursal.setTelefonos(dto.getTelefonos());
            sucursal.setTotalComensales(dto.getTotalComensales());
            sucursal.setMinToleranciaReserva(dto.getMinTolerenciaReserva());
            sucursal.setCategoriaRestaurante(dto.getCategoriaPrecio());
            sucursal.setNomLocalidad(dto.getNomLocalidad());
            sucursal.setNomProvincia(dto.getNomProvincia());
            response.getSucursal().add(sucursal);
        }
        return response;
    }

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "getZonasRequest")
    @ResponsePayload
    public GetZonasResponse getZonas(@RequestPayload GetZonasRequest request) {
        List<ZonaDto> zonas = zonaRepository.findBySucursal(
            request.getNroRestaurante(), 
            request.getNroSucursal()
        );
        
        GetZonasResponse response = new GetZonasResponse();
        for (ZonaDto dto : zonas) {
            ZonaType zona = new ZonaType();
            zona.setNroRestaurante(dto.getNroRestaurante());
            zona.setNroSucursal(dto.getNroSucursal());
            zona.setCodZona(dto.getCodZona());
            zona.setNomZona(dto.getNomZona());
            zona.setCantComensales(dto.getCantComensales());
            zona.setPermiteMenores(dto.getPermiteMenores());
            zona.setHabilitada(dto.getHabilitada());
            response.getZona().add(zona);
        }
        return response;
    }
}

