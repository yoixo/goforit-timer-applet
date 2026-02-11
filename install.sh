#!/bin/bash

# Installation script for Go-For-It! Timer Applet

set -e

APPLET_NAME="goforit-timer@local"
APPLET_DIR="$HOME/.local/share/cinnamon/applets/$APPLET_NAME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Installing Go-For-It Timer Applet"
echo "=========================================="
echo ""

# Check if applet files exist
if [ ! -f "$SCRIPT_DIR/goforit-timer@local/applet.js" ]; then
    echo "Error: Applet files not found"
    exit 1
fi

# Create directory
mkdir -p "$APPLET_DIR"

# Copy files
echo "Copying applet files..."
cp "$SCRIPT_DIR/goforit-timer@local/applet.js" "$APPLET_DIR/"
cp "$SCRIPT_DIR/goforit-timer@local/metadata.json" "$APPLET_DIR/"

# Verify installation
if [ -f "$APPLET_DIR/applet.js" ] && [ -f "$APPLET_DIR/metadata.json" ]; then
    echo "✓ Applet installed successfully"
    echo ""
    echo "Next steps:"
    echo "1. Restart Cinnamon: Alt+F2, type 'r', press Enter"
    echo "2. Right-click panel → Add applet → Go-For-It Timer"
    echo "3. Make sure Go-For-It! is running with DBus support"
else
    echo "✗ Installation failed"
    exit 1
fi