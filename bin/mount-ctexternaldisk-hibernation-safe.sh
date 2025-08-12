#!/bin/bash

# Enhanced CTExternalDisk Auto-Mount Script with Hibernation-Safe Handling
# This replaces the original mount script with hibernation-safe features

LOG_FILE="$HOME/.local/log/ctexternaldisk-mount-hibernation-safe.log"
ERROR_LOG="$HOME/.local/log/ctexternaldisk-mount-hibernation-safe.error.log"
LOCK_FILE="$HOME/.local/tmp/ctdisk-mount-hibernation-safe.lock"
LAST_MOUNT_FILE="$HOME/.local/tmp/ctdisk-last-mount-time"

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$LOCK_FILE")"

# Redirect stderr to error log
exec 2>>"$ERROR_LOG"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Function to check if passwordless sudo is available
check_passwordless_sudo() {
    sudo -n true 2>/dev/null
}

# Function to detect if system just woke from hibernation
detect_hibernation_wake() {
    local current_time=$(date +%s)
    local uptime_seconds=$(uptime | grep -o '[0-9]*:[0-9]*' | head -1 | awk -F: '{print $1*3600 + $2*60}')
    
    # If uptime is less than 10 minutes, likely just woke up
    if [ "$uptime_seconds" -lt 600 ]; then
        log_message "[HIBERNATION] System appears to have just woken up (uptime: ${uptime_seconds}s)"
        return 0
    fi
    
    # Check if last mount was more than 2 hours ago
    if [ -f "$LAST_MOUNT_FILE" ]; then
        local last_mount_time=$(cat "$LAST_MOUNT_FILE" 2>/dev/null || echo "0")
        local time_diff=$((current_time - last_mount_time))
        if [ "$time_diff" -gt 7200 ]; then  # 2 hours
            log_message "[HIBERNATION] Long gap since last mount (${time_diff}s), likely hibernation recovery"
            return 0
        fi
    fi
    
    return 1
}

# Function to mount the disk with hibernation-safe methods
mount_disk_hibernation_safe() {
    local device_node="$1"
    local mounted=false
    
    log_message "Attempting hibernation-safe mount of $device_node"
    
    # Method 1: Try diskutil mount (usually works without sudo)
    if diskutil mount "$device_node" >/dev/null 2>&1; then
        log_message "✅ Mounted using diskutil"
        mounted=true
    elif check_passwordless_sudo; then
        # Method 2: Try passwordless sudo with diskutil
        if sudo diskutil mount "$device_node" >/dev/null 2>&1; then
            log_message "✅ Mounted using sudo diskutil"
            mounted=true
        else
            # Method 3: Try passwordless sudo with mount command
            if sudo mkdir -p /Volumes/CTExternalDisk >/dev/null 2>&1 && \
               sudo mount -t apfs "/dev/$device_node" /Volumes/CTExternalDisk >/dev/null 2>&1; then
                log_message "✅ Mounted using sudo mount"
                mounted=true
            fi
        fi
    fi
    
    if [ "$mounted" = true ]; then
        # Record successful mount time
        date +%s > "$LAST_MOUNT_FILE"
        return 0
    else
        log_message "❌ All hibernation-safe mount methods failed"
        return 1
    fi
}

# Function to verify and repair iTunes symlink
verify_itunes_symlink() {
    local itunes_source="/Volumes/CTExternalDisk/Music_Library/iTunes"
    local itunes_target="$HOME/Music/iTunes"
    
    if [ -d "$itunes_source" ]; then
        if [ ! -L "$itunes_target" ] || [ "$(readlink "$itunes_target")" != "$itunes_source" ]; then
            rm -f "$itunes_target" 2>/dev/null
            ln -sf "$itunes_source" "$itunes_target"
            log_message "✅ iTunes symlink created/repaired"
        else
            log_message "✅ iTunes symlink verified"
        fi
    else
        log_message "⚠️  iTunes source directory not found"
    fi
}

# Function to fix mount point ownership
fix_mount_ownership() {
    local mount_point="/Volumes/CTExternalDisk"
    local current_owner=$(stat -f "%Su:%Sg" "$mount_point" 2>/dev/null)
    
    if [ "$current_owner" != "ctyeh:staff" ]; then
        if check_passwordless_sudo; then
            if sudo chown ctyeh:staff "$mount_point" 2>/dev/null; then
                log_message "✅ Fixed mount point ownership to ctyeh:staff"
            else
                log_message "⚠️  Could not fix mount point ownership"
            fi
        else
            log_message "⚠️  Cannot fix ownership - passwordless sudo not available"
        fi
    else
        log_message "✅ Mount point ownership is correct (ctyeh:staff)"
    fi
}

# Main mounting logic
main() {
    # Prevent multiple instances
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid=$(cat "$LOCK_FILE" 2>/dev/null)
        if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
            log_message "Another instance is running (PID: $lock_pid), exiting"
            exit 0
        fi
    fi
    
    echo $$ > "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"' EXIT
    
    # Check if hibernation wake was detected
    local hibernation_wake=false
    if detect_hibernation_wake; then
        hibernation_wake=true
        log_message "[HIBERNATION] Hibernation wake detected, using enhanced recovery"
        # Wait a bit longer for USB devices after hibernation
        sleep 5
    fi
    
    # Find CTExternalDisk
    local device_info
    device_info=$(diskutil list | grep "CTExternalDisk" | head -1)
    
    if [ -z "$device_info" ]; then
        log_message "CTExternalDisk not detected"
        exit 0
    fi
    
    local device_node
    device_node=$(echo "$device_info" | awk '{print $NF}')
    
    if [ -z "$device_node" ]; then
        log_message "Could not determine device node for CTExternalDisk"
        exit 1
    fi
    
    log_message "CTExternalDisk detected at: $device_node"
    
    # Check if already mounted
    if [ -d "/Volumes/CTExternalDisk" ]; then
        log_message "CTExternalDisk already mounted"
        
        # Fix mount point ownership if needed
        fix_mount_ownership
        
        verify_itunes_symlink
        
        # Show disk space
        local disk_space
        disk_space=$(df -h /Volumes/CTExternalDisk 2>/dev/null | tail -1)
        if [ -n "$disk_space" ]; then
            log_message "Disk space: $disk_space"
        fi
        exit 0
    fi
    
    # Mount the disk using hibernation-safe methods
    if mount_disk_hibernation_safe "$device_node"; then
        log_message "✅ CTExternalDisk mounted successfully at /Volumes/CTExternalDisk"
        
        # Fix mount point ownership
        fix_mount_ownership
        
        # Verify and repair symlinks
        verify_itunes_symlink
        
        # Show disk space
        local disk_space
        disk_space=$(df -h /Volumes/CTExternalDisk 2>/dev/null | tail -1)
        if [ -n "$disk_space" ]; then
            log_message "Disk space: $disk_space"
        fi
        
        if [ "$hibernation_wake" = true ]; then
            log_message "[HIBERNATION] ✅ Hibernation recovery completed successfully"
        fi
    else
        log_message "❌ Failed to mount CTExternalDisk"
        exit 1
    fi
}

main "$@"
