# Installation Guide

This guide provides detailed instructions for installing the CTExternalDisk Auto-Mount System on macOS.

## Prerequisites

- **macOS**: 10.15 (Catalina) or later
- **Bash**: 4.0 or later (included with macOS)
- **Administrator Access**: Required for initial setup only
- **External Drive**: APFS or HFS+ formatted external drive named "CTExternalDisk"

## Quick Installation

### 1. Download and Install

```bash
# Clone the repository
git clone https://github.com/yourusername/ctexternaldisk-automount.git
cd ctexternaldisk-automount

# Run the installer
./install.sh
```

### 2. Enable the System

```bash
# Enable auto-mount services
ctdisk-setup enable

# Verify installation
ctdisk-setup status
```

## Manual Installation

If you prefer to install manually or need to customize the installation:

### 1. Create Directories

```bash
mkdir -p ~/.local/bin
mkdir -p ~/.local/log
mkdir -p ~/.local/tmp
```

### 2. Copy Scripts

```bash
# Copy all scripts to ~/.local/bin
cp bin/* ~/.local/bin/
chmod +x ~/.local/bin/ctdisk*
chmod +x ~/.local/bin/mount-ctexternaldisk*
chmod +x ~/.local/bin/test-hibernation-recovery.sh
chmod +x ~/.local/bin/fix-ctdisk-ownership.sh
chmod +x ~/.local/bin/setup-sudoless-mount.sh
```

### 3. Install LaunchAgents

```bash
# Copy LaunchAgent configurations
cp config/*.plist ~/Library/LaunchAgents/

# Update paths in the plist files (replace /Users/ctyeh with your home directory)
sed -i '' "s|/Users/ctyeh|$HOME|g" ~/Library/LaunchAgents/com.user.ctexternaldisk.*.plist
```

### 4. Setup Passwordless Sudo

```bash
# Run the sudo setup script
setup-sudoless-mount.sh
```

### 5. Add to PATH

Add the following to your shell configuration file (`~/.zshrc` or `~/.bashrc`):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload your shell:

```bash
source ~/.zshrc  # or ~/.bashrc
```

## Post-Installation Setup

### 1. Enable Services

```bash
# Enable the auto-mount system
ctdisk-setup enable

# Check service status
ctdisk-setup status
```

### 2. Test the System

```bash
# Test basic functionality
ctdisk status

# Test hibernation recovery
test-hibernation-recovery.sh

# Test ownership repair
fix-ctdisk-ownership.sh
```

### 3. Configure Your Drive

If your external drive has a different name than "CTExternalDisk", you'll need to update the scripts:

```bash
# Edit the device name in the scripts
export CTDISK_DEVICE_NAME="YourDriveName"
```

## Verification

After installation, verify that everything is working:

### 1. Check Commands

```bash
# These commands should be available
ctdisk --help
ctdisk-setup --help
ctdisk-hibernation-safe --help
```

### 2. Check Services

```bash
# Services should be loaded
launchctl list | grep ctexternaldisk
```

### 3. Check Logs

```bash
# Log files should be created
ls -la ~/.local/log/ctexternaldisk*
```

## Troubleshooting

### Command Not Found

If you get "command not found" errors:

1. Check if `~/.local/bin` is in your PATH:
   ```bash
   echo $PATH | grep -o ~/.local/bin
   ```

2. If not, add it to your shell configuration:
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

### Permission Denied

If you get permission errors:

1. Check script permissions:
   ```bash
   ls -la ~/.local/bin/ctdisk*
   ```

2. Make scripts executable:
   ```bash
   chmod +x ~/.local/bin/ctdisk*
   ```

### Services Not Loading

If LaunchAgent services don't load:

1. Check plist syntax:
   ```bash
   plutil -lint ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist
   ```

2. Load services manually:
   ```bash
   launchctl load ~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist
   ```

## Uninstallation

To remove the system:

```bash
# Disable services
ctdisk-setup disable

# Remove scripts
rm -rf ~/.local/bin/ctdisk*
rm -rf ~/.local/bin/mount-ctexternaldisk*
rm -rf ~/.local/bin/test-hibernation-recovery.sh
rm -rf ~/.local/bin/fix-ctdisk-ownership.sh
rm -rf ~/.local/bin/setup-sudoless-mount.sh

# Remove LaunchAgents
rm ~/Library/LaunchAgents/com.user.ctexternaldisk.*.plist

# Remove logs (optional)
rm -rf ~/.local/log/ctexternaldisk*

# Remove sudoers configuration
sudo rm -f /etc/sudoers.d/ctexternaldisk-mount
```

## Next Steps

After successful installation:

1. Read the [User Guide](USER_GUIDE.md) for detailed usage instructions
2. Check the [Hibernation Guide](HIBERNATION.md) for hibernation-safe features
3. Review [Troubleshooting](TROUBLESHOOTING.md) for common issues

## Support

If you encounter issues during installation:

1. Check the [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Review the installation logs
3. Open an issue on GitHub with detailed error messages
