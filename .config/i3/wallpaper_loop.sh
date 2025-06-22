#!/bin/bash

wallpapers=(~/.config/Wallpapers/wallhaven-yqj53x.png)
count=${#wallpapers[@]}

# Exit if no images found
[ "$count" -eq 0 ] && exit 1

# Set the first wallpaper in the array
feh --bg-fill "${wallpapers[0]}"
