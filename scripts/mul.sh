#!/bin/bash
set -e

# Define input variables
APP1="$1"
APP2="$2"

# Check if APP2 is running
if ! pgrep -xf "$APP2" >/dev/null; then
    # If APP2 is not running, start it
    echo "Required app $APP2 is NOT already running. Starting it now..."
    sh $HOME/bg.sh "$APP2"
fi

# Wait for APP2 to start
while ! pgrep -xf "$APP2" >/dev/null; do
    sleep 1
done

# Start APP1 after APP2 has started
echo "Starting main app $APP1 now..."
sh $HOME/bg.sh "$APP1"
