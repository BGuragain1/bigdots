#!/bin/bash

# Get list of image files once, no constant `find` or nesting
wallpapers=(~/.config/Wallpapers/*.{jpg,jpeg,png})
count=${#wallpapers[@]}

# Exit if no images found
[ "$count" -eq 0 ] && exit 1

while true; do
  for img in "${wallpapers[@]}"; do
    feh --bg-fill "$img"
    sleep 300  # Wait 5 minutes
  done
done
