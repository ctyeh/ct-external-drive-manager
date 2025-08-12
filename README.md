# CT External Drive Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-10.15+-blue.svg)](https://www.apple.com/macos/)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

**Smart external drive management for macOS by CT**

A comprehensive, hibernation-safe auto-mount system for external drives on macOS. This system provides fully automated mounting, hibernation handling, ownership management, and seamless integration with macOS services.

## 🌟 Features

### 🛡️ Hibernation-Safe Auto-Mount System v2.0
- **✅ Automatic Hibernation Handling**: Safe ejection before sleep, automatic remount after wake
- **✅ Hibernation Recovery Detection**: Intelligent detection of hibernation wake-up scenarios
- **✅ Triple Mount Backup**: Three different mounting methods for maximum reliability
- **✅ Automatic Ownership Repair**: Ensures correct user ownership after every mount
- **✅ Passwordless Operation**: Secure sudoers configuration for fully automated operation
- **✅ Smart Waiting Strategy**: Extended wait times after hibernation for USB device readiness
- **✅ Automatic Symlink Repair**: Maintains iTunes and other application symlinks
- **✅ Enhanced Logging**: Comprehensive logging for troubleshooting and monitoring

### 🚀 System Architecture
- **Dual Service Design**: Main service + Boot service for complete coverage
- **LaunchAgent Integration**: Native macOS service integration
- **Device Node Tracking**: Handles device node changes after hibernation
- **Conflict Prevention**: Lock file mechanism prevents multiple instances
- **Error Recovery**: Multiple fallback methods and automatic retry logic

### 🔧 Management Tools
- **Complete CLI Interface**: Full command-line management and monitoring
- **Testing Framework**: Comprehensive hibernation recovery testing
- **Diagnostic Tools**: Advanced troubleshooting and system verification
- **Emergency Procedures**: Manual recovery methods for extreme situations

## 📋 Requirements

- **macOS**: 10.15 (Catalina) or later
- **Bash**: 4.0 or later (included with macOS)
- **Administrator Access**: Required for initial setup only
- **External Drive**: APFS or HFS+ formatted external drive

## 🚀 Quick Start

### 1. Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/ct-external-drive-manager.git
cd ct-external-drive-manager

# Run the installation script
./install.sh

# Enable the auto-mount system
ctdisk-setup enable
```

### 2. Basic Usage

```bash
# Check system status
ctdisk-setup status

# Manual mount/unmount
ctdisk mount
ctdisk unmount

# Test hibernation recovery
test-hibernation-recovery.sh

# Fix ownership issues
fix-ctdisk-ownership.sh
```

### 3. Hibernation-Safe Operations

```bash
# Setup hibernation-safe system
ctdisk-hibernation-safe setup-hibernation

# Test hibernation cycle
ctdisk-hibernation-safe test-sleep
ctdisk-hibernation-safe test-wake

# Manual hibernation operations
ctdisk-hibernation-safe sleep-safe    # Before hibernation
ctdisk-hibernation-safe wake-mount    # After hibernation
```

## 📖 Documentation

- **[Installation Guide](docs/INSTALLATION.md)**: Detailed installation instructions
- **[User Guide](docs/USER_GUIDE.md)**: Complete usage documentation
- **[Hibernation Guide](docs/HIBERNATION.md)**: Hibernation-safe system documentation
- **[Troubleshooting](docs/TROUBLESHOOTING.md)**: Common issues and solutions
- **[API Reference](docs/API.md)**: Command-line interface documentation

## 🛠️ Architecture

### Core Components

1. **Auto-Mount Scripts**
   - `mount-ctexternaldisk.sh`: Original auto-mount script
   - `mount-ctexternaldisk-hibernation-safe.sh`: Enhanced hibernation-safe script
   - `ctdisk-boot-mount.sh`: Boot-time mounting script

2. **Hibernation-Safe System**
   - `ctdisk-sleepwatcher-v2.sh`: Sleep/wake event handler
   - `ctdisk-hibernation-safe`: Management interface
   - Passwordless sudo configuration

3. **Management Tools**
   - `ctdisk`: Main management interface
   - `ctdisk-setup`: System setup and configuration
   - `test-hibernation-recovery.sh`: Testing framework
   - `fix-ctdisk-ownership.sh`: Ownership repair tool

4. **LaunchAgent Services**
   - Main auto-mount service (30-second intervals)
   - Boot-time mount service
   - System integration and monitoring

### System Flow

```
System Boot/Wake → Device Detection → Mount Attempt → Ownership Fix → Symlink Repair → Monitoring
                                   ↓
                            Hibernation Detection → Enhanced Recovery Mode
```

## 🧪 Testing

### Automated Testing

```bash
# Run all tests
./tests/run_tests.sh

# Test hibernation recovery
test-hibernation-recovery.sh

# Test ownership repair
./tests/test_ownership.sh

# Test service integration
./tests/test_services.sh
```

### Manual Testing

```bash
# Test mount/unmount cycle
ctdisk unmount && sleep 5 && ctdisk mount

# Test hibernation simulation
diskutil unmount /Volumes/CTExternalDisk
# Wait for auto-recovery...

# Verify system status
ctdisk-setup status
```

## 🔧 Configuration

### Customization

The system can be customized by editing configuration files:

- **Device Name**: Modify `DEVICE_NAME` in scripts
- **Mount Point**: Change `MOUNT_POINT` variable
- **Retry Intervals**: Adjust timing in LaunchAgent plists
- **Log Levels**: Configure logging verbosity

### Advanced Configuration

```bash
# Custom device name
export CTDISK_DEVICE_NAME="MyExternalDrive"

# Custom mount point
export CTDISK_MOUNT_POINT="/Volumes/MyDrive"

# Enable debug logging
export CTDISK_DEBUG=1
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Fork and clone the repository
git clone https://github.com/yourusername/ct-external-drive-manager.git
cd ct-external-drive-manager

# Install development dependencies
./dev/setup.sh

# Run tests
./tests/run_tests.sh

# Create a feature branch
git checkout -b feature/your-feature-name
```

### Code Style

- Follow shell scripting best practices
- Use meaningful variable names
- Include comprehensive error handling
- Add logging for debugging
- Write tests for new features

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ by CT for the macOS community
- Inspired by the need for reliable external drive management
- Thanks to all contributors and testers

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/ct-external-drive-manager/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/ct-external-drive-manager/discussions)
- **Documentation**: [Wiki](https://github.com/yourusername/ct-external-drive-manager/wiki)

## 🗺️ Roadmap

- [ ] GUI application for easier management
- [ ] Support for multiple external drives
- [ ] Integration with Time Machine
- [ ] Cloud backup integration
- [ ] Advanced notification system
- [ ] Performance monitoring dashboard

---

**CT External Drive Manager - Smart external drive management for macOS** ✨
