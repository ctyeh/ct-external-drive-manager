#!/bin/bash

# Disk Health Monitor for CTExternalDisk
# Monitors disk health and tracks power-off events

LOG_FILE="$HOME/.local/log/ctexternaldisk-health.log"
POWER_OFF_LOG="$HOME/.local/log/ctexternaldisk-power-off-events.log"
HEALTH_DATA_FILE="$HOME/.local/tmp/ctdisk-health-data"

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$HEALTH_DATA_FILE")"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

log_power_off() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$POWER_OFF_LOG"
}

echo "🔍 DISK HEALTH MONITOR"
echo "======================"
echo ""

# Check if drive is connected
if ! mount | grep -q "/Volumes/CTExternalDisk"; then
    echo "❌ CTExternalDisk not mounted - cannot check health"
    exit 1
fi

echo "📊 Checking disk health status..."
echo ""

# Basic disk information
echo "🔧 Drive Information:"
echo "===================="
diskutil info disk7s1 | grep -E "(Volume Name|Media Name|Disk Size|File System)"
echo ""

# Check disk space and usage
echo "💾 Disk Usage:"
echo "=============="
df -h /Volumes/CTExternalDisk
echo ""

# Check for file system errors
echo "🔍 File System Health Check:"
echo "============================"
echo "Running quick file system verification..."
if diskutil verifyVolume disk7s1 >/dev/null 2>&1; then
    echo "✅ File system appears healthy"
    log_message "✅ File system verification passed"
else
    echo "⚠️  File system issues detected - consider running First Aid"
    log_message "⚠️  File system verification failed"
fi

# Check for recent power-off events
echo ""
echo "📊 Power-Off Event Analysis:"
echo "============================"

# Count power-off events in the last 30 days
if [ -f "$POWER_OFF_LOG" ]; then
    recent_events=$(grep "$(date -v-30d '+%Y-%m')" "$POWER_OFF_LOG" 2>/dev/null | wc -l)
    echo "Power-off events in last 30 days: $recent_events"
    
    if [ "$recent_events" -gt 30 ]; then
        echo "⚠️  HIGH FREQUENCY: Consider reducing direct power-offs"
        log_message "⚠️  High power-off frequency detected: $recent_events events/month"
    elif [ "$recent_events" -gt 10 ]; then
        echo "🟡 MODERATE FREQUENCY: Monitor disk health regularly"
        log_message "🟡 Moderate power-off frequency: $recent_events events/month"
    else
        echo "✅ LOW FREQUENCY: Minimal health impact expected"
        log_message "✅ Low power-off frequency: $recent_events events/month"
    fi
else
    echo "No power-off event history found"
fi

# Check disk temperature (if available)
echo ""
echo "🌡️  Disk Temperature Check:"
echo "==========================="
# Note: External USB drives typically don't report temperature via standard macOS tools
echo "Temperature monitoring not available for external USB drives"

# Check for bad sectors or errors
echo ""
echo "🔍 Error Detection:"
echo "=================="
echo "Checking system logs for disk errors..."
recent_errors=$(log show --last 7d --predicate 'subsystem == "com.apple.kernel" AND (eventMessage CONTAINS "disk6" OR eventMessage CONTAINS "disk7")' 2>/dev/null | grep -i error | wc -l)
if [ "$recent_errors" -gt 0 ]; then
    echo "⚠️  $recent_errors disk-related errors found in last 7 days"
    log_message "⚠️  $recent_errors disk errors detected in system logs"
else
    echo "✅ No recent disk errors detected"
    log_message "✅ No disk errors in system logs"
fi

# Health recommendations
echo ""
echo "💡 HEALTH RECOMMENDATIONS:"
echo "=========================="

# Calculate health score based on various factors
health_score=100

# Deduct points for high power-off frequency
if [ -f "$POWER_OFF_LOG" ]; then
    if [ "$recent_events" -gt 30 ]; then
        health_score=$((health_score - 20))
        echo "⚠️  Reduce direct power-off frequency (current: high)"
    elif [ "$recent_events" -gt 10 ]; then
        health_score=$((health_score - 10))
        echo "🟡 Consider reducing direct power-off frequency (current: moderate)"
    fi
fi

# Deduct points for file system issues
if ! diskutil verifyVolume disk7s1 >/dev/null 2>&1; then
    health_score=$((health_score - 15))
    echo "⚠️  Run First Aid to fix file system issues"
fi

# Deduct points for recent errors
if [ "$recent_errors" -gt 0 ]; then
    health_score=$((health_score - 10))
    echo "⚠️  Monitor system logs for recurring disk errors"
fi

echo ""
echo "📊 OVERALL HEALTH SCORE: $health_score/100"
echo "==============================="

if [ "$health_score" -ge 90 ]; then
    echo "🟢 EXCELLENT: Disk health is very good"
    log_message "🟢 Health score: $health_score/100 - Excellent"
elif [ "$health_score" -ge 75 ]; then
    echo "🟡 GOOD: Disk health is acceptable, minor concerns"
    log_message "🟡 Health score: $health_score/100 - Good"
elif [ "$health_score" -ge 60 ]; then
    echo "🟠 FAIR: Disk health needs attention"
    log_message "🟠 Health score: $health_score/100 - Fair"
else
    echo "🔴 POOR: Disk health is concerning, consider replacement"
    log_message "🔴 Health score: $health_score/100 - Poor"
fi

echo ""
echo "🔧 MAINTENANCE SUGGESTIONS:"
echo "==========================="
echo "1. Run this health check monthly: ./bin/disk-health-monitor.sh"
echo "2. Use safety check before power-off: ./bin/safe-power-off-check.sh"
echo "3. Consider proper ejection when convenient"
echo "4. Monitor for unusual noises or slow performance"
echo "5. Maintain regular backups of important data"

# Save health data
echo "$(date +%s):$health_score:$recent_events:$recent_errors" >> "$HEALTH_DATA_FILE"

echo ""
echo "📝 Health check completed and logged"
log_message "Health check completed - Score: $health_score/100"
