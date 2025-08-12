#!/bin/bash

# Setup script to enable sudo-free mounting for CTExternalDisk
# This creates a sudoers rule that allows specific mount/unmount commands without password

SUDOERS_FILE="/etc/sudoers.d/ctexternaldisk-mount"
USERNAME=$(whoami)

echo "🔧 Setting up sudo-free mounting for CTExternalDisk..."
echo ""
echo "This will create a sudoers rule to allow the following commands without password:"
echo "  - mkdir -p /Volumes/CTExternalDisk"
echo "  - mount -t apfs /dev/disk*s1 /Volumes/CTExternalDisk"
echo "  - umount /Volumes/CTExternalDisk"
echo "  - diskutil mount disk*s1"
echo "  - diskutil unmount /Volumes/CTExternalDisk"
echo ""

# Create the sudoers rule
cat << EOF | sudo tee "$SUDOERS_FILE" > /dev/null
# Allow $USERNAME to mount/unmount CTExternalDisk without password
$USERNAME ALL=(root) NOPASSWD: /bin/mkdir -p /Volumes/CTExternalDisk
$USERNAME ALL=(root) NOPASSWD: /sbin/mount -t apfs /dev/disk[0-9]*s1 /Volumes/CTExternalDisk
$USERNAME ALL=(root) NOPASSWD: /sbin/umount /Volumes/CTExternalDisk
$USERNAME ALL=(root) NOPASSWD: /usr/sbin/diskutil mount disk[0-9]*s1
$USERNAME ALL=(root) NOPASSWD: /usr/sbin/diskutil unmount /Volumes/CTExternalDisk
$USERNAME ALL=(root) NOPASSWD: /usr/sbin/diskutil unmount force /Volumes/CTExternalDisk
EOF

# Verify the sudoers file syntax
if sudo visudo -c -f "$SUDOERS_FILE"; then
    echo "✅ Sudoers rule created successfully!"
    echo ""
    echo "You can now use these commands without password:"
    echo "  sudo mkdir -p /Volumes/CTExternalDisk"
    echo "  sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk"
    echo "  sudo diskutil mount disk7s1"
    echo "  sudo diskutil unmount /Volumes/CTExternalDisk"
    echo ""
    echo "Testing the setup..."
    
    # Test the setup
    if sudo -n mkdir -p /Volumes/CTExternalDisk 2>/dev/null; then
        echo "✅ Passwordless mkdir test passed"
    else
        echo "❌ Passwordless mkdir test failed"
    fi
    
    if sudo -n diskutil mount disk7s1 2>/dev/null; then
        echo "✅ Passwordless mount test passed"
        echo "✅ CTExternalDisk mounted successfully!"
    else
        echo "⚠️  Mount test failed (disk may already be mounted or not connected)"
    fi
    
else
    echo "❌ Error in sudoers file syntax. Removing..."
    sudo rm -f "$SUDOERS_FILE"
    exit 1
fi

echo ""
echo "🎉 Setup complete! Your hibernation scripts can now mount/unmount without password prompts."
