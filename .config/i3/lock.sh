#!/bin/bash

# Configuration
BG_IMAGE="$HOME/Pictures/lockscreen.png"  # Your preferred background
TEMP_BG="/tmp/lock-screen.png"
LOCK_ICON="$HOME/Pictures/lock.png"  # Optional lock icon

# Get screenshot and apply effects
maim -u | convert - \
    -blur 0x8 \
    -fill "#2E3440" -colorize 30% \
    -fill "#D8DEE9" -gravity center \
    -font "Noto-Sans" -pointsize 32 \
    -annotate +0+200 "Type password to unlock" \
    "$TEMP_BG"

# Add lock icon if available
if [ -f "$LOCK_ICON" ]; then
    convert "$TEMP_BG" \
        "$LOCK_ICON" -gravity center -composite \
        "$TEMP_BG"
fi

# Lock screen with image
i3lock \
    --image "$TEMP_BG" \
    --ignore-empty-password \
    --show-failed-attempts \
    --indicator \
    --clock \
    --time-color="#ECEFF4" \
    --date-color="#ECEFF4" \
    --inside-color="#2E344088" \
    --ring-color="#3B4252" \
    --keyhl-color="#81A1C1" \
    --line-color="#2E3440" \
    --insidever-color="#2E344088" \
    --ringver-color="#A3BE8C" \
    --insidewrong-color="#BF616A88" \
    --ringwrong-color="#BF616A" \
    --verif-color="#ECEFF4" \
    --wrong-color="#ECEFF4" \
    --time-font="Noto Sans" \
    --date-font="Noto Sans" \
    --verif-font="Noto Sans" \
    --wrong-font="Noto Sans" \
    --noinput-text="" \
    --radius 180 \
    --ring-width 12

# Clean up
rm "$TEMP_BG"