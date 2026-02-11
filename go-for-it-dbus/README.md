# Go-For-It! DBus Integration

This directory contains the patches needed to add DBus support to Go-For-It!

## Quick Install (Automated) ⭐

The easiest way to apply patches:

```bash
cd go-for-it-dbus
./apply-dbus-patches.sh
```

This script will:
1. ✅ Check dependencies
2. ✅ Find or clone Go-For-It!
3. ✅ Apply patches automatically
4. ✅ Compile with DBus support
5. ✅ Install (optional)

## Files

- `TimerDBusService.vala` - DBus service implementation
- `apply-dbus-patches.sh` - Automated patching script ⭐
- `Main.vala` - Modified main application file (reference)
- `go-for-it.vala` - Modified entry point (reference)
- `CMakeLists.txt` - Modified build configuration (reference)

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

### Option 1: Automated (Recommended)

```bash
./apply-dbus-patches.sh
```

### Option 2: Manual

If you prefer to apply patches manually:

```bash
# Clone Go-For-It!
git clone https://github.com/JMoerman/Go-For-It.git
cd Go-For-It

# Copy DBus files
cp /path/to/goforit-timer-applet/go-for-it-dbus/TimerDBusService.vala src/Services/

# Edit src/CMakeLists.txt - add after Services/Notifications.vala:
# Services/TimerDBusService.vala

# Edit src/Main.vala - add the DBus service initialization
# (see TimerDBusService.vala for the complete setup_dbus_service method)

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