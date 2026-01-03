#!/bin/bash
# Connect to device via ADB wireless

# DEVICE_IP="170.20.10.7:5555"
DEVICE_IP="192.168.1.8:5555"
# DEVICE_IP="192.168.0.152:5555"
echo "📱 Connecting to device at $DEVICE_IP..."

# Check if already connected
if adb devices | grep -q "$DEVICE_IP"; then
    echo "✅ Device already connected"
else
    adb connect $DEVICE_IP

    if [ $? -eq 0 ]; then
        echo "✅ Device connected successfully"
    else
        echo "❌ Failed to connect to device"
        exit 1
    fi
fi

echo ""
echo "Connected devices:"
flutter devices
