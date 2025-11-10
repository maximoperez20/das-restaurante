# das-restaurante-soap

Repositorio de Servicio SOAP para Restaurantes - Entrega de Materia DAS - UBP 2025

## 📋 Descripción

Servicio SOAP que expone funcionalidades de restaurantes, sucursales, zonas, turnos, disponibilidad, contenidos y clicks. Funciona como backend para el sistema das-ristorino.

## 🛠️ Tecnologías

- **Framework**: Spring Boot 3.5.7
- **Java**: 17
- **Base de Datos**: SQL Server (`das_restaurante_soap`)
- **Puerto**: 8081
- **Protocolo**: SOAP/XML
- **Build Tool**: Maven

## 🚀 Configuración Rápida

### Prerrequisitos

- Java 17 o superior
- Maven 3.6+
- SQL Server (local o Docker)
- Docker Desktop (opcional, para SQL Server)

### 1. Configurar Base de Datos

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
   -Q "CREATE DATABASE das_restaurante_soap;"
```

O si usas SQL Server local:
```sql
CREATE DATABASE das_restaurante_soap;
GO
```

### 3. Ejecutar Scripts SQL

**IMPORTANTE**: Ejecuta los scripts en el siguiente orden:

```bash
# 1. Crear tablas
docker cp scripts/sql/01_create_tables.sql SQL_Server_Docker:/tmp/
docker exec -it SQL_Server_Docker /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U sa -P DB_Password -d das_restaurante_soap -i /tmp/01_create_tables.sql

# 2. Crear stored procedures
docker cp scripts/sql/02_create_stored_procedures.sql SQL_Server_Docker:/tmp/
docker exec -it SQL_Server_Docker /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U sa -P DB_Password -d das_restaurante_soap -i /tmp/02_create_stored_procedures.sql

# 3. Insertar datos básicos
docker cp scripts/sql/03_insert_datos_basicos.sql SQL_Server_Docker:/tmp/
docker exec -it SQL_Server_Docker /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U sa -P DB_Password -d das_restaurante_soap -i /tmp/03_insert_datos_basicos.sql
```

**O usando SQL Server Management Studio (SSMS):**
1. Abre SSMS y conéctate a tu instancia de SQL Server
2. Abre y ejecuta `scripts/sql/01_create_tables.sql`
3. Abre y ejecuta `scripts/sql/02_create_stored_procedures.sql`
4. Abre y ejecuta `scripts/sql/03_insert_datos_basicos.sql`

### 4. Verificar Configuración

Verifica que la base de datos tenga datos:

```bash
docker exec -it SQL_Server_Docker /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U sa -P DB_Password -d das_restaurante_soap \
   -Q "SELECT COUNT(*) AS total_restaurantes FROM restaurantes;"
```

Deberías ver al menos 1 restaurante.

### 5. Configurar application.properties

Verifica que `backend/das-restaurante-soap/src/main/resources/application.properties` tenga:

```properties
spring.application.name=das-restaurante-soap

spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=das_restaurante_soap;encrypt=false
spring.datasource.username=sa
spring.datasource.password=DB_Password
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver

server.port=8081
spring.ws.path=/ws
```

### 6. Compilar y Ejecutar la Aplicación

```bash
cd backend/das-restaurante-soap

# Compilar
./mvnw clean install

# Ejecutar
./mvnw spring-boot:run
```

O desde tu IDE:
- Importa el proyecto como proyecto Maven
- Ejecuta la clase `DasRestauranteApplication`

### 7. Verificar que el Servicio Funciona

La aplicación estará disponible en:
- **SOAP Endpoint**: `http://localhost:8081/ws`
- **WSDL**: `http://localhost:8081/ws/restaurantes.wsdl`

Puedes probar el WSDL abriendo en tu navegador:
```
http://localhost:8081/ws/restaurantes.wsdl
```

## 📊 Estructura de Scripts SQL

```
scripts/sql/
├── 01_create_tables.sql          # Crea todas las tablas (CREATE OR ALTER)
├── 02_create_stored_procedures.sql  # Crea stored procedures (CREATE OR ALTER)
└── 03_insert_datos_basicos.sql   # Inserta datos básicos (1 restaurante compartido)
```

## 📡 Endpoints SOAP

### WSDL
- **URL**: `http://localhost:8081/ws/restaurantes.wsdl`
- **Namespace**: `http://das.ubp.edu.ar/restaurante`

### Operaciones Disponibles

1. **getRestaurantes** - Buscar restaurantes
2. **getSucursales** - Obtener sucursales de un restaurante
3. **getZonas** - Obtener zonas de una sucursal
4. **getHorariosDisponibles** - Consultar disponibilidad de turnos
5. **registrarContenido** - Registrar contenido promocional
6. **notificarClick** - Notificar click en contenido

## 🔧 Configuración Manual

### application.properties

```properties
spring.application.name=das-restaurante-soap

# SQL Server
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=das_restaurante_soap;encrypt=false
spring.datasource.username=sa
spring.datasource.password=DB_Password
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver

# Pool de conexiones
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=20000

# Servidor
server.port=8081

# SOAP
spring.ws.path=/ws
```

## 🐛 Troubleshooting

### Error de Conexión a Base de Datos

```bash
# Verificar que SQL Server esté corriendo
docker ps | grep SQL_Server_Docker

# Verificar que la base de datos exista
docker exec -it SQL_Server_Docker /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U sa -P DB_Password \
   -Q "SELECT name FROM sys.databases WHERE name='das_restaurante_soap';"
```

### Error de Puerto en Uso

```bash
# Ver qué proceso usa el puerto 8081
lsof -i :8081  # macOS/Linux
netstat -ano | findstr :8081  # Windows

# Cambiar el puerto en application.properties
server.port=8082
```

### Error al Ejecutar Scripts SQL

- Verifica que ejecutaste los scripts en orden: `01_create_tables.sql` → `02_create_stored_procedures.sql` → `03_insert_datos_basicos.sql`
- Verifica que la base de datos `das_restaurante_soap` existe
- Revisa los logs de SQL Server para errores específicos

### El WSDL No Se Genera

- Verifica que la aplicación esté corriendo
- Verifica que el puerto 8081 esté disponible
- Revisa los logs de Spring Boot para errores

## 🧪 Testing

### Probar WSDL

```bash
# Abrir en navegador
open http://localhost:8081/ws/restaurantes.wsdl
```

### Probar con SoapUI o Postman

1. Importa el WSDL desde `http://localhost:8081/ws/restaurantes.wsdl`
2. Prueba la operación `getRestaurantes` con parámetro vacío o con query

### Probar desde Terminal (curl)

```bash
# Obtener WSDL
curl http://localhost:8081/ws/restaurantes.wsdl
```

## 📝 Notas Importantes

### Restaurante Compartido

El script `03_insert_datos_basicos.sql` inserta 1 restaurante con UUID hardcodeado:
- **UUID**: `12345678-1234-1234-1234-123456789abc`
- **Razón Social**: "Los Aroza SRL"
- **CUIT**: "30700987654"

**Este mismo restaurante debe existir en das-ristorino con el mismo UUID** para que la integración funcione correctamente.

### Orden de Ejecución de Scripts

1. **01_create_tables.sql** - Crea todas las tablas
2. **02_create_stored_procedures.sql** - Crea stored procedures
3. **03_insert_datos_basicos.sql** - Inserta datos básicos

## 📁 Estructura del Proyecto

```
das-restaurante/
├── backend/
│   └── das-restaurante-soap/
│       ├── src/main/java/
│       │   └── ar/edu/ubp/das/
│       │       ├── endpoint/          # Endpoints SOAP
│       │       ├── repository/        # Acceso a datos
│       │       ├── dto/               # Data Transfer Objects
│       │       └── config/            # Configuración
│       └── src/main/resources/
│           ├── application.properties
│           └── xsd/
│               └── restaurante.xsd    # Contrato SOAP
└── scripts/sql/
    ├── 01_create_tables.sql
    ├── 02_create_stored_procedures.sql
    └── 03_insert_datos_basicos.sql
```

## 👥 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

**Desarrollado por el equipo DAS - UBP 2025**
