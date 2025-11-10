#!/bin/bash
# Hot reload the Flutter app without rebuilding

echo "🔄 Triggering hot reload..."

# Find the Flutter VM service port
FLUTTER_PORT=$(lsof -ti:41569 2>/dev/null || ps aux | grep "flutter run" | grep -v grep | head -1 | awk '{print $2}')

if [ -z "$FLUTTER_PORT" ]; then
    echo "❌ No running Flutter app found"
    echo "💡 Use ./scripts/clean_build.sh to start a new session"
    exit 1
fi

# Try to trigger hot reload via r command
echo "r" | nc -N localhost 41569 2>/dev/null || {
    echo "⚠️  Direct hot reload failed, trying flutter attach..."
    flutter attach -d 192.168.1.8:5555
}

echo "✅ Hot reload triggered"
