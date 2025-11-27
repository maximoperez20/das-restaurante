# Arquitectura del Sistema - das-ristorino

## Resumen

Sistema de reservas de restaurantes con 3 aplicaciones que se comunican entre sí, usando una base de datos compartida.

## Aplicaciones

### 1. das-restaurante-rest (Puerto 8082)
- **Protocolo**: REST/JSON
- **Restaurantes**: La Bella Pizza, La Fábrica Burger
- **Función**: Maneja todos los restaurantes que usan REST

### 2. das-restaurante-soap (Puerto 8081)
- **Protocolo**: SOAP/XML
- **Restaurantes**: Perukai, Sabores del Norte
- **Función**: Maneja todos los restaurantes que usan SOAP

### 3. das-ristorino (Puerto 8080)
- **Protocolo**: REST/JSON (Backend) + Angular (Frontend)
- **Función**: Orquestador principal que coordina requests a los servicios de restaurantes

## Base de Datos

- **Nombre**: `das_restaurante`
- **Tipo**: SQL Server
- **Uso**: Compartida por todas las aplicaciones
- **Diseño**: Multi-tenant (todos los restaurantes en la misma BD)

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────┐
│         das-ristorino (Puerto 8080)            │
│  ┌──────────────────────────────────────────┐  │
│  │  RestauranteClientFactory                 │  │
│  │  - Consulta tipo_protocolo de BD          │  │
│  │  - Selecciona REST o SOAP dinámicamente   │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
┌──────────────────┐   ┌──────────────────┐
│ das-restaurante- │   │ das-restaurante- │
│      REST        │   │      SOAP        │
│  (Puerto 8082)   │   │  (Puerto 8081)   │
│                  │   │                  │
│ • La Bella Pizza │   │ • Perukai        │
│ • La Fábrica     │   │ • Sabores Norte  │
└──────────────────┘   └──────────────────┘
        │                       │
        └───────────┬───────────┘
                    ▼
        ┌───────────────────────┐
        │  das_restaurante  │
        │    (Base de Datos)    │
        │  (Compartida por todos)│
        └───────────────────────┘
```

## Flujo de Requests

1. **Usuario hace una acción en Ristorino** (ej: reservar en La Bella Pizza)

2. **Ristorino consulta la BD**:
   ```sql
   SELECT tipo_protocolo, url_servicio 
   FROM restaurantes 
   WHERE nro_restaurante = 'BELLA-PIZZA-...'
   ```
   Resultado: `tipo_protocolo = 'REST'`, `url_servicio = 'http://localhost:8082/api'`

3. **RestauranteClientFactory selecciona el cliente**:
   - Si es `REST` → usa `RestauranteRestClient` → `http://localhost:8082/api`
   - Si es `SOAP` → usa `RestauranteSoapClientImpl` → `http://localhost:8081/ws`

4. **Request al servicio correspondiente**:
   - REST: `POST http://localhost:8082/api/restaurantes/{id}/reservas`
   - SOAP: `SOAP Request` a `http://localhost:8081/ws`

5. **El servicio procesa y responde** a Ristorino

## Por qué esta arquitectura

✅ **Simplicidad**: 3 apps en lugar de 4+ (una por restaurante)  
✅ **Eficiencia**: Menos recursos, un pool de conexiones por servicio  
✅ **Escalabilidad**: Fácil agregar más restaurantes sin nuevas apps  
✅ **Mantenibilidad**: Un solo código base por protocolo  
✅ **Base de datos compartida**: Catálogos y clientes compartidos

## Levantar el Sistema

```bash
# Terminal 1: REST Service
cd das-restaurante/backend/das-restaurante-rest
mvn spring-boot:run

# Terminal 2: SOAP Service
cd das-restaurante/backend/das-restaurante-soap
mvn spring-boot:run

# Terminal 3: Ristorino Backend
cd das-ristorino/backend
mvn spring-boot:run

# Terminal 4: Ristorino Frontend (opcional)
cd das-ristorino/frontend/das-ristorino-frontend
npm start
```

## Configuración de Restaurantes

Cada restaurante tiene en la tabla `restaurantes`:
- `tipo_protocolo`: `'REST'` o `'SOAP'`
- `url_servicio`: URL completa del servicio (ej: `http://localhost:8082/api`)

El sistema selecciona automáticamente el protocolo y URL correctos para cada restaurante.

