#!/bin/bash

# Display manager script - handles multiple monitor configurations with better resolution support

# Find internal and external outputs
internal=$(xrandr | grep " connected primary" | cut -d ' ' -f1)
if [ -z "$internal" ]; then
    # If no primary is set, just take the first connected display
    internal=$(xrandr | grep " connected" | head -n 1 | cut -d ' ' -f1)
fi

external=$(xrandr | grep " connected" | grep -v "$internal" | cut -d ' ' -f1)

# If no external, exit
if [ -z "$external" ]; then
    notify-send "No external monitor detected."
    exit 1
fi

# Get preferred resolutions for both monitors
internal_res=$(xrandr | grep -A1 "^$internal connected" | tail -n1 | awk '{print $1}')
external_res=$(xrandr | grep -A1 "^$external connected" | tail -n1 | awk '{print $1}')

# If resolution detection fails, fall back to 1920x1080
[ -z "$internal_res" ] && internal_res="1920x1080"
[ -z "$external_res" ] && external_res="1920x1080"

# Ask user for mode
choice=$(echo -e "Mirror\nExtend\nInternal only\nExternal only" | rofi -dmenu -p "Display mode:")

# Apply the selected configuration
case "$choice" in
    Mirror)
        # For mirroring, use the resolution that both displays support
        xrandr --output "$external" --same-as "$internal" --mode "$external_res" --output "$internal" --mode "$internal_res"
        
        # Force refresh desktop environment
        if command -v xfwm4 &> /dev/null; then
            xfwm4 --replace &
        elif command -v marco &> /dev/null; then
            marco --replace &
        elif command -v kwin &> /dev/null; then
            kwin --replace &
        elif command -v openbox &> /dev/null; then
            openbox --restart &
        elif command -v i3 &> /dev/null; then
            i3-msg restart &
        fi
        ;;
        
    Extend)
        xrandr --output "$internal" --auto --primary --output "$external" --right-of "$internal" --auto
        
        # Force desktop refresh
        if command -v xfwm4 &> /dev/null; then
            xfwm4 --replace &
        elif command -v marco &> /dev/null; then
            marco --replace &
        elif command -v kwin &> /dev/null; then
            kwin --replace &
        elif command -v openbox &> /dev/null; then
            openbox --restart &
        elif command -v i3 &> /dev/null; then
            i3-msg restart &
        fi
        ;;
        
    "Internal only")
        xrandr --output "$external" --off --output "$internal" --auto --primary
        ;;
        
    "External only")
        xrandr --output "$internal" --off --output "$external" --auto --primary
        ;;
        
    *)
        notify-send "Cancelled or invalid choice."
        exit 1
        ;;
esac

# Reset desktop environment to fix application sizing
if command -v xdotool &> /dev/null; then
    sleep 1
    xdotool key super+r  # Common key to reset windows in many environments
fi

notify-send "Display mode changed to: $choice"