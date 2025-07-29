

#!/bin/bash

# Find the first USB audio sink automatically
USB_SINK=$(pactl list short sinks | grep usb | awk '{print $2}' | head -n 1)

if [ -z "$USB_SINK" ]; then
  notify-send "No USB headphone found"
  exit 1
fi

# Set the detected USB sink as default
pactl set-default-sink "$USB_SINK"

# Move all playing streams to the USB sink
for input in $(pactl list short sink-inputs | awk '{print $1}'); do
  pactl move-sink-input "$input" "$USB_SINK"
done

# Optional: Play a test sound
paplay /usr/share/sounds/alsa/Front_Center.wav

# Optional: Notification
notify-send "Switched audio to $USB_SINK"
