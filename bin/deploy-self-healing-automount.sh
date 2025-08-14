#!/bin/bash

# Deploy Self-Healing Auto-Mount System
# Replaces the current hibernation-safe script with the enhanced version

echo "🔧 Deploying Self-Healing Auto-Mount System"
echo "============================================"
echo ""

# Navigate to project directory
cd "$(dirname "$0")/.."

echo "📁 Current directory: $(pwd)"
echo ""

echo "🔍 Backing up current system..."
echo "==============================="

# Backup current hibernation-safe script
if [ -f ~/.local/bin/mount-ctexternaldisk-hibernation-safe.sh ]; then
    cp ~/.local/bin/mount-ctexternaldisk-hibernation-safe.sh ~/.local/bin/mount-ctexternaldisk-hibernation-safe.sh.backup.$(date +%s)
    echo "✅ Current script backed up"
else
    echo "⚠️  No existing script found to backup"
fi

echo ""
echo "🚀 Deploying new self-healing script..."
echo "======================================="

# Copy new script to local bin
cp bin/mount-ctexternaldisk-hibernation-safe-v3.sh ~/.local/bin/mount-ctexternaldisk-hibernation-safe.sh
chmod +x ~/.local/bin/mount-ctexternaldisk-hibernation-safe.sh

echo "✅ New self-healing script deployed"
echo ""

echo "🔄 Restarting auto-mount service..."
echo "==================================="

# Restart the LaunchAgent service to use the new script
launchctl unload ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist 2>/dev/null || true
sleep 2
launchctl load ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist

echo "✅ Auto-mount service restarted with self-healing features"
echo ""

echo "🔍 Verifying deployment..."
echo "=========================="

# Check service status
if launchctl list | grep -q ctexternaldisk.automount; then
    echo "✅ Auto-mount service is running"
else
    echo "❌ Auto-mount service is not running"
    exit 1
fi

# Test the new script
echo ""
echo "🧪 Testing self-healing features..."
echo "==================================="

# Wait a moment for the service to detect the drive
sleep 5

# Check recent logs
if [ -f ~/.local/log/ctexternaldisk-mount-hibernation-safe.log ]; then
    echo "Recent auto-mount log:"
    tail -3 ~/.local/log/ctexternaldisk-mount-hibernation-safe.log
fi

echo ""
echo "🎉 SELF-HEALING AUTO-MOUNT SYSTEM DEPLOYED!"
echo "==========================================="
echo ""
echo "🛡️ New Features Active:"
echo "✅ Enhanced mount state detection"
echo "✅ Service health monitoring"
echo "✅ Automatic failure recovery"
echo "✅ Self-healing service restart"
echo "✅ Comprehensive health logging"
echo ""
echo "📝 Health logs available at:"
echo "~/.local/log/ctexternaldisk-service-health.log"
echo ""
echo "🔧 If issues occur, the system will automatically:"
echo "1. Detect failure patterns"
echo "2. Restart the LaunchAgent service"
echo "3. Reset failure counters"
echo "4. Log all recovery actions"
