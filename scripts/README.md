# MemoryFlow Development Scripts

Automated scripts for common repetitive tasks during development.

## Available Scripts

### 1. Clean Build (`clean_build.sh`)
**When to use**: You want to start completely fresh with cache cleared
```bash
./scripts/clean_build.sh
```
- Runs `flutter clean`
- Starts new debug session on device
- **Use this for**: Major code changes, dependency updates, or troubleshooting build issues

### 2. Quick Restart (`quick_restart.sh`)
**When to use**: You want to restart the app without cleaning cache
```bash
./scripts/quick_restart.sh
```
- Stops current Flutter session
- Starts fresh without cleaning build cache
- **Use this for**: Testing changes that require app restart
- **Faster than**: clean_build.sh

### 3. Hot Reload (`hot_reload.sh`)
**When to use**: You made small UI/logic changes
```bash
./scripts/hot_reload.sh
```
- Triggers hot reload on running app
- **Fastest option** for testing changes
- **Use this for**: UI tweaks, text changes, minor logic updates

### 4. Connect Device (`connect_device.sh`)
**When to use**: Device disconnected or starting new session
```bash
./scripts/connect_device.sh
```
- Connects to POCO F1 via ADB wireless (192.168.1.8:5555)
- Shows connected devices
- **Use this for**: Reconnecting after device disconnect

### 5. Stop Debug (`stop_debug.sh`)
**When to use**: You want to stop all running Flutter sessions
```bash
./scripts/stop_debug.sh
```
- Kills all `flutter run` processes
- Shows any remaining Flutter/Dart processes
- **Use this for**: Cleaning up before starting fresh

### 6. Clear App Data (`clear_app_data.sh`)
**When to use**: You want to reset the app database and cache on device
```bash
./scripts/clear_app_data.sh
```
- Clears all app data on device (like uninstall/reinstall)
- Resets SQLite database
- **Use this for**: Testing fresh install, clearing test data

### 7. View Logs (`view_logs.sh`)
**When to use**: You want to monitor app logs in real-time
```bash
./scripts/view_logs.sh
```
- Shows filtered Flutter app logs
- Press Ctrl+C to exit
- **Use this for**: Debugging, monitoring topic operations

## Common Workflows

### After making code changes:
```bash
# Quick iteration (fastest)
./scripts/hot_reload.sh

# Need restart but not clean
./scripts/quick_restart.sh

# Clean everything and rebuild
./scripts/clean_build.sh
```

### Starting new day:
```bash
./scripts/connect_device.sh
./scripts/clean_build.sh
```

### Debugging issues:
```bash
# Terminal 1
./scripts/clean_build.sh

# Terminal 2 (separate window)
./scripts/view_logs.sh
```

### Testing fresh install:
```bash
./scripts/stop_debug.sh
./scripts/clear_app_data.sh
./scripts/quick_restart.sh
```

## Notes

- All scripts are configured for device IP: `192.168.1.8:5555`
- To change device IP, edit the scripts in the `scripts/` folder
- Scripts use color emoji indicators for better visibility
