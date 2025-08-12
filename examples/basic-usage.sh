#!/bin/bash

# Example: Basic Usage of CTExternalDisk Auto-Mount System
# This script demonstrates common usage patterns

echo "🚀 CTExternalDisk Auto-Mount System - Basic Usage Examples"
echo "=========================================================="
echo ""

# Check if system is installed
if ! command -v ctdisk >/dev/null 2>&1; then
    echo "❌ CTExternalDisk system not found in PATH"
    echo "Please install the system first: ./install.sh"
    exit 1
fi

echo "✅ CTExternalDisk system found"
echo ""

# Example 1: Check system status
echo "📊 Example 1: Checking System Status"
echo "-----------------------------------"
echo "Command: ctdisk-setup status"
echo ""
ctdisk-setup status
echo ""

# Example 2: Check drive status
echo "💾 Example 2: Checking Drive Status"
echo "----------------------------------"
echo "Command: ctdisk status"
echo ""
ctdisk status
echo ""

# Example 3: Manual mount/unmount
echo "🔧 Example 3: Manual Mount/Unmount Operations"
echo "--------------------------------------------"
echo "Note: These operations are normally handled automatically"
echo ""

read -p "Do you want to test manual unmount/mount? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Unmounting drive..."
    ctdisk unmount
    echo ""
    
    echo "Waiting 5 seconds..."
    sleep 5
    echo ""
    
    echo "Mounting drive..."
    ctdisk mount
    echo ""
fi

# Example 4: Hibernation-safe operations
echo "🛡️ Example 4: Hibernation-Safe Operations"
echo "----------------------------------------"
echo "Command: ctdisk-hibernation-safe status"
echo ""
ctdisk-hibernation-safe status
echo ""

# Example 5: Test hibernation recovery
echo "🧪 Example 5: Test Hibernation Recovery"
echo "--------------------------------------"
read -p "Do you want to run hibernation recovery test? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running hibernation recovery test..."
    echo "This will temporarily unmount the drive and test auto-recovery"
    echo ""
    test-hibernation-recovery.sh
    echo ""
fi

# Example 6: Check and fix ownership
echo "👤 Example 6: Ownership Management"
echo "---------------------------------"
echo "Command: fix-ctdisk-ownership.sh --check-only"
echo ""
if command -v fix-ctdisk-ownership.sh >/dev/null 2>&1; then
    fix-ctdisk-ownership.sh --check-only
else
    echo "fix-ctdisk-ownership.sh not found in PATH"
fi
echo ""

# Example 7: View recent logs
echo "📝 Example 7: Viewing Recent Logs"
echo "--------------------------------"
echo "Recent auto-mount activity:"
if [[ -f "$HOME/.local/log/ctexternaldisk-mount.log" ]]; then
    tail -5 "$HOME/.local/log/ctexternaldisk-mount.log"
else
    echo "No log file found at $HOME/.local/log/ctexternaldisk-mount.log"
fi
echo ""

# Example 8: Configuration check
echo "⚙️ Example 8: Configuration Check"
echo "--------------------------------"
echo "Checking passwordless sudo configuration..."
if command -v ctdisk-hibernation-safe >/dev/null 2>&1; then
    ctdisk-hibernation-safe check-sudo
else
    echo "ctdisk-hibernation-safe not found in PATH"
fi
echo ""

echo "🎉 Basic usage examples completed!"
echo ""
echo "For more advanced usage, see:"
echo "  - docs/USER_GUIDE.md"
echo "  - docs/HIBERNATION.md"
echo "  - docs/API.md"
