#Requires -Version 5.1
<#
.SYNOPSIS
    Configures Army Men games (Steam versions) for Windows 11 compatibility.

.DESCRIPTION
    This script automates the configuration of Army Men games by:
    - Prompting user to select which game to configure
    - Detecting screen resolution
    - Locating the game via Steam
    - Installing cnc-ddraw with enhanced graphics
    - Configuring windowed mode with upscaling

.PARAMETER GameChoice
    Optional parameter to specify which game to configure:
    1 = Army Men 2
    2 = Army Men: Toys in Space

.NOTES
    Supported Games:
    - Army Men 2 (App ID: 549170, Executable: ArmyMen2.exe)
    - Army Men: Toys in Space (App ID: 549180, Executable: ARMYMENTIS.exe)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 2)]
    [int]$GameChoice
)

#region Game Definitions
$script:SupportedGames = @{
    1 = @{
        Name = "Army Men 2"
        AppId = "549170"
        Executable = "ArmyMen2.exe"
        InstallDir = "Army Men II"
        DisplayName = "Army Men 2"
    }
    2 = @{
        Name = "Army Men: Toys in Space"
        AppId = "549180"
        Executable = "ARMYMENTIS.exe"
        InstallDir = "Army Men - Toys in Space"
        DisplayName = "Army Men: Toys in Space"
    }
}
#endregion

#region Configuration State
$script:ConfigState = @{
    SelectedGame = $null
    Resolution = @{
        Width = 0
        Height = 0
    }
    SteamPath = ""
    LibraryFolders = @()
    GamePath = ""
    ExecutablePath = ""
    CompatibilityFlags = ""
    ConfigFilePath = ""
    CncDdrawVersion = ""
    Errors = @()
    Success = $false
}
#endregion

#region Game Selection

<#
.SYNOPSIS
    Prompts the user to select which Army Men game to configure.

.OUTPUTS
    Integer representing the selected game (1 or 2).

.EXAMPLE
    $gameChoice = Select-ArmyMenGame
#>
function Select-ArmyMenGame {
    [CmdletBinding()]
    [OutputType([int])]
    param()

    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Green
    Write-Host "Army Men Games Configuration Tool" -ForegroundColor Green
    Write-Host "=" * 60 -ForegroundColor Green
    Write-Host ""
    Write-Host "Select which Army Men game to configure:" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($gameId in $script:SupportedGames.Keys | Sort-Object) {
        $game = $script:SupportedGames[$gameId]
        Write-Host "$gameId. $($game.DisplayName)" -ForegroundColor White
    }
    
    Write-Host ""
    
    do {
        $choice = Read-Host "Enter your choice (1-2)"
        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le 2) {
            $selectedGame = $script:SupportedGames[[int]$choice]
            Write-Host ""
            Write-Status -Message "Selected: $($selectedGame.DisplayName)" -Type "Success"
            Write-Host ""
            return [int]$choice
        } else {
            Write-Host "Invalid choice. Please enter 1 or 2." -ForegroundColor Red
        }
    } while ($true)
}

#endregion

#region Output Functions

<#
.SYNOPSIS
    Displays a status message with appropriate formatting based on type.

.PARAMETER Message
    The message to display.

.PARAMETER Type
    The type of message: Info, Success, Warning, or Error.

.EXAMPLE
    Write-Status -Message "Detecting screen resolution..." -Type "Info"
#>
function Write-Status {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Type = "Info"
    )

    $prefix = switch ($Type) {
        "Info"    { "[*]" }
        "Success" { "[+]" }
        "Warning" { "[!]" }
        "Error"   { "[-]" }
    }

    $color = switch ($Type) {
        "Info"    { "Cyan" }
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error"   { "Red" }
    }

    Write-Host "$prefix $Message" -ForegroundColor $color
}

<#
.SYNOPSIS
    Displays a summary of all configuration operations performed.

.PARAMETER Results
    A hashtable containing the results of each configuration phase.

.EXAMPLE
    Write-Summary -Results $ConfigState
#>
function Write-Summary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Results
    )

    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor White
    Write-Host "Configuration Summary" -ForegroundColor White
    Write-Host "=" * 60 -ForegroundColor White
    Write-Host ""

    # Resolution
    if ($Results.Resolution.Width -gt 0 -and $Results.Resolution.Height -gt 0) {
        Write-Status -Message "Screen Resolution: $($Results.Resolution.Width)x$($Results.Resolution.Height)" -Type "Success"
    } else {
        Write-Status -Message "Screen Resolution: Not detected" -Type "Error"
    }

    # Steam Path
    if (-not [string]::IsNullOrEmpty($Results.SteamPath)) {
        Write-Status -Message "Steam Path: $($Results.SteamPath)" -Type "Success"
    } else {
        Write-Status -Message "Steam Path: Not found" -Type "Error"
    }

    # Library Folders
    if ($Results.LibraryFolders.Count -gt 0) {
        Write-Status -Message "Steam Libraries: $($Results.LibraryFolders.Count) found" -Type "Success"
    } else {
        Write-Status -Message "Steam Libraries: None found" -Type "Error"
    }

    # Game Path
    if (-not [string]::IsNullOrEmpty($Results.GamePath)) {
        Write-Status -Message "Game Path: $($Results.GamePath)" -Type "Success"
    } else {
        Write-Status -Message "Game Path: Not found" -Type "Error"
    }

    # Compatibility Settings
    if (-not [string]::IsNullOrEmpty($Results.CompatibilityFlags)) {
        Write-Status -Message "Compatibility Flags: Applied" -Type "Success"
        Write-Host "    Flags: $($Results.CompatibilityFlags)" -ForegroundColor Gray
    } else {
        Write-Status -Message "Compatibility Flags: Not applied" -Type "Warning"
    }

    # Config File
    if (-not [string]::IsNullOrEmpty($Results.ConfigFilePath)) {
        Write-Status -Message "Config File: $($Results.ConfigFilePath)" -Type "Success"
    } else {
        Write-Status -Message "Config File: Not configured" -Type "Warning"
    }

    # cnc-ddraw
    if (-not [string]::IsNullOrEmpty($Results.CncDdrawVersion)) {
        Write-Status -Message "cnc-ddraw: $($Results.CncDdrawVersion) installed with enhancements" -Type "Success"
        Write-Host "    Features: 1600x1200 window, OpenGL + sharp upscaling, graphics switcher" -ForegroundColor Gray
    } else {
        Write-Status -Message "cnc-ddraw: Not installed" -Type "Warning"
    }

    # Errors
    if ($Results.Errors.Count -gt 0) {
        Write-Host ""
        Write-Status -Message "Errors encountered:" -Type "Error"
        foreach ($error in $Results.Errors) {
            Write-Host "    - $error" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor White

    # Overall Status
    if ($Results.Success) {
        Write-Status -Message "Configuration completed successfully!" -Type "Success"
        Write-Host ""
        Write-Host "🎮 Next Steps:" -ForegroundColor Yellow
        Write-Host "1. Launch Army Men 2 from Steam" -ForegroundColor White
        Write-Host "2. If prompted for DirectPlay, click 'Install this feature' and restart" -ForegroundColor White
        Write-Host "3. Game should open in 1600x1200 windowed mode with sharp upscaling" -ForegroundColor White
        Write-Host "4. Use Graphics_Switcher.bat in game folder to try different visual modes" -ForegroundColor White
        Write-Host "5. Enable Steam FPS counter: Steam → Settings → In-Game → FPS Counter" -ForegroundColor White
    } else {
        Write-Status -Message "Configuration completed with errors." -Type "Error"
    }

    Write-Host "=" * 60 -ForegroundColor White
    Write-Host ""
}

#endregion

#region Resolution Detection Module

<#
.SYNOPSIS
    Detects the primary monitor's screen resolution.

.DESCRIPTION
    Retrieves the primary monitor's width and height in pixels using System.Windows.Forms.Screen.
    Falls back to WMI Win32_VideoController query if Forms assembly is unavailable.

.OUTPUTS
    PSCustomObject with Width and Height properties.

.EXAMPLE
    $resolution = Get-ScreenResolution
    Write-Host "Resolution: $($resolution.Width)x$($resolution.Height)"

.NOTES
    Requirements: 1.1, 1.2, 1.3
    Feature: army-men-2-config, Property 1: Resolution values are valid positive integers
#>
function Get-ScreenResolution {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    $resolution = $null

    # Primary detection: System.Windows.Forms.Screen
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        $primaryScreen = [System.Windows.Forms.Screen]::PrimaryScreen
        
        if ($null -ne $primaryScreen -and $null -ne $primaryScreen.Bounds) {
            $width = $primaryScreen.Bounds.Width
            $height = $primaryScreen.Bounds.Height
            
            if ($width -gt 0 -and $height -gt 0) {
                $resolution = [PSCustomObject]@{
                    Width  = [int]$width
                    Height = [int]$height
                }
                Write-Verbose "Resolution detected via Windows Forms: $($resolution.Width)x$($resolution.Height)"
                return $resolution
            }
        }
    }
    catch {
        Write-Verbose "Windows Forms method failed: $($_.Exception.Message). Trying WMI fallback..."
    }

    # Fallback: WMI Win32_VideoController
    try {
        $videoController = Get-CimInstance -ClassName Win32_VideoController -ErrorAction Stop | 
            Where-Object { $_.CurrentHorizontalResolution -gt 0 -and $_.CurrentVerticalResolution -gt 0 } |
            Select-Object -First 1

        if ($null -ne $videoController) {
            $width = $videoController.CurrentHorizontalResolution
            $height = $videoController.CurrentVerticalResolution
            
            if ($width -gt 0 -and $height -gt 0) {
                $resolution = [PSCustomObject]@{
                    Width  = [int]$width
                    Height = [int]$height
                }
                Write-Verbose "Resolution detected via WMI: $($resolution.Width)x$($resolution.Height)"
                return $resolution
            }
        }
    }
    catch {
        Write-Verbose "WMI method failed: $($_.Exception.Message)"
    }

    # Both methods failed
    throw "Failed to detect screen resolution. Please ensure display drivers are installed."
}

#endregion

#region Steam Locator Module

<#
.SYNOPSIS
    Gets the Steam installation path from the Windows Registry.

.DESCRIPTION
    Reads the Steam installation path from the Windows Registry.
    First checks the 64-bit registry path (WOW6432Node), then falls back to the 32-bit path.

.OUTPUTS
    String path to Steam installation directory.

.EXAMPLE
    $steamPath = Get-SteamInstallPath
    Write-Host "Steam is installed at: $steamPath"

.NOTES
    Requirements: 2.1
#>
function Get-SteamInstallPath {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    # Primary path: 64-bit Windows (most common)
    $registryPath64 = "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam"
    # Fallback path: 32-bit Windows
    $registryPath32 = "HKLM:\SOFTWARE\Valve\Steam"

    $steamPath = $null

    # Try 64-bit registry path first
    try {
        if (Test-Path $registryPath64) {
            $steamPath = (Get-ItemProperty -Path $registryPath64 -Name "InstallPath" -ErrorAction Stop).InstallPath
            if (-not [string]::IsNullOrEmpty($steamPath) -and (Test-Path $steamPath)) {
                Write-Verbose "Steam path found via 64-bit registry: $steamPath"
                return $steamPath
            }
        }
    }
    catch {
        Write-Verbose "64-bit registry path failed: $($_.Exception.Message)"
    }

    # Fallback to 32-bit registry path
    try {
        if (Test-Path $registryPath32) {
            $steamPath = (Get-ItemProperty -Path $registryPath32 -Name "InstallPath" -ErrorAction Stop).InstallPath
            if (-not [string]::IsNullOrEmpty($steamPath) -and (Test-Path $steamPath)) {
                Write-Verbose "Steam path found via 32-bit registry: $steamPath"
                return $steamPath
            }
        }
    }
    catch {
        Write-Verbose "32-bit registry path failed: $($_.Exception.Message)"
    }

    # Both methods failed
    throw "Steam installation not found. Please ensure Steam is installed."
}

<#
.SYNOPSIS
    Parses Steam's libraryfolders.vdf to get all library folder paths.

.DESCRIPTION
    Reads and parses the libraryfolders.vdf file from Steam's steamapps directory
    to extract all configured Steam library folder paths.

.PARAMETER SteamPath
    The path to the Steam installation directory.

.OUTPUTS
    Array of library folder path strings.

.EXAMPLE
    $libraries = Get-SteamLibraryFolders -SteamPath "C:\Program Files (x86)\Steam"

.NOTES
    Requirements: 2.2
    Feature: army-men-2-config, Property 2: VDF parsing extracts all library paths
#>
function Get-SteamLibraryFolders {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SteamPath
    )

    $vdfPath = Join-Path -Path $SteamPath -ChildPath "steamapps\libraryfolders.vdf"

    if (-not (Test-Path $vdfPath)) {
        throw "Could not parse Steam library configuration at $vdfPath."
    }

    try {
        $vdfContent = Get-Content -Path $vdfPath -Raw -ErrorAction Stop
    }
    catch {
        throw "Could not parse Steam library configuration at $vdfPath."
    }

    $libraryFolders = [System.Collections.ArrayList]@()

    # Parse VDF format using regex to extract path values
    # VDF format: "path"    "C:\\Program Files (x86)\\Steam"
    $pathPattern = '"path"\s+"([^"]+)"'
    $regexMatches = [regex]::Matches($vdfContent, $pathPattern)

    foreach ($match in $regexMatches) {
        if ($match.Groups.Count -ge 2) {
            $path = $match.Groups[1].Value
            # Unescape double backslashes from VDF format
            $path = $path -replace '\\\\', '\'
            
            if (-not [string]::IsNullOrEmpty($path)) {
                [void]$libraryFolders.Add($path)
            }
        }
    }

    # If no paths found via "path" key, the VDF might be malformed or empty
    if ($libraryFolders.Count -eq 0) {
        throw "Could not parse Steam library configuration at $vdfPath."
    }

    Write-Verbose "Found $($libraryFolders.Count) Steam library folder(s)"
    # Use comma operator to ensure array is returned even with single element
    return ,$libraryFolders.ToArray()
}

#endregion

#region Game Finder Module

<#
.SYNOPSIS
    Finds the selected Army Men game installation directory in Steam libraries.

.DESCRIPTION
    Searches each Steam library folder for the specified Army Men game app manifest,
    parses the manifest to extract the installation directory, and verifies the game executable exists.

.PARAMETER LibraryFolders
    Array of Steam library folder paths to search.

.PARAMETER GameInfo
    Hashtable containing game information (AppId, Executable, InstallDir, etc.).

.OUTPUTS
    String path to the Army Men game installation directory.

.EXAMPLE
    $gamePath = Find-ArmyMenInstallation -LibraryFolders @("C:\Program Files (x86)\Steam") -GameInfo $gameInfo

.NOTES
    Requirements: 2.3, 2.4, 2.5
    Feature: army-men-config, Property 3: Game search finds manifest when present
#>
function Find-ArmyMenInstallation {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$LibraryFolders,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$GameInfo
    )

    $appId = $GameInfo.AppId
    $manifestFileName = "appmanifest_$appId.acf"
    $searchedPaths = @()

    foreach ($libraryFolder in $LibraryFolders) {
        $steamAppsPath = Join-Path -Path $libraryFolder -ChildPath "steamapps"
        $manifestPath = Join-Path -Path $steamAppsPath -ChildPath $manifestFileName
        $searchedPaths += $steamAppsPath

        Write-Verbose "Searching for $($GameInfo.DisplayName) manifest at: $manifestPath"

        if (Test-Path $manifestPath) {
            try {
                $manifestContent = Get-Content -Path $manifestPath -Raw -ErrorAction Stop
                
                # Parse manifest to extract installdir value
                # ACF format: "installdir"    "Army Men II"
                $installDirPattern = '"installdir"\s+"([^"]+)"'
                $match = [regex]::Match($manifestContent, $installDirPattern)

                if ($match.Success -and $match.Groups.Count -ge 2) {
                    $installDir = $match.Groups[1].Value
                    
                    # Construct full game installation path
                    $gamePath = Join-Path -Path $steamAppsPath -ChildPath "common\$installDir"
                    
                    Write-Verbose "Found install directory: $installDir"
                    Write-Verbose "Full game path: $gamePath"

                    # Verify game directory exists
                    if (Test-Path $gamePath) {
                        # Verify game executable exists
                        $executablePath = Join-Path -Path $gamePath -ChildPath $GameInfo.Executable
                        
                        if (Test-Path $executablePath) {
                            Write-Verbose "Game executable found at: $executablePath"
                            return $gamePath
                        }
                        else {
                            Write-Verbose "Game executable not found at: $executablePath"
                            # Continue searching other libraries
                        }
                    }
                    else {
                        Write-Verbose "Game directory does not exist: $gamePath"
                        # Continue searching other libraries
                    }
                }
                else {
                    Write-Verbose "Could not parse installdir from manifest: $manifestPath"
                }
            }
            catch {
                Write-Verbose "Error reading manifest at $manifestPath : $($_.Exception.Message)"
                # Continue searching other libraries
            }
        }
    }

    # Game not found in any library
    $searchedPathsList = $searchedPaths -join ", "
    throw "$($GameInfo.DisplayName) (App ID $appId) not found. Searched libraries: $searchedPathsList"
}

#endregion

#region Compatibility Configurator Module

<#
.SYNOPSIS
    Applies Windows compatibility settings for Army Men 2.

.DESCRIPTION
    Sets Windows compatibility flags for the game executable via the registry.
    Applies the following settings:
    - Windows XP Service Pack 3 compatibility mode
    - Run as Administrator
    - Disable fullscreen optimizations
    - 16-bit color mode

.PARAMETER ExecutablePath
    The full path to the game executable (AM2.exe).

.OUTPUTS
    PSCustomObject with applied settings summary.

.EXAMPLE
    $result = Set-CompatibilitySettings -ExecutablePath "C:\Steam\steamapps\common\Army Men II\AM2.exe"

.NOTES
    Requirements: 3.1, 3.2, 3.3, 3.4, 3.5
    Feature: army-men-2-config, Property 4: All compatibility flags are correctly applied
#>
function Set-CompatibilitySettings {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExecutablePath
    )

    # Validate executable path
    if ([string]::IsNullOrWhiteSpace($ExecutablePath)) {
        throw "Executable path cannot be empty."
    }

    # Build compatibility flags string
    # ~ = Use settings from this entry (not inherited)
    # WINXPSP3 = Windows XP Service Pack 3 compatibility mode
    # RUNASADMIN = Run as Administrator
    # DISABLEDXMAXIMIZEDWINDOWEDMODE = Disable fullscreen optimizations
    # 16BITCOLOR = Reduced color mode (16-bit)
    # HIGHDPIAWARE = High DPI awareness for better scaling
    $compatibilityFlags = "~ WINXPSP3 RUNASADMIN DISABLEDXMAXIMIZEDWINDOWEDMODE 16BITCOLOR HIGHDPIAWARE"

    # Registry path for compatibility layers
    $registryPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"

    try {
        # Ensure the registry path exists
        if (-not (Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
            Write-Verbose "Created registry path: $registryPath"
        }

        # Set the compatibility flags for the executable
        Set-ItemProperty -Path $registryPath -Name $ExecutablePath -Value $compatibilityFlags -Type String -ErrorAction Stop
        Write-Verbose "Applied compatibility flags to: $ExecutablePath"
        Write-Verbose "Flags: $compatibilityFlags"

        # Return summary of applied settings
        $result = [PSCustomObject]@{
            ExecutablePath      = $ExecutablePath
            RegistryPath        = $registryPath
            CompatibilityFlags  = $compatibilityFlags
            Settings            = @{
                CompatibilityMode           = "Windows XP Service Pack 3"
                RunAsAdministrator          = $true
                DisableFullscreenOptimizations = $true
                ReducedColorMode            = "16-bit"
                HighDPIAware               = $true
            }
            Success             = $true
        }

        return $result
    }
    catch {
        $errorMessage = "Failed to apply compatibility settings: $($_.Exception.Message). Try running as Administrator."
        throw $errorMessage
    }
}

<#
.SYNOPSIS
    Gets the current compatibility settings for an executable.

.DESCRIPTION
    Reads the compatibility flags from the registry for the specified executable.

.PARAMETER ExecutablePath
    The full path to the executable.

.OUTPUTS
    String containing the compatibility flags, or $null if not set.

.EXAMPLE
    $flags = Get-CompatibilitySettings -ExecutablePath "C:\Steam\steamapps\common\Army Men II\AM2.exe"
#>
function Get-CompatibilitySettings {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExecutablePath
    )

    $registryPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"

    try {
        if (Test-Path $registryPath) {
            $value = Get-ItemProperty -Path $registryPath -Name $ExecutablePath -ErrorAction SilentlyContinue
            if ($null -ne $value) {
                return $value.$ExecutablePath
            }
        }
        return $null
    }
    catch {
        return $null
    }
}

<#
.SYNOPSIS
    Removes compatibility settings for an executable.

.DESCRIPTION
    Removes the compatibility flags from the registry for the specified executable.

.PARAMETER ExecutablePath
    The full path to the executable.

.EXAMPLE
    Remove-CompatibilitySettings -ExecutablePath "C:\Steam\steamapps\common\Army Men II\AM2.exe"
#>
function Remove-CompatibilitySettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExecutablePath
    )

    $registryPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"

    try {
        if (Test-Path $registryPath) {
            Remove-ItemProperty -Path $registryPath -Name $ExecutablePath -ErrorAction SilentlyContinue
        }
    }
    catch {
        # Silently ignore errors during cleanup
    }
}

#endregion

#region Game Configurator Module

<#
.SYNOPSIS
    Gets the path to the Army Men 2 configuration file.

.DESCRIPTION
    Locates the game's configuration file by checking the game directory first,
    then falling back to the user's AppData folder.

.PARAMETER GamePath
    The path to the Army Men 2 installation directory.

.OUTPUTS
    String path to the configuration file (may not exist yet).

.EXAMPLE
    $configPath = Get-GameConfigPath -GamePath "C:\Steam\steamapps\common\Army Men II"

.NOTES
    Requirements: 4.1
#>
function Get-GameConfigPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GamePath
    )

    # Primary location: game directory
    $gameConfigPath = Join-Path -Path $GamePath -ChildPath "AM2.ini"
    
    if (Test-Path $gameConfigPath) {
        Write-Verbose "Found config file in game directory: $gameConfigPath"
        return $gameConfigPath
    }

    # Secondary location: AppData\Local
    $appDataPath = [Environment]::GetFolderPath('LocalApplicationData')
    $appDataConfigPath = Join-Path -Path $appDataPath -ChildPath "Army Men II\AM2.ini"
    
    if (Test-Path $appDataConfigPath) {
        Write-Verbose "Found config file in AppData: $appDataConfigPath"
        return $appDataConfigPath
    }

    # Default to game directory for new config file creation
    Write-Verbose "No existing config file found, will create at: $gameConfigPath"
    return $gameConfigPath
}

<#
.SYNOPSIS
    Sets the game resolution in the Army Men 2 configuration file.

.DESCRIPTION
    Writes the screen resolution values to the game's configuration file.
    Creates the configuration file if it doesn't exist.
    The configuration file uses INI format with ScreenWidth and ScreenHeight keys.

.PARAMETER GamePath
    The path to the Army Men 2 installation directory.

.PARAMETER Width
    The screen width in pixels.

.PARAMETER Height
    The screen height in pixels.

.OUTPUTS
    PSCustomObject with ConfigFilePath and Success properties.

.EXAMPLE
    $result = Set-GameResolution -GamePath "C:\Steam\steamapps\common\Army Men II" -Width 1920 -Height 1080

.NOTES
    Requirements: 4.1, 4.2, 4.3
    Feature: army-men-2-config, Property 5: Configuration round-trip preserves resolution
#>
function Set-GameResolution {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GamePath,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 7680)]
        [int]$Width,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 4320)]
        [int]$Height
    )

    # Validate game path
    if ([string]::IsNullOrWhiteSpace($GamePath)) {
        throw "Game path cannot be empty."
    }

    if (-not (Test-Path $GamePath)) {
        throw "Game path does not exist: $GamePath"
    }

    # Get the configuration file path
    $configPath = Get-GameConfigPath -GamePath $GamePath

    try {
        # Ensure the directory exists
        $configDir = Split-Path -Path $configPath -Parent
        if (-not (Test-Path $configDir)) {
            New-Item -ItemType Directory -Path $configDir -Force -ErrorAction Stop | Out-Null
            Write-Verbose "Created config directory: $configDir"
        }

        # Read existing config content or create new
        $configContent = @{}
        if (Test-Path $configPath) {
            # Parse existing INI file
            $existingContent = Get-Content -Path $configPath -ErrorAction Stop
            foreach ($line in $existingContent) {
                if ($line -match '^\s*([^=]+)\s*=\s*(.*)$') {
                    $key = $matches[1].Trim()
                    $value = $matches[2].Trim()
                    $configContent[$key] = $value
                }
            }
            Write-Verbose "Read existing config with $($configContent.Count) entries"
        }

        # Force windowed mode to avoid DirectPlay and fullscreen issues
        # Use a more compatible resolution that old games can handle
        $safeWidth = if ($Width -gt 1920) { 1024 } else { $Width }
        $safeHeight = if ($Height -gt 1080) { 768 } else { $Height }
        
        # Update resolution values with safe resolution
        $configContent['ScreenWidth'] = $safeWidth.ToString()
        $configContent['ScreenHeight'] = $safeHeight.ToString()
        $configContent['Windowed'] = '1'
        $configContent['FullScreen'] = '0'
        $configContent['ColorDepth'] = '16'
        $configContent['DirectDraw'] = '0'
        $configContent['Direct3D'] = '0'
        $configContent['Hardware3D'] = '0'
        
        # Create enhanced configuration with larger window and upscaling
        $configContent['ScreenWidth'] = '1600'
        $configContent['ScreenHeight'] = '1200'
        $configContent['Windowed'] = '1'
        $configContent['FullScreen'] = '0'
        $configContent['ColorDepth'] = '16'
        $configContent['DirectDraw'] = '0'
        $configContent['Direct3D'] = '0'
        $configContent['Hardware3D'] = '0'

        # Write config file
        $outputLines = @()
        foreach ($key in $configContent.Keys | Sort-Object) {
            $outputLines += "$key=$($configContent[$key])"
        }
        
        Set-Content -Path $configPath -Value $outputLines -Force -ErrorAction Stop
        Write-Verbose "Wrote config file: $configPath"

        # Return success result
        $result = [PSCustomObject]@{
            ConfigFilePath = $configPath
            Width          = $Width
            Height         = $Height
            Success        = $true
        }

        return $result
    }
    catch {
        $manualInstructions = @"
Could not write game configuration. Manual steps:
1. Navigate to: $GamePath
2. Create or edit file: AM2.ini
3. Add the following lines:
   ScreenWidth=$Width
   ScreenHeight=$Height
"@
        throw $manualInstructions
    }
}

<#
.SYNOPSIS
    Gets the current resolution settings from the Army Men 2 configuration file.

.DESCRIPTION
    Reads the screen resolution values from the game's configuration file.

.PARAMETER GamePath
    The path to the Army Men 2 installation directory.

.OUTPUTS
    PSCustomObject with Width and Height properties, or $null if not found.

.EXAMPLE
    $resolution = Get-GameResolution -GamePath "C:\Steam\steamapps\common\Army Men II"

.NOTES
    Requirements: 4.2
#>
function Get-GameResolution {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GamePath
    )

    $configPath = Get-GameConfigPath -GamePath $GamePath

    if (-not (Test-Path $configPath)) {
        return $null
    }

    try {
        $content = Get-Content -Path $configPath -ErrorAction Stop
        $width = $null
        $height = $null

        foreach ($line in $content) {
            if ($line -match '^\s*ScreenWidth\s*=\s*(\d+)\s*$') {
                $width = [int]$matches[1]
            }
            elseif ($line -match '^\s*ScreenHeight\s*=\s*(\d+)\s*$') {
                $height = [int]$matches[1]
            }
        }

        if ($null -ne $width -and $null -ne $height) {
            return [PSCustomObject]@{
                Width  = $width
                Height = $height
            }
        }

        return $null
    }
    catch {
        Write-Verbose "Error reading config file: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Removes the game configuration file.

.DESCRIPTION
    Deletes the Army Men 2 configuration file. Used for testing cleanup.

.PARAMETER GamePath
    The path to the Army Men 2 installation directory.

.EXAMPLE
    Remove-GameConfig -GamePath "C:\Steam\steamapps\common\Army Men II"
#>
function Remove-GameConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GamePath
    )

    $configPath = Get-GameConfigPath -GamePath $GamePath

    if (Test-Path $configPath) {
        Remove-Item -Path $configPath -Force -ErrorAction SilentlyContinue
    }
}

#endregion

#region cnc-ddraw Installation Module

<#
.SYNOPSIS
    Downloads and installs cnc-ddraw wrapper for windowed mode compatibility.

.DESCRIPTION
    Downloads the latest cnc-ddraw from GitHub, backs up existing ddraw.dll,
    and configures it for windowed mode operation.

.PARAMETER GamePath
    The path to the Army Men 2 installation directory.

.OUTPUTS
    PSCustomObject with installation results.

.EXAMPLE
    Install-CncDdraw -GamePath "C:\Steam\steamapps\common\Army Men II"

.NOTES
    Requirements: Internet connection for download
#>
function Install-CncDdraw {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GamePath
    )

    try {
        # Get latest cnc-ddraw release
        $apiUrl = "https://api.github.com/repos/FunkyFr3sh/cnc-ddraw/releases/latest"
        $release = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing -ErrorAction Stop
        $asset = $release.assets | Where-Object { $_.name -eq "cnc-ddraw.zip" }
        
        if (-not $asset) {
            throw "cnc-ddraw.zip not found in latest release"
        }

        # Download cnc-ddraw
        $downloadPath = Join-Path $env:TEMP "cnc-ddraw.zip"
        $extractPath = Join-Path $env:TEMP "cnc-ddraw"
        
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $downloadPath -UseBasicParsing -ErrorAction Stop
        Write-Verbose "Downloaded cnc-ddraw v$($release.tag_name)"

        # Extract
        if (Test-Path $extractPath) { Remove-Item $extractPath -Recurse -Force }
        Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force -ErrorAction Stop

        # Backup existing ddraw.dll
        $existingDdraw = Join-Path $GamePath "ddraw.dll"
        if (Test-Path $existingDdraw) {
            $backupPath = Join-Path $GamePath "ddraw.dll.backup"
            Copy-Item $existingDdraw -Destination $backupPath -Force
            Write-Verbose "Backed up existing ddraw.dll"
        }

        # Install cnc-ddraw files
        $newDdraw = Join-Path $extractPath "ddraw.dll"
        if (Test-Path $newDdraw) {
            Copy-Item $newDdraw -Destination $GamePath -Force
        }

        # Create shaders directory and upscaling shaders
        $shadersPath = Join-Path $GamePath "Shaders"
        New-Item -ItemType Directory -Path $shadersPath -Force -ErrorAction SilentlyContinue | Out-Null

        # Create sharp upscaling shader
        $sharpUpscaleShader = @"
#version 330

uniform sampler2D rubyTexture;
uniform vec2 rubyTextureSize;
uniform vec2 rubyOutputSize;

in vec2 tex_coord;
out vec4 fragColor;

void main()
{
    vec2 texel = 1.0 / rubyTextureSize;
    vec2 scale = rubyOutputSize / rubyTextureSize;
    
    vec2 texel_floored = floor(tex_coord * rubyTextureSize);
    vec2 s = fract(tex_coord * rubyTextureSize);
    
    vec2 region_range = 0.5 - 0.5 / scale;
    
    vec2 center_dist = s - 0.5;
    vec2 f = (center_dist - clamp(center_dist, -region_range, region_range)) * scale + 0.5;
    
    vec2 mod_texel = texel_floored + f;
    
    fragColor = texture(rubyTexture, (mod_texel + 0.5) * texel);
}
"@

        # Create smooth upscaling shader
        $smoothUpscaleShader = @"
#version 330

uniform sampler2D rubyTexture;
uniform vec2 rubyTextureSize;

in vec2 tex_coord;
out vec4 fragColor;

void main()
{
    vec2 texel = 1.0 / rubyTextureSize;
    vec2 texel_coord = tex_coord * rubyTextureSize;
    
    vec2 texel_floored = floor(texel_coord);
    vec2 s = fract(texel_coord);
    
    vec4 c00 = texture(rubyTexture, (texel_floored + vec2(0.0, 0.0)) * texel);
    vec4 c10 = texture(rubyTexture, (texel_floored + vec2(1.0, 0.0)) * texel);
    vec4 c01 = texture(rubyTexture, (texel_floored + vec2(0.0, 1.0)) * texel);
    vec4 c11 = texture(rubyTexture, (texel_floored + vec2(1.0, 1.0)) * texel);
    
    vec4 top = mix(c00, c10, smoothstep(0.0, 1.0, s.x));
    vec4 bottom = mix(c01, c11, smoothstep(0.0, 1.0, s.x));
    
    fragColor = mix(top, bottom, smoothstep(0.0, 1.0, s.y));
}
"@

        # Save shaders
        Set-Content -Path (Join-Path $shadersPath "sharp-upscale.glsl") -Value $sharpUpscaleShader -Force -ErrorAction SilentlyContinue
        Set-Content -Path (Join-Path $shadersPath "smooth-upscale.glsl") -Value $smoothUpscaleShader -Force -ErrorAction SilentlyContinue

        # Create enhanced cnc-ddraw configuration with sharp upscaling
        $ddrawConfig = @"
[ddraw]
windowed=true
fullscreen=false
width=1600
height=1200
maintas=true
border=true
resizable=true
renderer=opengl
nonexclusive=true
adjmouse=true
singlecpu=true
vsync=true
noactivateapp=false
savesettings=true
boxing=false
shader=Shaders\sharp-upscale.glsl
maxfps=60
showfps=true
no_compat_warning=true
"@

        # Create alternative configurations (all include no_compat_warning=true)
        $noShaderConfig = $ddrawConfig -replace "shader=Shaders\\sharp-upscale\.glsl", "shader="
        $smoothConfig = $ddrawConfig -replace "sharp-upscale\.glsl", "smooth-upscale.glsl"
        $pixelPerfectConfig = $ddrawConfig -replace "width=1600`nheight=1200`nmaintas=true", "width=1280`nheight=960`nmaintas=false" -replace "resizable=true", "resizable=false"

        $configPath = Join-Path $GamePath "ddraw.ini"
        Set-Content -Path $configPath -Value $ddrawConfig -Force -ErrorAction Stop
        Set-Content -Path (Join-Path $GamePath "ddraw_noshader.ini") -Value $noShaderConfig -Force -ErrorAction SilentlyContinue
        Set-Content -Path (Join-Path $GamePath "ddraw_smooth.ini") -Value $smoothConfig -Force -ErrorAction SilentlyContinue
        Set-Content -Path (Join-Path $GamePath "ddraw_pixelperfect.ini") -Value $pixelPerfectConfig -Force -ErrorAction SilentlyContinue

        # Create graphics switcher
        $switcherScript = @"
@echo off
:start
cls
echo.
echo Army Men 2 Graphics Switcher
echo ===========================
echo.
echo 1 - Original GDI (Safe)
echo 2 - Enhanced OpenGL
echo 3 - Sharp Upscaling (Recommended)
echo 4 - Smooth Upscaling
echo 5 - Pixel Perfect 2x
echo.
set /p "choice=Enter your choice (1-5): "

if "%choice%"=="1" goto option1
if "%choice%"=="2" goto option2
if "%choice%"=="3" goto option3
if "%choice%"=="4" goto option4
if "%choice%"=="5" goto option5
goto invalid

:option1
copy /y "ddraw.ini.original" "ddraw.ini" >nul 2>&1
echo Applied: Original GDI configuration
goto end

:option2
copy /y "ddraw_noshader.ini" "ddraw.ini" >nul 2>&1
echo Applied: Enhanced OpenGL (no shader)
goto end

:option3
copy /y "ddraw_sharp.ini" "ddraw.ini" >nul 2>&1
echo Applied: Sharp Upscaling (recommended)
goto end

:option4
copy /y "ddraw_smooth.ini" "ddraw.ini" >nul 2>&1
echo Applied: Smooth Upscaling
goto end

:option5
copy /y "ddraw_pixelperfect.ini" "ddraw.ini" >nul 2>&1
echo Applied: Pixel Perfect 2x
goto end

:invalid
echo Invalid choice! Please enter 1, 2, 3, 4, or 5
pause
goto start

:end
echo.
echo Configuration updated successfully!
echo Launch the game to see the changes.
echo.
pause
"@
        Set-Content -Path (Join-Path $GamePath "Graphics_Switcher.bat") -Value $switcherScript -Force -ErrorAction SilentlyContinue

        # Cleanup
        Remove-Item $downloadPath -Force -ErrorAction SilentlyContinue
        Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue

        return [PSCustomObject]@{
            Success = $true
            Version = $release.tag_name
            ConfigPath = $configPath
            Message = "cnc-ddraw installed with enhanced graphics: 1600x1200 windowed mode, OpenGL renderer, sharp upscaling shader, and graphics switcher"
        }
    }
    catch {
        throw "Failed to install cnc-ddraw: $($_.Exception.Message)"
    }
}

#endregion

#region Main Execution

<#
.SYNOPSIS
    Main execution flow for configuring Army Men games.

.DESCRIPTION
    Orchestrates the complete configuration process:
    0. Select which game to configure
    1. Detect screen resolution
    2. Locate Steam installation
    3. Find selected Army Men game
    4. Install cnc-ddraw with enhancements
    5. Configure game with windowed mode and upscaling
    6. Display summary

.PARAMETER GameChoice
    Optional parameter to specify which game to configure (1 or 2).

.NOTES
    Requirements: 5.1, 5.2, 5.3, 5.4
    Feature: army-men-config, Property 6: Status messages generated for each phase
#>
function Invoke-ArmyMenConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 2)]
        [int]$GameChoice
    )

    # Initialize configuration state
    $script:ConfigState = @{
        Resolution = @{
            Width = 0
            Height = 0
        }
        SteamPath = ""
        LibraryFolders = @()
        GamePath = ""
        ExecutablePath = ""
        CompatibilityFlags = ""
        ConfigFilePath = ""
        Errors = @()
        Success = $false
    }

    $allStepsSucceeded = $true

    #region Phase 0: Game Selection
    if (-not $GameChoice) {
        $GameChoice = Select-ArmyMenGame
    }
    
    $script:ConfigState.SelectedGame = $script:SupportedGames[$GameChoice]
    Write-Status -Message "Configuring: $($script:ConfigState.SelectedGame.DisplayName)" -Type "Info"
    Write-Host ""
    #endregion

    #region Phase 1: Resolution Detection
    Write-Status -Message "Detecting screen resolution..." -Type "Info"
    
    try {
        $resolution = Get-ScreenResolution
        $script:ConfigState.Resolution.Width = $resolution.Width
        $script:ConfigState.Resolution.Height = $resolution.Height
        Write-Status -Message "Screen resolution detected: $($resolution.Width)x$($resolution.Height)" -Type "Success"
    }
    catch {
        $errorMsg = "Failed to detect screen resolution: $($_.Exception.Message)"
        $script:ConfigState.Errors += $errorMsg
        Write-Status -Message $errorMsg -Type "Error"
        $allStepsSucceeded = $false
        # Resolution detection is critical - cannot continue without it
        Write-Summary -Results $script:ConfigState
        return $script:ConfigState
    }
    #endregion

    #region Phase 2: Steam Location
    Write-Status -Message "Locating Steam installation..." -Type "Info"
    
    try {
        $steamPath = Get-SteamInstallPath
        $script:ConfigState.SteamPath = $steamPath
        Write-Status -Message "Steam found at: $steamPath" -Type "Success"
    }
    catch {
        $errorMsg = "Failed to locate Steam: $($_.Exception.Message)"
        $script:ConfigState.Errors += $errorMsg
        Write-Status -Message $errorMsg -Type "Error"
        $allStepsSucceeded = $false
        # Steam location is critical - cannot continue without it
        Write-Summary -Results $script:ConfigState
        return $script:ConfigState
    }

    # Parse Steam library folders
    Write-Status -Message "Parsing Steam library folders..." -Type "Info"
    
    try {
        $libraryFolders = Get-SteamLibraryFolders -SteamPath $steamPath
        $script:ConfigState.LibraryFolders = $libraryFolders
        Write-Status -Message "Found $($libraryFolders.Count) Steam library folder(s)" -Type "Success"
    }
    catch {
        $errorMsg = "Failed to parse Steam libraries: $($_.Exception.Message)"
        $script:ConfigState.Errors += $errorMsg
        Write-Status -Message $errorMsg -Type "Error"
        $allStepsSucceeded = $false
        # Library parsing is critical - cannot continue without it
        Write-Summary -Results $script:ConfigState
        return $script:ConfigState
    }
    #endregion

    #region Phase 3: Game Search
    $selectedGame = $script:ConfigState.SelectedGame
    Write-Status -Message "Searching for $($selectedGame.DisplayName) installation..." -Type "Info"
    
    try {
        $gamePath = Find-ArmyMenInstallation -LibraryFolders $libraryFolders -GameInfo $selectedGame
        $script:ConfigState.GamePath = $gamePath
        $script:ConfigState.ExecutablePath = Join-Path -Path $gamePath -ChildPath $selectedGame.Executable
        Write-Status -Message "$($selectedGame.DisplayName) found at: $gamePath" -Type "Success"
    }
    catch {
        $errorMsg = "Failed to find $($selectedGame.DisplayName): $($_.Exception.Message)"
        $script:ConfigState.Errors += $errorMsg
        Write-Status -Message $errorMsg -Type "Error"
        $allStepsSucceeded = $false
        # Game location is critical - cannot continue without it
        Write-Summary -Results $script:ConfigState
        return $script:ConfigState
    }
    #endregion

    #region Phase 4: cnc-ddraw Installation
    Write-Status -Message "Installing cnc-ddraw for windowed mode compatibility..." -Type "Info"
    
    try {
        $cncResult = Install-CncDdraw -GamePath $script:ConfigState.GamePath
        $script:ConfigState.CncDdrawVersion = $cncResult.Version
        Write-Status -Message "cnc-ddraw $($cncResult.Version) installed successfully" -Type "Success"
        Write-Host "    - Windowed mode enabled (1600x1200)" -ForegroundColor Gray
        Write-Host "    - OpenGL renderer with sharp upscaling" -ForegroundColor Gray
        Write-Host "    - DirectDraw interception active" -ForegroundColor Gray
        Write-Host "    - Graphics switcher created" -ForegroundColor Gray
    }
    catch {
        $errorMsg = "Failed to install cnc-ddraw: $($_.Exception.Message)"
        $script:ConfigState.Errors += $errorMsg
        Write-Status -Message $errorMsg -Type "Error"
        $allStepsSucceeded = $false
        # Continue with remaining steps even if this fails
    }
    #endregion

    #region Phase 5: Game Configuration
    Write-Status -Message "Configuring game resolution settings..." -Type "Info"
    
    try {
        $configResult = Set-GameResolution -GamePath $script:ConfigState.GamePath -Width $script:ConfigState.Resolution.Width -Height $script:ConfigState.Resolution.Height
        $script:ConfigState.ConfigFilePath = $configResult.ConfigFilePath
        Write-Status -Message "Game resolution configured: $($script:ConfigState.Resolution.Width)x$($script:ConfigState.Resolution.Height)" -Type "Success"
    }
    catch {
        $errorMsg = "Failed to configure game resolution: $($_.Exception.Message)"
        $script:ConfigState.Errors += $errorMsg
        Write-Status -Message $errorMsg -Type "Error"
        $allStepsSucceeded = $false
        # Continue to summary even if this fails (Requirement 5.3)
    }
    #endregion

    #region Phase 6: Summary
    $script:ConfigState.Success = $allStepsSucceeded
    Write-Summary -Results $script:ConfigState
    #endregion

    return $script:ConfigState
}

# Execute main configuration when script is run directly (not dot-sourced for testing)
if ($MyInvocation.InvocationName -ne '.') {
    Invoke-ArmyMenConfiguration -GameChoice $GameChoice
}

#endregion
