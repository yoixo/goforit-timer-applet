# Go-For-It! DBus Integration

This directory contains the patches needed to add DBus support to Go-For-It!

## Files

- `TimerDBusService.vala` - DBus service implementation
- `Main.vala` - Modified main application file
- `go-for-it.vala` - Modified entry point
- `CMakeLists.txt` - Modified build configuration

## DBus Interface

**Service Name:** `com.github.jmoerman.goforit.Timer`  
**Object Path:** `/com/github/jmoerman/goforit/Timer`

### Methods

- `Start()` - Start the timer
- `Stop()` - Stop the timer  
- `Reset()` - Reset the timer

### Properties

- `RemainingTime` (uint) - Remaining seconds
- `State` (string) - "running", "stopped", or "finished"
- `IsBreakActive` (bool) - Whether break mode is active
- `ActiveTask` (string) - Current task description

### Signals

- `TimeChanged(uint remaining_seconds)` - Emitted every second
- `StateChanged(string state)` - Emitted when state changes
- `TimerFinished(bool break_active)` - Emitted when timer finishes
- `ActiveTaskChanged(string task_description)` - Emitted when task changes

## Installation

### Prerequisites

```bash
sudo apt install build-essential cmake valac libgtk-3-dev libcanberra-dev
```

### Apply Patches

```bash
# Clone Go-For-It!
git clone https://github.com/JMoerman/Go-For-It.git
cd Go-For-It

# Copy DBus files
cp /path/to/goforit-timer-applet/go-for-it-dbus/TimerDBusService.vala src/Services/
cp /path/to/goforit-timer-applet/go-for-it-dbus/Main.vala src/
cp /path/to/goforit-timer-applet/go-for-it-dbus/go-for-it.vala executable/
cp /path/to/goforit-timer-applet/go-for-it-dbus/CMakeLists.txt src/

# Build
rm -rf build && mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make -j$(nproc)

# Install
sudo make install
sudo ldconfig
```

### Verify Installation

```bash
# Start Go-For-It!
go-for-it &

# Check DBus service
dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep goforit

# Test methods
dbus-send --session --dest=com.github.jmoerman.goforit.Timer --type=method_call /com/github/jmoerman/goforit/Timer com.github.jmoerman.goforit.Timer.Start
dbus-send --session --dest=com.github.jmoerman.goforit.Timer --type=method_call --print-reply /com/github/jmoerman/goforit/Timer org.freedesktop.DBus.Properties.Get string:com.github.jmoerman.goforit.Timer string:RemainingTime
```

## Testing

Use `d-feet` or `qdbusviewer` to explore the DBus interface:

```bash
sudo apt install d-feet
d-feet
```

Then search for `com.github.jmoerman.goforit.Timer` in the session bus.