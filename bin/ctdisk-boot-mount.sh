#!/bin/bash

# CTExternalDisk Boot-Time Mount Script
# This script runs once at login to ensure immediate mounting after restart/hibernation

DISK_UUID="3E314969-A8AD-49EA-8743-F773357E61AB"
MOUNT_POINT="/Volumes/CTExternalDisk"
LOG_FILE="/Users/ctyeh/.local/log/ctexternaldisk-mount.log"
MAX_WAIT=120  # Maximum 2 minutes to wait for device

# Function to log messages with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): [BOOT] $1" >> "$LOG_FILE"
}

# Function to wait for device to appear
wait_for_device() {
    local wait_time=0
    local check_interval=5
    
    log_message "Waiting for CTExternalDisk to be detected after boot/wake..."
    
    while [ $wait_time -lt $MAX_WAIT ]; do
        # Check if device exists
        if diskutil list | grep -q "$DISK_UUID" || diskutil list | grep -q "CTExternalDisk"; then
            log_message "CTExternalDisk detected after ${wait_time}s"
            return 0
        fi
        
        sleep $check_interval
        wait_time=$((wait_time + check_interval))
        
        # Log progress every 30 seconds
        if [ $((wait_time % 30)) -eq 0 ]; then
            log_message "Still waiting for CTExternalDisk... (${wait_time}s elapsed)"
        fi
    done
    
    log_message "CTExternalDisk not detected after ${MAX_WAIT}s, giving up"
    return 1
}

# Function to trigger the main mount script
trigger_mount() {
    log_message "Triggering main mount script..."
    /Users/ctyeh/.local/bin/mount-ctexternaldisk.sh
    return $?
}

# Main logic
main() {
    log_message "Boot-time mount script started"
    
    # Check if already mounted
    if mount | grep -q "$MOUNT_POINT" && [ -d "$MOUNT_POINT" ] && [ "$(ls -A "$MOUNT_POINT" 2>/dev/null)" ]; then
        log_message "CTExternalDisk already mounted, boot script exiting"
        exit 0
    fi
    
    # Wait for device to appear
    if wait_for_device; then
        # Give the system a moment to fully recognize the device
        sleep 5
        
        # Trigger the main mount script
        if trigger_mount; then
            log_message "Boot-time mounting completed successfully"
        else
            log_message "Boot-time mounting failed, regular auto-mount will continue trying"
        fi
    else
        log_message "Device not detected during boot wait period"
    fi
}

# Run main function
main "$@"
