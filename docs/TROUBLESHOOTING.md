# Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the CTExternalDisk Auto-Mount System.

## Quick Diagnostics

### System Status Check

```bash
# Check overall system status
ctdisk-setup status

# Check hibernation-safe system
ctdisk-hibernation-safe status

# Check drive status
ctdisk status
```

### Log Analysis

```bash
# View recent auto-mount activity
tail -20 ~/.local/log/ctexternaldisk-mount.log

# View hibernation-safe activity
tail -20 ~/.local/log/ctexternaldisk-mount-hibernation-safe.log

# View sleep/wake events
tail -20 ~/.local/log/ctexternaldisk-sleepwake-v2.log
```

## Common Issues

### 1. Drive Not Auto-Mounting

#### Symptoms
- External drive connected but not mounted
- No automatic mounting after connection

#### Diagnosis
```bash
# Check if services are running
ctdisk-setup status

# Check if drive is detected
diskutil list | grep CTExternalDisk

# Check recent logs
tail -10 ~/.local/log/ctexternaldisk-mount.log
```

#### Solutions

**Service Not Running:**
```bash
# Enable and start services
ctdisk-setup enable
ctdisk-setup restart
```

**Drive Name Mismatch:**
```bash
# Check actual drive name
diskutil list

# Update scripts with correct name (if different from CTExternalDisk)
# Edit the scripts in ~/.local/bin/
```

**Permission Issues:**
```bash
# Check passwordless sudo
ctdisk-hibernation-safe check-sudo

# Reconfigure if needed
setup-sudoless-mount.sh
```

### 2. Hibernation Recovery Failure

#### Symptoms
- Drive not mounting after system wake from hibernation
- Mount attempts failing after hibernation

#### Diagnosis
```bash
# Check hibernation detection
grep "HIBERNATION" ~/.local/log/ctexternaldisk-mount-hibernation-safe.log

# Check device node changes
diskutil list | grep CTExternalDisk

# Test hibernation recovery
test-hibernation-recovery.sh
```

#### Solutions

**Device Node Changed:**
```bash
# The system should handle this automatically
# Manual recovery:
ctdisk-hibernation-safe wake-mount
```

**Mount Methods Failing:**
```bash
# Try manual mount methods
diskutil mount disk7s1
sudo diskutil mount disk7s1
sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk
```

**USB Device Not Ready:**
```bash
# Wait longer and retry
sleep 30
ctdisk-hibernation-safe wake-mount
```

### 3. Permission/Ownership Issues

#### Symptoms
- Cannot write to external drive
- "Permission denied" errors
- Applications cannot access drive

#### Diagnosis
```bash
# Check mount point ownership
ls -ld /Volumes/CTExternalDisk

# Check current user
whoami

# Test write permissions
touch /Volumes/CTExternalDisk/test.txt && rm /Volumes/CTExternalDisk/test.txt
```

#### Solutions

**Wrong Ownership:**
```bash
# Automatic fix
fix-ctdisk-ownership.sh

# Manual fix
sudo chown $(whoami):staff /Volumes/CTExternalDisk
```

**Permission Issues:**
```bash
# Check and fix permissions
sudo chmod 755 /Volumes/CTExternalDisk
```

### 4. Symlink Issues

#### Symptoms
- iTunes library not accessible
- Broken symlinks after hibernation
- Applications cannot find files

#### Diagnosis
```bash
# Check iTunes symlink
ls -la ~/Music/iTunes

# Check symlink target
readlink ~/Music/iTunes

# Verify target exists
ls -la /Volumes/CTExternalDisk/Music_Library/iTunes
```

#### Solutions

**Broken Symlink:**
```bash
# Automatic repair
ctdisk-hibernation-safe mount

# Manual repair
rm -f ~/Music/iTunes
ln -sf /Volumes/CTExternalDisk/Music_Library/iTunes ~/Music/iTunes
```

### 5. Service Loading Issues

#### Symptoms
- Services not starting automatically
- LaunchAgent errors in Console

#### Diagnosis
```bash
# Check service status
launchctl list | grep ctexternaldisk

# Check plist syntax
plutil -lint ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist

# Check Console for errors
log show --predicate 'subsystem == "com.apple.launchd"' --last 1h | grep ctexternaldisk
```

#### Solutions

**Plist Syntax Errors:**
```bash
# Reinstall LaunchAgents
ctdisk-setup disable
ctdisk-setup enable
```

**Path Issues:**
```bash
# Update paths in plist files
sed -i '' "s|/Users/ctyeh|$HOME|g" ~/Library/LaunchAgents/com.user.ctexternaldisk.*.plist
```

**Service Conflicts:**
```bash
# Restart services
ctdisk-setup restart
```

## Advanced Troubleshooting

### Debug Mode

Enable detailed logging for troubleshooting:

```bash
# Edit scripts and add debug flag
export CTDISK_DEBUG=1

# Or modify the scripts directly
# Add 'set -x' at the beginning of scripts for verbose output
```

### Manual Testing

#### Test Individual Components

```bash
# Test basic mount script
/Users/$(whoami)/.local/bin/mount-ctexternaldisk.sh

# Test hibernation-safe script
/Users/$(whoami)/.local/bin/mount-ctexternaldisk-hibernation-safe.sh

# Test boot mount script
/Users/$(whoami)/.local/bin/ctdisk-boot-mount.sh
```

#### Test Mount Methods

```bash
# Method 1: diskutil
diskutil mount disk7s1

# Method 2: sudo diskutil
sudo diskutil mount disk7s1

# Method 3: sudo mount
sudo mkdir -p /Volumes/CTExternalDisk
sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk
```

### System Information

#### Collect System Information

```bash
# macOS version
sw_vers

# Disk information
diskutil list

# Mount information
mount | grep CTExternalDisk

# Service information
launchctl list | grep ctexternaldisk

# Log file sizes
ls -lh ~/.local/log/ctexternaldisk*
```

#### Environment Check

```bash
# Check PATH
echo $PATH | grep -o ~/.local/bin

# Check shell
echo $SHELL

# Check user
whoami
id
```

## Error Messages

### Common Error Messages and Solutions

#### "Volume on disk7s1 failed to mount"

**Cause:** Drive may be corrupted or not properly formatted

**Solution:**
```bash
# Check disk health
diskutil verifyVolume /dev/disk7s1

# Repair if needed
diskutil repairVolume /dev/disk7s1

# Try alternative mount method
sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk
```

#### "Operation not permitted"

**Cause:** Insufficient permissions or SIP restrictions

**Solution:**
```bash
# Check passwordless sudo
ctdisk-hibernation-safe check-sudo

# Reconfigure sudo
setup-sudoless-mount.sh

# Check SIP status
csrutil status
```

#### "Device not found"

**Cause:** Drive disconnected or device node changed

**Solution:**
```bash
# Check if drive is connected
diskutil list | grep CTExternalDisk

# Check USB connections
system_profiler SPUSBDataType | grep -A 5 CTExternalDisk

# Reconnect drive if necessary
```

#### "Command not found"

**Cause:** Scripts not in PATH or not executable

**Solution:**
```bash
# Check PATH
echo $PATH | grep ~/.local/bin

# Add to PATH if missing
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Make scripts executable
chmod +x ~/.local/bin/ctdisk*
```

## Performance Issues

### Slow Mounting

#### Symptoms
- Long delays before drive mounts
- Timeouts during mount operations

#### Solutions
```bash
# Increase timeout values in scripts
# Edit mount-ctexternaldisk-hibernation-safe.sh
HIBERNATION_WAIT_TIME=20  # Increase from 10

# Check USB port/cable
# Try different USB port or cable

# Check drive health
diskutil verifyVolume /Volumes/CTExternalDisk
```

### High CPU Usage

#### Symptoms
- High CPU usage from mount scripts
- System slowdown during mounting

#### Solutions
```bash
# Check service intervals
# Edit LaunchAgent plist files to increase intervals

# Reduce logging verbosity
# Comment out debug logging in scripts

# Check for infinite loops in logs
tail -f ~/.local/log/ctexternaldisk-mount.log
```

## Recovery Procedures

### Complete System Reset

If all else fails, perform a complete reset:

```bash
# 1. Disable all services
ctdisk-setup disable

# 2. Remove all components
rm -rf ~/.local/bin/ctdisk*
rm -rf ~/.local/bin/mount-ctexternaldisk*
rm -rf ~/.local/bin/test-hibernation-recovery.sh
rm -rf ~/.local/bin/fix-ctdisk-ownership.sh
rm ~/Library/LaunchAgents/com.user.ctexternaldisk.*.plist
sudo rm -f /etc/sudoers.d/ctexternaldisk-mount

# 3. Clean logs
rm -rf ~/.local/log/ctexternaldisk*

# 4. Reinstall
./install.sh
ctdisk-setup enable
```

### Emergency Manual Mount

If automatic mounting fails completely:

```bash
# 1. Find the device
diskutil list | grep CTExternalDisk

# 2. Create mount point
sudo mkdir -p /Volumes/CTExternalDisk

# 3. Mount manually
sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk

# 4. Fix ownership
sudo chown $(whoami):staff /Volumes/CTExternalDisk

# 5. Create symlinks
ln -sf /Volumes/CTExternalDisk/Music_Library/iTunes ~/Music/iTunes
```

## Getting Help

### Before Seeking Help

1. Check this troubleshooting guide
2. Review the logs for error messages
3. Try the diagnostic commands
4. Attempt the suggested solutions

### Information to Provide

When seeking help, provide:

```bash
# System information
sw_vers
echo "Shell: $SHELL"
echo "User: $(whoami)"

# Service status
ctdisk-setup status

# Recent logs
echo "=== Recent Mount Log ==="
tail -20 ~/.local/log/ctexternaldisk-mount.log

echo "=== Recent Hibernation Log ==="
tail -20 ~/.local/log/ctexternaldisk-mount-hibernation-safe.log

# Disk information
diskutil list | grep -A 5 -B 5 CTExternalDisk
```

### Support Channels

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and community support
- **Documentation**: Check all documentation files first

## Prevention

### Regular Maintenance

```bash
# Weekly checks
ctdisk-setup status
test-hibernation-recovery.sh

# Monthly log rotation
mv ~/.local/log/ctexternaldisk-mount.log ~/.local/log/ctexternaldisk-mount.log.old

# Quarterly system verification
ctdisk-hibernation-safe setup-hibernation
```

### Best Practices

1. **Keep system updated**: Regularly update macOS and the auto-mount system
2. **Monitor logs**: Occasionally check logs for errors
3. **Test hibernation**: Periodically test hibernation recovery
4. **Backup configuration**: Keep a backup of your configuration files
5. **Document changes**: Note any customizations you make
