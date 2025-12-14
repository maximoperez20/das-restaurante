package ar.edu.ubp.das.controller;

import ar.edu.ubp.das.dto.MenuDto;
import ar.edu.ubp.das.repository.MenuRepository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/menu")
public class MenuController {

    private static final Logger logger = LoggerFactory.getLogger(MenuController.class);

    private final MenuRepository menuRepository;

    public MenuController(MenuRepository menuRepository) {
        this.menuRepository = menuRepository;
    }

    @GetMapping("/activo")
    public ResponseEntity<byte[]> obtenerMenuActivo(@RequestParam String nroRestaurante,
                                                     @RequestParam String nroSucursal) {
        try {
            MenuDto menuDto = menuRepository.obtenerActivo(nroRestaurante, nroSucursal);
            
            if (menuDto == null || menuDto.getDatosArchivo() == null) {
                logger.warn("No se encontró menú activo para restaurante {} sucursal {}", 
                           nroRestaurante, nroSucursal);
                return ResponseEntity.notFound().build();
            }

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType(menuDto.getTipoMime()));
            headers.setContentLength(menuDto.getTamanoBytes());
            headers.setContentDispositionFormData("inline", menuDto.getNombreArchivo());
            
            // Cache headers (opcional pero recomendado para Ristorino)
            if (menuDto.getHashSha256() != null) {
                headers.setETag("\"" + menuDto.getHashSha256() + "\"");
            }
            headers.setCacheControl("public, max-age=3600");

            logger.info("Enviando menú activo {} para restaurante {} sucursal {}", 
                       menuDto.getNombreArchivo(), nroRestaurante, nroSucursal);

            return new ResponseEntity<>(menuDto.getDatosArchivo(), headers, HttpStatus.OK);

        } catch (Exception e) {
            logger.error("Error al obtener el menú activo para restaurante {} sucursal {}: {}", 
                         nroRestaurante, nroSucursal, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    
}
