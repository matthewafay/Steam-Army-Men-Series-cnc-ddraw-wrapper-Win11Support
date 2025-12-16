# Army Men Games Configuration Tool

A PowerShell script that automatically configures Army Men games (Steam versions) for optimal Windows 11 compatibility using cnc-ddraw wrapper.

## Supported Games

- **Army Men** (App ID: 549160)
- **Army Men II** (App ID: 549170)
- **Army Men RTS** (App ID: 694500)
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

1. **Prerequisites**: 
   - Ensure you have one or more Army Men games installed via Steam
   - Games must be installed and appear in your Steam library
   - Steam should be installed in the default location on C:\ drive (`C:\Program Files (x86)\Steam`)
   - Games should be in default Steam library locations (the script will search all Steam libraries)
   - The script will show "(Installed)" or "(Not Installed)" next to each game option
2. **Run the script**: Execute `Configure-ArmyMen.ps1` in PowerShell
3. **Select your game**: Choose which Army Men game to configure (1, 2, 3, or 4)
4. **Follow the output**: The script will display progress and results for each configuration step

```powershell
# Interactive mode - prompts for game selection
.\Configure-ArmyMen.ps1

# Direct mode - configure Army Men
.\Configure-ArmyMen.ps1 -GameChoice 1

# Direct mode - configure Army Men II
.\Configure-ArmyMen.ps1 -GameChoice 2

# Direct mode - configure Army Men RTS
.\Configure-ArmyMen.ps1 -GameChoice 3

# Direct mode - configure Army Men: Toys in Space
.\Configure-ArmyMen.ps1 -GameChoice 4
```

## Graphics Wrappers

This tool uses different graphics wrappers depending on the game's requirements:

### cnc-ddraw (Army Men, Army Men II, Toys in Space)

**cnc-ddraw** is a DirectDraw wrapper that intercepts legacy DirectDraw API calls and translates them to modern OpenGL or Direct3D. These older Army Men games use DirectDraw for rendering, which doesn't work well on modern Windows.

**What it does:**
- Intercepts DirectDraw calls from the game
- Renders using modern OpenGL with shader support
- Enables windowed mode with proper scaling
- Provides upscaling shaders for sharper graphics
- Prevents screen resolution changes

**Files installed:**
- `ddraw.dll` - The wrapper DLL that intercepts DirectDraw calls
- `ddraw.ini` - Configuration file for windowed mode, resolution, shaders
- `Shaders/` - GLSL shader files for upscaling effects

### dgVoodoo2 (Army Men RTS)

**dgVoodoo2** is a DirectX wrapper that translates DirectX 8.0 calls to DirectX 11. Army Men RTS uses DirectX 8.0, which has hardware detection issues on modern systems (the infamous "DirectX 8.0 compatible graphics card was not found" error).

**What it does:**
- Intercepts DirectX 8.0 API calls
- Translates them to DirectX 11 for modern GPU compatibility
- Enables windowed mode independent of the game
- Provides anti-aliasing options (up to 8x MSAA)
- Bypasses the DirectX 8.0 hardware check that fails on modern GPUs

**Files installed:**
- `D3D8.dll` - DirectX 8.0 wrapper
- `D3DImm.dll` - DirectX Immediate Mode wrapper
- `DDraw.dll` - DirectDraw wrapper (for compatibility)
- `dgVoodoo.conf` - Configuration file
- `dgVoodooCpl.exe` - Control panel for adjusting settings

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
  - Army Men (App ID: 549160, Executable: Armymen.exe)
  - Army Men II (App ID: 549170, Executable: ArmyMen2.exe)
  - Army Men RTS (App ID: 694500, Executable: amrts.exe)
  - Army Men: Toys in Space (App ID: 549180, Executable: ARMYMENTIS.exe)
- Parses Steam manifest files to locate game installation directory
- Verifies game executable exists

### Phase 4: Graphics Wrapper Installation
**For Army Men, Army Men II, and Toys in Space:**
- Downloads the latest cnc-ddraw wrapper from GitHub
- Backs up the original ddraw.dll file
- Installs cnc-ddraw with enhanced windowed mode configuration
- Creates upscaling shaders (sharp and smooth) for better graphics
- Configures OpenGL renderer with VSync for optimal performance
- Sets up 1600x1200 windowed mode for comfortable gameplay

**For Army Men RTS:**
- Downloads dgVoodoo2 from the official site
- Installs DirectX 8.0 wrapper DLLs (D3D8.dll, D3DImm.dll, DDraw.dll)
- Configures windowed mode with 8x anti-aliasing
- Disables the dgVoodoo watermark
- Installs dgVoodooCpl.exe for manual configuration if needed

### Phase 5: Graphics Configuration System
- Creates multiple visual presets (sharp, smooth, pixel-perfect, original)
- Installs Graphics_Switcher.bat for easy configuration switching
- Forces windowed mode to prevent screen resolution changes
- Enables FPS counter support and performance optimizations

## Requirements

- **PowerShell 5.1** or later
- **Windows 10/11** (tested on Windows 11)
- **Steam** installed in default location (`C:\Program Files (x86)\Steam`)
- **Army Men games** installed via Steam (Army Men, Army Men II, Army Men RTS, and/or Army Men: Toys in Space)
- **Games installed on C:\ drive** in default Steam library locations
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
- Ensure Steam is installed in the default location (`C:\Program Files (x86)\Steam`)
- Check that Steam appears in Windows "Add or Remove Programs"
- If Steam is installed elsewhere, the script may not detect it automatically

**"Army Men [game] not found"**
- Verify the selected game is installed via Steam (should show "Installed" in the menu)
- Check that the game appears in your Steam library
- Try running Steam as administrator and verify game files
- Make sure you selected the correct game number (1 for Army Men, 2 for Army Men II, 3 for Army Men RTS, 4 for Toys in Space)
- If the game shows "(Not Installed)", install it from Steam first

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
2. Select which Army Men game to configure (1, 2, 3, or 4)
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

**For Army Men:**
1. Navigate to `C:\Program Files (x86)\Steam\steamapps\common\Army Men`
2. Double-click `Graphics_Switcher.bat`
3. Choose your preferred visual mode (1-5)
4. Launch the game to see the changes

**For Army Men II:**
1. Navigate to `C:\Program Files (x86)\Steam\steamapps\common\Army Men II`
2. Double-click `Graphics_Switcher.bat`
3. Choose your preferred visual mode (1-5)
4. Launch the game to see the changes

**For Army Men RTS:**
1. Navigate to `C:\Program Files (x86)\Steam\steamapps\common\Army Men RTS`
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

### **❓ Army Men RTS: "DirectX 8.0 compatible graphics card was not found"**
**Problem**: Army Men RTS shows this error on startup

**Why this happens**: Army Men RTS uses DirectX 8.0 and performs a hardware check that fails on modern GPUs. The script installs dgVoodoo2 to intercept these calls.

**Solutions**:
1. Run the configuration script - it automatically installs dgVoodoo2
2. If the error persists, verify `D3D8.dll` exists in the game folder
3. Check that dgVoodoo.conf was created in the game folder

### **❓ Army Men RTS: Still Fullscreen After Configuration**
**Problem**: Army Men RTS launches in fullscreen instead of windowed mode

**Solutions**:
1. Run `dgVoodooCpl.exe` from the game folder (`C:\Program Files (x86)\Steam\steamapps\common\Army Men RTS`)
2. **Important**: Change the "Config folder" dropdown to the game folder (click the `.\` button or Add the game path)
3. Go to the **General** tab and select **"Windowed"** under Appearance
4. Go to the **DirectX** tab and **uncheck** "Application controlled fullscreen/windowed state"
5. Click **Apply**

### **❓ Army Men RTS: dgVoodoo Watermark Visible**
**Problem**: "dgVoodoo" watermark appears in the bottom-right corner

**Solutions**:
1. Run `dgVoodooCpl.exe` from the game folder
2. Go to the **DirectX** tab
3. **Uncheck** "dgVoodoo Watermark" at the bottom
4. Click **Apply**

### **❓ Army Men RTS: Adjusting Graphics Settings**
**Problem**: Want to change resolution, anti-aliasing, or other settings

**Solutions**:
1. Run `dgVoodooCpl.exe` from the game folder
2. **DirectX tab** settings:
   - **Resolution**: Change from "Unforced" to a specific resolution
   - **Antialiasing (MSAA)**: Set to 2x, 4x, or 8x for smoother edges
   - **dgVoodoo Watermark**: Uncheck to hide the watermark
3. **General tab** settings:
   - **Appearance**: Windowed or Full Screen
   - **Scaling mode**: How the image is scaled (centered, stretched, etc.)
4. Click **Apply** after making changes

## Game Selection

When you run the script without parameters, it will display an interactive menu with installation status:

```
============================================================
Army Men Games Configuration Tool
============================================================

Select which Army Men game to configure:

1. Army Men (Installed)
2. Army Men II (Not Installed)
3. Army Men RTS (Installed)
4. Army Men: Toys in Space (Installed)

Enter your choice (1-4):
```

The script automatically detects which games are installed and shows their status. You can only configure games that are marked as "(Installed)".

You can also skip the menu by using the `-GameChoice` parameter:
- `.\Configure-ArmyMen.ps1 -GameChoice 1` for Army Men
- `.\Configure-ArmyMen.ps1 -GameChoice 2` for Army Men II
- `.\Configure-ArmyMen.ps1 -GameChoice 3` for Army Men RTS
- `.\Configure-ArmyMen.ps1 -GameChoice 4` for Army Men: Toys in Space

## Contributing

This project uses property-based testing to ensure reliability across different system configurations. When contributing:

1. Add unit tests for new functions
2. Include property-based tests for functions with variable inputs
3. Update documentation for any new features
4. Ensure all tests pass before submitting changes

## Disclaimer

**AI-Assisted Development**: This script was created with assistance from AI tools and may contain errors or unexpected behavior. While extensively tested, users should:

- **Review the script** before running it on their systems
- **Backup important files** before making changes
- **Test in a safe environment** first if possible
- **Report issues** if you encounter problems

The script modifies system registry settings and downloads external files. Use at your own discretion and risk.

## License

This project is provided as-is for educational and personal use. Army Men games are trademarks of their respective owners.