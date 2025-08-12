#!/bin/bash

# CTExternalDisk Auto-Mount Script (Enhanced)
# This script intelligently mounts the CTExternalDisk when available
# Enhanced for hibernation/restart scenarios and LaunchAgent compatibility

DISK_UUID="3E314969-A8AD-49EA-8743-F773357E61AB"
DEVICE_NODE="/dev/disk7s1"
MOUNT_POINT="/Volumes/CTExternalDisk"
LOG_FILE="/Users/ctyeh/.local/log/ctexternaldisk-mount.log"
LOCK_FILE="/tmp/ctexternaldisk-mount.lock"
MAX_RETRIES=3
RETRY_DELAY=5

# Function to log messages with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Function to create lock file to prevent multiple instances
create_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid=$(cat "$LOCK_FILE" 2>/dev/null)
        if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
            # Another instance is running
            exit 0
        else
            # Stale lock file, remove it
            rm -f "$LOCK_FILE"
        fi
    fi
    echo $$ > "$LOCK_FILE"
}

# Function to remove lock file
remove_lock() {
    rm -f "$LOCK_FILE"
}

# Trap to ensure lock is removed on exit
trap remove_lock EXIT

# Function to check if disk is already mounted
is_mounted() {
    mount | grep -q "$MOUNT_POINT" && [ -d "$MOUNT_POINT" ] && [ "$(ls -A "$MOUNT_POINT" 2>/dev/null)" ]
    return $?
}

# Function to check if device exists (enhanced detection)
device_exists() {
    # Check multiple ways to detect the device
    [ -e "$DEVICE_NODE" ] && return 0
    diskutil list | grep -q "$DISK_UUID" && return 0
    diskutil list | grep -q "CTExternalDisk" && return 0
    
    # Wait a moment and try again (for post-hibernation detection)
    sleep 2
    [ -e "$DEVICE_NODE" ] && return 0
    diskutil list | grep -q "$DISK_UUID" && return 0
    diskutil list | grep -q "CTExternalDisk" && return 0
    
    return 1
}

# Function to find the correct device node (in case it changes after hibernation)
find_device_node() {
    # Try the known device node first
    if [ -e "$DEVICE_NODE" ]; then
        echo "$DEVICE_NODE"
        return 0
    fi
    
    # Search for the device by UUID
    local device=$(diskutil info "$DISK_UUID" 2>/dev/null | grep "Device Node" | awk '{print $3}')
    if [ -n "$device" ] && [ -e "$device" ]; then
        echo "$device"
        return 0
    fi
    
    # Search by name in diskutil list
    local device=$(diskutil list | grep -B 10 "CTExternalDisk" | grep "^/dev/" | tail -1 | awk '{print $1}')
    if [ -n "$device" ] && [ -e "$device" ]; then
        echo "$device"
        return 0
    fi
    
    return 1
}

# Function to wait for system to be ready (post-hibernation/restart)
wait_for_system_ready() {
    local max_wait=60  # Maximum 60 seconds
    local wait_time=0
    
    while [ $wait_time -lt $max_wait ]; do
        # Check if diskutil is responsive
        if diskutil list >/dev/null 2>&1; then
            return 0
        fi
        sleep 2
        wait_time=$((wait_time + 2))
    done
    
    log_message "Warning: System may not be fully ready after $max_wait seconds"
    return 1
}

# Function to mount the disk (enhanced with retries, no sudo required)
mount_disk() {
    local current_device_node
    local retry_count=0
    
    # Find the current device node
    current_device_node=$(find_device_node)
    if [ -z "$current_device_node" ]; then
        log_message "Could not find device node for CTExternalDisk"
        return 1
    fi
    
    # Update device node if it changed
    if [ "$current_device_node" != "$DEVICE_NODE" ]; then
        log_message "Device node changed from $DEVICE_NODE to $current_device_node"
        DEVICE_NODE="$current_device_node"
    fi
    
    # Retry mounting with different methods
    while [ $retry_count -lt $MAX_RETRIES ]; do
        retry_count=$((retry_count + 1))
        
        # Method 1: Try diskutil mount (preferred for LaunchAgent)
        if diskutil mount "$DEVICE_NODE" >/dev/null 2>&1; then
            log_message "Successfully mounted CTExternalDisk using diskutil (attempt $retry_count)"
            return 0
        fi
        
        # Method 2: Try mounting by UUID
        if diskutil mount "$DISK_UUID" >/dev/null 2>&1; then
            log_message "Successfully mounted CTExternalDisk using UUID (attempt $retry_count)"
            return 0
        fi
        
        # Method 3: Try with explicit mount point creation (requires sudo, fallback)
        if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
            if [ ! -d "$MOUNT_POINT" ]; then
                sudo mkdir -p "$MOUNT_POINT" 2>/dev/null
            fi
            if sudo mount -t apfs "$DEVICE_NODE" "$MOUNT_POINT" >/dev/null 2>&1; then
                log_message "Successfully mounted CTExternalDisk using sudo mount (attempt $retry_count)"
                return 0
            fi
        fi
        
        # If not the last attempt, wait before retrying
        if [ $retry_count -lt $MAX_RETRIES ]; then
            log_message "Mount attempt $retry_count failed, retrying in $RETRY_DELAY seconds..."
            sleep $RETRY_DELAY
            
            # Re-check device node in case it changed
            current_device_node=$(find_device_node)
            if [ -n "$current_device_node" ]; then
                DEVICE_NODE="$current_device_node"
            fi
        fi
    done
    
    log_message "Failed to mount CTExternalDisk after $MAX_RETRIES attempts"
    return 1
}

# Function to verify and fix symbolic links
verify_symbolic_links() {
    local itunes_link="/Users/ctyeh/Music/iTunes"
    local itunes_target="$MOUNT_POINT/Music_Library/iTunes"
    
    if [ -L "$itunes_link" ] && [ -d "$itunes_target" ]; then
        log_message "iTunes symbolic link verified and working"
        return 0
    elif [ -L "$itunes_link" ] && [ ! -d "$itunes_target" ]; then
        log_message "Warning: iTunes symbolic link exists but target directory not found"
        return 1
    elif [ ! -L "$itunes_link" ] && [ -d "$itunes_target" ]; then
        log_message "Recreating iTunes symbolic link"
        rm -f "$itunes_link" 2>/dev/null
        ln -s "$itunes_target" "$itunes_link" 2>/dev/null
        if [ $? -eq 0 ]; then
            log_message "iTunes symbolic link recreated successfully"
            return 0
        else
            log_message "Failed to recreate iTunes symbolic link"
            return 1
        fi
    else
        log_message "Warning: iTunes symbolic link needs attention"
        return 1
    fi
}

# Function to fix mount point ownership
fix_mount_ownership() {
    local mount_point="$MOUNT_POINT"
    local current_owner=$(stat -f "%Su:%Sg" "$mount_point" 2>/dev/null)
    
    if [ "$current_owner" != "ctyeh:staff" ]; then
        if sudo -n chown ctyeh:staff "$mount_point" 2>/dev/null; then
            log_message "✅ Fixed mount point ownership to ctyeh:staff"
        else
            log_message "⚠️  Could not fix mount point ownership (may need password)"
        fi
    else
        log_message "✅ Mount point ownership is correct (ctyeh:staff)"
    fi
}

# Function to detect if system just woke from hibernation or restarted
detect_system_state() {
    local uptime_seconds=$(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//')
    local current_time=$(date +%s)
    local uptime=$((current_time - uptime_seconds))
    
    # If system uptime is less than 5 minutes, likely just restarted
    if [ $uptime -lt 300 ]; then
        log_message "System recently restarted (uptime: ${uptime}s), waiting for full initialization..."
        wait_for_system_ready
        sleep 10  # Additional wait for USB devices to be recognized
        return 0
    fi
    
    # Check for hibernation by looking at system log (simplified check)
    if pmset -g log | tail -20 | grep -q "Wake from" 2>/dev/null; then
        log_message "System may have recently woken from sleep/hibernation"
        sleep 5  # Wait for USB devices to be re-recognized
        return 0
    fi
    
    return 0
}

# Main logic
main() {
    # Create lock to prevent multiple instances
    create_lock
    
    # Detect system state and wait if necessary
    detect_system_state
    
    # Check if already mounted
    if is_mounted; then
        # Disk is already mounted, fix ownership and verify symbolic links
        fix_mount_ownership
        verify_symbolic_links >/dev/null 2>&1
        exit 0
    fi
    
    # Check if device exists
    if ! device_exists; then
        # Device not connected, exit silently
        exit 0
    fi
    
    log_message "CTExternalDisk detected but not mounted, attempting to mount..."
    
    # Attempt to mount
    if mount_disk; then
        log_message "CTExternalDisk mounted successfully at $MOUNT_POINT"
        
        # Wait a moment for the mount to stabilize
        sleep 2
        
        # Fix mount point ownership
        fix_mount_ownership
        
        # Verify and fix symbolic links
        if verify_symbolic_links; then
            log_message "All symbolic links verified successfully"
        fi
        
        # Log disk space information
        local disk_info=$(df -h "$MOUNT_POINT" 2>/dev/null | tail -1)
        if [ -n "$disk_info" ]; then
            log_message "Disk space: $disk_info"
        fi
        
    else
        log_message "Failed to mount CTExternalDisk after all attempts"
        exit 1
    fi
}

# Run main function
main "$@"
