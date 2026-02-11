/* Copyright 2024 GoForIt! developers
 *
 * This file is part of GoForIt!.
 *
 * GoForIt! is free software: you can redistribute it
 * and/or modify it under the terms of version 3 of the
 * GNU General Public License as published by the Free Software Foundation.
 *
 * GoForIt! is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with GoForIt!. If not, see http://www.gnu.org/licenses/.
 */

/**
 * Interfaz DBus para el servicio de temporizador
 */
[DBus(name = "com.github.jmoerman.goforit.Timer")]
public interface GOFI.TimerDBusInterface : Object {
    public abstract void Start() throws GLib.Error;
    public abstract void Stop() throws GLib.Error;
    public abstract void Reset() throws GLib.Error;
    
    public abstract uint RemainingTime { get; }
    public abstract string State { owned get; }
    public abstract bool IsBreakActive { get; }
    public abstract string ActiveTask { owned get; }
    
    public signal void TimeChanged(uint remaining_seconds);
    public signal void StateChanged(string state);
    public signal void TimerFinished(bool break_active);
    public signal void ActiveTaskChanged(string task_description);
}

/**
 * Service DBus para exponer el estado y control del temporizador
 * 
 * Interfaz: com.github.jmoerman.goforit.Timer
 * Path: /com/github/jmoerman/goforit/Timer
 */
public class GOFI.TimerDBusService : Object, GOFI.TimerDBusInterface {
    private TaskTimer _timer;
    private bool _is_connected = false;

    /**
     * Constructor del servicio DBus
     */
    public TimerDBusService(TaskTimer timer) {
        this._timer = timer;
    }

    /**
     * Inicializar conexión con el timer
     */
    public void initialize() throws GLib.Error {
        if (!_is_connected) {
            // Conectar señales del timer
            _timer.timer_updated.connect(on_timer_updated);
            _timer.timer_started.connect(on_timer_started);
            _timer.timer_stopped.connect(on_timer_stopped);
            _timer.timer_finished.connect(on_timer_finished);
            _timer.active_task_changed.connect(on_active_task_changed);
            _is_connected = true;
        }
    }

    /**
     * Iniciar el temporizador
     */
    public void Start() throws GLib.Error {
        _timer.start();
    }

    /**
     * Detener el temporizador
     */
    public void Stop() throws GLib.Error {
        _timer.stop();
    }

    /**
     * Reiniciar el temporizador
     */
    public void Reset() throws GLib.Error {
        _timer.reset();
    }

    /**
     * Obtener el tiempo restante en segundos
     */
    public uint RemainingTime {
        get {
            return _timer.remaining_duration;
        }
    }

    /**
     * Obtener el estado del temporizador
     * "running", "stopped", "finished"
     */
    public string State {
        owned get {
            if (_timer.running) {
                return "running";
            } else if (_timer.remaining_duration > 0) {
                return "stopped";
            } else {
                return "finished";
            }
        }
    }

    /**
     * Obtener el estado del descanso
     */
    public bool IsBreakActive {
        get {
            return _timer.break_active;
        }
    }

    /**
     * Obtener la tarea activa (solo el texto)
     */
    public string ActiveTask {
        owned get {
            if (_timer.active_task != null) {
                return _timer.active_task.description;
            }
            return "";
        }
    }



    // Handlers de señales del timer original
    private void on_timer_updated(uint remaining_duration) {
        TimeChanged(remaining_duration);
    }

    private void on_timer_started() {
        StateChanged("running");
    }

    private void on_timer_stopped(DateTime start_time, uint runtime) {
        StateChanged("stopped");
    }

    private void on_timer_finished(bool break_active) {
        StateChanged("finished");
        TimerFinished(break_active);
    }

    private void on_active_task_changed(TodoTask? task) {
        if (task != null) {
            ActiveTaskChanged(task.description);
        } else {
            ActiveTaskChanged("");
        }
    }
}