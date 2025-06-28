#!/bin/bash

# Kill all running Waybar instances
killall .waybar-wrapped

# Small delay to ensure process is fully stopped
sleep 2

# Restart Waybar
waybar &
