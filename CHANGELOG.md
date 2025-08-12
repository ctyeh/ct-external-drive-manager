# Changelog

All notable changes to CT External Drive Manager will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial open source release
- Comprehensive documentation
- Test framework
- Installation script

## [2.0.0] - 2025-08-12

### Added
- **Hibernation-Safe System v2.0**: Complete hibernation recovery solution
- **Hibernation Recovery Detection**: Automatic detection of hibernation wake-up scenarios
- **Triple Mount Backup**: Three different mounting methods for maximum reliability
- **Automatic Ownership Repair**: Ensures correct user ownership after every mount
- **Enhanced Logging**: Dedicated hibernation-safe mounting logs
- **Hibernation Recovery Testing**: `test-hibernation-recovery.sh` comprehensive testing tool
- **Ownership Repair Tool**: `fix-ctdisk-ownership.sh` dedicated ownership management
- **Smart Waiting Strategy**: Extended wait times after hibernation for USB device readiness
- **Service Integration**: Main service now uses hibernation-safe mounting script

### Enhanced
- **Mount Reliability**: Multiple fallback mounting methods
- **Error Recovery**: Advanced error handling and automatic retry logic
- **Symlink Maintenance**: Automatic repair of application symlinks after hibernation
- **Troubleshooting**: Enhanced diagnostic tools and recovery procedures

### Fixed
- **Hibernation Recovery**: Resolved auto-mount failures after system hibernation
- **Ownership Issues**: Fixed mount point ownership problems (root vs user)
- **Device Node Changes**: Handles device node changes after hibernation
- **Permission Problems**: Resolved write permission issues on external drive

## [1.1.0] - 2025-08-11

### Added
- **Hibernation-Safe System**: Complete hibernation handling with safe ejection and recovery
- **Passwordless Sudo**: Secure sudoers configuration for automated operations
- **Sleep/Wake Handler**: `ctdisk-sleepwatcher-v2.sh` for hibernation event handling
- **Hibernation Management**: `ctdisk-hibernation-safe` command-line interface
- **Sudo Setup Tool**: `setup-sudoless-mount.sh` for automated sudo configuration
- **Hibernation Logging**: Dedicated logs for hibernation/wake events
- **Device Node Tracking**: Handles device node changes after hibernation
- **iTunes Symlink Maintenance**: Automatic repair of iTunes library symlinks
- **Testing Suite**: Hibernation cycle simulation and testing tools
- **Security Features**: Restricted sudoers rules for mount operations only

### Enhanced
- **Automation**: Complete automation of hibernation handling
- **Reliability**: No manual intervention required for hibernation cycles
- **Safety**: Safe ejection before hibernation prevents file system corruption
- **Recovery**: Automatic remounting after hibernation wake-up

## [1.0.0] - 2025-08-09

### Added
- **Dual Service Architecture**: Main service + Boot service for complete coverage
- **Enhanced Auto-Mount**: Intelligent mounting with system state awareness
- **Boot-Time Mounting**: Immediate mounting after system login
- **System State Detection**: Recognizes restart vs hibernation scenarios
- **Advanced Logging**: Detailed system state and operation logging
- **Service Management**: `ctdisk-setup` for service control and monitoring
- **Testing Tools**: Boot-time testing and service restart capabilities
- **Error Recovery**: Robust error handling and retry mechanisms
- **Device Tracking**: Dynamic device node detection and tracking
- **Symlink Verification**: Automatic symlink validation and repair

### Enhanced
- **Hibernation Support**: Perfect support for hibernation wake-up scenarios
- **Restart Support**: Seamless operation after system restarts
- **Reliability**: Multiple fallback mechanisms for mount operations
- **Monitoring**: Comprehensive status reporting and health checks

## [0.9.0] - 2025-08-08

### Added
- **Basic Auto-Mount System**: Initial automatic mounting functionality
- **LaunchAgent Integration**: Native macOS service integration
- **Command-Line Interface**: `ctdisk` management tool
- **Logging System**: Basic operation logging for troubleshooting
- **Symlink Management**: iTunes library symlink creation and maintenance
- **Quick Aliases**: Convenient shortcuts for common operations
- **Status Monitoring**: Drive status and space reporting
- **Error Handling**: Basic error detection and reporting

### Features
- Automatic mounting when external drive is connected
- Manual mount/unmount operations
- Drive status and health checking
- iTunes library symlink management
- Basic logging and troubleshooting support

## [0.1.0] - 2025-08-07

### Added
- **Initial Implementation**: Basic external drive mounting scripts
- **Manual Operations**: Simple mount/unmount functionality
- **Drive Detection**: Basic external drive detection
- **Symlink Creation**: Manual iTunes library symlink setup

### Features
- Manual mounting of CTExternalDisk
- Basic drive detection and mounting
- Simple iTunes library integration
- Manual operation only

---

## Version History Summary

- **v2.0.0**: Hibernation-Safe System with complete automation and ownership management
- **v1.1.0**: Hibernation handling with passwordless sudo and sleep/wake events
- **v1.0.0**: Dual service architecture with boot-time support and enhanced reliability
- **v0.9.0**: Basic auto-mount system with LaunchAgent integration
- **v0.1.0**: Initial manual mounting implementation

## Migration Notes

### Upgrading to v2.0.0
- Automatic ownership repair is now included in all mount operations
- New hibernation recovery testing tools available
- Enhanced logging provides more detailed troubleshooting information
- All existing configurations remain compatible

### Upgrading to v1.1.0
- Passwordless sudo configuration is now required for full automation
- Run `setup-sudoless-mount.sh` after upgrading
- Hibernation handling is now completely automated
- New hibernation-specific commands available

### Upgrading to v1.0.0
- Dual service architecture provides better reliability
- Boot service handles system restart scenarios
- Enhanced logging provides better troubleshooting
- All previous functionality remains available

## Support

For support with any version:
- Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- Review the [User Guide](docs/USER_GUIDE.md) for your version
- Open an issue on GitHub with version information
