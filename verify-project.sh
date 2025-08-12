#!/bin/bash

# CTExternalDisk Auto-Mount System - Project Verification
# Verifies that all project files are present and properly configured

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_CHECKS++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Check if file exists
check_file() {
    local file="$1"
    local description="$2"
    
    ((TOTAL_CHECKS++))
    
    if [[ -f "$PROJECT_DIR/$file" ]]; then
        log_success "$description"
        return 0
    else
        log_error "$description (missing: $file)"
        return 1
    fi
}

# Check if directory exists
check_directory() {
    local dir="$1"
    local description="$2"
    
    ((TOTAL_CHECKS++))
    
    if [[ -d "$PROJECT_DIR/$dir" ]]; then
        log_success "$description"
        return 0
    else
        log_error "$description (missing: $dir)"
        return 1
    fi
}

# Check if script is executable
check_executable() {
    local script="$1"
    local description="$2"
    
    ((TOTAL_CHECKS++))
    
    if [[ -x "$PROJECT_DIR/$script" ]]; then
        log_success "$description"
        return 0
    else
        log_error "$description (not executable: $script)"
        return 1
    fi
}

# Main verification function
main() {
    echo "🔍 CTExternalDisk Auto-Mount System - Project Verification"
    echo "=========================================================="
    echo ""
    
    log_info "Verifying project structure..."
    echo ""
    
    # Check directories
    log_info "Checking directories..."
    check_directory "bin" "Binary directory exists"
    check_directory "docs" "Documentation directory exists"
    check_directory "config" "Configuration directory exists"
    check_directory "tests" "Tests directory exists"
    check_directory "examples" "Examples directory exists"
    echo ""
    
    # Check main files
    log_info "Checking main project files..."
    check_file "README.md" "Main README file"
    check_file "LICENSE" "License file"
    check_file "CHANGELOG.md" "Changelog file"
    check_file "CONTRIBUTING.md" "Contributing guide"
    check_file ".gitignore" "Git ignore file"
    check_executable "install.sh" "Installation script"
    echo ""
    
    # Check binary scripts
    log_info "Checking binary scripts..."
    check_file "bin/ctdisk" "Main ctdisk command"
    check_file "bin/ctdisk-setup" "Setup command"
    check_file "bin/ctdisk-hibernation-safe" "Hibernation-safe command"
    check_file "bin/mount-ctexternaldisk.sh" "Original mount script"
    check_file "bin/mount-ctexternaldisk-hibernation-safe.sh" "Hibernation-safe mount script"
    check_file "bin/ctdisk-boot-mount.sh" "Boot mount script"
    check_file "bin/ctdisk-sleepwatcher-v2.sh" "Sleep watcher script"
    check_file "bin/test-hibernation-recovery.sh" "Hibernation recovery test"
    check_file "bin/fix-ctdisk-ownership.sh" "Ownership fix script"
    check_file "bin/setup-sudoless-mount.sh" "Sudo setup script"
    echo ""
    
    # Check configuration files
    log_info "Checking configuration files..."
    check_file "config/com.user.ctexternaldisk.automount.plist" "Main LaunchAgent plist"
    check_file "config/com.user.ctexternaldisk.bootmount.plist" "Boot LaunchAgent plist"
    echo ""
    
    # Check documentation
    log_info "Checking documentation..."
    check_file "docs/INSTALLATION.md" "Installation guide"
    check_file "docs/HIBERNATION.md" "Hibernation guide"
    check_file "docs/TROUBLESHOOTING.md" "Troubleshooting guide"
    check_file "docs/API.md" "API reference"
    check_file "docs/USER_GUIDE_ZH.md" "Chinese user guide"
    echo ""
    
    # Check tests
    log_info "Checking test files..."
    check_executable "tests/run_tests.sh" "Test runner script"
    check_executable "tests/test_ownership.sh" "Ownership test script"
    echo ""
    
    # Check examples
    log_info "Checking example files..."
    check_executable "examples/basic-usage.sh" "Basic usage example"
    check_file "examples/custom-device-config.sh" "Custom device config example"
    echo ""
    
    # Summary
    echo "📊 Verification Summary"
    echo "======================"
    echo "Total Checks: $TOTAL_CHECKS"
    echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
    echo -e "Failed: ${RED}$((TOTAL_CHECKS - PASSED_CHECKS))${NC}"
    echo ""
    
    if [[ $PASSED_CHECKS -eq $TOTAL_CHECKS ]]; then
        echo -e "${GREEN}✅ All verification checks passed!${NC}"
        echo "The project is ready for GitHub upload."
        echo ""
        echo "Next steps:"
        echo "1. Initialize git repository: git init"
        echo "2. Add files: git add ."
        echo "3. Commit: git commit -m 'Initial commit'"
        echo "4. Add remote: git remote add origin <your-repo-url>"
        echo "5. Push: git push -u origin main"
        return 0
    else
        echo -e "${RED}❌ Some verification checks failed${NC}"
        echo "Please fix the issues before uploading to GitHub."
        return 1
    fi
}

# Run verification
main "$@"
