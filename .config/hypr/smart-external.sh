#!/bin/bash
echo "=== DEBUG MONITOR SETUP ==="
echo ""
echo "1. Current monitors:"
hyprctl monitors
echo ""
echo "2. Current workspaces:"
hyprctl workspaces
echo ""
echo "3. Active window rules:"
hyprctl getoption general:monitor
hyprctl getoption workspace
echo ""
echo "4. Testing workspace move..."
EXTERNAL=$(hyprctl monitors | grep -o "^Monitor [^:]*" | sed 's/Monitor //' | grep -v "eDP-1" | head -1)
echo "External monitor detected: $EXTERNAL"
if [ -n "$EXTERNAL" ]; then
    echo "Attempting to move workspace 1..."
    hyprctl dispatch movetoworkspace 1,monitor:$EXTERNAL
    sleep 0.5
    hyprctl workspaces
fi
