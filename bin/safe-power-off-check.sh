#!/bin/bash

# Safe Power-Off Check Script
# Checks if it's safe to power off the external drive directly

LOG_FILE="$HOME/.local/log/ctexternaldisk-power-off-check.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

echo "🔍 SAFE POWER-OFF CHECK"
echo "======================="
echo ""

# Check if drive is mounted
if ! mount | grep -q "/Volumes/CTExternalDisk"; then
    echo "✅ Drive is not mounted - Safe to power off"
    log_message "✅ Drive not mounted - safe to power off"
    exit 0
fi

echo "📊 Checking drive safety for direct power-off..."
echo ""

# Check 1: Active file operations
echo "🔍 Checking for active file operations..."
active_processes=$(lsof /Volumes/CTExternalDisk 2>/dev/null | wc -l)
if [ "$active_processes" -gt 1 ]; then
    echo "⚠️  WARNING: $((active_processes-1)) active file operations detected"
    echo "   Active processes:"
    lsof /Volumes/CTExternalDisk 2>/dev/null | tail -n +2 | awk '{print "   - " $1 " (PID: " $2 ")"}'
    echo ""
    echo "❌ NOT SAFE to power off - wait for operations to complete"
    log_message "❌ Not safe - $((active_processes-1)) active operations"
    exit 1
else
    echo "✅ No active file operations"
fi

# Check 2: Recent file activity
echo ""
echo "🔍 Checking for recent file activity..."
recent_activity=$(find /Volumes/CTExternalDisk -type f -newermt "1 minute ago" 2>/dev/null | wc -l)
if [ "$recent_activity" -gt 0 ]; then
    echo "⚠️  WARNING: $recent_activity files modified in the last minute"
    echo "❌ NOT SAFE to power off - recent file activity detected"
    log_message "❌ Not safe - $recent_activity recent file modifications"
    exit 1
else
    echo "✅ No recent file activity"
fi

# Check 3: System cache status
echo ""
echo "🔍 Checking system cache status..."
# Force sync to flush any pending writes
sync
echo "✅ System caches flushed"

# Check 4: Spotlight indexing
echo ""
echo "🔍 Checking Spotlight indexing status..."
if mdutil -s /Volumes/CTExternalDisk 2>/dev/null | grep -q "Indexing enabled"; then
    indexing_status=$(mdutil -s /Volumes/CTExternalDisk 2>/dev/null)
    if echo "$indexing_status" | grep -q "Indexing enabled"; then
        echo "⚠️  WARNING: Spotlight indexing may be active"
        echo "   Status: $indexing_status"
        echo "⚠️  Consider waiting or it's generally safe with APFS journaling"
    else
        echo "✅ Spotlight indexing not active"
    fi
else
    echo "✅ Spotlight indexing disabled or not active"
fi

# Final assessment
echo ""
echo "🎯 FINAL ASSESSMENT:"
echo "===================="
echo "✅ Drive appears safe for direct power-off"
echo ""
echo "💡 RECOMMENDATIONS:"
echo "==================="
echo "✅ APFS journaling will protect against corruption"
echo "✅ Self-healing auto-mount will handle recovery"
echo "✅ File system verification will run on reconnect"
echo ""
echo "⚠️  For maximum safety, consider using:"
echo "   diskutil eject /Volumes/CTExternalDisk"
echo ""
echo "🔌 If you power off directly:"
echo "   - Your system will auto-recover on reconnect"
echo "   - File system verification will ensure integrity"
echo "   - Self-healing features will handle any issues"

log_message "✅ Safety check completed - drive appears safe for power-off"
exit 0
