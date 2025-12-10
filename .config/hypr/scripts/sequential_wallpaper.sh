#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers/"
HISTORY_FILE="$HOME/.last_wallpaper"

MONITOR_2560x1440="HDMI-A-1" # Target monitor for 2560x1440 wallpapers
MONITOR_1920x1080="DP-1"     # Target monitor for 1920x1080 wallpapers
SUFFIX_2560x1440="2560x1440.jpg"
SUFFIX_1920x1080="1920x1080.jpg"

# Function to get all wallpapers of a specific suffix
get_wallpapers_by_suffix() {
    local suffix="$1"
    # Use grep to filter and find to locate, then sort
    find "$WALLPAPER_DIR" -type f -name "*$suffix" | sort
}

# Function to read the last used index for a specific resolution
read_last_index() {
    local res="$1"
    if [[ -f "$HISTORY_FILE" ]]; then
        # Use grep to find the line for the specific resolution and awk to get the index
        grep "^$res=" "$HISTORY_FILE" | awk -F'=' '{print $2}'
    fi
}

# Function to update the index for a specific resolution
update_last_index() {
    local res="$1"
    local index="$2"
    
    # Check if history file exists
    if [[ ! -f "$HISTORY_FILE" ]]; then
        touch "$HISTORY_FILE"
    fi

    # Read the current content of the file
    local current_content
    current_content=$(cat "$HISTORY_FILE")

    # The new line to write
    local new_line="${res}=${index}"
    
    # If the resolution key exists, replace it; otherwise, append it.
    if grep -q "^$res=" "$HISTORY_FILE"; then
        # Replace the line using sed -i (in-place)
        sed -i "/^$res=/c\\$new_line" "$HISTORY_FILE"
    else
        # Append the new line
        echo "$new_line" >> "$HISTORY_FILE"
    fi
}

# Function to select the next wallpaper based on its current list
select_next_wallpaper() {
    local wallpapers_list=("$@")
    local res_key="${wallpapers_list[0]}" # The first element is used as the key for history, e.g., '2560x1440'
    
    # Remove the key from the list to only have paths
    unset 'wallpapers_list[0]'
    wallpapers_list=("${wallpapers_list[@]}")

    local total_wallpapers=${#wallpapers_list[@]}

    if [[ $total_wallpapers -eq 0 ]]; then
        return 1 # No wallpapers found
    fi

    local last_index=$(read_last_index "$res_key")
    local next_index=0

    # Determine the next index, defaulting to 0 if history is missing or invalid
    if [[ -n "$last_index" ]] && [[ "$last_index" =~ ^[0-9]+$ ]] && (( last_index < total_wallpapers - 1 )); then
        next_index=$((last_index + 1))
    fi

    local next_wallpaper="${wallpapers_list[$next_index]}"
    
    # Update history for the next run
    update_last_index "$res_key" "$next_index"

    echo "$next_wallpaper" # Output the selected wallpaper path
    return 0
}

# --- Main Logic ---

# 1. Get the lists of wallpapers
WALLPAPERS_2560=($(get_wallpapers_by_suffix "$SUFFIX_2560x1440"))
WALLPAPERS_1920=($(get_wallpapers_by_suffix "$SUFFIX_1920x1080"))

# Add the key for the selection function
WALLPAPERS_2560=("2560x1440" "${WALLPAPERS_2560[@]}")
WALLPAPERS_1920=("1920x1080" "${WALLPAPERS_1920[@]}")


# 2. Select the next wallpaper for each resolution
# Select for 2560x1440
WALLPAPER_2560=$(select_next_wallpaper "${WALLPAPERS_2560[@]}")
RESULT_2560=$?

# Select for 1920x1080
WALLPAPER_1920=$(select_next_wallpaper "${WALLPAPERS_1920[@]}")
RESULT_1920=$?

# 3. Check for errors (no wallpapers found)
if [[ $RESULT_2560 -ne 0 ]] && [[ $RESULT_1920 -ne 0 ]]; then
    echo "Error: No wallpapers found for either $SUFFIX_2560x1440 or $SUFFIX_1920x1080 in $WALLPAPER_DIR"
    exit 1
fi

# 4. Preload and apply wallpapers
echo "Applying Wallpapers..."

# Apply 2560x1440 wallpaper
if [[ $RESULT_2560 -eq 0 ]]; then
    echo "  -> Preloading: $WALLPAPER_2560"
    hyprctl hyprpaper preload "$WALLPAPER_2560"
    echo "  -> Applying to $MONITOR_2560x1440"
    # hyprctl hyprpaper wallpaper [monitorname],[path]
    hyprctl hyprpaper wallpaper "$MONITOR_2560x1440,$WALLPAPER_2560"
else
    echo "  -> Warning: No 2560x1440 wallpaper found. Skipping $MONITOR_2560x1440."
fi

# Apply 1920x1080 wallpaper
if [[ $RESULT_1920 -eq 0 ]]; then
    echo "  -> Preloading: $WALLPAPER_1920"
    hyprctl hyprpaper preload "$WALLPAPER_1920"
    echo "  -> Applying to $MONITOR_1920x1080"
    # hyprctl hyprpaper wallpaper [monitorname],[path]
    hyprctl hyprpaper wallpaper "$MONITOR_1920x1080,$WALLPAPER_1920"
else
    echo "  -> Warning: No 1920x1080 wallpaper found. Skipping $MONITOR_1920x1080."
fi

echo "Done."
