#!/bin/bash

# Test ownership repair functionality

# Test configuration
TEST_NAME="Ownership Repair"
MOUNT_POINT="/Volumes/CTExternalDisk"

# Test functions
test_ownership_check() {
    echo "Testing ownership check functionality..."
    
    # Check if mount point exists
    if [[ ! -d "$MOUNT_POINT" ]]; then
        echo "SKIP: Mount point $MOUNT_POINT not found"
        return 0
    fi
    
    # Get current ownership
    local current_owner
    current_owner=$(stat -f "%Su:%Sg" "$MOUNT_POINT" 2>/dev/null)
    
    if [[ -n "$current_owner" ]]; then
        echo "PASS: Can read ownership ($current_owner)"
        return 0
    else
        echo "FAIL: Cannot read ownership"
        return 1
    fi
}

test_write_permissions() {
    echo "Testing write permissions..."
    
    # Check if mount point exists
    if [[ ! -d "$MOUNT_POINT" ]]; then
        echo "SKIP: Mount point $MOUNT_POINT not found"
        return 0
    fi
    
    # Test write permission
    local test_file="$MOUNT_POINT/test_write_permission.tmp"
    
    if touch "$test_file" 2>/dev/null; then
        rm -f "$test_file"
        echo "PASS: Write permissions working"
        return 0
    else
        echo "FAIL: No write permissions"
        return 1
    fi
}

test_ownership_repair_script() {
    echo "Testing ownership repair script..."
    
    # Check if script exists
    if ! command -v fix-ctdisk-ownership.sh >/dev/null 2>&1; then
        echo "SKIP: fix-ctdisk-ownership.sh not found in PATH"
        return 0
    fi
    
    # Run the script in check-only mode
    if fix-ctdisk-ownership.sh --check-only >/dev/null 2>&1; then
        echo "PASS: Ownership repair script runs successfully"
        return 0
    else
        echo "FAIL: Ownership repair script failed"
        return 1
    fi
}

# Main test execution
main() {
    echo "🧪 Running $TEST_NAME Tests"
    echo "=========================="
    echo ""
    
    local total_tests=0
    local passed_tests=0
    
    # Run tests
    local tests=(
        "test_ownership_check"
        "test_write_permissions"
        "test_ownership_repair_script"
    )
    
    for test_func in "${tests[@]}"; do
        echo "Running: $test_func"
        if $test_func; then
            ((passed_tests++))
        fi
        ((total_tests++))
        echo ""
    done
    
    # Summary
    echo "Results: $passed_tests/$total_tests tests passed"
    
    if [[ $passed_tests -eq $total_tests ]]; then
        echo "✅ All ownership tests passed"
        exit 0
    else
        echo "❌ Some ownership tests failed"
        exit 1
    fi
}

# Run tests
main "$@"
