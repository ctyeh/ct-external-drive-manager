#!/bin/bash

# Test script for hibernation recovery
# Simulates hibernation by unmounting the disk and testing auto-recovery

echo "🧪 Testing Hibernation Recovery System"
echo "======================================"
echo ""

# Check initial status
echo "1. Initial Status Check:"
ctdisk status
echo ""

# Unmount the disk to simulate hibernation
echo "2. Simulating hibernation (unmounting disk)..."
if diskutil unmount /Volumes/CTExternalDisk >/dev/null 2>&1; then
    echo "✅ Disk unmounted successfully"
else
    echo "⚠️  Disk was not mounted or unmount failed"
fi
echo ""

# Wait for auto-mount system to detect and remount
echo "3. Waiting for auto-mount system to recover (60 seconds)..."
for i in {1..12}; do
    echo -n "."
    sleep 5
    if [ -d "/Volumes/CTExternalDisk" ]; then
        echo ""
        echo "✅ Auto-mount recovery detected after $((i*5)) seconds!"
        break
    fi
done
echo ""

# Check final status
echo "4. Final Status Check:"
ctdisk status
echo ""

# Check iTunes symlink
echo "5. iTunes Symlink Check:"
if [ -L "$HOME/Music/iTunes" ] && [ -d "$(readlink "$HOME/Music/iTunes")" ]; then
    echo "✅ iTunes symlink is working"
    ls -la ~/Music/iTunes
else
    echo "❌ iTunes symlink is broken or missing"
fi
echo ""

# Show recent logs
echo "6. Recent Auto-Mount Logs:"
tail -5 ~/.local/log/ctexternaldisk-mount-hibernation-safe.log
echo ""

echo "🎉 Hibernation recovery test completed!"
echo ""
echo "If the disk auto-mounted successfully, your hibernation recovery system is working!"
