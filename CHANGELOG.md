# Changelog

All notable changes to the Battery Health Check script will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1] - 2025-12-18

### Added
- Enhanced header documentation with clear descriptions, usage, and examples
- Jamf binary validation before running recon (prevents Self Service hangs)
- Better error dialogs with actionable suggestions
- Strategic inline comments for complex logic
- JAMF_BINARY constant (removed hardcoded path)

### Changed
- Removed unused SCRIPT_VERSION constant (version in header comment only)
- Improved error message for data collection failures
- Enhanced documentation for maintainability

### Performance
- Line count: 475 lines (lean!)
- Same 75% performance improvement from v2.0

## [2.0] - 2025-12-18

### Added
- All variables organized at top of script
- Constants section for all magic values
- Specific exit codes (0, 1, 2, 3) for better error tracking
- Cleanup trap for temp files
- DRY `show_dialog()` helper function
- Modular `calculate_battery_age()` function
- ShellCheck SC2155 fixes (separate declarations)
- ShellCheck SC2329 directive for trap function

### Changed
- **MAJOR:** Single ioreg call instead of 5+ calls (75% faster data collection)
- Single pmset call instead of 2 calls
- Reorganized code into clear sections
- Improved code modularity

### Performance
- Data collection time: 1.5-2s → 0.3-0.5s (75% improvement)
- System calls reduced by 80%
- Memory usage: <20MB (same as v1.x)

## [1.15] - 2025-12-17

### Added
- Recon progress with 30-second refresh intervals
- Refresh counter display (starting at 0)
- Dynamic status message for ongoing recon

### Changed
- Reverted from 5-second to 30-second refresh to reduce window flashing
- Counter starts at 0 instead of 1
- First message: "Updating inventory..." subsequent: "Still updating inventory..."

### Fixed
- Suppressed "Terminated: 15" messages with wait command

## [1.14] - 2025-12-17

### Changed
- Persistent progress window with no flashing
- Progress window stays visible during entire recon process

## [1.13] - 2025-12-17

### Changed
- Adjusted refresh interval to 5 seconds to reduce window flashing

## [1.12] - 2025-12-17

### Added
- Live elapsed time updates every second during recon

## [1.11] - 2025-12-17

### Added
- Periodic progress updates every 30 seconds during recon

## [1.10] - 2025-12-17

### Fixed
- Recon progress window stays visible during entire process

## [1.9] - 2025-12-17

### Added
- Recon feedback notification after completion
- Updated no-battery message for clarity

## [1.8] - 2025-12-17

### Changed
- Moved status icons to right side of text
- Removed bullet points for cleaner appearance

## [1.7] - 2025-12-17

### Added
- Consistent icons for all display lines

## [1.6] - 2025-12-17

### Changed
- Simplified to use macOS native condition as primary health status

## [1.5] - 2025-12-17

### Changed
- Cleaned up display layout
- Shortened button text

## [1.4] - 2025-12-17

### Added
- macOS battery condition indicator
- Optional inventory update feature

## [1.3] - 2025-12-17

### Fixed
- Battery age calculation accuracy
- Improved error handling for empty values

## [1.2] - 2025-12-17

### Added
- Battery detection for desktop Macs
- Battery age display from manufacture date

## [1.1] - 2025-12-17

### Changed
- Simplified icons to ASCII for better compatibility across macOS versions

## [1.0] - 2025-12-17

### Added
- Initial release
- Battery failure detection via PermanentFailureStatus
- Cycle count display
- Current capacity display
- Charging status
- Power source information
- Apple coverage check link on battery failure
- Emoji icons for status indicators
