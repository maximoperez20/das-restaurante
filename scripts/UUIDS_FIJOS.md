# UUIDs Fijos para Correlación entre das_ristorino y das_restaurante

Este documento lista todos los UUIDs fijos definidos para sucursales y zonas, que deben coincidir exactamente entre `das_ristorino` y `das_restaurante`.

## Sucursales

### La Bella Pizza (REST)
- **Sucursal 1 - Alta Córdoba**: `BELLA-PIZZA-SUC-0001-0001-0001-0001`
- **Sucursal 2 - General Paz**: `BELLA-PIZZA-SUC-0002-0002-0002-0002`

### Perukai (SOAP)
- **Sucursal 1 - Nueva Córdoba**: `PERUKAI-SUC-0001-0001-0001-0001`
- **Sucursal 2 - Güemes**: `PERUKAI-SUC-0002-0002-0002-0002`

### La Fábrica Burger (REST)
- **Sucursal 1 - Cerro de las Rosas**: `FABRICA-BURGER-SUC-0001-0001-0001-0001`

### Sabores del Norte (SOAP)
- **Sucursal 1 - Centro**: `SABORES-NORTE-SUC-0001-0001-0001-0001`
- **Sucursal 2 - Cerro de las Rosas**: `SABORES-NORTE-SUC-0002-0002-0002-0002`

## Zonas (Compartidas entre restaurantes)

Las zonas son catálogos compartidos en `das_restaurante`, por lo que todos los restaurantes que usan la misma zona comparten el mismo UUID:

- **Salón Principal**: `ZONA-SALON-PRINCIPAL-0001-0001-0001-0001`
- **Terraza**: `ZONA-TERRAZA-0001-0001-0001-0001`
- **Patio**: `ZONA-PATIO-0001-0001-0001-0001`
- **Patio Cubierto**: `ZONA-PATIO-CUBIERTO-0001-0001-0001-0001`
- **Barra**: `ZONA-BARRA-0001-0001-0001-0001`

## Mapeo en das_ristorino

En `das_ristorino`, las tablas `sucursales_restaurantes` y `zonas_sucursales_restaurantes` tienen:
- `nro_sucursal`: UUID interno de ristorino (generado con NEWID())
- `cod_sucursal_restaurante`: UUID fijo del sistema del restaurante (debe coincidir con `nro_sucursal` en `das_restaurante`)
- `cod_zona`: UUID interno de ristorino (generado con NEWID())
- `cod_zona_restaurante`: UUID fijo del sistema del restaurante (debe coincidir con `cod_zona` en `das_restaurante`)

## Uso en Stored Procedures

El stored procedure `get_horarios_disponibles` en `das_restaurante` recibe `@nro_sucursal` que debe ser el UUID fijo de la sucursal. Desde `das_ristorino`, se envía `cod_sucursal_restaurante` como `nroSucursal` en la llamada al servicio.

