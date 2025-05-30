#!/bin/bash

# Output image path
img="/tmp/i3lock_blur.png"

# Take a screenshot and blur it
scrot "$img"
convert "$img" -blur 0x8 "$img"

# Launch i3lock-color with styling
i3lock \
--image="$img" \
--inside-color=373445FF \
--ring-color=ffffffff \
--line-color=00000000 \
--separator-color=00000000 \
--keyhl-color=d23c3dff \
--bshl-color=d23c3dff \
--ringver-color=ffffffff \
--ringwrong-color=d23c3dff \
--insidever-color=373445FF \
--insidewrong-color=373445FF \
--verif-color=ffffffff \
--wrong-color=ffffffff \
--time-color=ffffffff \
--date-color=ffffffff \
--layout-color=ffffffff \
--greeter-color=ffffffff \
--radius=180 \
--ring-width=7 \
--verif-text="Checking..." \
--wrong-text="Nope!" \
--noinput-text="..." \
--time-str="%H:%M:%S" \
--date-str="%A, %d %B %Y" \
--greeter-text="Welcome, $USER" \
--greeter-pos="x+950:y+350" \
--greeter-font="JetBrainsMono Nerd Font" \
--greeter-size=28 \
--time-font="JetBrainsMono Nerd Font" \
--date-font="JetBrainsMono Nerd Font" \
--time-size=36 \
--date-size=20 \
--ind-pos="x+960:y+540" \
--time-pos="x+950:y+460" \
--date-pos="x+950:y+500"
