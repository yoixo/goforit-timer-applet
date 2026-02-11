#!/bin/bash

# Minimal installation script for Go-For-It! Timer Applet

APPLET_DIR="$HOME/.local/share/cinnamon/applets/goforit-timer@local"

mkdir -p "$APPLET_DIR"
cp metadata.json applet.js "$APPLET_DIR/"

echo "Applet installed successfully!"
echo "Restart Cinnamon to see the applet (Alt+F2, type 'r', press Enter)"