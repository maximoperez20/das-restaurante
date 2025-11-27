# Comandos curl para probar das-restaurante-rest

## 1. Health Check (Básico)

```bash
# Verificar que el servicio está corriendo
curl -X GET http://localhost:8082/health

# Verificar conexión a base de datos
curl -X GET http://localhost:8082/health/db
```

## 2. Obtener Restaurantes

```bash
# Obtener todos los restaurantes
curl -X GET http://localhost:8082/api/restaurantes

# Buscar restaurantes con query
curl -X GET "http://localhost:8082/api/restaurantes?query=Bella"
```

## 3. Obtener Sucursales

```bash
# Obtener sucursales de La Bella Pizza (REST)
curl -X GET http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/sucursales

# Obtener sucursales de Perukai (SOAP)
curl -X GET http://localhost:8082/api/restaurantes/PERUKAI-2222-2222-2222-222222222222/sucursales

# Obtener sucursales del restaurante compartido
curl -X GET http://localhost:8082/api/restaurantes/12345678-1234-1234-1234-123456789abc/sucursales
```

## 4. Obtener Zonas

```bash
# Primero necesitas obtener el nroSucursal de una sucursal
# Luego obtener las zonas (reemplaza {nroSucursal} con el UUID real)
curl -X GET http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/sucursales/{nroSucursal}/zonas
```

## 5. Obtener Horarios Disponibles

```bash
# Obtener horarios disponibles para una fecha específica
# Reemplaza {nroSucursal} con el UUID real de una sucursal
curl -X GET "http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/sucursales/{nroSucursal}/horarios-disponibles?fecha=2025-01-15&cantidad=4"

# Con zona específica
curl -X GET "http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/sucursales/{nroSucursal}/horarios-disponibles?fecha=2025-01-15&cantidad=4&codZona={codZona}"
```

## 6. Registrar Contenido

```bash
# Registrar un contenido promocional
curl -X POST http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/contenidos \
  -H "Content-Type: application/json" \
  -d '{
    "nroSucursal": null,
    "contenidoAPublicar": "Promoción especial: Pizza Margherita 20% OFF",
    "imagenAPublicar": null,
    "costoClick": 0.50
  }'
```

## 7. Listar Contenidos

```bash
# Listar contenidos de un restaurante
curl -X GET http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/contenidos

# Listar contenidos de una sucursal específica
curl -X GET "http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/contenidos?nroSucursal={nroSucursal}"
```

## 8. Notificar Click

```bash
# Notificar un click en un contenido
# Reemplaza {nroContenido} con el UUID del contenido obtenido anteriormente
curl -X POST http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/contenidos/{nroContenido}/clicks \
  -H "Content-Type: application/json" \
  -d '{
    "nroClick": "CLICK-001",
    "fechaHoraRegistro": "2025-01-15T20:30:00",
    "nroCliente": null,
    "costoClick": 0.50
  }'
```

## 9. Notificar Clicks en Batch

```bash
# Notificar múltiples clicks a la vez
curl -X POST http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/clicks/batch \
  -H "Content-Type: application/json" \
  -d '{
    "clicks": [
      {
        "nroClick": "CLICK-001",
        "nroContenido": "{nroContenido1}",
        "fechaHoraRegistro": "2025-01-15T20:30:00",
        "nroCliente": null,
        "costoClick": 0.50
      },
      {
        "nroClick": "CLICK-002",
        "nroContenido": "{nroContenido2}",
        "fechaHoraRegistro": "2025-01-15T20:35:00",
        "nroCliente": null,
        "costoClick": 0.50
      }
    ]
  }'
```

## 10. Registrar Reserva

```bash
# Registrar una reserva
# Reemplaza {nroSucursal} y {codZona} con valores reales
curl -X POST http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/reservas \
  -H "Content-Type: application/json" \
  -d '{
    "datosCliente": {
      "apellido": "Pérez",
      "nombre": "Juan",
      "correo": "juan.perez@example.com",
      "telefonos": "351-555-1234"
    },
    "nroSucursal": "{nroSucursal}",
    "codZona": "{codZona}",
    "fechaReserva": "2025-01-20",
    "horaDesde": "20:00:00",
    "cantAdultos": 2,
    "cantMenores": 0
  }'
```

## 11. Cancelar Reserva

```bash
# Cancelar una reserva
# Reemplaza {codReserva} con el código de reserva obtenido anteriormente
curl -X POST http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/reservas/{codReserva}/cancelar
```

## Script de Prueba Completo

```bash
#!/bin/bash

echo "=== 1. Health Check ==="
curl -s http://localhost:8082/health | jq .
echo ""

echo "=== 2. Health Check DB ==="
curl -s http://localhost:8082/health/db | jq .
echo ""

echo "=== 3. Obtener Restaurantes ==="
curl -s http://localhost:8082/api/restaurantes | jq .
echo ""

echo "=== 4. Obtener Sucursales (La Bella Pizza) ==="
curl -s http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/sucursales | jq .
echo ""

echo "=== 5. Obtener Horarios Disponibles ==="
# Nota: Necesitas reemplazar {nroSucursal} con un UUID real
# curl -s "http://localhost:8082/api/restaurantes/BELLA-PIZZA-1111-1111-1111-111111111111/sucursales/{nroSucursal}/horarios-disponibles?fecha=2025-01-20&cantidad=4" | jq .
echo ""

echo "Pruebas completadas!"
```

## Notas

- Si no tienes `jq` instalado, puedes remover `| jq .` de los comandos
- Los UUIDs de restaurantes están hardcodeados en los scripts SQL
- Para obtener `nroSucursal` y `codZona`, primero ejecuta los endpoints de sucursales y zonas
- Las fechas deben estar en formato ISO: `YYYY-MM-DD`
- Las horas deben estar en formato: `HH:mm:ss`

