#!/bin/bash

# Enhanced CTExternalDisk Auto-Mount Script v3 with Self-Healing Features
# Prevents LaunchAgent service from getting stuck in bad execution states

LOG_FILE="$HOME/.local/log/ctexternaldisk-mount-hibernation-safe.log"
ERROR_LOG="$HOME/.local/log/ctexternaldisk-mount-hibernation-safe.error.log"
HEALTH_LOG="$HOME/.local/log/ctexternaldisk-service-health.log"
LOCK_FILE="$HOME/.local/tmp/ctdisk-mount-hibernation-safe.lock"
LAST_MOUNT_FILE="$HOME/.local/tmp/ctdisk-last-mount-time"
FAILURE_COUNT_FILE="$HOME/.local/tmp/ctdisk-failure-count"
SERVICE_STATE_FILE="$HOME/.local/tmp/ctdisk-service-state"

# Device configuration
DISK_UUID="3E314969-A8AD-49EA-8743-F773357E61AB"
DEFAULT_DEVICE_NODE="/dev/disk7s1"
MOUNT_POINT="/Volumes/CTExternalDisk"

# Self-healing configuration
MAX_CONSECUTIVE_FAILURES=3
FAILURE_RESET_TIME=300  # 5 minutes
SERVICE_RESTART_COOLDOWN=60  # 1 minute between restarts

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$LOCK_FILE")"

# Redirect stderr to error log
exec 2>>"$ERROR_LOG"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

log_health() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): [HEALTH] $1" | tee -a "$HEALTH_LOG"
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

# Enhanced mount state detection
is_drive_actually_mounted() {
    # Check multiple ways to ensure drive is really mounted
    local mount_check=false
    local df_check=false
    local directory_check=false
    
    # Method 1: Check mount command output
    if mount | grep -q "/dev/disk.*on /Volumes/CTExternalDisk"; then
        mount_check=true
    fi
    
    # Method 2: Check df command
    if df /Volumes/CTExternalDisk >/dev/null 2>&1; then
        df_check=true
    fi
    
    # Method 3: Check if directory exists and is accessible
    if [ -d "/Volumes/CTExternalDisk" ] && [ -r "/Volumes/CTExternalDisk" ]; then
        directory_check=true
    fi
    
    log_health "Mount state check: mount=$mount_check, df=$df_check, dir=$directory_check"
    
    # Drive is considered mounted if at least 2 out of 3 checks pass
    local passed_checks=0
    $mount_check && ((passed_checks++))
    $df_check && ((passed_checks++))
    $directory_check && ((passed_checks++))
    
    if [ $passed_checks -ge 2 ]; then
        return 0  # Drive is mounted
    else
        return 1  # Drive is not mounted
    fi
}

# Function to detect service health issues
detect_service_issues() {
    local current_time=$(date +%s)
    local failure_count=0
    
    # Read current failure count
    if [ -f "$FAILURE_COUNT_FILE" ]; then
        failure_count=$(cat "$FAILURE_COUNT_FILE" 2>/dev/null || echo "0")
    fi
    
    # Check if we're in a failure loop
    if [ "$failure_count" -ge "$MAX_CONSECUTIVE_FAILURES" ]; then
        log_health "Detected service failure loop: $failure_count consecutive failures"
        return 0  # Issues detected
    fi
    
    return 1  # No issues detected
}

# Function to reset failure count
reset_failure_count() {
    echo "0" > "$FAILURE_COUNT_FILE"
    log_health "Failure count reset"
}

# Function to increment failure count
increment_failure_count() {
    local current_count=0
    if [ -f "$FAILURE_COUNT_FILE" ]; then
        current_count=$(cat "$FAILURE_COUNT_FILE" 2>/dev/null || echo "0")
    fi
    
    local new_count=$((current_count + 1))
    echo "$new_count" > "$FAILURE_COUNT_FILE"
    log_health "Failure count incremented to: $new_count"
    
    return $new_count
}

# Function to restart LaunchAgent service (self-healing)
restart_service_if_needed() {
    local current_time=$(date +%s)
    local last_restart=0
    
    # Check last restart time to avoid restart loops
    if [ -f "$SERVICE_STATE_FILE" ]; then
        last_restart=$(cat "$SERVICE_STATE_FILE" 2>/dev/null || echo "0")
    fi
    
    local time_since_restart=$((current_time - last_restart))
    
    if [ $time_since_restart -lt $SERVICE_RESTART_COOLDOWN ]; then
        log_health "Service restart on cooldown (${time_since_restart}s < ${SERVICE_RESTART_COOLDOWN}s)"
        return 1
    fi
    
    log_health "Attempting service self-healing restart..."
    
    # Record restart time
    echo "$current_time" > "$SERVICE_STATE_FILE"
    
    # Restart the LaunchAgent service
    if launchctl unload ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist 2>/dev/null; then
        sleep 2
        if launchctl load ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist 2>/dev/null; then
            log_health "✅ Service successfully restarted"
            reset_failure_count
            return 0
        else
            log_health "❌ Failed to reload service"
            return 1
        fi
    else
        log_health "❌ Failed to unload service"
        return 1
    fi
}

# Enhanced mount function with self-healing
mount_disk_hibernation_safe() {
    local device_node="$1"
    local mounted=false
    
    log_message "Attempting hibernation-safe mount of $device_node"
    
    # First, check if drive is actually mounted using enhanced detection
    if is_drive_actually_mounted; then
        log_message "✅ Drive is already properly mounted (verified)"
        reset_failure_count  # Reset on success
        return 0
    fi
    
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
        reset_failure_count  # Reset on success
        return 0
    else
        log_message "❌ All hibernation-safe mount methods failed"
        
        # Increment failure count and check for service issues
        increment_failure_count
        local failure_count=$?
        
        # If we've hit the failure threshold, attempt self-healing
        if [ $failure_count -ge $MAX_CONSECUTIVE_FAILURES ]; then
            log_health "Failure threshold reached ($failure_count >= $MAX_CONSECUTIVE_FAILURES)"
            
            if detect_service_issues; then
                log_health "Service issues detected, attempting self-healing..."
                restart_service_if_needed
            fi
        fi
        
        return 1
    fi
}

# Function to verify and repair iTunes symlink
verify_itunes_symlink() {
    local itunes_source="/Volumes/CTExternalDisk/Music_Library/iTunes"
    local itunes_target="$HOME/Music/iTunes"
    
    if [ -d "$itunes_source" ]; then
        if [ -L "$itunes_target" ]; then
            local current_target=$(readlink "$itunes_target")
            if [ "$current_target" = "$itunes_source" ]; then
                log_message "✅ iTunes symlink verified"
                return 0
            else
                log_message "🔧 iTunes symlink points to wrong location, fixing..."
                rm "$itunes_target"
            fi
        elif [ -e "$itunes_target" ]; then
            log_message "⚠️  iTunes target exists but is not a symlink, backing up..."
            mv "$itunes_target" "${itunes_target}.backup.$(date +%s)"
        fi
        
        ln -s "$itunes_source" "$itunes_target"
        log_message "✅ iTunes symlink created/repaired"
    else
        log_message "⚠️  iTunes source directory not found: $itunes_source"
    fi
}

# Function to fix mount point ownership
fix_mount_ownership() {
    if [ -d "/Volumes/CTExternalDisk" ]; then
        local current_owner=$(stat -f "%Su:%Sg" /Volumes/CTExternalDisk)
        local expected_owner="ctyeh:staff"
        
        if [ "$current_owner" = "$expected_owner" ]; then
            log_message "✅ Mount point ownership is correct ($current_owner)"
        else
            log_message "🔧 Fixing mount point ownership from $current_owner to $expected_owner"
            if check_passwordless_sudo; then
                sudo chown ctyeh:staff /Volumes/CTExternalDisk
                log_message "✅ Mount point ownership fixed"
            else
                log_message "⚠️  Cannot fix ownership without passwordless sudo"
            fi
        fi
    fi
}

# Function to find the correct device node (in case it changes after hibernation)
find_device_node() {
    # Try the known device node first
    if [ -e "$DEFAULT_DEVICE_NODE" ]; then
        echo "$DEFAULT_DEVICE_NODE"
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
        # Get the s1 partition (APFS volume)
        if [[ "$device" =~ ^/dev/disk[0-9]+$ ]]; then
            device="${device}s1"
        fi
        if [ -e "$device" ]; then
            echo "$device"
            return 0
        fi
    fi
    
    return 1
}

# Function to check if device exists
device_exists() {
    # Check multiple ways to detect the device
    [ -e "$DEFAULT_DEVICE_NODE" ] && return 0
    diskutil list | grep -q "$DISK_UUID" && return 0
    diskutil list | grep -q "CTExternalDisk" && return 0
    
    # Wait a moment and try again (for post-hibernation detection)
    sleep 2
    [ -e "$DEFAULT_DEVICE_NODE" ] && return 0
    diskutil list | grep -q "$DISK_UUID" && return 0
    diskutil list | grep -q "CTExternalDisk" && return 0
    
    return 1
}

# Enhanced hibernation detection with self-healing awareness
detect_hibernation_recovery() {
    local current_time=$(date +%s)
    local last_mount_time=0
    
    if [ -f "$LAST_MOUNT_FILE" ]; then
        last_mount_time=$(cat "$LAST_MOUNT_FILE" 2>/dev/null || echo "0")
    fi
    
    local time_gap=$((current_time - last_mount_time))
    
    # Consider it hibernation recovery if gap > 30 minutes
    if [ $time_gap -gt 1800 ]; then
        log_message "[HIBERNATION] Long gap since last mount (${time_gap}s), likely hibernation recovery"
        log_message "[HIBERNATION] Hibernation wake detected, using enhanced recovery"
        
        # Add extra delay for hibernation recovery
        sleep 5
        return 0
    fi
    
    return 1
}

# Main function with enhanced error handling and self-healing
main() {
    local device_node="$1"
    
    # If no device node provided, try to auto-detect
    if [ -z "$device_node" ]; then
        log_message "No device node provided, attempting auto-detection..."
        
        # Check if device exists
        if ! device_exists; then
            log_message "Device not detected, skipping mount attempt"
            exit 0
        fi
        
        # Find the actual device node
        device_node=$(find_device_node)
        if [ -z "$device_node" ]; then
            log_message "❌ Could not determine device node"
            increment_failure_count
            exit 1
        fi
        
        log_message "✅ Auto-detected device node: $device_node"
    fi
    
    # Check for lock file to prevent concurrent executions
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid=$(cat "$LOCK_FILE" 2>/dev/null)
        if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
            log_message "⚠️  Another instance is running (PID: $lock_pid)"
            exit 0
        else
            log_message "🔧 Removing stale lock file"
            rm -f "$LOCK_FILE"
        fi
    fi
    
    # Create lock file
    echo $$ > "$LOCK_FILE"
    
    # Cleanup function
    cleanup() {
        rm -f "$LOCK_FILE"
    }
    trap cleanup EXIT
    
    # Detect hibernation recovery
    detect_hibernation_recovery
    
    # Wait for device to be ready
    sleep 5
    
    log_message "CTExternalDisk detected at: $device_node"
    
    # Enhanced mount state check
    if is_drive_actually_mounted; then
        log_message "CTExternalDisk already mounted (verified)"
        
        # Fix mount point ownership if needed
        fix_mount_ownership
        
        verify_itunes_symlink
        
        # Show disk space
        local disk_space
        disk_space=$(df -h /Volumes/CTExternalDisk 2>/dev/null | tail -1)
        if [ -n "$disk_space" ]; then
            log_message "Disk space: $disk_space"
        fi
        
        reset_failure_count  # Reset on successful verification
        exit 0
    fi
    
    # Mount the disk using hibernation-safe methods with self-healing
    if mount_disk_hibernation_safe "$device_node"; then
        log_message "✅ CTExternalDisk mounted successfully at /Volumes/CTExternalDisk"
        
        # Fix ownership and verify symlink
        fix_mount_ownership
        verify_itunes_symlink
        
        # Show disk space
        local disk_space
        disk_space=$(df -h /Volumes/CTExternalDisk 2>/dev/null | tail -1)
        if [ -n "$disk_space" ]; then
            log_message "Disk space: $disk_space"
        fi
        
        log_health "✅ Mount operation completed successfully"
        exit 0
    else
        log_message "❌ Failed to mount CTExternalDisk"
        log_health "❌ Mount operation failed"
        exit 1
    fi
}

# Run main function
main "$@"
