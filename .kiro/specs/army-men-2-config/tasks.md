# Implementation Plan

- [x] 1. Set up project structure and core script framework





  - Create main script file `Configure-ArmyMen2.ps1`
  - Create `tests/` directory for Pester tests
  - Set up configuration state hashtable structure
  - Implement Write-Status and Write-Summary output functions
  - _Requirements: 5.1, 5.2, 5.4_





- [ ] 2. Implement resolution detection module

  - [ ] 2.1 Create Get-ScreenResolution function



    - Implement primary detection using System.Windows.Forms.Screen
    - Add fallback to WMI Win32_VideoController query

    - Return PSCustomObject with Width and Height properties
    - Handle errors and return appropriate exceptions
    - _Requirements: 1.1, 1.2, 1.3_
  - [ ] 2.2 Write property test for resolution validation

    - **Property 1: Resolution values are valid positive integers**
    - **Validates: Requirements 1.1, 1.2**
  - [ ] 2.3 Write unit tests for resolution detection

    - Test successful resolution retrieval
    - Test fallback mechanism
    - Test error handling when detection fails
    - _Requirements: 1.1, 1.2, 1.3_

- [ ] 3. Implement Steam locator module

  - [ ] 3.1 Create Get-SteamInstallPath function

    - Read Steam path from HKLM:\SOFTWARE\WOW6432Node\Valve\Steam
    - Fall back to HKLM:\SOFTWARE\Valve\Steam for 32-bit systems
    - Return installation path string
    - Throw exception if Steam not found
    - _Requirements: 2.1_
  - [ ] 3.2 Create Get-SteamLibraryFolders function

    - Parse libraryfolders.vdf from Steam's steamapps directory
    - Use regex to extract path values from VDF format
    - Return array of library folder paths
    - Handle malformed VDF with appropriate error
    - _Requirements: 2.2_
  - [ ] 3.3 Write property test for VDF parsing

    - **Property 2: VDF parsing extracts all library paths**
    - **Validates: Requirements 2.2**
  - [ ] 3.4 Write unit tests for Steam locator

    - Test registry path reading
    - Test VDF parsing with sample content
    - Test handling of missing Steam installation
    - _Requirements: 2.1, 2.2_

- [ ] 4. Implement game finder module

  - [ ] 4.1 Create Find-ArmyMen2Installation function

    - Search each library folder for appmanifest_299220.acf
    - Parse manifest to extract installdir value
    - Construct and return full game installation path
    - Verify game executable exists at path
    - Throw exception if game not found in any library
    - _Requirements: 2.3, 2.4, 2.5_
  - [ ] 4.2 Write property test for game search

    - **Property 3: Game search finds manifest when present**
    - **Validates: Requirements 2.3, 2.5**
  - [ ] 4.3 Write unit tests for game finder

    - Test finding game in primary library
    - Test finding game in secondary library
    - Test game not found scenario
    - _Requirements: 2.3, 2.4, 2.5_

- [ ] 5. Checkpoint - Ensure all tests pass

  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Implement compatibility configurator module

  - [ ] 6.1 Create Set-CompatibilitySettings function

    - Build compatibility flags string: ~ WINXPSP3 RUNASADMIN DISABLEDXMAXIMIZEDWINDOWEDMODE 16BITCOLOR
    - Write to HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers
    - Use executable path as registry value name
    - Return summary of applied settings
    - Handle registry write errors with specific messages
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  - [ ] 6.2 Write property test for compatibility flags

    - **Property 4: All compatibility flags are correctly applied**
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
  - [ ] 6.3 Write unit tests for compatibility settings

    - Test all flags present in registry value
    - Test registry path correctness
    - Test error handling for permission issues
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 7. Implement game configurator module

  - [ ] 7.1 Create Set-GameResolution function
    - Locate game configuration file (check game directory and AppData)
    - Create config file if it doesn't exist
    - Write resolution width and height values
    - Return success status
    - Handle file write errors with manual instructions
    - _Requirements: 4.1, 4.2, 4.3_
  - [ ] 7.2 Write property test for configuration round-trip
    - **Property 5: Configuration round-trip preserves resolution**
    - **Validates: Requirements 4.2**
  - [ ] 7.3 Write unit tests for game configuration
    - Test config file creation
    - Test resolution value writing
    - Test reading back written values
    - _Requirements: 4.1, 4.2, 4.3_

- [ ] 8. Integrate all modules into main script

  - [ ] 8.1 Wire up main execution flow
    - Call Get-ScreenResolution and store results
    - Call Get-SteamInstallPath and Get-SteamLibraryFolders
    - Call Find-ArmyMen2Installation with library folders
    - Call Set-CompatibilitySettings with game executable path
    - Call Set-GameResolution with detected resolution
    - Display summary of all operations
    - _Requirements: 5.1, 5.2, 5.3, 5.4_
  - [ ] 8.2 Write property test for status messages
    - **Property 6: Status messages generated for each phase**
    - **Validates: Requirements 5.1, 5.4**
  - [ ] 8.3 Write integration tests
    - Test full script execution flow with mocked dependencies
    - Test error handling and continuation behavior
    - Test final success/failure status reporting
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [ ] 9. Final Checkpoint - Ensure all tests pass

  - Ensure all tests pass, ask the user if questions arise.
