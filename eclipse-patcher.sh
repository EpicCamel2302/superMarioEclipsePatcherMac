#!/bin/bash

# Set up directories
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN_DIR="$SCRIPT_DIR/bin"
PATCHES_DIR="$SCRIPT_DIR/patches"

mkdir -p "$BIN_DIR" "$PATCHES_DIR"

# Function to print colored text
cecho() {
    local code=$1
    shift
    echo -e "\033[${code}m$@\033[0m"
}

# Check for required tools
check_tool() {
    if ! command -v $1 &> /dev/null; then
        cecho "31" "$1 not found! Please install it and try again."
        exit 1
    fi
}

check_tool "md5"
check_tool "curl"
check_tool "xdelta3"

# Move and rename patch files
mv "$SCRIPT_DIR"/*.xdelta "$PATCHES_DIR" 2>/dev/null
mv "$PATCHES_DIR/Super_Mario_Eclipse_v1_0.xdelta" "$PATCHES_DIR/v1.0.0.xdelta" 2>/dev/null
mv "$PATCHES_DIR/Super_Mario_Eclipse_v1_0_hotfix_0.xdelta" "$PATCHES_DIR/v1.0.1.xdelta" 2>/dev/null
mv "$PATCHES_DIR/Super_Mario_Eclipse_v1_0_hotfix_1.xdelta" "$PATCHES_DIR/v1.0.2.xdelta" 2>/dev/null

# Check for patches
if [ ! "$(ls -A "$PATCHES_DIR"/*.xdelta 2>/dev/null)" ]; then
    cecho "31" "No patches found in the ./patches/ directory!"
    cecho "33" "Download patches now? (y/n): "
    read -r choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        open "https://gamebanana.com/mods/download/536309"
        cecho "33" "Place patches in the ./patches/ directory then press any key to proceed..."
        read -n 1 -s
    else
        exit 0
    fi
fi

# Check for game dump
if [ -z "$1" ]; then
    cecho "31" "No game dump supplied! Drag-and-drop your copy of Super Mario Sunshine onto this script to patch it."
    cecho "33" "The following requirements must be met for successful patching:"
    cecho "37" "    Format ... ISO"
    cecho "37" "    Region ... NTSC (USA)"
    cecho "33" "Modified or compressed formats such as CISO, NKIT, & RVZ are unsupported!"
    cecho "31" "Piracy is not condoned or endorsed by Eclipse Team, you must legally dump your own copy of the game!"
    cecho "33" "Dumping guide: https://wii.hacks.guide/dump-games.html"
    cecho "33" "For other issues and support, please visit our Discord server @ https://discord.gg/u6NHuHVRpJ"
    cecho "33" "If you are updating Super Mario Eclipse, patch from your original copy of Super Mario Sunshine!"
    exit 1
fi

# Main process
cecho "31" "Piracy is not condoned or endorsed by Eclipse Team, you must legally dump your own copy of the game!"
cecho "33" "Dumping guide: https://wii.hacks.guide/dump-games.html"
cecho "33" "For other issues and support, please visit our Discord server @ https://discord.gg/u6NHuHVRpJ"
cecho "33" "Infile: $(basename "$1")"
cecho "33" "If you are updating Super Mario Eclipse, patch from your original copy of Super Mario Sunshine!"
cecho "33" "Press any key to proceed with verification."
read -n 1 -s

# Compute MD5 hash
cecho "33" "Calculating MD5 checksum..."
MD5=$(md5 -q "$1")

if [ "$MD5" = "0c6d2edae9fdf40dfc410ff1623e4119" ]; then
    cecho "32" "MD5 checksum match! The MD5 of $(basename "$1") matches the required checksum:"
    cecho "33" "Required checksum ..... 0c6d2edae9fdf40dfc410ff1623e4119"
    cecho "33" "Your checksum ......... $MD5"
else
    cecho "31" "MD5 checksum mismatch! The MD5 of $(basename "$1") does not match the required checksum:"
    cecho "33" "Required checksum ..... 0c6d2edae9fdf40dfc410ff1623e4119"
    cecho "33" "Your checksum ......... $MD5"
    cecho "33" "The following requirements must be met for successful patching:"
    cecho "37" "    Format ... ISO"
    cecho "37" "    Region ... NTSC (USA)"
    cecho "33" "Modified or compressed formats such as CISO, NKIT, & RVZ are unsupported! The game must be redumped."
    exit 1
fi

# List and select patches
cecho "33" "Available patches:"
cecho "35" "$(ls "$PATCHES_DIR"/*.xdelta)"
cecho "33" "Copy or type the full patch name from the above list: "
read -r PatchFile

if [ -z "$PatchFile" ]; then
    cecho "31" "You must select a patch from the list to proceed!"
    exit 1
fi

# Remove any leading path from PatchFile
PatchFile=$(basename "$PatchFile")

PATCH_FILE="$PATCHES_DIR/$PatchFile"

if [ ! -f "$PATCH_FILE" ]; then
    cecho "31" "Patch file not found: $PATCH_FILE"
    exit 1
fi

PatchName=$(basename "$PatchFile" .xdelta)

# Patch the game
cecho "33" "Patching $(basename "$1") with $PatchName..."
OUTPUT_FILE="$(dirname "$1")/(GMSE04) Super Mario Eclipse $PatchName.iso"

xdelta3 -d -s "$1" "$PATCH_FILE" "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    cecho "32" "Patching completed successfully."
    cecho "33" "Output file: $OUTPUT_FILE"
else
    cecho "31" "Patching failed. Please check your input files and try again."
fi
