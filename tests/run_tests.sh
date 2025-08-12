#!/bin/bash

# CT External Drive Manager Test Runner
# Runs all test suites and reports results

set -e

# Configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$TEST_DIR")"
RESULTS_DIR="$TEST_DIR/results"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Setup test environment
setup_test_env() {
    log_info "Setting up test environment..."
    
    # Create results directory
    mkdir -p "$RESULTS_DIR"
    
    # Clear previous results
    rm -f "$RESULTS_DIR"/*.log
    
    # Set PATH to include project binaries
    export PATH="$PROJECT_DIR/bin:$PATH"
    
    log_success "Test environment ready"
}

# Run a single test file
run_test_file() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .sh)
    local result_file="$RESULTS_DIR/${test_name}.log"
    
    log_info "Running test: $test_name"
    
    if bash "$test_file" > "$result_file" 2>&1; then
        log_success "$test_name"
        ((PASSED_TESTS++))
        return 0
    else
        log_error "$test_name (see $result_file for details)"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Run all tests
run_all_tests() {
    log_info "Starting test suite..."
    echo ""
    
    # Find all test files
    local test_files=()
    while IFS= read -r -d '' file; do
        test_files+=("$file")
    done < <(find "$TEST_DIR" -name "test_*.sh" -type f -print0)
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        log_warning "No test files found"
        return 0
    fi
    
    # Run each test
    for test_file in "${test_files[@]}"; do
        run_test_file "$test_file"
        ((TOTAL_TESTS++))
    done
}

# Generate test report
generate_report() {
    echo ""
    echo "🧪 Test Results Summary"
    echo "======================"
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "\n${GREEN}✅ All tests passed!${NC}"
        return 0
    else
        echo -e "\n${RED}❌ Some tests failed${NC}"
        echo ""
        echo "Failed test details:"
        for log_file in "$RESULTS_DIR"/*.log; do
            if [[ -f "$log_file" ]]; then
                local test_name=$(basename "$log_file" .log)
                if grep -q "FAIL\|ERROR" "$log_file" 2>/dev/null; then
                    echo "  - $test_name: $(tail -1 "$log_file")"
                fi
            fi
        done
        return 1
    fi
}

# Cleanup test environment
cleanup_test_env() {
    log_info "Cleaning up test environment..."
    
    # Remove temporary files if any
    # (Add cleanup logic here if needed)
    
    log_success "Cleanup completed"
}

# Main function
main() {
    echo "🚀 CT External Drive Manager Test Suite"
    echo "======================================="
    echo ""
    
    # Setup
    setup_test_env
    
    # Run tests
    run_all_tests
    
    # Generate report
    generate_report
    local exit_code=$?
    
    # Cleanup
    cleanup_test_env
    
    echo ""
    if [[ $exit_code -eq 0 ]]; then
        echo "🎉 Test suite completed successfully!"
    else
        echo "💥 Test suite completed with failures"
        echo "Check log files in $RESULTS_DIR for details"
    fi
    
    exit $exit_code
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --verbose, -v  Enable verbose output"
        echo "  --clean        Clean results directory before running"
        echo ""
        echo "Test files are automatically discovered in the tests/ directory"
        echo "Results are saved to tests/results/"
        exit 0
        ;;
    --verbose|-v)
        set -x
        ;;
    --clean)
        rm -rf "$RESULTS_DIR"
        log_info "Results directory cleaned"
        ;;
esac

# Run main function
main "$@"
