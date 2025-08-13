# Sleepwatcher Setup Guide

## Overview
This guide explains how to set up the real sleepwatcher utility for hibernation-safe external drive management.

## Installation

### 1. Install Sleepwatcher via Homebrew
```bash
brew install sleepwatcher
```

### 2. Create Sleep/Wake Scripts
The sleepwatcher utility requires `~/.sleep` and `~/.wakeup` scripts:

**~/.sleep** (executed before system sleep/hibernation):
```bash
#!/bin/bash
# Sleep script for sleepwatcher - safely eject CTExternalDisk before hibernation
/Users/ctyeh/.local/bin/ctdisk-sleepwatcher-v2.sh --sleep
```

**~/.wakeup** (executed after system wake):
```bash
#!/bin/bash
# Wake script for sleepwatcher - remount CTExternalDisk after hibernation
/Users/ctyeh/.local/bin/ctdisk-sleepwatcher-v2.sh --wake
```

### 3. Make Scripts Executable
```bash
chmod +x ~/.sleep ~/.wakeup
```

### 4. Configure Passwordless Sudo
Run the setup script to enable passwordless mounting:
```bash
./bin/setup-sudoless-mount.sh
```

### 5. Start Sleepwatcher Service
```bash
brew services start sleepwatcher
```

## Verification

### Check Service Status
```bash
brew services list | grep sleepwatcher
ps aux | grep sleepwatcher | grep -v grep
```

### Test Sleep/Wake Cycle
```bash
# Test sleep (should safely eject drive)
~/.sleep

# Test wake (should remount drive)
~/.wakeup
```

## How It Works

1. **Sleep Detection**: Real sleepwatcher daemon monitors system power events
2. **Safe Ejection**: Before hibernation, `~/.sleep` calls our script with `--sleep` argument
3. **Hibernation**: System hibernates with drive safely disconnected
4. **Wake Detection**: After wake, sleepwatcher detects system resume
5. **Auto Remount**: `~/.wakeup` calls our script with `--wake` argument to remount drive

## Previous Issue

The original implementation used a broken LaunchAgent that called our utility script without arguments, causing it to show usage and exit. The real sleepwatcher utility properly monitors power events and calls our scripts with the correct arguments.

## Files Created

- `~/.sleep` - Sleep script (calls `ctdisk-sleepwatcher-v2.sh --sleep`)
- `~/.wakeup` - Wake script (calls `ctdisk-sleepwatcher-v2.sh --wake`)
- `~/Library/LaunchAgents/homebrew.mxcl.sleepwatcher.plist` - Homebrew service plist

## Troubleshooting

### Service Not Running
```bash
brew services restart sleepwatcher
```

### Permission Issues
```bash
./bin/setup-sudoless-mount.sh
```

### Check Logs
```bash
tail -f ~/.local/log/ctexternaldisk-sleepwake-v2.log
```
