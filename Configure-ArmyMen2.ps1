#Requires -Version 5.1
<#
.SYNOPSIS
    Configures Army Men 2 (Steam version) for Windows 11 compatibility.

.DESCRIPTION
    This script automates the configuration of Army Men 2 by:
    - Detecting screen resolution
    - Locating the game via Steam
    - Applying Windows compatibility settings
    - Configuring game-specific resolution settings

.NOTES
    Requirements: 5.1, 5.2, 5.4
#>

[CmdletBinding()]
param()

#region Configuration State
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

#region Main Execution

# Main script execution will be wired up in task 8
# For now, export functions for testing

#endregion
