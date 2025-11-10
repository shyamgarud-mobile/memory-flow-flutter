#!/bin/bash
# Stop all Flutter debug sessions

echo "🛑 Stopping all Flutter debug sessions..."

# Kill all flutter run processes
pkill -f "flutter run"

if [ $? -eq 0 ]; then
    echo "✅ All Flutter debug sessions stopped"
else
    echo "ℹ️  No running Flutter sessions found"
fi

# Show remaining dart/flutter processes
REMAINING=$(ps aux | grep -E "(flutter|dart)" | grep -v grep | wc -l)
if [ $REMAINING -gt 0 ]; then
    echo ""
    echo "⚠️  Some Flutter/Dart processes still running:"
    ps aux | grep -E "(flutter|dart)" | grep -v grep
fi
