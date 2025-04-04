#!/bin/bash
set -e

# Change to the plugin directory if not already there
cd "$(dirname "$(dirname "$(readlink -f "$0")")")" || exit 1

echo "====================================================="
echo "Running tests for dokku-gel plugin"
echo "====================================================="

# Make sure required directories exist
mkdir -p /home/dokku/data

# Check if specific tests were specified
if [ $# -gt 0 ]; then
    TEST_FILES="$*"
    echo "Running specified tests: $TEST_FILES"
else
    # Run all tests if no specific test was provided
    TEST_FILES="tests/*.bats"
    echo "Running all tests"
fi

# Ensure symlinks are set up correctly
mkdir -p /var/lib/dokku/plugins/enabled
ln -sf /var/lib/dokku/plugins/dokku-gel /var/lib/dokku/plugins/enabled/gel

# Add some debugging information
echo "Plugin directory: $(pwd)"
echo "Plugin files:"
ls -la

# Run the tests with Bats
if command -v bats >/dev/null 2>&1; then
    echo "Using bats to run tests..."
    bats $TEST_FILES
else
    echo "Error: Bats not found. Please install bats first."
    echo "Try: apt-get update && apt-get install -y bats"
    exit 1
fi

echo "====================================================="
echo "Tests completed"
echo "=====================================================" 