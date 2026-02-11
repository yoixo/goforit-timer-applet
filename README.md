# Go-For-It! Timer Applet for Cinnamon

A minimal Cinnamon applet that integrates with Go-For-It! to display and control the timer from the panel.

## Quick Start

```bash
# 1. Install the applet
./install.sh

# 2. Restart Cinnamon
nohup cinnamon --replace &
```

## Repository Structure

```
goforit-timer-applet/
├── goforit-timer@local/          # Cinnamon applet files
│   ├── applet.js                 # Main applet code
│   ├── metadata.json             # Applet metadata
│   ├── README.md                 # Applet documentation
│   └── install.sh                # Installation script
├── go-for-it-dbus/               # Go-For-It! DBus patches
│   ├── TimerDBusService.vala     # DBus service implementation
│   ├── apply-dbus-patches.sh     # Automated patching script ⭐
│   └── README.md                 # Patching instructions
├── README.md                     # This file
├── install.sh                    # Main installation script
└── LICENSE                       # GPL v3 License
```

## Prerequisites

- Linux Mint 22.1+ with Cinnamon 6.4+
- Go-For-It! with DBus support (see go-for-it-dbus/ directory)

## Installation

### Option 1: Automated Installation

```bash
git clone https://github.com/yoixo/goforit-timer-applet.git
cd goforit-timer-applet
./install.sh
```

### Option 2: Manual Installation

```bash
# Clone repository
git clone https://github.com/yoixo/goforit-timer-applet.git
cd goforit-timer-applet

# Install applet
mkdir -p ~/.local/share/cinnamon/applets/goforit-timer@local
cp goforit-timer@local/* ~/.local/share/cinnamon/applets/goforit-timer@local/

# Restart Cinnamon
nohup cinnamon --replace &
```

### Option 3: Via Cinnamon Settings

1. Copy `goforit-timer@local/` to `~/.local/share/cinnamon/applets/`
2. Right-click on Cinnamon panel
3. Select "Add applet to panel"
4. Find and select "Go-For-It Timer"

## Usage

1. **Start Go-For-It!** with DBus support enabled
2. **Click the timer** in the panel to toggle Start/Stop
3. The timer displays remaining time in `MM:SS` format

## Building Go-For-It! with DBus Support

Go-For-It! needs to be patched to expose the timer via DBus.

### Automated (Recommended)

```bash
cd go-for-it-dbus
./apply-dbus-patches.sh
```

### Manual

See the `go-for-it-dbus/` directory for manual patching instructions.

## Features

- ✅ Minimal design - Just the timer display
- ✅ Click to toggle Start/Stop
- ✅ Automatic connection to Go-For-It! via DBus
- ✅ Real-time updates every second
- ✅ No context menu - pure simplicity

## Troubleshooting

### Timer shows "--:--"
- Ensure Go-For-It! is running
- Check DBus service: `dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep goforit`

### Click doesn't work
- Restart Cinnamon after installing
- Check Go-For-It! has DBus support compiled

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under GPL v3 - the same license as Go-For-It!

## Acknowledgments

- [Go-For-It!](https://github.com/JMoerman/Go-For-It) - The productivity timer app
- Cinnamon Desktop Environment
