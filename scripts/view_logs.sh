#!/bin/bash
# View real-time Flutter app logs

echo "📋 Viewing Flutter app logs (Ctrl+C to exit)..."
echo "─────────────────────────────────────────────────"

# Clear old logs first
adb -s 192.168.1.8:5555 logcat -c

# Follow live logs filtered for Flutter/app
adb -s 192.168.1.8:5555 logcat | grep -E "(flutter|MemoryFlow|Topic|Database|ERROR)"
