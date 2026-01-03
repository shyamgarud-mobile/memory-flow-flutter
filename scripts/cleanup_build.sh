#!/bin/bash
# Cleanup script for freeing disk space and fixing build issues

set -e  # Exit on error

echo "🧹 MemoryFlow Build Cleanup Script"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track total space freed
INITIAL_SPACE=$(df / | tail -1 | awk '{print $4}')

echo -e "${BLUE}📊 Current disk usage:${NC}"
df -h / | tail -1
echo ""

# Function to calculate freed space
calculate_freed() {
    CURRENT_SPACE=$(df / | tail -1 | awk '{print $4}')
    FREED=$((CURRENT_SPACE - INITIAL_SPACE))
    echo -e "${GREEN}✅ Freed approximately $(($FREED / 1024))MB${NC}"
}

# 1. Stop all Gradle daemons
echo -e "${BLUE}1. Stopping Gradle daemons...${NC}"
pkill -9 -f gradle 2>/dev/null || true
cd "$(dirname "$0")/.." && cd android && ./gradlew --stop 2>/dev/null || true
cd - > /dev/null
echo -e "${GREEN}✅ Stopped all Gradle daemons${NC}"
echo ""

# 2. Clean Flutter build artifacts
echo -e "${BLUE}2. Cleaning Flutter build artifacts...${NC}"
if command -v flutter &> /dev/null; then
    flutter clean
    echo -e "${GREEN}✅ Flutter clean completed${NC}"
else
    echo -e "${YELLOW}⚠️  Flutter not found in PATH, trying installed_apps...${NC}"
    if [ -f ~/installed_apps/flutter/bin/flutter ]; then
        ~/installed_apps/flutter/bin/flutter clean
        echo -e "${GREEN}✅ Flutter clean completed${NC}"
    else
        echo -e "${YELLOW}⚠️  Flutter not found, skipping${NC}"
    fi
fi
echo ""

# 3. Remove Android build caches
echo -e "${BLUE}3. Removing Android/Gradle caches...${NC}"
rm -rf android/.gradle 2>/dev/null && echo -e "${GREEN}  ✅ Removed android/.gradle${NC}" || true
rm -rf android/app/build 2>/dev/null && echo -e "${GREEN}  ✅ Removed android/app/build${NC}" || true
rm -rf android/build 2>/dev/null && echo -e "${GREEN}  ✅ Removed android/build${NC}" || true
rm -rf .dart_tool 2>/dev/null && echo -e "${GREEN}  ✅ Removed .dart_tool${NC}" || true
rm -rf build 2>/dev/null && echo -e "${GREEN}  ✅ Removed build${NC}" || true
echo ""

# 4. Clear user caches (optional)
echo -e "${BLUE}4. Clearing system caches (optional)...${NC}"
read -p "Clear user caches (Google, GeoServices, etc.)? This is safe. [y/N]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/Library/Caches/Google 2>/dev/null && echo -e "${GREEN}  ✅ Cleared Google caches${NC}" || true
    rm -rf ~/Library/Caches/GeoServices 2>/dev/null && echo -e "${GREEN}  ✅ Cleared GeoServices cache${NC}" || true
    rm -rf ~/Library/Caches/com.apple.helpd 2>/dev/null && echo -e "${GREEN}  ✅ Cleared help daemon cache${NC}" || true
    rm -rf ~/Library/Logs/* 2>/dev/null && echo -e "${GREEN}  ✅ Cleared user logs${NC}" || true
else
    echo -e "${YELLOW}  ⏭️  Skipped user caches${NC}"
fi
echo ""

# 5. Clean Downloads folder (optional)
echo -e "${BLUE}5. Cleaning Downloads folder (optional)...${NC}"
DOWNLOADS_SIZE=$(du -sh ~/Downloads 2>/dev/null | cut -f1 || echo "0")
echo "  Downloads folder size: $DOWNLOADS_SIZE"
read -p "Clear ~/Downloads folder? [y/N]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/Downloads/* 2>/dev/null && echo -e "${GREEN}  ✅ Cleared Downloads folder${NC}" || true
else
    echo -e "${YELLOW}  ⏭️  Skipped Downloads${NC}"
fi
echo ""

# 6. Clean node_modules in ~/code (aggressive)
echo -e "${BLUE}6. Cleaning node_modules directories (aggressive)...${NC}"
if [ -d ~/code ]; then
    NODE_MODULES=$(find ~/code -type d -name "node_modules" 2>/dev/null | wc -l | xargs)
    echo "  Found $NODE_MODULES node_modules directories"
    if [ "$NODE_MODULES" -gt 0 ]; then
        read -p "Remove all node_modules directories in ~/code? You can reinstall with 'npm install'. [y/N]: " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            find ~/code -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null
            echo -e "${GREEN}  ✅ Removed all node_modules directories${NC}"
        else
            echo -e "${YELLOW}  ⏭️  Skipped node_modules${NC}"
        fi
    else
        echo -e "${YELLOW}  ⏭️  No node_modules found${NC}"
    fi
else
    echo -e "${YELLOW}  ⏭️  ~/code directory not found${NC}"
fi
echo ""

# 7. Clean Flutter build artifacts in ~/code
echo -e "${BLUE}7. Cleaning Flutter build artifacts in ~/code (aggressive)...${NC}"
if [ -d ~/code ]; then
    FLUTTER_BUILDS=$(find ~/code -type d -name ".dart_tool" -o -type d -name "build" 2>/dev/null | wc -l | xargs)
    echo "  Found $FLUTTER_BUILDS Flutter build directories"
    if [ "$FLUTTER_BUILDS" -gt 0 ]; then
        read -p "Remove Flutter build artifacts in ~/code? [y/N]: " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            find ~/code -type d -name ".dart_tool" -exec rm -rf {} + 2>/dev/null
            find ~/code -type d -name "build" -exec rm -rf {} + 2>/dev/null
            echo -e "${GREEN}  ✅ Removed Flutter build artifacts${NC}"
        else
            echo -e "${YELLOW}  ⏭️  Skipped Flutter build artifacts${NC}"
        fi
    else
        echo -e "${YELLOW}  ⏭️  No Flutter build artifacts found${NC}"
    fi
fi
echo ""

# 8. Summary
echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}📊 Final disk usage:${NC}"
df -h / | tail -1
echo ""
calculate_freed
echo ""
echo -e "${GREEN}✨ Cleanup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Run: flutter run -d <device-id>"
echo "  2. Or use: ./scripts/connect_device.sh to connect your device"
echo ""
