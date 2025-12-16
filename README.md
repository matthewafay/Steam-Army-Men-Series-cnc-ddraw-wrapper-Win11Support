# Army Men Games Configuration Tool

A PowerShell script that automatically configures Army Men games (Steam versions) for optimal Windows 11 compatibility using cnc-ddraw wrapper.

## Supported Games

- **Army Men 2** (App ID: 549170)
- **Army Men: Toys in Space** (App ID: 549180)

## Overview

This tool automates the complex setup process required to run Army Men games on modern Windows systems by:

- **Game Selection** - Interactive prompt to choose which Army Men game to configure
- **Auto-detecting** your screen resolution
- **Locating** your Steam installation and game files
- **Installing** cnc-ddraw wrapper for windowed mode compatibility
- **Configuring** DirectDraw interception to prevent crashes and resolution changes

## Features

- ✅ **Automatic Resolution Detection** - Detects your primary monitor's resolution using multiple fallback methods
- ✅ **Steam Integration** - Automatically finds Steam installation and library folders
- ✅ **Game Discovery** - Locates Army Men 2 installation across multiple Steam libraries
- ✅ **cnc-ddraw Integration** - Downloads and installs cnc-ddraw wrapper for modern compatibility
- ✅ **Enhanced Graphics** - 1600x1200 windowed mode with OpenGL renderer and sharp upscaling
- ✅ **Multiple Visual Modes** - Sharp upscaling, smooth upscaling, pixel-perfect, and original modes
- ✅ **Graphics Switcher** - Easy-to-use tool for switching between different visual configurations
- ✅ **DirectPlay Support** - Guides users through DirectPlay installation when needed
- ✅ **Comprehensive Testing** - Includes extensive unit tests and property-based testing

## Quick Start

1. **Prerequisites**: Ensure you have one or both Army Men games installed via Steam
2. **Run the script**: Execute `Configure-ArmyMen.ps1` in PowerShell
3. **Select your game**: Choose which Army Men game to configure (1 or 2)
4. **Follow the output**: The script will display progress and results for each configuration step

```powershell
# Interactive mode - prompts for game selection
.\Configure-ArmyMen.ps1

# Direct mode - configure Army Men 2
.\Configure-ArmyMen.ps1 -GameChoice 1

# Direct mode - configure Army Men: Toys in Space
.\Configure-ArmyMen.ps1 -GameChoice 2
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
- Searches all Steam libraries for the selected Army Men game:
  - Army Men 2 (App ID: 549170, Executable: ArmyMen2.exe)
  - Army Men: Toys in Space (App ID: 549180, Executable: ARMYMENTIS.exe)
- Parses Steam manifest files to locate game installation directory
- Verifies game executable exists

### Phase 4: cnc-ddraw Installation & Graphics Enhancement
- Downloads the latest cnc-ddraw wrapper from GitHub
- Backs up the original ddraw.dll file
- Installs cnc-ddraw with enhanced windowed mode configuration
- Creates upscaling shaders (sharp and smooth) for better graphics
- Configures OpenGL renderer with VSync for optimal performance
- Sets up 1600x1200 windowed mode for comfortable gameplay

### Phase 5: Graphics Configuration System
- Creates multiple visual presets (sharp, smooth, pixel-perfect, original)
- Installs Graphics_Switcher.bat for easy configuration switching
- Forces windowed mode to prevent screen resolution changes
- Enables FPS counter support and performance optimizations

## Requirements

- **PowerShell 5.1** or later
- **Windows 10/11** (tested on Windows 11)
- **Army Men games** installed via Steam (Army Men 2 and/or Army Men: Toys in Space)
- **Internet connection** (to download cnc-ddraw)
- **DirectPlay Windows feature** (script will prompt for installation if needed)

## Testing

The project includes comprehensive test coverage using Pester:

```powershell
# Run all tests
Invoke-Pester .\tests\Configure-ArmyMen2.Tests.ps1

# Run specific test categories
Invoke-Pester .\tests\Configure-ArmyMen2.Tests.ps1 -Tag "Unit"
Invoke-Pester .\tests\Configure-ArmyMen2.Tests.ps1 -Tag "Property"
```

Note: The test file still references the old script name but tests the same functionality.

### Test Coverage
- **Unit Tests**: Individual function testing with mocked dependencies
- **Property-Based Tests**: Validates behavior across random input ranges
- **Integration Tests**: End-to-end workflow validation

## Troubleshooting

### Common Issues

**"Steam installation not found"**
- Ensure Steam is installed and has been run at least once
- Check that Steam appears in Windows "Add or Remove Programs"

**"Army Men [game] not found"**
- Verify the selected game is installed via Steam
- Check that the game appears in your Steam library
- Try running Steam as administrator and verify game files
- Make sure you selected the correct game number (1 for Army Men 2, 2 for Toys in Space)

**"Failed to detect screen resolution"**
- Update your display drivers
- Ensure your monitor is properly connected and recognized by Windows
- Try running the script as administrator

**"DirectPlay required" popup**
- Click "Install this feature" when Windows prompts
- Restart your computer after installation
- DirectPlay is required for the game's networking code

**"Black screen in windowed mode"**
- The script automatically configures cnc-ddraw with OpenGL renderer and upscaling
- If issues persist, use Graphics_Switcher.bat to try different visual modes
- Fallback: Change `renderer=opengl` to `renderer=gdi` in ddraw.ini

### Manual Configuration

If the script fails, you can manually set up cnc-ddraw:

1. **Download cnc-ddraw**: Get the latest version from GitHub (FunkyFr3sh/cnc-ddraw)
2. **Install**: Copy `ddraw.dll` to the game directory
3. **Configure**: Create `ddraw.ini` with enhanced settings:
   ```ini
   [ddraw]
   windowed=true
   fullscreen=false
   width=1600
   height=1200
   renderer=opengl
   nonexclusive=true
   singlecpu=true
   vsync=true
   maxfps=60
   shader=Shaders\sharp-upscale.glsl
   no_compat_warning=true
   ```
4. **DirectPlay**: Enable via Windows Features → Legacy Components → DirectPlay

## Architecture

The script is organized into modular components:

- **Resolution Detection Module**: Multi-method screen resolution detection
- **Steam Locator Module**: Registry-based Steam installation discovery
- **Game Finder Module**: Steam library parsing and game location
- **Compatibility Configurator Module**: Windows compatibility registry management
- **Game Configurator Module**: INI file configuration management
- **Output Functions**: Formatted status reporting and summary generation

## After Installation

**First Launch:**
1. Run the configuration script: `.\Configure-ArmyMen.ps1`
2. Select which Army Men game to configure (1 or 2)
3. Launch the configured game from Steam
4. If prompted for DirectPlay, click "Install this feature" and restart
5. Game opens in enhanced 1600x1200 windowed mode

**What You Get:**
- ✅ **Enhanced Graphics** - Sharp upscaling shader for crisp, clean pixels
- ✅ **Large Window** - 1600x1200 default size (still resizable)
- ✅ **Modern Rendering** - OpenGL with VSync for smooth 60 FPS
- ✅ **Multiple Visual Modes** - Sharp, smooth, pixel-perfect, and original presets
- ✅ **Graphics Switcher** - Easy tool to switch between visual configurations
- ✅ **Stable Performance** - No crashes or screen resolution changes
- ✅ **FPS Counter Support** - Use Steam's built-in FPS counter

## Graphics Modes

The script creates multiple visual presets you can switch between:

### **Sharp Upscaling** ⭐ (Default)
- Pixel-perfect scaling with crisp, clean edges
- Best for maintaining the original retro aesthetic
- 1600x1200 windowed mode with OpenGL + VSync

### **Smooth Upscaling**
- Anti-aliased scaling for a softer, modern look
- Reduces pixelation but may appear slightly blurred
- Same performance as sharp mode

### **Pixel Perfect 2x**
- Fixed 1280x960 window (exactly 2x original resolution)
- Non-resizable for perfect pixel alignment
- Best for purists who want exact scaling

### **Enhanced OpenGL**
- Modern rendering without upscaling shaders
- Good performance baseline
- Fallback if shaders cause issues

### **Original GDI**
- Safe fallback using the original rendering method
- Use if you experience any compatibility issues

## Switching Graphics Modes

Use the **Graphics_Switcher.bat** file in your game directory:

**For Army Men 2:**
1. Navigate to `C:\Program Files (x86)\Steam\steamapps\common\Army Men II`
2. Double-click `Graphics_Switcher.bat`
3. Choose your preferred visual mode (1-5)
4. Launch the game to see the changes

**For Army Men: Toys in Space:**
1. Navigate to `C:\Program Files (x86)\Steam\steamapps\common\Army Men - Toys in Space`
2. Double-click `Graphics_Switcher.bat`
3. Choose your preferred visual mode (1-5)
4. Launch the game to see the changes

## FAQ / Known Issues

### **❓ "DirectPlay Required" Popup Appears**
**Problem**: Windows shows "An app on your PC needs the following Windows feature: DirectPlay"

**Solution**:
1. Click **"Install this feature"** (don't skip it!)
2. Wait for installation to complete
3. **Restart your computer** (this is required)
4. Launch the game again

**Why this happens**: Army Men games use DirectPlay for their networking code, even in single-player mode. Windows 11 doesn't include DirectPlay by default, but it's available as an optional feature.

### **❓ Game Shows Black Screen in Window**
**Problem**: Game window opens but shows only black screen

**Solutions**:
1. Try different graphics modes using `Graphics_Switcher.bat`
2. Start with "Original GDI" mode (option 1)
3. If that works, try "Enhanced OpenGL" (option 2)
4. Check that your graphics drivers are up to date

### **❓ Game Crashes on Startup**
**Problem**: Game closes immediately or shows error message

**Solutions**:
1. Make sure DirectPlay is installed (see above)
2. Run the game as Administrator
3. Use Graphics_Switcher.bat to try "Original GDI" mode
4. Verify game files in Steam (Right-click game → Properties → Local Files → Verify)

### **❓ Graphics Look Blurry or Pixelated**
**Problem**: Game doesn't look as sharp as expected

**Solutions**:
1. Use Graphics_Switcher.bat to try "Sharp Upscaling" mode
2. For pixel-perfect scaling, try "Pixel Perfect 2x" mode
3. Make sure you're not running in fullscreen mode (Alt+Enter to toggle)

### **❓ FPS Counter Not Showing**
**Problem**: Can't see frame rate display

**Solutions**:
1. Enable Steam's FPS counter: Steam → Settings → In-Game → FPS Counter → Bottom-left
2. Try keyboard shortcuts in-game: Ctrl+Tab, F1, or Ctrl+F
3. Use Windows Game Bar: Win+G → Performance tab

### **❓ Window Too Small/Large**
**Problem**: Game window size isn't comfortable

**Solutions**:
1. Drag window corners to resize (if resizable mode is enabled)
2. Use Graphics_Switcher.bat to try different preset sizes
3. Edit `ddraw.ini` manually to set custom width/height values

### **❓ Script Fails to Download cnc-ddraw**
**Problem**: "Failed to install cnc-ddraw" error message

**Solutions**:
1. Check your internet connection
2. Run PowerShell as Administrator
3. Temporarily disable antivirus/firewall
4. Download cnc-ddraw manually from GitHub (FunkyFr3sh/cnc-ddraw)

## Game Selection

When you run the script without parameters, it will display an interactive menu:

```
============================================================
Army Men Games Configuration Tool
============================================================

Select which Army Men game to configure:

1. Army Men 2
2. Army Men: Toys in Space

Enter your choice (1-2):
```

You can also skip the menu by using the `-GameChoice` parameter:
- `.\Configure-ArmyMen.ps1 -GameChoice 1` for Army Men 2
- `.\Configure-ArmyMen.ps1 -GameChoice 2` for Army Men: Toys in Space

## Contributing

This project uses property-based testing to ensure reliability across different system configurations. When contributing:

1. Add unit tests for new functions
2. Include property-based tests for functions with variable inputs
3. Update documentation for any new features
4. Ensure all tests pass before submitting changes

## License

This project is provided as-is for educational and personal use. Army Men games are trademarks of their respective owners.