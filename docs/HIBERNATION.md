# Hibernation-Safe System Guide

The CTExternalDisk Auto-Mount System includes advanced hibernation-safe features that ensure your external drive is properly handled during sleep/wake cycles.

## Overview

The hibernation-safe system provides:

- **Safe Ejection**: Automatically ejects the drive before system hibernation
- **Automatic Recovery**: Detects hibernation wake-up and remounts the drive
- **Enhanced Mounting**: Uses multiple mounting methods for maximum reliability
- **Ownership Repair**: Ensures correct file permissions after mounting
- **Symlink Maintenance**: Repairs application symlinks after hibernation

## Architecture

### Components

1. **Sleep/Wake Handler**: `ctdisk-sleepwatcher-v2.sh`
   - Monitors system sleep/wake events
   - Safely ejects drive before hibernation
   - Triggers recovery after wake-up

2. **Hibernation-Safe Mount Script**: `mount-ctexternaldisk-hibernation-safe.sh`
   - Detects hibernation recovery scenarios
   - Uses triple mount backup methods
   - Repairs ownership and symlinks

3. **Management Interface**: `ctdisk-hibernation-safe`
   - Command-line interface for hibernation features
   - Testing and diagnostic tools
   - Manual hibernation operations

### System Flow

```
System Sleep → Safe Ejection → Hibernation
     ↓
System Wake → Hibernation Detection → Enhanced Mount → Ownership Fix → Symlink Repair
```

## Features

### 🛡️ Hibernation Recovery Detection

The system automatically detects when the system wakes from hibernation and enables enhanced recovery mode:

- **Extended Wait Times**: Allows USB devices more time to initialize
- **Device Node Tracking**: Handles device node changes (e.g., disk7s1 → disk8s1)
- **Enhanced Logging**: Records hibernation events for troubleshooting

### 🔧 Triple Mount Backup

Three different mounting methods ensure maximum reliability:

1. **diskutil mount**: Standard macOS mounting
2. **sudo diskutil mount**: Elevated diskutil mounting
3. **sudo mount**: Direct mount command with APFS support

### 👤 Automatic Ownership Repair

Every mount operation includes ownership verification and repair:

- Ensures mount point is owned by the user (not root)
- Provides full read/write permissions
- Prevents permission-related application issues

### 🔗 Symlink Maintenance

Automatically maintains application symlinks:

- iTunes library symlinks
- Custom application symlinks
- Verifies and repairs broken links

## Usage

### Basic Operations

```bash
# Check hibernation-safe system status
ctdisk-hibernation-safe status

# Manual hibernation-safe mount
ctdisk-hibernation-safe mount

# Manual hibernation-safe unmount
ctdisk-hibernation-safe unmount
```

### Hibernation Operations

```bash
# Prepare for hibernation (safe ejection)
ctdisk-hibernation-safe sleep-safe

# Recover after hibernation (remount)
ctdisk-hibernation-safe wake-mount
```

### Testing

```bash
# Test hibernation cycle
ctdisk-hibernation-safe test-sleep
ctdisk-hibernation-safe test-wake

# Complete hibernation recovery test
test-hibernation-recovery.sh
```

### Setup and Configuration

```bash
# Setup hibernation-safe system
ctdisk-hibernation-safe setup-hibernation

# Check passwordless sudo configuration
ctdisk-hibernation-safe check-sudo
```

## Configuration

### Passwordless Sudo

The hibernation-safe system requires passwordless sudo for mount operations. This is configured automatically during installation:

```bash
# Check sudo configuration
ctdisk-hibernation-safe check-sudo

# Reconfigure if needed
setup-sudoless-mount.sh
```

### Custom Device Names

If your external drive has a different name:

```bash
# Edit the hibernation-safe script
export CTDISK_DEVICE_NAME="YourDriveName"
```

### Timing Configuration

Adjust hibernation recovery timing in the script:

```bash
# Edit mount-ctexternaldisk-hibernation-safe.sh
HIBERNATION_WAIT_TIME=10  # seconds to wait after hibernation
MAX_RETRIES=5             # maximum mount attempts
```

## Monitoring

### Log Files

The hibernation-safe system maintains detailed logs:

```bash
# Main hibernation-safe mount log
tail -f ~/.local/log/ctexternaldisk-mount-hibernation-safe.log

# Sleep/wake event log
tail -f ~/.local/log/ctexternaldisk-sleepwake-v2.log

# General auto-mount log
tail -f ~/.local/log/ctexternaldisk-mount.log
```

### Status Monitoring

```bash
# Check overall system status
ctdisk-setup status

# Check hibernation-safe specific status
ctdisk-hibernation-safe status

# View recent hibernation events
grep "HIBERNATION\|SLEEP\|WAKE" ~/.local/log/ctexternaldisk-*.log
```

## Troubleshooting

### Common Issues

#### Drive Not Mounting After Hibernation

1. Check hibernation detection:
   ```bash
   grep "HIBERNATION" ~/.local/log/ctexternaldisk-mount-hibernation-safe.log
   ```

2. Test manual hibernation recovery:
   ```bash
   ctdisk-hibernation-safe wake-mount
   ```

3. Check device node changes:
   ```bash
   diskutil list | grep CTExternalDisk
   ```

#### Permission Issues After Hibernation

1. Check mount point ownership:
   ```bash
   ls -ld /Volumes/CTExternalDisk
   ```

2. Fix ownership manually:
   ```bash
   fix-ctdisk-ownership.sh
   ```

3. Test write permissions:
   ```bash
   touch /Volumes/CTExternalDisk/test.txt && rm /Volumes/CTExternalDisk/test.txt
   ```

#### Symlinks Broken After Hibernation

1. Check symlink status:
   ```bash
   ls -la ~/Music/iTunes
   ```

2. Repair symlinks manually:
   ```bash
   ctdisk-hibernation-safe mount  # This includes symlink repair
   ```

### Advanced Troubleshooting

#### Debug Mode

Enable debug logging for detailed troubleshooting:

```bash
# Edit the hibernation-safe script and add:
export CTDISK_DEBUG=1
```

#### Manual Recovery

If automatic recovery fails:

```bash
# 1. Check if device is detected
diskutil list | grep CTExternalDisk

# 2. Try manual mount methods
diskutil mount disk7s1
# or
sudo diskutil mount disk7s1
# or
sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk

# 3. Fix ownership and symlinks
fix-ctdisk-ownership.sh
ctdisk-hibernation-safe mount
```

## Best Practices

### Before Hibernation

- The system automatically handles hibernation preparation
- Manual preparation: `ctdisk-hibernation-safe sleep-safe`
- Ensure no applications are actively using the drive

### After Hibernation

- The system automatically handles recovery
- Manual recovery: `ctdisk-hibernation-safe wake-mount`
- Verify drive accessibility and permissions

### Regular Maintenance

```bash
# Weekly system check
ctdisk-setup status
test-hibernation-recovery.sh

# Monthly log cleanup
rm ~/.local/log/ctexternaldisk-*.log.old

# Quarterly configuration verification
ctdisk-hibernation-safe setup-hibernation
```

## Integration with Applications

### iTunes/Music App

The system automatically maintains iTunes library symlinks:

- Source: `/Volumes/CTExternalDisk/Music_Library/iTunes`
- Target: `~/Music/iTunes`
- Automatic repair after hibernation

### Custom Applications

To add custom symlink maintenance:

1. Edit `mount-ctexternaldisk-hibernation-safe.sh`
2. Add your symlink logic to the `verify_itunes_symlink()` function
3. Test with hibernation recovery

## Performance Considerations

### Hibernation Recovery Time

- Normal recovery: 5-15 seconds
- Enhanced recovery (after hibernation): 15-30 seconds
- Factors: USB device initialization, file system check

### System Impact

- Minimal CPU usage during normal operation
- Brief CPU spike during hibernation recovery
- No impact on system hibernation/wake speed

## Security

### Passwordless Sudo

The system uses restricted passwordless sudo:

- Limited to specific mount/unmount commands
- No general sudo access granted
- Secure sudoers configuration

### File Permissions

- Mount point owned by user (not root)
- Full read/write access for user
- Proper permission inheritance

## Future Enhancements

- Support for multiple external drives
- GUI notification system
- Advanced hibernation detection
- Cloud backup integration
- Performance monitoring
