# das-restaurante-rest

Repositorio de Servicio REST para Restaurantes - Entrega de Materia DAS - UBP 2025

## 📋 Descripción

Servicio REST que expone funcionalidades de restaurantes, sucursales, zonas, turnos, disponibilidad, contenidos y clicks. Funciona como backend para el sistema das-ristorino. Es equivalente funcional al servicio SOAP (`das-restaurante-soap`) pero usando REST/JSON.

## 🛠️ Tecnologías

- **Framework**: Spring Boot 3.5.7
- **Java**: 17
- **Base de Datos**: SQL Server (`das_restaurante`)
- **Puerto**: 8082
- **Protocolo**: REST/JSON
- **Build Tool**: Maven

## 🚀 Configuración Rápida

### Prerrequisitos

- Java 17 o superior
- Maven 3.6+
- SQL Server (local o Docker)
- Docker Desktop (opcional, para SQL Server)

### 1. Configurar Base de Datos

**IMPORTANTE**: Este servicio REST usa la misma base de datos que el servicio SOAP (`das_restaurante`).

#### Opción A: SQL Server en Docker

```bash
# Ejecutar SQL Server en Docker
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=DB_Password" \
   -p 1433:1433 --name SQL_Server_Docker \
   -d mcr.microsoft.com/mssql/server:2022-latest

# Esperar 10-15 segundos para que SQL Server inicie
```

#### Opción B: SQL Server Local

Asegúrate de tener SQL Server instalado y corriendo en `localhost:1433`.

### 2. Crear Base de Datos

```bash
# Conectar a SQL Server y crear la base de datos
docker exec -it SQL_Server_Docker /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U sa -P DB_Password \
   -Q "CREATE DATABASE das_restaurante;"
```

O si usas SQL Server local:
```sql
CREATE DATABASE das_restaurante;
GO
```

### 3. Ejecutar Scripts SQL

**IMPORTANTE**: Ejecuta los scripts en el siguiente orden (los mismos que para SOAP):

```bash
# 1. Crear tablas
docker cp ../scripts/sql/01_create_tables.sql SQL_Server_Docker:/tmp/
docker exec -it SQL_Server_Docker /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U sa -P DB_Password -d das_restaurante -i /tmp/01_create_tables.sql

# 2. Crear stored procedures
docker cp ../scripts/sql/02_create_stored_procedures.sql SQL_Server_Docker:/tmp/
docker exec -it SQL_Server_Docker /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U sa -P DB_Password -d das_restaurante -i /tmp/02_create_stored_procedures.sql

# 3. Insertar datos básicos
docker cp ../scripts/sql/03_insert_datos_basicos.sql SQL_Server_Docker:/tmp/
docker exec -it SQL_Server_Docker /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U sa -P DB_Password -d das_restaurante -i /tmp/03_insert_datos_basicos.sql
```

### 4. Configurar application.properties

Edita `src/main/resources/application.properties` si es necesario:

```properties
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=das_restaurante;encrypt=false
spring.datasource.username=sa
spring.datasource.password=DB_Password
server.port=8082
```

### 5. Compilar y Ejecutar

```bash
# Compilar
mvn clean package

# Ejecutar
mvn spring-boot:run
```

O ejecutar el JAR/WAR generado:

```bash
java -jar target/das-restaurante-rest-0.0.1-SNAPSHOT.war
```

## 📡 Endpoints REST

### Base URL
- **URL**: `http://localhost:8082/api`

### Endpoints Disponibles

#### 1. Restaurantes

- **GET** `/api/restaurantes?query={query}` - Buscar restaurantes
  - Query params: `query` (opcional) - Filtro de búsqueda
  - Response: Lista de restaurantes

- **GET** `/api/restaurantes/{nroRestaurante}/sucursales` - Obtener sucursales de un restaurante
  - Path params: `nroRestaurante` - UUID del restaurante
  - Response: Lista de sucursales

- **GET** `/api/restaurantes/{nroRestaurante}/sucursales/{nroSucursal}/zonas` - Obtener zonas de una sucursal
  - Path params: `nroRestaurante`, `nroSucursal`
  - Response: Lista de zonas

#### 2. Horarios Disponibles

- **GET** `/api/restaurantes/{nroRestaurante}/sucursales/{nroSucursal}/horarios-disponibles`
  - Path params: `nroRestaurante`, `nroSucursal`
  - Query params:
    - `fecha` (requerido) - Fecha en formato ISO (YYYY-MM-DD)
    - `codZona` (opcional) - Código de zona específica
    - `cantidad` (opcional) - Cantidad de personas
  - Response: JSON con zonas y horarios disponibles agrupados

#### 3. Contenidos

- **POST** `/api/restaurantes/{nroRestaurante}/contenidos` - Registrar contenido promocional
  - Body: JSON con `nroSucursal`, `contenidoAPublicar`, `imagenAPublicar` (base64), `costoClick`
  - Response: JSON con `nroContenido`, `exitoso`, `mensaje`

- **GET** `/api/restaurantes/{nroRestaurante}/contenidos?nroSucursal={nroSucursal}` - Listar contenidos
  - Query params: `nroSucursal` (opcional)
  - Response: JSON con lista de contenidos

#### 4. Clicks

- **POST** `/api/restaurantes/{nroRestaurante}/contenidos/{nroContenido}/clicks` - Notificar click
  - Body: JSON con `nroClick`, `fechaHoraRegistro`, `nroCliente` (opcional), `costoClick` (opcional)
  - Response: JSON con `exitoso`, `mensaje`

- **POST** `/api/restaurantes/{nroRestaurante}/clicks/batch` - Notificar clicks en bloque
  - Body: JSON con `clicks` (array de clicks)
  - Response: JSON con resumen de procesamiento

#### 5. Reservas

- **POST** `/api/restaurantes/{nroRestaurante}/reservas` - Registrar reserva
  - Body: JSON con `datosCliente`, `nroSucursal`, `codZona`, `fechaReserva`, `horaDesde`, `cantAdultos`, `cantMenores`
  - Response: JSON con `codReserva`, `confirmada`, `mensaje`

- **POST** `/api/restaurantes/{nroRestaurante}/reservas/{codReserva}/cancelar` - Cancelar reserva
  - Response: JSON con `exitosa`, `mensaje`

#### 6. Health Check

- **GET** `/health` - Estado del servicio
- **GET** `/health/db` - Estado de la conexión a base de datos

## 🔧 Configuración Manual

### application.properties

```properties
spring.application.name=das-restaurante-rest

# SQL Server
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=das_restaurante;encrypt=false
spring.datasource.username=sa
spring.datasource.password=DB_Password
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver

# Pool de conexiones
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=20000
spring.datasource.hikari.idle-timeout=300000

# Servidor
server.port=8082

# Logging
logging.level.org.springframework.jdbc=DEBUG
logging.level.com.zaxxer.hikari=DEBUG
```

## 🧪 Testing

### Probar con curl

```bash
# Health check
curl http://localhost:8082/health

# Obtener restaurantes
curl http://localhost:8082/api/restaurantes

# Obtener sucursales
curl http://localhost:8082/api/restaurantes/{nroRestaurante}/sucursales

# Obtener horarios disponibles
curl "http://localhost:8082/api/restaurantes/{nroRestaurante}/sucursales/{nroSucursal}/horarios-disponibles?fecha=2025-01-15&cantidad=4"
```

### Probar con Postman

1. Importa la colección de endpoints REST
2. Configura la base URL: `http://localhost:8082/api`
3. Prueba cada endpoint según la documentación

## 📝 Notas Importantes

### Base de Datos Compartida

Este servicio REST usa la **misma base de datos** que el servicio SOAP (`das_restaurante`). Ambos servicios pueden coexistir y usar los mismos datos.

### Equivalencia con SOAP

Este servicio REST es funcionalmente equivalente al servicio SOAP (`das-restaurante-soap`), pero:
- Usa REST/JSON en lugar de SOAP/XML
- Corre en el puerto 8082 (SOAP corre en 8081)
- Usa los mismos stored procedures y lógica de negocio
- Comparte la misma base de datos

### Orden de Ejecución de Scripts

1. **01_create_tables.sql** - Crea todas las tablas
2. **02_create_stored_procedures.sql** - Crea stored procedures
3. **03_insert_datos_basicos.sql** - Inserta datos básicos

## 📁 Estructura del Proyecto

```
das-restaurante-rest/
├── src/main/java/
│   └── ar/edu/ubp/das/
│       ├── controller/          # REST Controllers
│       ├── repository/          # Acceso a datos
│       ├── dto/                 # Data Transfer Objects
│       ├── config/              # Configuración
│       ├── components/          # Componentes reutilizables
│       └── rest/                # Clase principal y ServletInitializer
└── src/main/resources/
    └── application.properties   # Configuración de la aplicación
```

## 🔄 Integración con das-ristorino

El servicio REST se integra con `das-ristorino` a través del `RestauranteRestClient`, que envía requests HTTP a este servicio en lugar de usar SOAP.

