#!/bin/bash

# CTExternalDisk Auto-Mount System Installer
# Installs the hibernation-safe auto-mount system for external drives on macOS

set -e

# Configuration
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/Library/LaunchAgents"
LOG_DIR="$HOME/.local/log"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This installer is designed for macOS only."
        exit 1
    fi
    log_success "macOS detected"
}

# Check if running with appropriate permissions
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Please do not run this installer as root/sudo."
        log_info "The installer will prompt for sudo when needed."
        exit 1
    fi
    log_success "Running with user permissions"
}

# Create necessary directories
create_directories() {
    log_info "Creating necessary directories..."
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOG_DIR"
    mkdir -p "$HOME/.local/tmp"
    
    log_success "Directories created"
}

# Install scripts
install_scripts() {
    log_info "Installing scripts to $INSTALL_DIR..."
    
    # Copy all scripts from bin directory
    for script in "$PROJECT_DIR/bin"/*; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script")
            cp "$script" "$INSTALL_DIR/"
            chmod +x "$INSTALL_DIR/$script_name"
            log_info "Installed: $script_name"
        fi
    done
    
    log_success "All scripts installed"
}

# Install LaunchAgent configurations
install_launchagents() {
    log_info "Installing LaunchAgent configurations..."
    
    # Update paths in LaunchAgent files
    for plist in "$PROJECT_DIR/config"/*.plist; do
        if [[ -f "$plist" ]]; then
            plist_name=$(basename "$plist")
            
            # Replace placeholder paths with actual paths
            sed "s|/Users/ctyeh/.local/bin|$INSTALL_DIR|g" "$plist" > "$CONFIG_DIR/$plist_name"
            sed -i '' "s|/Users/ctyeh/.local/log|$LOG_DIR|g" "$CONFIG_DIR/$plist_name"
            sed -i '' "s|/Users/ctyeh|$HOME|g" "$CONFIG_DIR/$plist_name"
            
            log_info "Installed: $plist_name"
        fi
    done
    
    log_success "LaunchAgent configurations installed"
}

# Setup passwordless sudo
setup_passwordless_sudo() {
    log_info "Setting up passwordless sudo for mount operations..."
    
    if [[ -f "$INSTALL_DIR/setup-sudoless-mount.sh" ]]; then
        "$INSTALL_DIR/setup-sudoless-mount.sh"
        log_success "Passwordless sudo configured"
    else
        log_warning "setup-sudoless-mount.sh not found, skipping passwordless sudo setup"
        log_info "You can run it manually later: setup-sudoless-mount.sh"
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    # Check if main commands are available
    local commands=("ctdisk" "ctdisk-setup" "ctdisk-hibernation-safe")
    
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            log_success "$cmd is available"
        else
            log_error "$cmd is not available in PATH"
            log_info "You may need to add $INSTALL_DIR to your PATH"
        fi
    done
    
    # Check LaunchAgent files
    for plist in "$CONFIG_DIR"/com.user.ctexternaldisk.*.plist; do
        if [[ -f "$plist" ]]; then
            log_success "LaunchAgent installed: $(basename "$plist")"
        fi
    done
}

# Add to PATH if needed
setup_path() {
    local shell_rc=""
    
    # Determine shell configuration file
    if [[ "$SHELL" == */zsh ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == */bash ]]; then
        shell_rc="$HOME/.bashrc"
    fi
    
    if [[ -n "$shell_rc" ]]; then
        # Check if PATH already includes our install directory
        if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
            log_info "Adding $INSTALL_DIR to PATH in $shell_rc"
            echo "" >> "$shell_rc"
            echo "# CTExternalDisk Auto-Mount System" >> "$shell_rc"
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$shell_rc"
            log_success "PATH updated in $shell_rc"
            log_info "Please restart your terminal or run: source $shell_rc"
        else
            log_success "PATH already includes $INSTALL_DIR"
        fi
    fi
}

# Main installation function
main() {
    echo "🚀 CTExternalDisk Auto-Mount System Installer"
    echo "=============================================="
    echo ""
    
    check_macos
    check_permissions
    
    log_info "Starting installation..."
    echo ""
    
    create_directories
    install_scripts
    install_launchagents
    setup_passwordless_sudo
    setup_path
    verify_installation
    
    echo ""
    echo "🎉 Installation completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc (or ~/.bashrc)"
    echo "2. Enable the auto-mount system: ctdisk-setup enable"
    echo "3. Check system status: ctdisk-setup status"
    echo "4. Test hibernation recovery: test-hibernation-recovery.sh"
    echo ""
    echo "For more information, see the documentation in the docs/ directory."
    echo ""
    echo "Happy auto-mounting! 🎯"
}

# Run main function
main "$@"
