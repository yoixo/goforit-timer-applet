Instalación completa (applet + parche DBus para GoForIt)

1. Dependencias
sudo apt install build-essential cmake valac libgtk-3-dev libcanberra-dev git

2. Clonar GoForIt y applet desde fuente y aplicar parches DBus

git clone https://github.com/yoixo/goforit-timer-applet
git clone https://github.com/yoixo/Go-For-It

cd goforit-timer-applet/go-for-it-dbus
./apply-dbus-patches.sh ~/Go-For-It

# Responde 's' cuando pregunte si instalar

3. Instalar el applet de Cinnamon

cd ~/Desktop/goforit-timer-applet

./install.sh

4. Reiniciar Cinnamon

nohup cinnamon --replace &

5. Agregar el applet al panel

Botón derecho en el panel → Add applet to panel → buscar Go-For-It Timer

6. Verificar que funciona

# Inicia GoForIt, luego:
dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep goforit

# Debe mostrar: "com.github.jmoerman.goforit.Timer"
⚠️ Importante: GoForIt instalado desde apt NO incluye el servicio DBus. Siempre hay que compilarlo desde fuente con los parches de go-for-it-dbus/.

