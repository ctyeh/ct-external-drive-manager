#!/bin/bash

# Example: Custom Device Configuration
# This example shows how to configure the auto-mount system for a different device name

# Configuration for a custom external drive
export CTDISK_DEVICE_NAME="MyExternalDrive"
export CTDISK_MOUNT_POINT="/Volumes/MyExternalDrive"

# Optional: Custom log directory
export CTDISK_LOG_DIR="$HOME/logs/mydrive"

# Optional: Enable debug logging
export CTDISK_DEBUG=1

# Create custom log directory if it doesn't exist
mkdir -p "$CTDISK_LOG_DIR"

echo "Custom configuration loaded:"
echo "  Device Name: $CTDISK_DEVICE_NAME"
echo "  Mount Point: $CTDISK_MOUNT_POINT"
echo "  Log Directory: $CTDISK_LOG_DIR"
echo "  Debug Mode: ${CTDISK_DEBUG:-0}"

# Usage:
# 1. Source this file before running commands:
#    source examples/custom-device-config.sh
#    ctdisk mount
#
# 2. Or add to your shell configuration:
#    echo 'source /path/to/custom-device-config.sh' >> ~/.zshrc
