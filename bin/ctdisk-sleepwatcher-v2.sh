#!/bin/bash

# CTExternalDisk Sleep/Wake Handler v2
# Uses passwordless sudo for automatic hibernation handling

LOG_FILE="$HOME/.local/log/ctexternaldisk-sleepwake-v2.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Function to check if passwordless sudo is configured
check_passwordless_sudo() {
    if sudo -n true 2>/dev/null; then
        return 0
    else
        log_message "⚠️  Passwordless sudo not configured. Run setup-sudoless-mount.sh first"
        return 1
    fi
}

# Function to safely eject before sleep
handle_sleep() {
    log_message "[SLEEP] System going to sleep, checking CTExternalDisk..."
    
    if [ -d "/Volumes/CTExternalDisk" ]; then
        log_message "[SLEEP] CTExternalDisk mounted, attempting safe ejection..."
        
        # Sync any pending writes
        sync
        
        # Try graceful unmount (no sudo needed for diskutil unmount)
        if diskutil unmount "/Volumes/CTExternalDisk" >/dev/null 2>&1; then
            log_message "[SLEEP] ✅ CTExternalDisk safely ejected before sleep"
        else
            # Try force unmount with passwordless sudo if configured
            if check_passwordless_sudo; then
                if sudo diskutil unmount force "/Volumes/CTExternalDisk" >/dev/null 2>&1; then
                    log_message "[SLEEP] ✅ CTExternalDisk force ejected before sleep"
                else
                    log_message "[SLEEP] ⚠️  Failed to eject CTExternalDisk"
                fi
            else
                log_message "[SLEEP] ⚠️  Cannot force eject without passwordless sudo"
            fi
        fi
    else
        log_message "[SLEEP] CTExternalDisk not mounted, no action needed"
    fi
}

# Function to remount after wake
handle_wake() {
    log_message "[WAKE] System woke up, waiting for USB devices..."
    
    # Wait for USB subsystem to be ready
    sleep 5
    
    # Check if CTExternalDisk is detected but not mounted
    if diskutil list | grep -q "CTExternalDisk"; then
        if [ ! -d "/Volumes/CTExternalDisk" ]; then
            log_message "[WAKE] CTExternalDisk detected but not mounted, attempting mount..."
            
            # Find the current device node (may have changed after hibernation)
            local device_node
            device_node=$(diskutil list | grep "CTExternalDisk" | awk '{print $NF}' | head -1)
            
            if [ -n "$device_node" ]; then
                log_message "[WAKE] Found device at: $device_node"
                
                # Try mounting methods in order of preference
                local mounted=false
                
                # Method 1: Try diskutil mount (sometimes works without sudo)
                if diskutil mount "$device_node" >/dev/null 2>&1; then
                    log_message "[WAKE] ✅ Mounted using diskutil"
                    mounted=true
                elif check_passwordless_sudo; then
                    # Method 2: Use passwordless sudo with mount command
                    if sudo mkdir -p /Volumes/CTExternalDisk >/dev/null 2>&1 && \
                       sudo mount -t apfs "/dev/$device_node" /Volumes/CTExternalDisk >/dev/null 2>&1; then
                        log_message "[WAKE] ✅ Mounted using sudo mount"
                        mounted=true
                    elif sudo diskutil mount "$device_node" >/dev/null 2>&1; then
                        log_message "[WAKE] ✅ Mounted using sudo diskutil"
                        mounted=true
                    fi
                fi
                
                if [ "$mounted" = true ]; then
                    # Verify iTunes symlink
                    if [ -L "$HOME/Music/iTunes" ]; then
                        log_message "[WAKE] ✅ iTunes symlink verified"
                    else
                        # Recreate iTunes symlink
                        if [ -d "/Volumes/CTExternalDisk/Music_Library/iTunes" ]; then
                            ln -sf "/Volumes/CTExternalDisk/Music_Library/iTunes" "$HOME/Music/iTunes"
                            log_message "[WAKE] ✅ iTunes symlink recreated"
                        else
                            log_message "[WAKE] ⚠️  iTunes source directory not found"
                        fi
                    fi
                else
                    log_message "[WAKE] ❌ Failed to mount CTExternalDisk"
                fi
            else
                log_message "[WAKE] ❌ Could not find device node for CTExternalDisk"
            fi
        else
            log_message "[WAKE] CTExternalDisk already mounted"
        fi
    else
        log_message "[WAKE] CTExternalDisk not detected by system"
    fi
}

# Main execution
case "$1" in
    "--sleep")
        handle_sleep
        ;;
    "--wake")
        handle_wake
        ;;
    "--check-sudo")
        if check_passwordless_sudo; then
            echo "✅ Passwordless sudo is configured"
            exit 0
        else
            echo "❌ Passwordless sudo is not configured"
            echo "Run: /Users/ctyeh/.local/bin/setup-sudoless-mount.sh"
            exit 1
        fi
        ;;
    *)
        echo "CTExternalDisk Sleep/Wake Handler v2"
        echo ""
        echo "Usage: $0 {--sleep|--wake|--check-sudo}"
        echo ""
        echo "  --sleep      Safely eject disk before hibernation"
        echo "  --wake       Remount disk after wake-up"
        echo "  --check-sudo Check if passwordless sudo is configured"
        echo ""
        echo "Setup: Run setup-sudoless-mount.sh first to enable passwordless mounting"
        exit 1
        ;;
esac
