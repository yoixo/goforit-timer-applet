#!/bin/bash

# Script de instalación del applet Go-For-It Timer para Cinnamon
# Este script instala el applet en ~/.local/share/cinnamon/applets/

set -e

APPLET_NAME="goforit-timer@local"
APPLET_DIR="$HOME/.local/share/cinnamon/applets/$APPLET_NAME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Instalando Go-For-It Timer Applet"
echo "=========================================="
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "$SCRIPT_DIR/goforit-timer@local/applet.js" ]; then
    echo "Error: No se encontró el archivo applet.js"
    echo "Asegúrate de ejecutar este script desde el directorio cinnamon-applet/"
    exit 1
fi

# Crear directorio del applet si no existe
echo "1. Creando directorio del applet..."
mkdir -p "$APPLET_DIR"

# Copiar archivos
echo "2. Copiando archivos..."
cp "$SCRIPT_DIR/goforit-timer@local/metadata.json" "$APPLET_DIR/"
cp "$SCRIPT_DIR/goforit-timer@local/applet.js" "$APPLET_DIR/"

# Verificar instalación
echo "3. Verificando instalación..."
if [ -f "$APPLET_DIR/applet.js" ] && [ -f "$APPLET_DIR/metadata.json" ]; then
    echo "✓ Archivos instalados correctamente"
else
    echo "✗ Error: No se pudieron instalar todos los archivos"
    exit 1
fi

# Informar al usuario
echo ""
echo "=========================================="
echo "Instalación completada exitosamente!"
echo "=========================================="
echo ""
echo "Para activar el applet:"
echo "1. Haz clic derecho en el panel de Cinnamon"
echo "2. Selecciona 'Añadir applet al panel'"
echo "3. Busca 'Go-For-It Timer'"
echo "4. Haz clic para añadirlo"
echo ""
echo "O reinicia Cinnamon para que el applet aparezca automáticamente:"
echo "  Alt+F2, escribe 'r' y presiona Enter"
echo ""
echo "Asegúrate de que Go-For-It! esté ejecutándose con soporte DBus."
echo ""