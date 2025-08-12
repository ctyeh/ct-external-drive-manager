# API Reference

This document provides a complete reference for all command-line tools and their options.

## Core Commands

### `ctdisk`

Main management interface for the CTExternalDisk auto-mount system.

#### Usage
```bash
ctdisk [command] [options]
```

#### Commands

##### `mount`
Manually mount the external drive.

```bash
ctdisk mount
```

**Exit Codes:**
- `0`: Success
- `1`: Drive not found
- `2`: Mount failed

##### `unmount`
Safely unmount the external drive.

```bash
ctdisk unmount
```

**Exit Codes:**
- `0`: Success
- `1`: Drive not mounted
- `2`: Unmount failed

##### `status`
Display current drive status and information.

```bash
ctdisk status
```

**Output:**
- Mount status
- Available space
- Device information

##### `check`
Check drive health and file system integrity.

```bash
ctdisk check
```

**Exit Codes:**
- `0`: Drive healthy
- `1`: Drive has issues
- `2`: Check failed

### `ctdisk-setup`

System setup and configuration management.

#### Usage
```bash
ctdisk-setup [command] [options]
```

#### Commands

##### `enable`
Enable the auto-mount system services.

```bash
ctdisk-setup enable
```

**Actions:**
- Loads LaunchAgent services
- Starts auto-mount monitoring
- Enables hibernation handling

##### `disable`
Disable the auto-mount system services.

```bash
ctdisk-setup disable
```

**Actions:**
- Unloads LaunchAgent services
- Stops auto-mount monitoring
- Disables hibernation handling

##### `status`
Display system service status and recent activity.

```bash
ctdisk-setup status
```

**Output:**
- Service status (running/stopped)
- Recent log entries
- System health information

##### `restart`
Restart all auto-mount services.

```bash
ctdisk-setup restart
```

**Actions:**
- Stops all services
- Reloads configurations
- Starts services

##### `logs`
Display recent log entries.

```bash
ctdisk-setup logs [lines]
```

**Parameters:**
- `lines`: Number of log lines to display (default: 20)

##### `test-boot`
Test boot-time mounting functionality.

```bash
ctdisk-setup test-boot
```

**Actions:**
- Simulates boot-time mounting
- Tests service initialization
- Validates configuration

### `ctdisk-hibernation-safe`

Hibernation-safe system management and operations.

#### Usage
```bash
ctdisk-hibernation-safe [command] [options]
```

#### Commands

##### `mount`
Mount drive using hibernation-safe methods.

```bash
ctdisk-hibernation-safe mount
```

**Features:**
- Triple mount backup methods
- Automatic ownership repair
- Symlink maintenance

##### `unmount`
Safely unmount drive for hibernation.

```bash
ctdisk-hibernation-safe unmount
```

**Features:**
- Safe ejection
- Application notification
- Clean unmount verification

##### `status`
Display hibernation-safe system status.

```bash
ctdisk-hibernation-safe status
```

**Output:**
- Mount status
- Ownership information
- Symlink status
- Available space

##### `sleep-safe`
Prepare system for hibernation (safe ejection).

```bash
ctdisk-hibernation-safe sleep-safe
```

**Actions:**
- Safely ejects external drive
- Notifies applications
- Logs hibernation preparation

##### `wake-mount`
Recover from hibernation (remount drive).

```bash
ctdisk-hibernation-safe wake-mount
```

**Actions:**
- Detects hibernation recovery
- Uses enhanced mounting methods
- Repairs ownership and symlinks

##### `test-sleep`
Test hibernation preparation.

```bash
ctdisk-hibernation-safe test-sleep
```

**Actions:**
- Simulates hibernation preparation
- Tests safe ejection
- Validates sleep handling

##### `test-wake`
Test hibernation recovery.

```bash
ctdisk-hibernation-safe test-wake
```

**Actions:**
- Simulates hibernation recovery
- Tests enhanced mounting
- Validates wake handling

##### `check-sudo`
Verify passwordless sudo configuration.

```bash
ctdisk-hibernation-safe check-sudo
```

**Output:**
- Sudo configuration status
- Permission verification
- Security validation

##### `setup-hibernation`
Setup and verify hibernation-safe system.

```bash
ctdisk-hibernation-safe setup-hibernation
```

**Actions:**
- Verifies all components
- Tests hibernation handling
- Validates configuration

## Utility Commands

### `test-hibernation-recovery.sh`

Comprehensive hibernation recovery testing framework.

#### Usage
```bash
test-hibernation-recovery.sh [options]
```

#### Options
- `--verbose`: Enable verbose output
- `--timeout=N`: Set timeout in seconds (default: 60)

#### Test Sequence
1. Initial status check
2. Simulated hibernation (unmount)
3. Wait for auto-recovery
4. Final status verification
5. Symlink validation
6. Log analysis

#### Exit Codes
- `0`: All tests passed
- `1`: Some tests failed
- `2`: Critical failure

### `fix-ctdisk-ownership.sh`

Ownership and permission repair tool.

#### Usage
```bash
fix-ctdisk-ownership.sh [options]
```

#### Options
- `--check-only`: Only check ownership, don't fix
- `--verbose`: Enable verbose output

#### Actions
1. Checks current ownership
2. Verifies write permissions
3. Repairs ownership if needed
4. Validates repair success

#### Exit Codes
- `0`: Ownership correct or fixed
- `1`: Ownership issues found
- `2`: Repair failed

### `setup-sudoless-mount.sh`

Passwordless sudo configuration tool.

#### Usage
```bash
setup-sudoless-mount.sh [options]
```

#### Options
- `--remove`: Remove passwordless sudo configuration
- `--verify`: Verify configuration only

#### Actions
1. Creates sudoers configuration
2. Sets secure permissions
3. Tests passwordless access
4. Validates security

#### Security Features
- Restricted to specific commands
- Limited to mount/unmount operations
- Secure file permissions
- User-specific configuration

## Configuration Files

### LaunchAgent Plists

#### `com.user.ctexternaldisk.automount.plist`

Main auto-mount service configuration.

**Key Settings:**
- `StartInterval`: 30 seconds
- `RunAtLoad`: true
- `KeepAlive`: false

**Program:** `mount-ctexternaldisk-hibernation-safe.sh`

#### `com.user.ctexternaldisk.bootmount.plist`

Boot-time mount service configuration.

**Key Settings:**
- `RunAtLoad`: true
- `LaunchOnlyOnce`: true

**Program:** `ctdisk-boot-mount.sh`

### Sudoers Configuration

#### `/etc/sudoers.d/ctexternaldisk-mount`

Passwordless sudo configuration for mount operations.

**Allowed Commands:**
- `diskutil mount`
- `diskutil unmount`
- `mount -t apfs`
- `umount`
- `mkdir -p /Volumes/CTExternalDisk`
- `chown ctyeh:staff /Volumes/CTExternalDisk`

## Environment Variables

### Configuration Variables

#### `CTDISK_DEVICE_NAME`
Override default device name.

```bash
export CTDISK_DEVICE_NAME="MyExternalDrive"
```

#### `CTDISK_MOUNT_POINT`
Override default mount point.

```bash
export CTDISK_MOUNT_POINT="/Volumes/MyDrive"
```

#### `CTDISK_DEBUG`
Enable debug logging.

```bash
export CTDISK_DEBUG=1
```

#### `CTDISK_LOG_DIR`
Override log directory.

```bash
export CTDISK_LOG_DIR="$HOME/logs"
```

### Runtime Variables

#### `HIBERNATION_WAIT_TIME`
Wait time after hibernation detection (seconds).

**Default:** 10
**Range:** 5-30

#### `MAX_MOUNT_RETRIES`
Maximum mount attempt retries.

**Default:** 3
**Range:** 1-10

#### `DEVICE_WAIT_TIMEOUT`
Timeout for device detection (seconds).

**Default:** 120
**Range:** 30-300

## Log Files

### Log Locations

All log files are stored in `~/.local/log/`:

#### `ctexternaldisk-mount.log`
Main auto-mount activity log.

**Content:**
- Mount/unmount operations
- Device detection events
- Error messages
- Status updates

#### `ctexternaldisk-mount-hibernation-safe.log`
Hibernation-safe mount operations log.

**Content:**
- Hibernation detection events
- Enhanced mount operations
- Ownership repair actions
- Symlink maintenance

#### `ctexternaldisk-sleepwake-v2.log`
Sleep/wake event handling log.

**Content:**
- System sleep events
- Wake detection
- Hibernation preparation
- Recovery operations

#### `ctexternaldisk-mount.error.log`
Error-specific log file.

**Content:**
- Mount failures
- Permission errors
- System errors
- Critical failures

### Log Format

```
YYYY-MM-DD HH:MM:SS: [LEVEL] Message
```

**Levels:**
- `INFO`: General information
- `WARN`: Warning messages
- `ERROR`: Error conditions
- `DEBUG`: Debug information (when enabled)

## Exit Codes

### Standard Exit Codes

- `0`: Success
- `1`: General error
- `2`: Misuse of shell command
- `3`: Permission denied
- `4`: Device not found
- `5`: Mount failed
- `6`: Unmount failed
- `7`: Configuration error
- `8`: Service error

### Script-Specific Exit Codes

#### Mount Scripts
- `10`: Device not detected
- `11`: Mount point creation failed
- `12`: All mount methods failed
- `13`: Ownership repair failed
- `14`: Symlink repair failed

#### Setup Scripts
- `20`: Service load failed
- `21`: Service unload failed
- `22`: Configuration invalid
- `23`: Permission setup failed

#### Test Scripts
- `30`: Test timeout
- `31`: Test assertion failed
- `32`: Test environment invalid

## Integration

### Shell Integration

Add to your shell configuration (`.zshrc` or `.bashrc`):

```bash
# CTExternalDisk Auto-Mount System
export PATH="$HOME/.local/bin:$PATH"

# Aliases for convenience
alias mount-ct="ctdisk mount"
alias unmount-ct="ctdisk unmount"
alias status-ct="ctdisk status"
```

### Application Integration

#### iTunes/Music App

The system automatically maintains iTunes library symlinks:

```bash
# Source location
/Volumes/CTExternalDisk/Music_Library/iTunes

# Symlink location
~/Music/iTunes
```

#### Custom Applications

To integrate with custom applications:

1. Modify the symlink maintenance function in `mount-ctexternaldisk-hibernation-safe.sh`
2. Add your application's symlink logic
3. Test with hibernation recovery

### System Integration

#### Notification Center

Future versions may include Notification Center integration for:
- Mount/unmount notifications
- Hibernation event notifications
- Error alerts

#### Spotlight Integration

The system ensures proper Spotlight indexing by:
- Maintaining correct ownership
- Preserving extended attributes
- Handling hibernation gracefully

## Troubleshooting API

### Diagnostic Commands

```bash
# System health check
ctdisk-setup status

# Hibernation system check
ctdisk-hibernation-safe setup-hibernation

# Permission check
fix-ctdisk-ownership.sh --check-only

# Service check
launchctl list | grep ctexternaldisk
```

### Debug Mode

Enable debug mode for detailed troubleshooting:

```bash
export CTDISK_DEBUG=1
ctdisk mount  # Will show detailed debug output
```

### Log Analysis

```bash
# Recent activity
tail -20 ~/.local/log/ctexternaldisk-mount.log

# Error analysis
grep ERROR ~/.local/log/ctexternaldisk-*.log

# Hibernation events
grep "HIBERNATION\|SLEEP\|WAKE" ~/.local/log/ctexternaldisk-*.log
```
