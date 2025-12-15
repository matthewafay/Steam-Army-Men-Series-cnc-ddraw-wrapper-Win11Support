#Requires -Modules Pester

<#
.SYNOPSIS
    Pester tests for Configure-ArmyMen2.ps1

.DESCRIPTION
    Unit tests and property-based tests for the Army Men 2 configuration script.
#>

# Import the main script to get access to functions
. "$PSScriptRoot\..\Configure-ArmyMen2.ps1"

Describe "Write-Status" {
    # Mock Write-Host to capture output
    Mock Write-Host { $script:CapturedOutput = $Object } -Verifiable

    It "Should output Info messages with [*] prefix" {
        $script:CapturedOutput = ""
        Write-Status -Message "Test message" -Type "Info"
        $script:CapturedOutput | Should Match "\[\*\] Test message"
    }

    It "Should output Success messages with [+] prefix" {
        $script:CapturedOutput = ""
        Write-Status -Message "Test message" -Type "Success"
        $script:CapturedOutput | Should Match "\[\+\] Test message"
    }

    It "Should output Warning messages with [!] prefix" {
        $script:CapturedOutput = ""
        Write-Status -Message "Test message" -Type "Warning"
        $script:CapturedOutput | Should Match "\[!\] Test message"
    }

    It "Should output Error messages with [-] prefix" {
        $script:CapturedOutput = ""
        Write-Status -Message "Test message" -Type "Error"
        $script:CapturedOutput | Should Match "\[-\] Test message"
    }

    It "Should default to Info type when not specified" {
        $script:CapturedOutput = ""
        Write-Status -Message "Default type"
        $script:CapturedOutput | Should Match "\[\*\] Default type"
    }
}

Describe "Write-Summary" {
    # Capture all Write-Host calls
    $script:AllOutput = @()
    Mock Write-Host { $script:AllOutput += $Object }

    It "Should display resolution when detected" {
        $script:AllOutput = @()
        $results = @{
            Resolution = @{ Width = 1920; Height = 1080 }
            SteamPath = ""
            LibraryFolders = @()
            GamePath = ""
            ExecutablePath = ""
            CompatibilityFlags = ""
            ConfigFilePath = ""
            Errors = @()
            Success = $false
        }

        Write-Summary -Results $results
        ($script:AllOutput -join "`n") | Should Match "1920x1080"
    }

    It "Should indicate success when Success is true" {
        $script:AllOutput = @()
        $results = @{
            Resolution = @{ Width = 1920; Height = 1080 }
            SteamPath = "C:\Steam"
            LibraryFolders = @("C:\Steam")
            GamePath = "C:\Steam\steamapps\common\Army Men II"
            ExecutablePath = "C:\Steam\steamapps\common\Army Men II\AM2.exe"
            CompatibilityFlags = "~ WINXPSP3 RUNASADMIN"
            ConfigFilePath = "C:\config.ini"
            Errors = @()
            Success = $true
        }

        Write-Summary -Results $results
        ($script:AllOutput -join "`n") | Should Match "successfully"
    }

    It "Should list errors when present" {
        $script:AllOutput = @()
        $results = @{
            Resolution = @{ Width = 0; Height = 0 }
            SteamPath = ""
            LibraryFolders = @()
            GamePath = ""
            ExecutablePath = ""
            CompatibilityFlags = ""
            ConfigFilePath = ""
            Errors = @("Test error 1", "Test error 2")
            Success = $false
        }

        Write-Summary -Results $results
        ($script:AllOutput -join "`n") | Should Match "Test error 1"
    }
}

#region Property-Based Tests

Describe "Property 1: Resolution values are valid positive integers" -Tag "Property" {
    <#
    .SYNOPSIS
        Property-based test for resolution validation.
    
    .DESCRIPTION
        Feature: army-men-2-config, Property 1: Resolution values are valid positive integers
        Validates: Requirements 1.1, 1.2
        
        For any successful resolution detection, the returned width and height values 
        SHALL be positive integers within the valid monitor resolution range 
        (1 to 7680 for width, 1 to 4320 for height).
    #>

    It "Should return resolution with valid positive integer width and height" {
        # This property test verifies that Get-ScreenResolution returns valid values
        # We run multiple iterations to verify consistency
        $iterations = 100
        
        for ($i = 0; $i -lt $iterations; $i++) {
            $resolution = Get-ScreenResolution
            
            # Property: Width must be a positive integer within valid range
            $resolution.Width.GetType().Name | Should Be "Int32"
            $resolution.Width | Should BeGreaterThan 0
            ($resolution.Width -le 7680) | Should Be $true
            
            # Property: Height must be a positive integer within valid range
            $resolution.Height.GetType().Name | Should Be "Int32"
            $resolution.Height | Should BeGreaterThan 0
            ($resolution.Height -le 4320) | Should Be $true
        }
    }

    It "Should return consistent resolution values across multiple calls" {
        # Property: Resolution detection should be deterministic
        $iterations = 100
        $firstResolution = Get-ScreenResolution
        
        for ($i = 0; $i -lt $iterations; $i++) {
            $resolution = Get-ScreenResolution
            
            # Property: Subsequent calls should return the same values
            $resolution.Width | Should Be $firstResolution.Width
            $resolution.Height | Should Be $firstResolution.Height
        }
    }

    It "Should return a PSCustomObject with Width and Height properties" {
        $iterations = 100
        
        for ($i = 0; $i -lt $iterations; $i++) {
            $resolution = Get-ScreenResolution
            
            # Property: Result must have required properties
            ($resolution.PSObject.Properties.Name -contains "Width") | Should Be $true
            ($resolution.PSObject.Properties.Name -contains "Height") | Should Be $true
        }
    }
}

#endregion

#region Unit Tests - Resolution Detection

Describe "Get-ScreenResolution" -Tag "Unit" {
    <#
    .SYNOPSIS
        Unit tests for resolution detection.
    
    .DESCRIPTION
        Tests for Get-ScreenResolution function.
        Requirements: 1.1, 1.2, 1.3
    #>

    Context "Successful resolution retrieval" {
        It "Should return a PSCustomObject" {
            $resolution = Get-ScreenResolution
            $resolution | Should Not BeNullOrEmpty
            $resolution.GetType().Name | Should Be "PSCustomObject"
        }

        It "Should have Width property" {
            $resolution = Get-ScreenResolution
            $resolution.Width | Should Not BeNullOrEmpty
        }

        It "Should have Height property" {
            $resolution = Get-ScreenResolution
            $resolution.Height | Should Not BeNullOrEmpty
        }

        It "Should return positive width value" {
            $resolution = Get-ScreenResolution
            $resolution.Width | Should BeGreaterThan 0
        }

        It "Should return positive height value" {
            $resolution = Get-ScreenResolution
            $resolution.Height | Should BeGreaterThan 0
        }
    }

    Context "Resolution value types" {
        It "Should return Width as Int32" {
            $resolution = Get-ScreenResolution
            $resolution.Width.GetType().Name | Should Be "Int32"
        }

        It "Should return Height as Int32" {
            $resolution = Get-ScreenResolution
            $resolution.Height.GetType().Name | Should Be "Int32"
        }
    }

    Context "Common resolution detection" {
        It "Should detect a reasonable screen resolution" {
            $resolution = Get-ScreenResolution
            # Most modern displays are at least 800x600
            $resolution.Width | Should BeGreaterThan 799
            $resolution.Height | Should BeGreaterThan 599
        }
    }
}

#endregion

Describe "ConfigState Structure" {
    It "Should have Resolution property with Width and Height" {
        $script:ConfigState | Should Not BeNullOrEmpty
        $script:ConfigState.Resolution | Should Not BeNullOrEmpty
        $script:ConfigState.Resolution.Width | Should Be 0
        $script:ConfigState.Resolution.Height | Should Be 0
    }

    It "Should have SteamPath as empty string" {
        $script:ConfigState.SteamPath | Should Be ""
    }

    It "Should have LibraryFolders as array" {
        $script:ConfigState.LibraryFolders.GetType().BaseType.Name | Should Be "Array"
    }

    It "Should have GamePath as empty string" {
        $script:ConfigState.GamePath | Should Be ""
    }

    It "Should have ExecutablePath as empty string" {
        $script:ConfigState.ExecutablePath | Should Be ""
    }

    It "Should have CompatibilityFlags as empty string" {
        $script:ConfigState.CompatibilityFlags | Should Be ""
    }

    It "Should have ConfigFilePath as empty string" {
        $script:ConfigState.ConfigFilePath | Should Be ""
    }

    It "Should have Errors as array" {
        $script:ConfigState.Errors.GetType().BaseType.Name | Should Be "Array"
    }

    It "Should have Success as false" {
        $script:ConfigState.Success | Should Be $false
    }
}
