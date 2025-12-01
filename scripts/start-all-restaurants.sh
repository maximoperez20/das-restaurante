#!/bin/bash

# =========================================================================================
# Script para levantar todas las aplicaciones de restaurantes en background
# =========================================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../backend"
LOGS_DIR="$SCRIPT_DIR/../logs"

# Crear directorio de logs si no existe
mkdir -p "$LOGS_DIR"

echo "=========================================="
echo "LEVANTANDO APLICACIONES DE RESTAURANTES"
echo "=========================================="
echo ""

# Función para levantar aplicación
start_app() {
    local app_name=$1
    local app_dir=$2
    local log_file="$LOGS_DIR/$app_name.log"
    
    if [ ! -d "$BACKEND_DIR/$app_dir" ]; then
        echo "ERROR: Directorio $app_dir no existe"
        return 1
    fi
    
    echo "Levantando $app_name..."
    cd "$BACKEND_DIR/$app_dir"
    nohup ./mvnw spring-boot:run > "$log_file" 2>&1 &
    local pid=$!
    echo "  ✓ $app_name iniciado (PID: $pid, Log: $log_file)"
    echo $pid > "$LOGS_DIR/$app_name.pid"
    cd "$SCRIPT_DIR"
}

# Levantar aplicaciones
start_app "bella-pizza-rest" "bella-pizza-rest"
sleep 2
start_app "perukai-soap" "perukai-soap"
sleep 2
start_app "fabrica-burger-rest" "fabrica-burger-rest"
sleep 2
start_app "sabores-norte-soap" "sabores-norte-soap"

echo ""
echo "=========================================="
echo "APLICACIONES LEVANTADAS"
echo "=========================================="
echo ""
echo "Logs disponibles en: $LOGS_DIR"
echo ""
echo "Para detener todas las aplicaciones, ejecuta:"
echo "  ./stop-all-restaurants.sh"
echo ""
echo "Para ver los logs:"
echo "  tail -f $LOGS_DIR/*.log"
echo ""

