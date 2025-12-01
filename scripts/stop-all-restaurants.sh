#!/bin/bash

# =========================================================================================
# Script para detener todas las aplicaciones de restaurantes
# =========================================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="$SCRIPT_DIR/../logs"

echo "=========================================="
echo "DETENIENDO APLICACIONES DE RESTAURANTES"
echo "=========================================="
echo ""

if [ ! -d "$LOGS_DIR" ]; then
    echo "No hay aplicaciones en ejecución (directorio de logs no existe)"
    exit 0
fi

# Detener aplicaciones por PID
for pid_file in "$LOGS_DIR"/*.pid; do
    if [ -f "$pid_file" ]; then
        app_name=$(basename "$pid_file" .pid)
        pid=$(cat "$pid_file")
        
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "Deteniendo $app_name (PID: $pid)..."
            kill "$pid" || true
            sleep 1
            # Forzar kill si aún está corriendo
            if ps -p "$pid" > /dev/null 2>&1; then
                kill -9 "$pid" || true
            fi
            echo "  ✓ $app_name detenido"
        else
            echo "  $app_name ya no está en ejecución"
        fi
        
        rm -f "$pid_file"
    fi
done

echo ""
echo "=========================================="
echo "APLICACIONES DETENIDAS"
echo "=========================================="
echo ""

