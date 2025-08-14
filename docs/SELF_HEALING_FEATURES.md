# Self-Healing Auto-Mount System

## Overview

The enhanced auto-mount system includes self-healing features to prevent LaunchAgent service issues and automatically recover from failure states.

## Features

### 1. Enhanced Mount State Detection
- **3-Way Verification**: Checks mount status using multiple methods
  - `mount` command output
  - `df` command verification  
  - Directory accessibility check
- **Robust Detection**: Drive considered mounted only if 2+ checks pass
- **Prevents False Positives**: Avoids mounting over already-mounted drives

### 2. Service Health Monitoring
- **Failure Count Tracking**: Monitors consecutive mount failures
- **Health Logging**: Dedicated health log for diagnostics
- **Pattern Detection**: Identifies when service gets stuck in bad states

### 3. Automatic Self-Healing
- **Failure Threshold**: Triggers recovery after 3 consecutive failures
- **Service Restart**: Automatically restarts LaunchAgent service
- **Cooldown Period**: Prevents restart loops (60-second minimum between restarts)
- **Failure Reset**: Clears failure count after successful operations

### 4. Comprehensive Logging
- **Main Log**: `~/.local/log/ctexternaldisk-mount-hibernation-safe.log`
- **Health Log**: `~/.local/log/ctexternaldisk-service-health.log`
- **Error Log**: `~/.local/log/ctexternaldisk-mount-hibernation-safe.error.log`

## Configuration

### Self-Healing Parameters
```bash
MAX_CONSECUTIVE_FAILURES=3      # Failures before triggering recovery
FAILURE_RESET_TIME=300          # 5 minutes (currently unused)
SERVICE_RESTART_COOLDOWN=60     # 1 minute between service restarts
```

## How It Works

### Normal Operation
1. Drive detected → Enhanced mount state check
2. If already mounted → Verify ownership and symlinks → Success
3. If not mounted → Attempt mount → Success/Failure

### Failure Recovery
1. Mount attempt fails → Increment failure count
2. If failure count ≥ 3 → Trigger self-healing
3. Check service restart cooldown
4. Restart LaunchAgent service
5. Reset failure count
6. Resume normal operation

### Health Monitoring
- Logs all mount state checks
- Tracks failure patterns
- Records service restart events
- Provides diagnostic information

## Deployment

### Install Self-Healing System
```bash
cd /path/to/ct-external-drive-manager
./bin/deploy-self-healing-automount.sh
```

### Manual Deployment
```bash
# Copy enhanced script
cp bin/mount-ctexternaldisk-hibernation-safe-v3.sh ~/.local/bin/mount-ctexternaldisk-hibernation-safe.sh
chmod +x ~/.local/bin/mount-ctexternaldisk-hibernation-safe.sh

# Restart service
launchctl unload ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist
launchctl load ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist
```

## Monitoring

### Check Health Status
```bash
# View health log
tail -f ~/.local/log/ctexternaldisk-service-health.log

# Check failure count
cat ~/.local/tmp/ctdisk-failure-count

# Check service state
cat ~/.local/tmp/ctdisk-service-state
```

### Health Log Examples
```
2025-08-14 09:57:16: [HEALTH] Mount state check: mount=true, df=true, dir=true
2025-08-14 09:57:16: [HEALTH] Failure count reset
2025-08-14 10:15:23: [HEALTH] Failure count incremented to: 1
2025-08-14 10:15:45: [HEALTH] Failure threshold reached (3 >= 3)
2025-08-14 10:15:45: [HEALTH] Service issues detected, attempting self-healing...
2025-08-14 10:15:45: [HEALTH] Attempting service self-healing restart...
2025-08-14 10:15:47: [HEALTH] ✅ Service successfully restarted
```

## Troubleshooting

### If Self-Healing Doesn't Work
1. Check health log for error messages
2. Verify LaunchAgent permissions
3. Ensure passwordless sudo is configured
4. Check service restart cooldown timing

### Manual Recovery
```bash
# Force service restart
launchctl unload ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist
launchctl load ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist

# Reset failure count
echo "0" > ~/.local/tmp/ctdisk-failure-count

# Clear service state
rm -f ~/.local/tmp/ctdisk-service-state
```

### Disable Self-Healing
If needed, you can revert to the previous version:
```bash
# Restore backup
cp ~/.local/bin/mount-ctexternaldisk-hibernation-safe.sh.backup.* ~/.local/bin/mount-ctexternaldisk-hibernation-safe.sh

# Restart service
launchctl unload ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist
launchctl load ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist
```

## Benefits

### Prevents Common Issues
- ✅ LaunchAgent service getting stuck in bad states
- ✅ Repeated failed mount attempts on already-mounted drives
- ✅ Service execution context problems
- ✅ Manual intervention requirements

### Improves Reliability
- ✅ Automatic recovery from failure states
- ✅ Enhanced mount detection accuracy
- ✅ Comprehensive health monitoring
- ✅ Detailed diagnostic logging

### Reduces Maintenance
- ✅ Self-healing eliminates manual service restarts
- ✅ Health logs provide diagnostic information
- ✅ Automatic failure pattern detection
- ✅ Proactive issue resolution
