#!/bin/bash
# Clear app data on device (reset database and cache)

PACKAGE_NAME="com.garud.shyamkumar.memoryflow"

echo "🗑️  Clearing app data for $PACKAGE_NAME..."

adb -s 192.168.1.8:5555 shell pm clear $PACKAGE_NAME

if [ $? -eq 0 ]; then
    echo "✅ App data cleared successfully"
    echo "ℹ️  Database and all app files have been reset"
else
    echo "❌ Failed to clear app data"
    exit 1
fi
