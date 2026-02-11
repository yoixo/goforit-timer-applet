# Go-For-It! Timer Applet for Cinnamon

A minimal Cinnamon applet that displays and controls the Go-For-It! timer from the panel.

## Features

- Displays remaining time in `MM:SS` format
- Click to toggle Start/Stop
- Requires Go-For-It! with DBus support running

## Requirements

- Cinnamon 6.4+
- Go-For-It! with DBus support

## Installation

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/goforit-timer-applet.git
cd goforit-timer-applet

# Install applet
mkdir -p ~/.local/share/cinnamon/applets/goforit-timer@local
cp metadata.json applet.js ~/.local/share/cinnamon/applets/goforit-timer@local/

# Restart Cinnamon
nohup cinnamon --replace &
```

## Usage

1. Start Go-For-It! with DBus support
2. Add the applet to your panel (right-click panel → Add applet → Go-For-It Timer)
3. Click the timer to Start/Stop

## Setup Go-For-It! DBus Support

See the `go-for-it-dbus/` directory for patches to add DBus support to Go-For-It!

## License

GPL v3 - Same as Go-For-It!