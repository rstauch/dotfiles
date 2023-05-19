#!/bin/bash
set -e

# check if parameter is passed
if [ -z "$1" ]; then
    echo "Usage: $0 <command>"
    exit 1
fi

# execute command with nohup in background
nohup "$1" >/dev/null 2>&1 &
