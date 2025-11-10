#!/bin/bash
# Quick restart without cleaning (hot restart)

echo "🔄 Hot restarting Flutter app..."

# Kill existing flutter run processes
pkill -f "flutter run" 2>/dev/null

# Wait a moment for cleanup
sleep 1

# Start fresh
echo "🚀 Starting app on device..."
flutter run -d 192.168.1.8:5555
