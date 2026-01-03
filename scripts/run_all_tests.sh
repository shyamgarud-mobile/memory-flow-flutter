#!/bin/bash

# Script to run all tests for MemoryFlow
# Usage: ./scripts/run_all_tests.sh

set -e  # Exit on error

echo "🧪 MemoryFlow - Running All Tests"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Clean and get dependencies
print_status "Cleaning project..."
flutter clean
flutter pub get
print_success "Project cleaned and dependencies installed"
echo ""

# Run static analysis
print_status "Running static analysis..."
if flutter analyze; then
    print_success "Static analysis passed"
else
    print_error "Static analysis failed"
    exit 1
fi
echo ""

# Run unit tests
print_status "Running unit tests..."
if flutter test --coverage; then
    print_success "Unit tests passed"
else
    print_error "Unit tests failed"
    exit 1
fi
echo ""

# Run performance tests
print_status "Running performance tests..."
if flutter test test/performance/; then
    print_success "Performance tests passed"
else
    print_error "Performance tests failed"
    exit 1
fi
echo ""

# Run integration tests (if device/emulator is available)
print_status "Checking for connected devices..."
if flutter devices | grep -q "device"; then
    print_status "Running integration tests..."
    if flutter test integration_test/; then
        print_success "Integration tests passed"
    else
        print_error "Integration tests failed"
        exit 1
    fi
else
    echo "⚠️  No devices found - skipping integration tests"
    echo "   To run integration tests, connect a device or start an emulator"
fi
echo ""

# Generate coverage report
print_status "Generating coverage report..."
if [ -f "coverage/lcov.info" ]; then
    # Count total coverage
    COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}')
    print_success "Coverage report generated: $COVERAGE"
    echo "   View HTML report: genhtml coverage/lcov.info -o coverage/html"
    echo "   Open coverage/html/index.html in browser"
else
    echo "⚠️  Coverage file not found"
fi
echo ""

# Summary
echo "=================================="
echo -e "${GREEN}✓ All tests completed successfully!${NC}"
echo "=================================="
echo ""
echo "📊 Summary:"
echo "   ✓ Static analysis passed"
echo "   ✓ Unit tests passed"
echo "   ✓ Performance tests passed"
if flutter devices | grep -q "device"; then
    echo "   ✓ Integration tests passed"
else
    echo "   ⚠ Integration tests skipped (no device)"
fi
echo ""
echo "Next steps:"
echo "   1. Review test coverage"
echo "   2. Run on real devices"
echo "   3. Build release APK/AAB"
echo ""
