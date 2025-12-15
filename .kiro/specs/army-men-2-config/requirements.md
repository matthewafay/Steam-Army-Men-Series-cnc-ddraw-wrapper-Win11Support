# Requirements Document

## Introduction

This document specifies the requirements for a PowerShell script that automates the configuration of Army Men 2 (Steam version) to work properly on Windows 11. The script will detect the user's screen resolution, locate the game installation via Steam, and apply necessary compatibility settings and configuration changes.

## Glossary

- **Configuration Script**: A PowerShell script that automates the setup process for Army Men 2
- **Steam Library**: The directory where Steam stores installed games
- **Registry Settings**: Windows Registry entries that control application compatibility behavior
- **libraryfolders.vdf**: Steam's configuration file that lists all Steam library locations
- **Compatibility Mode**: Windows feature that allows older applications to run with settings from previous Windows versions

## Requirements

### Requirement 1

**User Story:** As a user, I want the script to detect my current screen resolution, so that the game can be configured with the correct display settings.

#### Acceptance Criteria

1. WHEN the script executes THEN the Configuration Script SHALL retrieve the primary monitor's width and height in pixels
2. WHEN the resolution is detected THEN the Configuration Script SHALL store the resolution values for use in game configuration
3. IF the resolution cannot be detected THEN the Configuration Script SHALL display an error message and terminate gracefully

### Requirement 2

**User Story:** As a user, I want the script to automatically find my Army Men 2 installation, so that I don't have to manually specify the game path.

#### Acceptance Criteria

1. WHEN the script executes THEN the Configuration Script SHALL read the Steam installation path from the Windows Registry
2. WHEN the Steam path is found THEN the Configuration Script SHALL parse the libraryfolders.vdf file to identify all Steam library locations
3. WHEN Steam libraries are identified THEN the Configuration Script SHALL search each library for the Army Men 2 installation directory (App ID 299220)
4. IF Army Men 2 is not found in any Steam library THEN the Configuration Script SHALL display an error message indicating the game is not installed
5. WHEN Army Men 2 is located THEN the Configuration Script SHALL store the full installation path for configuration use

### Requirement 3

**User Story:** As a user, I want the script to apply Windows 11 compatibility settings, so that the game runs without crashes or graphical issues.

#### Acceptance Criteria

1. WHEN the game path is confirmed THEN the Configuration Script SHALL set Windows compatibility mode to Windows XP Service Pack 3 for the game executable
2. WHEN applying compatibility settings THEN the Configuration Script SHALL enable "Run as Administrator" for the game executable
3. WHEN applying compatibility settings THEN the Configuration Script SHALL enable "Disable fullscreen optimizations" for the game executable
4. WHEN applying compatibility settings THEN the Configuration Script SHALL enable "Reduced color mode" set to 16-bit for the game executable
5. IF registry modifications fail THEN the Configuration Script SHALL display an error message with the specific failure reason

### Requirement 4

**User Story:** As a user, I want the script to configure the game's resolution settings, so that the game displays correctly on my monitor.

#### Acceptance Criteria

1. WHEN configuration begins THEN the Configuration Script SHALL locate or create the game's configuration file
2. WHEN the configuration file is accessible THEN the Configuration Script SHALL write the detected screen resolution values to the appropriate settings
3. IF the configuration file cannot be written THEN the Configuration Script SHALL display an error message and suggest manual configuration steps

### Requirement 5

**User Story:** As a user, I want clear feedback during the configuration process, so that I know what the script is doing and whether it succeeded.

#### Acceptance Criteria

1. WHEN each major step begins THEN the Configuration Script SHALL display a status message describing the current operation
2. WHEN the configuration completes successfully THEN the Configuration Script SHALL display a summary of all changes made
3. WHEN any step fails THEN the Configuration Script SHALL display a specific error message and continue with remaining steps where possible
4. WHEN the script finishes THEN the Configuration Script SHALL indicate overall success or failure status
