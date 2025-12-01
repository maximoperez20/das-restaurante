# Nueva Arquitectura: Aplicaciones Separadas por Restaurante

## Resumen

Se ha migrado de una arquitectura monolítica (una base de datos y dos aplicaciones) a una arquitectura distribuida donde cada restaurante tiene su propia base de datos y aplicación Java independiente.

## Arquitectura Anterior

- **1 base de datos**: `das_restaurante` (compartida por todos los restaurantes)
- **2 aplicaciones**: 
  - `das-restaurante-rest` (puerto 8082) - para restaurantes REST
  - `das-restaurante-soap` (puerto 8081) - para restaurantes SOAP

## Arquitectura Nueva

### Bases de Datos (4 bases de datos separadas)

1. **das_bella_pizza** - La Bella Pizza (REST)
2. **das_perukai** - Perukai (SOAP)
3. **das_fabrica_burger** - La Fábrica Burger (REST)
4. **das_sabores_norte** - Sabores del Norte (SOAP)

### Aplicaciones Java (4 aplicaciones en diferentes puertos)

1. **bella-pizza-rest** - Puerto 8082 - Base de datos: `das_bella_pizza`
2. **perukai-soap** - Puerto 8081 - Base de datos: `das_perukai`
3. **fabrica-burger-rest** - Puerto 8083 - Base de datos: `das_fabrica_burger`
4. **sabores-norte-soap** - Puerto 8084 - Base de datos: `das_sabores_norte`

## Estructura de Directorios

```
das-restaurante/
├── backend/
│   ├── bella-pizza-rest/          # Aplicación REST para La Bella Pizza
│   ├── fabrica-burger-rest/        # Aplicación REST para La Fábrica Burger
│   ├── perukai-soap/               # Aplicación SOAP para Perukai
│   ├── sabores-norte-soap/         # Aplicación SOAP para Sabores del Norte
│   ├── das-restaurante-rest/       # Aplicación original (mantener para referencia)
│   └── das-restaurante-soap/       # Aplicación original (mantener para referencia)
└── scripts/
    ├── bella-pizza/
    │   └── sql/
    │       ├── 01_create_database.sql
    │       ├── 02_create_tables.sql
    │       ├── 03_create_stored_procedures.sql
    │       ├── 04_insert_catalogos.sql
    │       └── 05_insert_restaurante.sql
    ├── perukai/
    │   └── sql/                    # Misma estructura
    ├── fabrica-burger/
    │   └── sql/                    # Misma estructura
    ├── sabores-norte/
    │   └── sql/                    # Misma estructura
    ├── setup-all-restaurants.sh     # Script para crear bases de datos y compilar
    ├── start-all-restaurants.sh     # Script para levantar todas las aplicaciones
    └── stop-all-restaurants.sh      # Script para detener todas las aplicaciones
```

## Configuración de URLs en das_ristorino

Las URLs de los servicios se configuran en la tabla `restaurantes` de la base de datos `das_ristorino`:

| Restaurante | Protocolo | Puerto | URL |
|------------|-----------|--------|-----|
| La Bella Pizza | REST | 8082 | http://localhost:8082/api |
| Perukai | SOAP | 8081 | http://localhost:8081/ws/restaurantes.wsdl |
| La Fábrica Burger | REST | 8083 | http://localhost:8083/api |
| Sabores del Norte | SOAP | 8084 | http://localhost:8084/ws/restaurantes.wsdl |

El script `das-ristorino/scripts/sql/15_update_urls_restaurantes.sql` actualiza estas URLs automáticamente.

## Setup Inicial

### 1. Crear Bases de Datos y Compilar Aplicaciones

```bash
cd das-restaurante/scripts
./setup-all-restaurants.sh
```

Este script:
- Crea las 4 bases de datos
- Ejecuta los scripts SQL (tablas, stored procedures, catálogos, datos)
- Compila todas las aplicaciones Java

### 2. Actualizar URLs en das_ristorino

```bash
cd das-ristorino/scripts/sql
sqlcmd -S localhost,1433 -U sa -P DB_Password -d das_ristorino -i 15_update_urls_restaurantes.sql
```

### 3. Levantar Aplicaciones

**Opción A: Levantar todas en background**
```bash
cd das-restaurante/scripts
./start-all-restaurants.sh
```

**Opción B: Levantar manualmente**
```bash
# Terminal 1: La Bella Pizza
cd das-restaurante/backend/bella-pizza-rest
./mvnw spring-boot:run

# Terminal 2: Perukai
cd das-restaurante/backend/perukai-soap
./mvnw spring-boot:run

# Terminal 3: La Fábrica Burger
cd das-restaurante/backend/fabrica-burger-rest
./mvnw spring-boot:run

# Terminal 4: Sabores del Norte
cd das-restaurante/backend/sabores-norte-soap
./mvnw spring-boot:run
```

### 4. Detener Aplicaciones

```bash
cd das-restaurante/scripts
./stop-all-restaurants.sh
```

## Verificación

### Verificar que las aplicaciones están corriendo

```bash
# Verificar puertos
netstat -an | grep -E "8081|8082|8083|8084"

# Ver logs
tail -f das-restaurante/logs/*.log
```

### Probar endpoints REST

```bash
# La Bella Pizza (puerto 8082)
curl http://localhost:8082/api/restaurantes

# La Fábrica Burger (puerto 8083)
curl http://localhost:8083/api/restaurantes
```

### Probar endpoints SOAP

Los endpoints SOAP están disponibles en:
- Perukai: http://localhost:8081/ws/restaurantes.wsdl
- Sabores del Norte: http://localhost:8084/ws/restaurantes.wsdl

## Ventajas de la Nueva Arquitectura

1. **Aislamiento**: Cada restaurante tiene su propia base de datos y aplicación
2. **Escalabilidad**: Se puede escalar cada restaurante independientemente
3. **Mantenimiento**: Cambios en un restaurante no afectan a los demás
4. **Despliegue**: Se pueden desplegar actualizaciones por restaurante
5. **Resiliencia**: Si una aplicación falla, las demás siguen funcionando

## Notas Importantes

- Las aplicaciones originales (`das-restaurante-rest` y `das-restaurante-soap`) se mantienen para referencia pero no se usan en producción
- Cada aplicación tiene su propio `application.properties` con la configuración de base de datos y puerto
- Los UUIDs de restaurantes y sucursales deben coincidir entre `das_ristorino` y las bases de datos individuales
- El `RestauranteClientFactory` en `das-ristorino` obtiene las URLs dinámicamente desde la base de datos

