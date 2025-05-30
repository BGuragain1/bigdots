#!/bin/bash

# i3 Control Center - Optimized Version
CONFIG_DIR="$HOME/.config/i3/"
mkdir -p "$CONFIG_DIR"
CACHE_DIR="$CONFIG_DIR/cache"
mkdir -p "$CACHE_DIR"

# Notification colors
BLUE="#2196F3"
GREEN="#4CAF50"
RED="#F44336"
YELLOW="#FFC107"
PURPLE="#9C27B0"

# Rofi commands
ROFI_CMD="rofi -dmenu -i -theme $CONFIG_DIR/control-center.rasi"
ROFI_MSG="rofi -e -theme $CONFIG_DIR/control-center.rasi"

# Check dependencies
check_deps() {
    local missing=()
    for cmd in rofi notify-send nmcli bluetoothctl; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    [ ${#missing[@]} -gt 0 ] && {
        notify-send -u critical "Missing Dependencies" "Install: ${missing[*]}" -h string:bgcolor:$RED
        exit 1
    }
}

# Async notification helper
notify() {
    local urgency="$1" title="$2" message="$3" color="$4"
    notify-send -u "$urgency" "$title" "$message" -h string:bgcolor:"$color" &
}

# Main Menu
main_menu() {
    while true; do
        choice=$(echo -e "  WiFi\n  Bluetooth\n  Displays\n  Screenshot\n  System\n  Exit" | $ROFI_CMD -p "Control Center")
        
        # Handle ESC key or empty selection
        [ -z "$choice" ] && exit 0
        
        case "$choice" in
            "  WiFi") wifi_menu ;;
            "  Bluetooth") bluetooth_menu ;;
            "  Displays") display_menu ;;
            "  Screenshot") screenshot_menu ;;
            "  System") system_menu ;;
            "  Exit") exit 0 ;;
            *) exit 0 ;;
        esac
    done
}

# ===================== WiFi Menu =====================
wifi_menu() {
    while true; do
        # Get current WiFi status
        wifi_status=$(nmcli -t -f WIFI radio)
        [ "$wifi_status" = "enabled" ] && status_icon="" || status_icon=""
        
        choice=$(echo -e "$status_icon  Toggle WiFi\n  Connect\n  Saved Networks\n  Rescan\n  Status\n  Back" | $ROFI_CMD -p "WiFi")
        
        # Handle ESC key or empty selection
        [ -z "$choice" ] && return
        
        case "$choice" in
            "  Toggle WiFi"|"  Toggle WiFi")
                if [ "$wifi_status" = "enabled" ]; then
                    nmcli radio wifi off && notify normal "WiFi" "Disabled" "$RED"
                else
                    nmcli radio wifi on && notify normal "WiFi" "Enabled" "$GREEN"
                fi
                ;;
            "  Connect")
                connect_wifi
                ;;
            "  Saved Networks")
                saved_wifi
                ;;
            "  Rescan")
                (nmcli device wifi rescan && notify normal "WiFi" "Scan completed" "$BLUE") &
                ;;
            "  Status")
                show_wifi_status
                ;;
            "  Back")
                return
                ;;
        esac
    done
}

connect_wifi() {
    # Cache scan results for 30 seconds
    if [ -f "$CACHE_DIR/wifi_scan" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_DIR/wifi_scan"))) -lt 30 ]; then
        networks=$(cat "$CACHE_DIR/wifi_scan")
    else
        networks=$(nmcli -t -f SSID,SECURITY,SIGNAL device wifi list | sort -t: -k3 -nr)
        echo "$networks" > "$CACHE_DIR/wifi_scan"
    fi

    # Format networks
    formatted=""
    while IFS=: read -r ssid security signal; do
        [ -z "$ssid" ] && continue
        if [[ "$security" =~ "WPA" ]] || [[ "$security" =~ "WEP" ]]; then
            icon=""
        else
            icon=""
        fi
        formatted+="$icon $ssid ($signal%)\n"
    done <<< "$networks"

    chosen=$(echo -ne "$formatted" | $ROFI_CMD -p "Connect to:")
    [ -z "$chosen" ] && return  # Handle ESC

    ssid=$(echo "$chosen" | awk '{print $2}')
    if [[ "$chosen" =~ "" ]]; then
        pass=$(rofi -dmenu -password -theme "$CONFIG_DIR/control-center.rasi" -p "Password for $ssid:")
        [ -z "$pass" ] && return  # Handle ESC
        nmcli device wifi connect "$ssid" password "$pass" | tee "$CACHE_DIR/wifi_connect.log"
    else
        nmcli device wifi connect "$ssid" | tee "$CACHE_DIR/wifi_connect.log"
    fi

    if grep -q "successfully" "$CACHE_DIR/wifi_connect.log"; then
        notify normal "WiFi" "Connected to $ssid" "$GREEN"
    else
        notify critical "WiFi" "Failed to connect" "$RED"
    fi
}

# ===================== Bluetooth Menu =====================
bluetooth_menu() {
    while true; do
        bt_status=$(bluetoothctl show | awk '/Powered:/ {print $2}')
        [ "$bt_status" = "yes" ] && status_icon="" || status_icon=""
        
        choice=$(echo -e "$status_icon  Toggle Bluetooth\n  Devices\n  Connect\n  Disconnect\n  Scan\n  Back" | $ROFI_CMD -p "Bluetooth")
        
        # Handle ESC key or empty selection
        [ -z "$choice" ] && return
        
        case "$choice" in
            "  Toggle Bluetooth"|"  Toggle Bluetooth")
                if [ "$bt_status" = "yes" ]; then
                    bluetoothctl power off && notify normal "Bluetooth" "Disabled" "$RED"
                else
                    bluetoothctl power on && notify normal "Bluetooth" "Enabled" "$GREEN"
                fi
                ;;
            "  Devices")
                show_bt_devices
                ;;
            "  Connect")
                connect_bt_device
                ;;
            "  Disconnect")
                disconnect_bt_device
                ;;
            "  Scan")
                (bluetoothctl --timeout 5 scan on && notify normal "Bluetooth" "Scan completed" "$BLUE") &
                ;;
            "  Back")
                return
                ;;
        esac
    done
}

connect_bt_device() {
    devices=$(bluetoothctl devices | cut -d' ' -f3-)
    [ -z "$devices" ] && {
        notify normal "Bluetooth" "No devices found. Scan first?" "$YELLOW"
        return
    }
    
    chosen=$(echo "$devices" | $ROFI_CMD -p "Connect to:")
    [ -z "$chosen" ] && return  # Handle ESC
    
    mac=$(bluetoothctl devices | grep "$chosen" | awk '{print $2}')
    notify normal "Bluetooth" "Connecting to $chosen..." "$BLUE"
    
    if bluetoothctl connect "$mac" | tee "$CACHE_DIR/bt_connect.log"; then
        notify normal "Bluetooth" "Connected to $chosen" "$GREEN"
    else
        notify critical "Bluetooth" "Connection failed" "$RED"
    fi
}

disconnect_bt_device() {
    connected=$(bluetoothctl devices Connected | cut -d' ' -f2-)
    [ -z "$connected" ] && {
        notify normal "Bluetooth" "No connected devices" "$YELLOW"
        return
    }
    
    chosen=$(echo "$connected" | $ROFI_CMD -p "Disconnect:")
    [ -z "$chosen" ] && return
    
    mac=$(echo "$chosen" | awk '{print $1}')
    if bluetoothctl disconnect "$mac"; then
        notify normal "Bluetooth" "Disconnected $(echo "$chosen" | cut -d' ' -f2-)" "$GREEN"
    else
        notify critical "Bluetooth" "Disconnect failed" "$RED"
    fi
}

#===================== Display Menu =====================#
display_menu() {
    if ! command -v xrandr &> /dev/null; then
        notify-send -i dialog-error "Error" "xrandr not found. Please install x11-xserver-utils" -h string:bgcolor:$RED
        main_menu
        return
    fi

    options="  Show Connected Displays\n  Mirror Displays\n  Extend Displays\n  Single Display Mode\n  Rotate Display\n  Scale Display\n  Back"
    chosen=$(echo -e "$options" | $ROFI_COMMAND -p "Display Options:")
    
    case $chosen in
        "  Show Connected Displays")
            connected_displays=$(xrandr --query | grep " connected" | cut -d " " -f1)
            if [[ -n "$connected_displays" ]]; then
                echo "$connected_displays" | $ROFI_COMMAND -p "Connected Displays:"
            else
                notify-send -i video-display "Displays" "No displays found" -h string:bgcolor:$RED
            fi
            display_menu
            ;;
        "  Mirror Displays")
            mirror_displays
            ;;
        "  Extend Displays")
            extend_displays
            ;;
        "  Single Display Mode")
            select_single_display
            ;;
        "  Rotate Display")
            rotate_display
            ;;
        "  Scale Display")
            scale_display
            ;;
        "  Back")
            main_menu
            ;;
    esac
}

mirror_displays() {
    mapfile -t displays < <(xrandr --query | grep " connected" | cut -d " " -f1)
    
    if [[ ${#displays[@]} -lt 2 ]]; then
        notify-send -i video-display "Displays" "At least two displays required for mirroring" -h string:bgcolor:$RED
        display_menu
        return
    fi
    
    primary=$(echo "${displays[*]}" | tr ' ' '\n' | $ROFI_COMMAND -p "Select primary display:")
    
    if [[ -n "$primary" ]]; then
        resolution=$(xrandr --query | grep -A 1 "^$primary" | grep -oP '\d+x\d+' | head -1)
        cmd="xrandr --output $primary --mode $resolution"
        
        for display in "${displays[@]}"; do
            if [[ "$display" != "$primary" ]]; then
                cmd+=" --output $display --mode $resolution --same-as $primary"
            fi
        done
        
        eval "$cmd"
        notify-send -i video-display "Displays" "Mirroring displays with $primary as primary" -h string:bgcolor:$GREEN
    fi
    display_menu
}

extend_displays() {
    mapfile -t displays < <(xrandr --query | grep " connected" | cut -d " " -f1)
    
    if [[ ${#displays[@]} -lt 2 ]]; then
        notify-send -i video-display "Displays" "At least two displays required for extending" -h string:bgcolor:$RED
        display_menu
        return
    fi
    
    primary=$(echo "${displays[*]}" | tr ' ' '\n' | $ROFI_COMMAND -p "Select primary display:")
    
    if [[ -n "$primary" ]]; then
        resolution=$(xrandr --query | grep -A 1 "^$primary" | grep -oP '\d+x\d+' | head -1)
        cmd="xrandr --output $primary --mode $resolution --primary"
        
        position="--right-of"
        last_display="$primary"
        
        for display in "${displays[@]}"; do
            if [[ "$display" != "$primary" ]]; then
                disp_resolution=$(xrandr --query | grep -A 1 "^$display" | grep -oP '\d+x\d+' | head -1)
                cmd+=" --output $display --mode $disp_resolution $position $last_display"
                last_display="$display"
            fi
        done
        
        eval "$cmd"
        notify-send -i video-display "Displays" "Extended displays with $primary as primary" -h string:bgcolor:$GREEN
    fi
    display_menu
}

select_single_display() {
    mapfile -t displays < <(xrandr --query | grep " connected" | cut -d " " -f1)
    selected=$(echo "${displays[*]}" | tr ' ' '\n' | $ROFI_COMMAND -p "Select display to use:")
    
    if [[ -n "$selected" ]]; then
        resolution=$(xrandr --query | grep -A 1 "^$selected" | grep -oP '\d+x\d+' | head -1)
        cmd="xrandr --output $selected --mode $resolution --primary"
        
        for display in "${displays[@]}"; do
            if [[ "$display" != "$selected" ]]; then
                cmd+=" --output $display --off"
            fi
        done
        
        eval "$cmd"
        notify-send -i video-display "Displays" "Using only $selected display" -h string:bgcolor:$GREEN
    fi
    display_menu
}

rotate_display() {
    mapfile -t displays < <(xrandr --query | grep " connected" | cut -d " " -f1)
    selected=$(echo "${displays[*]}" | tr ' ' '\n' | $ROFI_COMMAND -p "Select display to rotate:")
    
    if [[ -n "$selected" ]]; then
        rotation=$(echo -e "normal\nleft\nright\ninverted" | $ROFI_SHORT -p "Select rotation:")
        
        if [[ -n "$rotation" ]]; then
            xrandr --output "$selected" --rotate "$rotation"
            notify-send -i video-display "Displays" "Rotated $selected to $rotation" -h string:bgcolor:$GREEN
        fi
    fi
    display_menu
}

scale_display() {
    mapfile -t displays < <(xrandr --query | grep " connected" | cut -d " " -f1)
    selected=$(echo "${displays[*]}" | tr ' ' '\n' | $ROFI_COMMAND -p "Select display to scale:")
    
    if [[ -n "$selected" ]]; then
        scale=$(echo -e "1.0\n1.25\n1.5\n1.75\n2.0\ncustom" | $ROFI_SHORT -p "Select scale:")
        
        if [[ "$scale" == "custom" ]]; then
            scale=$(rofi -dmenu -theme $CONFIG_DIR/control-center.rasi -p "Enter custom scale (e.g., 1.3):")
        fi
        
        if [[ -n "$scale" ]] && [[ "$scale" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            xrandr --output "$selected" --scale "$scale"x"$scale"
            notify-send -i video-display "Displays" "Scaled $selected by $scale" -h string:bgcolor:$GREEN
        else
            notify-send -i dialog-error "Error" "Invalid scale value" -h string:bgcolor:$RED
        fi
    fi
    display_menu
}

#===================== Screenshot Menu =====================#
screenshot_menu() {
    if ! command -v maim &> /dev/null && ! command -v scrot &> /dev/null; then
        notify-send -i dialog-error "Error" "No screenshot tool found. Please install maim or scrot" -h string:bgcolor:$RED
        main_menu
        return
    fi
    
    screenshot_cmd=""
    if command -v maim &> /dev/null; then
        screenshot_cmd="maim"
    else
        screenshot_cmd="scrot"
    fi

    options="  Full Screen\n  Select Area\n  Current Window\n  Back"
    chosen=$(echo -e "$options" | $ROFI_COMMAND -p "Screenshot:")
    
    screenshot_dir="$HOME/Pictures/Screenshots"
    mkdir -p "$screenshot_dir"
    timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    screenshot_path="$screenshot_dir/screenshot_$timestamp.png"
    
    case $chosen in
        "  Full Screen")
            if [ "$screenshot_cmd" = "maim" ]; then
                maim "$screenshot_path"
            else
                scrot "$screenshot_path"
            fi
            notify-send -i camera-photo "Screenshot" "Full screen captured" -h string:bgcolor:$PURPLE
            screenshot_menu
            ;;
        "  Select Area")
            if [ "$screenshot_cmd" = "maim" ]; then
                notify-send -i camera-photo "Screenshot" "Select an area to capture" -h string:bgcolor:$BLUE
                maim -s "$screenshot_path"
            else
                notify-send -i camera-photo "Screenshot" "Select an area to capture" -h string:bgcolor:$BLUE
                scrot -s "$screenshot_path"
            fi
            if [ -f "$screenshot_path" ]; then
                notify-send -i camera-photo "Screenshot" "Area captured" -h string:bgcolor:$PURPLE
            fi
            screenshot_menu
            ;;
        "  Current Window")
            if [ "$screenshot_cmd" = "maim" ]; then
                active_window_id=$(xdotool getactivewindow)
                maim -i "$active_window_id" "$screenshot_path"
            else
                scrot -u "$screenshot_path"
            fi
            notify-send -i camera-photo "Screenshot" "Current window captured" -h string:bgcolor:$PURPLE
            screenshot_menu
            ;;
        "  Back")
            main_menu
            ;;
    esac
}

#===================== System Monitor Menu =====================#
system_monitor_menu() {
    options="  CPU Usage\n  Memory Usage\n  Disk Usage\n  Battery Status\n  Network Status\n  Running Processes\n  Back"
    chosen=$(echo -e "$options" | $ROFI_COMMAND -p "System Monitor:")
    
    case $chosen in
        "  CPU Usage")
            if command -v mpstat &> /dev/null; then
                cpu_usage=$(mpstat 1 1 | awk '/Average:/ {print 100 - $NF "%"}')
            else
                cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 "%"}')
            fi
            notify-send -i computer "CPU Usage" "$cpu_usage" -h string:bgcolor:$BLUE
            system_monitor_menu
            ;;
        "  Memory Usage")
            mem_info=$(free -h | grep Mem)
            mem_used=$(echo "$mem_info" | awk '{print $3}')
            mem_total=$(echo "$mem_info" | awk '{print $2}')
            mem_percent=$(free | grep Mem | awk '{printf("%.2f%%", $3/$2 * 100)}')
            notify-send -i memory "Memory Usage" "Used: $mem_used / $mem_total ($mem_percent)" -h string:bgcolor:$BLUE
            system_monitor_menu
            ;;
        "  Disk Usage")
            disk_info=$(df -h / | tail -1)
            disk_used=$(echo "$disk_info" | awk '{print $3}')
            disk_total=$(echo "$disk_info" | awk '{print $2}')
            disk_percent=$(echo "$disk_info" | awk '{print $5}')
            notify-send -i drive-harddisk "Disk Usage" "Used: $disk_used / $disk_total ($disk_percent)" -h string:bgcolor:$BLUE
            system_monitor_menu
            ;;
        "  Battery Status")
            if [ -d "/sys/class/power_supply/BAT0" ] || [ -d "/sys/class/power_supply/BAT1" ]; then
                for bat in /sys/class/power_supply/BAT?; do
                    if [ -e "$bat/capacity" ] && [ -e "$bat/status" ]; then
                        bat_capacity=$(cat "$bat/capacity")
                        bat_status=$(cat "$bat/status")
                        bat_name=$(basename "$bat")
                        
                        if [ "$bat_status" = "Charging" ]; then
                            icon="battery-good-charging"
                        elif [ "$bat_capacity" -gt 80 ]; then
                            icon="battery-full"
                        elif [ "$bat_capacity" -gt 60 ]; then
                            icon="battery-good"
                        elif [ "$bat_capacity" -gt 40 ]; then
                            icon="battery-medium"
                        elif [ "$bat_capacity" -gt 20 ]; then
                            icon="battery-low"
                        else
                            icon="battery-empty"
                        fi
                        
                        notify-send -i "$icon" "Battery Status ($bat_name)" "$bat_capacity% - $bat_status" -h string:bgcolor:$BLUE
                    fi
                done
            else
                notify-send -i dialog-information "Battery Status" "No battery found" -h string:bgcolor:$YELLOW
            fi
            system_monitor_menu
            ;;
        "  Network Status")
            if command -v nmcli &> /dev/null; then
                wifi_status=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
                if [[ -n "$wifi_status" ]]; then
                    wifi_strength=$(nmcli dev wifi | grep "$wifi_status" | awk '{print $7}')
                    notify-send -i network-wireless "WiFi" "Connected to: $wifi_status (Signal: $wifi_strength%)" -h string:bgcolor:$GREEN
                else
                    notify-send -i network-wireless-offline "WiFi" "Not connected" -h string:bgcolor:$RED
                fi
                
                eth_status=$(nmcli -t -f device,state dev | grep ethernet | cut -d':' -f2)
                if [[ "$eth_status" == "connected" ]]; then
                    notify-send -i network-wired "Ethernet" "Connected" -h string:bgcolor:$GREEN
                else
                    notify-send -i network-wired-offline "Ethernet" "Not connected" -h string:bgcolor:$RED
                fi
            else
                notify-send -i dialog-error "Network Status" "nmcli not found" -h string:bgcolor:$RED
            fi
            system_monitor_menu
            ;;
        "  Running Processes")
            processes=$(ps aux --sort=-%cpu | head -11 | tail -10 | awk '{print $2 " " $11 " [" $3 "%]"}')
            echo "$processes" | $ROFI_COMMAND -p "Top CPU Processes:"
            system_monitor_menu
            ;;
        "  Back")
            main_menu
            ;;
    esac
}

check_deps
main_menu