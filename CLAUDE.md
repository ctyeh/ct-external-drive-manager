# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CT External Drive Manager is a hibernation-safe auto-mount system for external drives on macOS. It provides automated mounting, hibernation handling, ownership management, and seamless integration with macOS services.

## Key Development Commands

### Installation and Setup
```bash
# Install the system
./install.sh

# Enable/disable the auto-mount system
ctdisk-setup enable
ctdisk-setup disable
ctdisk-setup status
```

### Testing
```bash
# Run all tests
./tests/run_tests.sh

# Test hibernation recovery
./bin/test-hibernation-recovery.sh

# Test ownership repair
./tests/test_ownership.sh

# Verify project structure
./verify-project.sh
```

### Manual Operations
```bash
# Mount/unmount the external disk
ctdisk mount
ctdisk unmount
ctdisk status
ctdisk check

# Fix ownership issues
./bin/fix-ctdisk-ownership.sh

# Hibernation-safe operations
ctdisk-hibernation-safe setup-hibernation
ctdisk-hibernation-safe test-sleep
ctdisk-hibernation-safe test-wake
```

## Architecture

### Core Components Structure

1. **Auto-Mount System**: Dual LaunchAgent services (main + boot) that monitor and mount the external drive
   - Main service runs every 30 seconds via `com.user.ctexternaldisk.automount.plist`
   - Boot service runs at startup via `com.user.ctexternaldisk.bootmount.plist`

2. **Hibernation-Safe Implementation**: Uses sleepwatcher to handle sleep/wake events
   - `ctdisk-sleepwatcher-v2.sh` manages sleep/wake transitions
   - Safe ejection before sleep, automatic remount after wake
   - Triple mount backup methods for reliability

3. **Device Management**: Handles device node changes and ownership
   - Tracks device by UUID: `3E314969-A8AD-49EA-8743-F773357E61AB`
   - Primary device node: `/dev/disk7s1`
   - Mount point: `/Volumes/CTExternalDisk`

### Key Script Responsibilities

- `bin/ctdisk`: Main user interface for manual operations
- `bin/ctdisk-setup`: System configuration and LaunchAgent management
- `bin/mount-ctexternaldisk-hibernation-safe.sh`: Core mounting logic with auto-detection and hibernation support
- `bin/mount-ctexternaldisk-hibernation-safe-v3.sh`: Latest version with self-healing and enhanced auto-detection
- `bin/ctdisk-hibernation-safe`: Management interface for hibernation features
- `bin/fix-ctdisk-ownership.sh`: Repairs ownership and permissions

### System Flow

1. **Normal Operation**: LaunchAgent → Device Detection → Mount Attempt → Ownership Fix → Symlink Repair
2. **Hibernation Flow**: Sleep Event → Safe Eject → Wake Event → Enhanced Recovery → Mount with Extended Retry

## Critical Implementation Details

### Device Configuration
The system is configured for a specific external disk. To modify for different devices:
- Update `DISK_UUID` in all scripts
- Update `DEVICE_NODE` to match the actual device
- Modify `MOUNT_POINT` if needed

### Logging
- Main logs: `~/.local/log/ctexternaldisk-*.log`
- Hibernation logs: `~/.local/log/ctdisk-hibernation.log`
- Use `tail -f ~/.local/log/ctexternaldisk-mount.log` to monitor

### Error Handling
- Lock file mechanism prevents multiple mount attempts: `/tmp/ctexternaldisk.lock`
- Extended wait times after hibernation (up to 60 seconds)
- Multiple fallback mount methods (mount, diskutil, mount_apfs)

### Permissions
- Requires passwordless sudo for mount operations
- Setup script configures sudoers: `bin/setup-sudoless-mount.sh`
- LaunchAgents run in user context, not root

## Common Development Tasks

### Adding New Features
1. Create feature in appropriate bin/ script
2. Update ctdisk or ctdisk-setup interface if user-facing
3. Add tests in tests/ directory
4. Update documentation in docs/
5. Run `./verify-project.sh` to ensure consistency

### Debugging Issues
1. Check logs in `~/.local/log/`
2. Verify LaunchAgent status: `launchctl list | grep ctexternaldisk`
3. Test manual mount: `sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk`
4. Check device presence: `diskutil list`

### Modifying LaunchAgents
- Edit plist files in config/
- Reload with: `launchctl unload -w ~/Library/LaunchAgents/com.user.ctexternaldisk.*.plist`
- Then: `launchctl load -w ~/Library/LaunchAgents/com.user.ctexternaldisk.*.plist`