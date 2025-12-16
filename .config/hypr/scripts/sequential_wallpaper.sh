#!/bin/bash

# Base directory for all wallpapers
BASE_WALLPAPER_DIR="$HOME/Pictures/wallpapers/"
# History file to track the last used wallpaper's index
HISTORY_FILE="$HOME/.last_wallpaper_index"

# --- Argument Parsing ---

# Check if a subdirectory (theme) was provided as a CLI argument
if [[ -n "$1" ]]; then
    # Sanitize the input to only allow alphanumeric characters and slashes
    THEME_SUBDIR=$(echo "$1" | sed 's/[^a-zA-Z0-9_\/-]/_/g')
else
    # Default to the base directory if no argument is given
    THEME_SUBDIR=""
fi

# Full directory to search for wallpapers
WALLPAPER_DIR="${BASE_WALLPAPER_DIR}${THEME_SUBDIR}"
# Key used in the history file to track the index for the current theme
HISTORY_KEY="${THEME_SUBDIR:-default}"

# --- Core Functions ---

# Function to get all wallpapers in the current directory, sorted by name (for "fair" ordering)
get_all_wallpapers() {
    # Find all files (case-insensitive for common image extensions) and sort the paths
    # Note: Using printf + mapfile is safer for handling paths with spaces/newlines than 'find | sort'
    find "$WALLPAPER_DIR" -type f -iregex '.*\.\(jpe?g\|png\|webp\)' | sort
}

# Function to read the last used index for the current theme
read_last_index() {
    if [[ -f "$HISTORY_FILE" ]]; then
        # Find the line starting with the theme key and extract the index
        grep "^$HISTORY_KEY=" "$HISTORY_FILE" | awk -F'=' '{print $2}'
    fi
}

# Function to update the index for the current theme
update_last_index() {
    local index="$1"

    # Create history file if it doesn't exist
    if [[ ! -f "$HISTORY_FILE" ]]; then
        touch "$HISTORY_FILE"
    fi

    local new_line="${HISTORY_KEY}=${index}"

    # If the key exists, replace the line; otherwise, append it.
    if grep -q "^$HISTORY_KEY=" "$HISTORY_FILE"; then
        # Use sed -i (in-place) to replace the line
        sed -i "/^$HISTORY_KEY=/c\\$new_line" "$HISTORY_FILE"
    else
        # Append the new line
        echo "$new_line" >> "$HISTORY_FILE"
    fi
}

# Function to select the next wallpaper path
select_next_wallpaper() {
    local wallpapers_list=()

    # Get the sorted list of all wallpaper paths
    readarray -t wallpapers_list < <(get_all_wallpapers)

    local total_wallpapers=${#wallpapers_list[@]}

    if [[ $total_wallpapers -eq 0 ]]; then
        echo "Error: No wallpapers found in $WALLPAPER_DIR" >&2
        return 1
    fi

    local last_index=$(read_last_index)
    local next_index=0

    # Determine the next index
    if [[ -n "$last_index" ]] && [[ "$last_index" =~ ^[0-9]+$ ]] && (( last_index < total_wallpapers - 1 )); then
        # Increment the index if it's valid and not the last one
        next_index=$((last_index + 1))
    fi

    local next_wallpaper="${wallpapers_list[$next_index]}"

    # Update history for the next run
    update_last_index "$next_index"

    echo "$next_wallpaper" # Output the selected wallpaper path
    return 0
}

# --- Main Logic ---

echo "Searching for wallpapers in: $WALLPAPER_DIR"

# 1. Select the next wallpaper
SELECTED_WALLPAPER=$(select_next_wallpaper)
RESULT=$?

if [[ $RESULT -ne 0 ]]; then
    exit 1 # Exit if no wallpapers were found
fi

echo "Selected Wallpaper: $SELECTED_WALLPAPER (Theme: $HISTORY_KEY)"

# 2. Get list of all connected monitors
# We use 'hyprctl monitors' and awk to extract just the monitor names.
# This ensures we apply the wallpaper to *all* active monitors.
MONITORS=$(hyprctl monitors | awk '/Monitor/ {print $2}')
if [[ -z "$MONITORS" ]]; then
    echo "Error: Could not retrieve monitor list from hyprctl." >&2
    exit 1
fi

# 3. Preload and apply the same wallpaper to all monitors
echo "Applying Wallpaper..."

# Preload the selected wallpaper once
echo "  -> Preloading: $SELECTED_WALLPAPER"
hyprctl hyprpaper preload "$SELECTED_WALLPAPER"

# Iterate over all detected monitors and apply the wallpaper
for MONITOR in $MONITORS; do
    echo "  -> Applying to $MONITOR"
    # hyprctl hyprpaper wallpaper [monitorname],[path]
    hyprctl hyprpaper wallpaper "$MONITOR,$SELECTED_WALLPAPER"
done

echo "Done."
