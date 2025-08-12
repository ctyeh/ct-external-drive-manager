#!/bin/bash

# Fix CTExternalDisk Ownership Script
# Ensures the mount point has correct ownership for user access

MOUNT_POINT="/Volumes/CTExternalDisk"
TARGET_USER="ctyeh"
TARGET_GROUP="staff"

echo "🔧 CTExternalDisk Ownership Fix Tool"
echo "===================================="
echo ""

# Check if disk is mounted
if [ ! -d "$MOUNT_POINT" ]; then
    echo "❌ CTExternalDisk is not mounted at $MOUNT_POINT"
    echo "Please mount the disk first using: ctdisk mount"
    exit 1
fi

# Check current ownership
current_owner=$(stat -f "%Su:%Sg" "$MOUNT_POINT" 2>/dev/null)
echo "Current ownership: $current_owner"
echo "Target ownership:  $TARGET_USER:$TARGET_GROUP"
echo ""

if [ "$current_owner" = "$TARGET_USER:$TARGET_GROUP" ]; then
    echo "✅ Ownership is already correct!"
    
    # Test write permissions
    if touch "$MOUNT_POINT/test_write_permission.tmp" 2>/dev/null; then
        rm "$MOUNT_POINT/test_write_permission.tmp"
        echo "✅ Write permissions are working"
    else
        echo "⚠️  Write permissions may be restricted"
    fi
else
    echo "🔧 Fixing ownership..."
    
    if sudo chown "$TARGET_USER:$TARGET_GROUP" "$MOUNT_POINT"; then
        echo "✅ Ownership fixed successfully!"
        
        # Verify the fix
        new_owner=$(stat -f "%Su:%Sg" "$MOUNT_POINT" 2>/dev/null)
        echo "New ownership: $new_owner"
        
        # Test write permissions
        if touch "$MOUNT_POINT/test_write_permission.tmp" 2>/dev/null; then
            rm "$MOUNT_POINT/test_write_permission.tmp"
            echo "✅ Write permissions are now working"
        else
            echo "⚠️  Write permissions may still be restricted"
        fi
    else
        echo "❌ Failed to fix ownership. You may need to run with sudo."
        exit 1
    fi
fi

echo ""
echo "📋 Current mount point details:"
ls -ld "$MOUNT_POINT"
echo ""
echo "🎉 Ownership fix completed!"
echo ""
echo "Note: The hibernation-safe auto-mount system now automatically"
echo "fixes ownership issues when mounting the disk."
