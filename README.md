# Army Men 2 Configuration Tool

A PowerShell script that automatically configures Army Men 2 (Steam version) for optimal Windows 11 compatibility.

## Overview

This tool automates the complex setup process required to run Army Men 2 on modern Windows systems by:

- **Auto-detecting** your screen resolution
- **Locating** your Steam installation and game files
- **Applying** Windows compatibility settings
- **Configuring** game resolution settings

## Features

- ✅ **Automatic Resolution Detection** - Detects your primary monitor's resolution using multiple fallback methods
- ✅ **Steam Integration** - Automatically finds Steam installation and library folders
- ✅ **Game Discovery** - Locates Army Men 2 installation across multiple Steam libraries
- ✅ **Compatibility Settings** - Applies Windows XP SP3 compatibility mode, admin privileges, and display optimizations
- ✅ **Configuration Management** - Creates and updates game configuration files with proper resolution settings
- ✅ **Comprehensive Testing** - Includes extensive unit tests and property-based testing

## Quick Start

1. **Prerequisites**: Ensure you have Army Men 2 installed via Steam
2. **Run the script**: Execute `Configure-ArmyMen2.ps1` in PowerShell
3. **Follow the output**: The script will display progress and results for each configuration step

```powershell
.\Configure-ArmyMen2.ps1
```

## What It Does

### Phase 1: Resolution Detection
- Detects your primary monitor's resolution using Windows Forms API
- Falls back to WMI queries if the primary method fails
- Validates resolution values are within acceptable ranges

### Phase 2: Steam Location
- Searches Windows Registry for Steam installation path
- Parses Steam's `libraryfolders.vdf` to find all library locations
- Handles both 32-bit and 64-bit registry locations

### Phase 3: Game Discovery
- Searches all Steam libraries for Army Men 2 (App ID: 299220)
- Parses Steam manifest files to locate game installation directory
- Verifies game executable (`AM2.exe`) exists

### Phase 4: Compatibility Settings
- Applies Windows XP Service Pack 3 compatibility mode
- Enables "Run as Administrator" 
- Disables fullscreen optimizations
- Sets 16-bit color mode
- Writes settings to Windows compatibility registry

### Phase 5: Game Configuration
- Creates or updates `AM2.ini` configuration file
- Sets `ScreenWidth` and `ScreenHeight` to match your display
- Preserves existing configuration settings

## Requirements

- **PowerShell 5.1** or later
- **Windows 10/11** (tested on Windows 11)
- **Army Men 2** installed via Steam
- **Administrator privileges** (for compatibility settings)

## Testing

The project includes comprehensive test coverage using Pester:

```powershell
# Run all tests
Invoke-Pester .\tests\Configure-ArmyMen2.Tests.ps1

# Run specific test categories
Invoke-Pester .\tests\Configure-ArmyMen2.Tests.ps1 -Tag "Unit"
Invoke-Pester .\tests\Configure-ArmyMen2.Tests.ps1 -Tag "Property"
```

### Test Coverage
- **Unit Tests**: Individual function testing with mocked dependencies
- **Property-Based Tests**: Validates behavior across random input ranges
- **Integration Tests**: End-to-end workflow validation

## Troubleshooting

### Common Issues

**"Steam installation not found"**
- Ensure Steam is installed and has been run at least once
- Check that Steam appears in Windows "Add or Remove Programs"

**"Army Men 2 not found"**
- Verify the game is installed via Steam
- Check that the game appears in your Steam library
- Try running Steam as administrator and verify game files

**"Failed to detect screen resolution"**
- Update your display drivers
- Ensure your monitor is properly connected and recognized by Windows
- Try running the script as administrator

**"Failed to apply compatibility settings"**
- Run PowerShell as Administrator
- Check that your user account has permission to modify registry settings

### Manual Configuration

If the script fails, you can manually apply these settings:

1. **Compatibility Settings**: Right-click `AM2.exe` → Properties → Compatibility
   - Check "Run this program in compatibility mode for: Windows XP (Service Pack 3)"
   - Check "Run this program as an administrator"
   - Check "Disable fullscreen optimizations"
   - Check "Reduced color mode: 16-bit (65536) color"

2. **Resolution Settings**: Create/edit `AM2.ini` in the game directory:
   ```ini
   ScreenWidth=2560
   ScreenHeight=1440
   ```

## Architecture

The script is organized into modular components:

- **Resolution Detection Module**: Multi-method screen resolution detection
- **Steam Locator Module**: Registry-based Steam installation discovery
- **Game Finder Module**: Steam library parsing and game location
- **Compatibility Configurator Module**: Windows compatibility registry management
- **Game Configurator Module**: INI file configuration management
- **Output Functions**: Formatted status reporting and summary generation

## Contributing

This project uses property-based testing to ensure reliability across different system configurations. When contributing:

1. Add unit tests for new functions
2. Include property-based tests for functions with variable inputs
3. Update documentation for any new features
4. Ensure all tests pass before submitting changes

## License

This project is provided as-is for educational and personal use. Army Men 2 is a trademark of its respective owners.