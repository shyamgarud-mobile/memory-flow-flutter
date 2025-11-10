#!/bin/bash
# Clean cache and start fresh debug session

echo "🧹 Cleaning Flutter cache..."
flutter clean

echo ""
echo "🔨 Building and running app on device..."
flutter run -d 192.168.1.8:5555
