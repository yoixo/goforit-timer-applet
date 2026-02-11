#!/bin/bash

# Script de parcheo automático para Go-For-It! DBus
# Este script aplica automáticamente los parches necesarios para habilitar DBus

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GOFI_DIR=""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para verificar dependencias
check_dependencies() {
    print_status "Verificando dependencias..."
    
    local deps=("cmake" "make" "valac" "awk")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Faltan dependencias: ${missing[*]}"
        echo "Instala con: sudo apt install build-essential cmake valac gawk libgtk-3-dev libcanberra-dev"
        exit 1
    fi
    
    print_status "Todas las dependencias están instaladas"
}

# Función para agregar el método setup_dbus_service
add_dbus_method() {
    local main_file="$1"
    
    print_status "Agregando método setup_dbus_service..."
    
    # Crear archivo temporal con el método
    cat > /tmp/dbus_method.txt << 'METHOD_EOF'

    private void setup_dbus_service () {
        if (dbus_service == null) {
            dbus_service = new TimerDBusService (task_timer);
            try {
                dbus_service.initialize ();
            } catch (Error e) {
                warning ("Failed to initialize DBus service: %s", e.message);
                return;
            }
            
            try {
                dbus_connection = Bus.get_sync (BusType.SESSION);
                dbus_connection.register_object ("/com/github/jmoerman/goforit/Timer", (TimerDBusInterface) dbus_service);
                
                Bus.own_name (BusType.SESSION, "com.github.jmoerman.goforit.Timer", 
                    BusNameOwnerFlags.REPLACE,
                    () => {
                        message ("DBus service name acquired successfully");
                    },
                    () => {},
                    () => warning ("Could not acquire DBus service name")
                );
            } catch (IOError e) {
                warning ("Failed to register DBus object: %s", e.message);
            } catch (Error e) {
                warning ("Failed to setup DBus service: %s", e.message);
            }
        }
    }
METHOD_EOF

    # Usar awk para insertar el método después de setup_timer_and_notifications
    awk -v method_file="/tmp/dbus_method.txt" '
    BEGIN {
        while ((getline line < method_file) > 0) {
            method = method line "\n"
        }
        close(method_file)
    }
    
    /^    private void setup_timer_and_notifications/ {
        in_func = 1
    }
    
    in_func && /^    }$/ {
        print
        printf "%s", method
        in_func = 0
        next
    }
    
    { print }
    ' "$main_file" > "$main_file.tmp"
    
    # Verificar que se agregó
    if grep -q "setup_dbus_service" "$main_file.tmp"; then
        mv "$main_file.tmp" "$main_file"
        rm -f /tmp/dbus_method.txt
        print_status "✓ Método setup_dbus_service agregado"
        return 0
    else
        rm -f "$main_file.tmp" /tmp/dbus_method.txt
        print_error "No se pudo agregar el método setup_dbus_service"
        return 1
    fi
}

# Función para aplicar parches
apply_patches() {
    print_status "Aplicando parches DBus a Go-For-It!..."
    
    # 1. Copiar TimerDBusService.vala
    if [ -f "$SCRIPT_DIR/TimerDBusService.vala" ]; then
        cp "$SCRIPT_DIR/TimerDBusService.vala" "$GOFI_DIR/src/Services/"
        print_status "✓ TimerDBusService.vala copiado"
    else
        print_error "No se encontró TimerDBusService.vala en $SCRIPT_DIR"
        exit 1
    fi
    
    # 2. Modificar Main.vala
    local main_file="$GOFI_DIR/src/Main.vala"
    if [ -f "$main_file" ]; then
        # Crear backup
        cp "$main_file" "$main_file.backup"
        
        # Verificar si ya está parcheado
        if grep -q "TimerDBusService" "$main_file"; then
            print_warning "Main.vala ya parece estar parcheado"
        else
            # Agregar variables
            sed -i 's/private Notifications notification_service;$/private Notifications notification_service;\n    private TimerDBusService dbus_service;\n    private DBusConnection dbus_connection;/' "$main_file"
            
            # Agregar llamada a setup_dbus_service
            sed -i 's/task_timer.timer_finished.connect (on_timer_elapsed);$/task_timer.timer_finished.connect (on_timer_elapsed);\n            \n            \/\/ Setup DBus service for external integration\n            setup_dbus_service ();/' "$main_file"
            
            print_status "✓ Variables y llamada agregadas a Main.vala"
        fi
        
        # Agregar el método (esto siempre debe ejecutarse si no existe)
        if ! grep -q "private void setup_dbus_service" "$main_file"; then
            add_dbus_method "$main_file"
        else
            print_warning "El método setup_dbus_service ya existe"
        fi
    fi
    
    # 3. Modificar CMakeLists.txt
    local cmake_file="$GOFI_DIR/src/CMakeLists.txt"
    if [ -f "$cmake_file" ]; then
        if grep -q "TimerDBusService.vala" "$cmake_file"; then
            print_warning "CMakeLists.txt ya incluye TimerDBusService.vala"
        else
            sed -i 's/Services\/Notifications.vala/Services\/Notifications.vala\n    Services\/TimerDBusService.vala/' "$cmake_file"
            print_status "✓ CMakeLists.txt modificado"
        fi
    fi
    
    print_status "Parches aplicados exitosamente"
}

# Función para compilar
build_gofi() {
    print_status "Compilando Go-For-It! con soporte DBus..."
    
    cd "$GOFI_DIR"
    
    # Limpiar build anterior
    if [ -d "build" ]; then
        rm -rf build
    fi
    
    mkdir build
    cd build
    
    # Configurar
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr
    
    # Compilar
    make -j$(nproc)
    
    print_status "Compilación completada exitosamente!"
}

# Función para instalar
install_gofi() {
    print_status "Instalando Go-For-It!..."
    
    cd "$GOFI_DIR/build"
    sudo make install
    sudo ldconfig
    
    print_status "Instalación completada"
}

# Función principal
main() {
    echo "=========================================="
    echo "Go-For-It! DBus Patcher"
    echo "=========================================="
    echo ""
    
    # Verificar dependencias
    check_dependencies
    
    # Obtener directorio de Go-For-It!
    if [ $# -ge 1 ] && [ -d "$1" ] && [ -f "$1/CMakeLists.txt" ]; then
        GOFI_DIR="$1"
        print_status "Usando directorio proporcionado: $GOFI_DIR"
    else
        print_error "Debes proporcionar la ruta al código fuente de Go-For-It!"
        echo ""
        echo "Ejemplo:"
        echo "  ./apply-dbus-patches.sh ~/Go-For-It"
        echo ""
        echo "Nota: Necesitas el código fuente, no la versión instalada."
        echo "Descárgalo con: git clone https://github.com/JMoerman/Go-For-It.git"
        exit 1
    fi
    
    # Aplicar parches
    apply_patches
    
    # Compilar
    build_gofi
    
    # Preguntar si instalar
    echo ""
    read -p "¿Deseas instalar Go-For-It! ahora? (s/n): " response
    if [[ "$response" =~ ^[Ss]$ ]]; then
        install_gofi
    fi
    
    echo ""
    echo "=========================================="
    echo "¡Parcheo completado!"
    echo "=========================================="
    echo ""
    echo "Para verificar que funciona:"
    echo "1. Inicia Go-For-It!: go-for-it &"
    echo "2. Verifica DBus: dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep goforit"
    echo ""
    echo "Ahora puedes usar el applet de Cinnamon"
}

# Ejecutar
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi