#!/bin/bash

# =========================================================================================
# Script de setup para todas las aplicaciones de restaurantes
# Crea las bases de datos y compila las aplicaciones
# =========================================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../backend"
SQL_SERVER="${SQL_SERVER:-localhost}"
SQL_PORT="${SQL_PORT:-1433}"
SQL_USER="${SQL_USER:-sa}"
SQL_PASSWORD="${SQL_PASSWORD:-DB_Password}"

echo "=========================================="
echo "SETUP DE APLICACIONES DE RESTAURANTES"
echo "=========================================="
echo ""

# Función para ejecutar SQL
execute_sql() {
    local db_name=$1
    local sql_file=$2
    echo "Ejecutando: $sql_file en $db_name..."
    sqlcmd -S "$SQL_SERVER,$SQL_PORT" -U "$SQL_USER" -P "$SQL_PASSWORD" -i "$sql_file" || {
        echo "ERROR: No se pudo ejecutar $sql_file"
        return 1
    }
}

# Función para crear base de datos y ejecutar scripts
setup_database() {
    local rest_name=$1
    local db_name=$2
    local scripts_dir="$SCRIPT_DIR/$rest_name/sql"
    
    echo ""
    echo "----------------------------------------"
    echo "Configurando: $rest_name ($db_name)"
    echo "----------------------------------------"
    
    # 1. Crear base de datos
    if [ -f "$scripts_dir/01_create_database.sql" ]; then
        execute_sql "master" "$scripts_dir/01_create_database.sql"
    fi
    
    # 2. Crear tablas
    if [ -f "$scripts_dir/02_create_tables.sql" ]; then
        execute_sql "$db_name" "$scripts_dir/02_create_tables.sql"
    fi
    
    # 3. Crear stored procedures
    if [ -f "$scripts_dir/03_create_stored_procedures.sql" ]; then
        execute_sql "$db_name" "$scripts_dir/03_create_stored_procedures.sql"
    fi
    
    # 4. Insertar catálogos
    if [ -f "$scripts_dir/04_insert_catalogos.sql" ]; then
        execute_sql "$db_name" "$scripts_dir/04_insert_catalogos.sql"
    fi
    
    # 5. Insertar datos del restaurante
    if [ -f "$scripts_dir/05_insert_restaurante.sql" ]; then
        execute_sql "$db_name" "$scripts_dir/05_insert_restaurante.sql"
    fi
    
    echo "✓ $rest_name configurado correctamente"
}

# Verificar que sqlcmd esté disponible
if ! command -v sqlcmd &> /dev/null; then
    echo "ERROR: sqlcmd no está instalado o no está en el PATH"
    echo "Instala SQL Server Command Line Utilities"
    exit 1
fi

# Configurar bases de datos
setup_database "bella-pizza" "das_bella_pizza"
setup_database "perukai" "das_perukai"
setup_database "fabrica-burger" "das_fabrica_burger"
setup_database "sabores-norte" "das_sabores_norte"

echo ""
echo "=========================================="
echo "COMPILANDO APLICACIONES JAVA"
echo "=========================================="
echo ""

# Compilar aplicaciones
cd "$BACKEND_DIR"

for app_dir in bella-pizza-rest fabrica-burger-rest perukai-soap sabores-norte-soap; do
    if [ -d "$app_dir" ]; then
        echo "Compilando: $app_dir..."
        cd "$app_dir"
        ./mvnw clean package -DskipTests || {
            echo "ERROR: No se pudo compilar $app_dir"
            cd "$BACKEND_DIR"
            continue
        }
        cd "$BACKEND_DIR"
        echo "✓ $app_dir compilado correctamente"
    fi
done

echo ""
echo "=========================================="
echo "SETUP COMPLETADO"
echo "=========================================="
echo ""
echo "Para levantar las aplicaciones, ejecuta:"
echo ""
echo "  # La Bella Pizza (REST - puerto 8082)"
echo "  cd backend/bella-pizza-rest && ./mvnw spring-boot:run"
echo ""
echo "  # Perukai (SOAP - puerto 8081)"
echo "  cd backend/perukai-soap && ./mvnw spring-boot:run"
echo ""
echo "  # La Fábrica Burger (REST - puerto 8083)"
echo "  cd backend/fabrica-burger-rest && ./mvnw spring-boot:run"
echo ""
echo "  # Sabores del Norte (SOAP - puerto 8084)"
echo "  cd backend/sabores-norte-soap && ./mvnw spring-boot:run"
echo ""
echo "O usa el script start-all-restaurants.sh para levantar todas en background"
echo ""

