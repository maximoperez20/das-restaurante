package ar.edu.ubp.das.controller;

import ar.edu.ubp.das.dto.RestauranteDto;
import ar.edu.ubp.das.dto.SucursalDto;
import ar.edu.ubp.das.dto.ZonaDto;
import ar.edu.ubp.das.repository.RestauranteRepository;
import ar.edu.ubp.das.repository.SucursalRepository;
import ar.edu.ubp.das.repository.ZonaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/restaurantes")
public class RestauranteController {

    @Autowired
    private RestauranteRepository restauranteRepository;

    @Autowired
    private SucursalRepository sucursalRepository;

    @Autowired
    private ZonaRepository zonaRepository;

    @GetMapping
    public ResponseEntity<List<RestauranteDto>> getRestaurantes(@RequestParam(required = false) String query) {
        List<RestauranteDto> restaurantes = restauranteRepository.findAll(query);
        return ResponseEntity.ok(restaurantes);
    }

    @GetMapping("/{nroRestaurante}/sucursales")
    public ResponseEntity<List<SucursalDto>> getSucursales(@PathVariable String nroRestaurante) {
        List<SucursalDto> sucursales = sucursalRepository.findByRestaurante(nroRestaurante);
        return ResponseEntity.ok(sucursales);
    }

    @GetMapping("/{nroRestaurante}/sucursales/{nroSucursal}/zonas")
    public ResponseEntity<List<ZonaDto>> getZonas(
            @PathVariable String nroRestaurante,
            @PathVariable String nroSucursal) {
        List<ZonaDto> zonas = zonaRepository.findBySucursal(nroRestaurante, nroSucursal);
        return ResponseEntity.ok(zonas);
    }
}

