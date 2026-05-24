const Applet = imports.ui.applet;
const Gio = imports.gi.Gio;
const GLib = imports.gi.GLib;

const DBUS_NAME = 'com.github.jmoerman.goforit.Timer';
const DBUS_PATH = '/com/github/jmoerman/goforit/Timer';
const DBUS_IFACE = 'com.github.jmoerman.goforit.Timer';

class MyApplet extends Applet.TextApplet {
    constructor(metadata, orientation, panelHeight, instanceId) {
        super(orientation, panelHeight, instanceId);

        this.set_applet_label('--:--');
        this.set_applet_tooltip('Go-For-It! Timer');

        this._proxy = null;
        this._remainingSeconds = 0;
        this._timerState = 'stopped';

        this._setupDBus();

        this._refreshInterval = GLib.timeout_add_seconds(
            GLib.PRIORITY_DEFAULT, 1, () => this._refreshState()
        );
    }

    _setupDBus() {
        Gio.bus_watch_name(
            Gio.BusType.SESSION,
            DBUS_NAME,
            Gio.BusNameWatcherFlags.NONE,
            (connection, name) => this._onBusAcquired(connection, name),
            (connection, name) => this._onBusVanished(connection, name)
        );
    }

    _onBusAcquired(connection, name) {
        try {
            this._proxy = Gio.DBusProxy.new_for_bus_sync(
                Gio.BusType.SESSION,
                Gio.DBusProxyFlags.NONE,
                null,
                DBUS_NAME,
                DBUS_PATH,
                DBUS_IFACE,
                null
            );

            this._proxy.connect('g-signal', (proxy, senderName, signalName, params) => {
                this._onDBusSignal(proxy, senderName, signalName, params);
            });
            this._refreshState();
        } catch (e) {
            this._proxy = null;
        }
    }

    _onBusVanished(connection, name) {
        this._proxy = null;
        this.set_applet_label('--:--');
    }

    _onDBusSignal(proxy, senderName, signalName, params) {
        if (signalName === 'TimeChanged') {
            this._remainingSeconds = params.get_child_value(0).get_uint32();
            this._updateDisplay();
        } else if (signalName === 'StateChanged') {
            this._timerState = params.get_child_value(0).get_string()[0];
            this._updateDisplay();
        }
    }

    _refreshState() {
        if (!this._proxy) return GLib.SOURCE_CONTINUE;

        try {
            let variant = this._proxy.call_sync(
                'org.freedesktop.DBus.Properties.Get',
                GLib.Variant.new('(ss)', [DBUS_IFACE, 'RemainingTime']),
                Gio.DBusCallFlags.NONE, -1, null
            );
            this._remainingSeconds = variant.get_child_value(0).get_variant().get_uint32();

            variant = this._proxy.call_sync(
                'org.freedesktop.DBus.Properties.Get',
                GLib.Variant.new('(ss)', [DBUS_IFACE, 'State']),
                Gio.DBusCallFlags.NONE, -1, null
            );
            this._timerState = variant.get_child_value(0).get_variant().get_string()[0];

            this._updateDisplay();
        } catch (e) {}

        return GLib.SOURCE_CONTINUE;
    }

    _updateDisplay() {
        let mins = Math.floor(this._remainingSeconds / 60);
        let secs = this._remainingSeconds % 60;
        let formattedTime = mins.toString().padStart(2, '0') + ':' + secs.toString().padStart(2, '0');
        this.set_applet_label(formattedTime);
        this.set_applet_tooltip('Go-For-It! Timer - ' + this._timerState);
    }

    on_applet_clicked(event) {
        if (!this._proxy) return true;

        try {
            if (this._timerState === 'running') {
                this._proxy.call_sync('Stop', null, Gio.DBusCallFlags.NONE, -1, null);
            } else {
                this._proxy.call_sync('Start', null, Gio.DBusCallFlags.NONE, -1, null);
            }
        } catch (e) {}

        return true;
    }

    on_applet_removed_from_panel() {
        if (this._refreshInterval) {
            GLib.source_remove(this._refreshInterval);
        }
    }
}

function main(metadata, orientation, panelHeight, instanceId) {
    return new MyApplet(metadata, orientation, panelHeight, instanceId);
}