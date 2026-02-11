const Applet = imports.ui.applet;
const Gio = imports.gi.Gio;
const GLib = imports.gi.GLib;
const Lang = imports.lang;

const DBUS_NAME = 'com.github.jmoerman.goforit.Timer';
const DBUS_PATH = '/com/github/jmoerman/goforit/Timer';
const DBUS_IFACE = 'com.github.jmoerman.goforit.Timer';

function MyApplet(orientation, panel_height, instance_id) {
    this._init(orientation, panel_height, instance_id);
}

MyApplet.prototype = {
    __proto__: Applet.TextApplet.prototype,

    _init: function(orientation, panel_height, instance_id) {
        Applet.TextApplet.prototype._init.call(this, orientation, panel_height, instance_id);
        
        this.set_applet_label("--:--");
        this.set_applet_tooltip("Go-For-It! Timer");
        
        this._proxy = null;
        this._remainingSeconds = 0;
        this._timerState = 'stopped';
        
        this._setupDBus();
        
        this._refreshInterval = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, 
            Lang.bind(this, this._refreshState));
    },

    _setupDBus: function() {
        Gio.bus_watch_name(
            Gio.BusType.SESSION,
            DBUS_NAME,
            Gio.BusNameWatcherFlags.NONE,
            Lang.bind(this, this._onBusAcquired),
            Lang.bind(this, this._onBusVanished)
        );
    },

    _onBusAcquired: function(connection, name) {
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
            
            this._proxy.connect('g-signal', Lang.bind(this, this._onDBusSignal));
            this._refreshState();
        } catch (e) {
            this._proxy = null;
        }
    },

    _onBusVanished: function(connection, name) {
        this._proxy = null;
        this.set_applet_label('--:--');
    },

    _onDBusSignal: function(proxy, senderName, signalName, params) {
        if (signalName === 'TimeChanged') {
            this._remainingSeconds = params.get_child_value(0).get_uint32();
            this._updateDisplay();
        } else if (signalName === 'StateChanged') {
            this._timerState = params.get_child_value(0).get_string()[0];
            this._updateDisplay();
        }
    },

    _refreshState: function() {
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
    },

    _updateDisplay: function() {
        let mins = Math.floor(this._remainingSeconds / 60);
        let secs = this._remainingSeconds % 60;
        let formattedTime = mins.toString().padStart(2, '0') + ':' + secs.toString().padStart(2, '0');
        this.set_applet_label(formattedTime);
        this.set_applet_tooltip('Go-For-It! Timer - ' + this._timerState);
    },

    on_applet_clicked: function(event) {
        if (!this._proxy) return true;
        
        try {
            if (this._timerState === 'running') {
                this._proxy.call_sync('Stop', null, Gio.DBusCallFlags.NONE, -1, null);
            } else {
                this._proxy.call_sync('Start', null, Gio.DBusCallFlags.NONE, -1, null);
            }
        } catch (e) {}
        
        return true;
    },

    on_applet_removed_from_panel: function() {
        if (this._refreshInterval) {
            GLib.source_remove(this._refreshInterval);
        }
    }
};

function main(metadata, orientation, panel_height, instance_id) {
    return new MyApplet(orientation, panel_height, instance_id);
}