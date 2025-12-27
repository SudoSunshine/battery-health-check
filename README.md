# Battery Health Check for Jamf Pro

A professional battery health monitoring tool for macOS devices deployed via Jamf Pro Self Service. Displays comprehensive battery information including failure detection, cycle count, charge level, and optional inventory updates.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Jamf Pro](https://img.shields.io/badge/Jamf%20Pro-Required-orange)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-2.1-brightgreen)

## Features

- ✅ **Battery Failure Detection** - Detects hardware failures via PermanentFailureStatus
- ✅ **Health Condition** - Displays macOS native battery condition (Normal/Replace Soon/Service Battery)
- ✅ **Cycle Count Tracking** - Shows current cycles vs. design limit
- ✅ **Battery Age Calculation** - Calculates battery age from manufacture date (when available)
- ✅ **Charge Status** - Current charge level and power source
- ✅ **Optional Inventory Update** - Updates Jamf Pro inventory with progress tracking
- ✅ **Apple Coverage Link** - Direct link to check AppleCare coverage on battery failure
- ✅ **Desktop Mac Detection** - Friendly message for non-laptop devices
- ✅ **Optimized Performance** - Single ioreg call (75% faster than traditional methods)

## Screenshots

### Normal Battery Status
```
No Failure Detected ✓
Health Status: Normal ✓
Battery Age: 2.3 years
Cycle Count: 238 of 1000
Current Charge: 85%
Power: AC Power (charging)
```

### Battery Failure Detected
```
Battery Failure Detected ✗
Health Status: Service Battery ⚠
Cycle Count: 950 of 1000
Current Charge: 45%
Power: Battery Power (discharging)

[Check Coverage] [Close]
```

## Requirements

- macOS 13.0 (Ventura) or later
- Jamf Pro agent installed
- MacBook, MacBook Air, or MacBook Pro (laptops only)
- jamfHelper (included with Jamf Pro)

## Installation

### Via Jamf Pro (Recommended)

1. **Upload Script to Jamf Pro**
   - Navigate to **Settings** → **Computer Management** → **Scripts**
   - Click **New**
   - Name: `Battery Health Check`
   - Copy the contents of `battery_health_check_v2.1.sh`
   - Click **Save**

2. **Create Self Service Policy**
   - Navigate to **Computers** → **Policies**
   - Click **New**
   - Name: `Check Battery Health`
   - Category: `Self Service`
   - Trigger: `None` (Self Service only)
   - Execution Frequency: `Ongoing`

3. **Add Script to Policy**
   - Select **Scripts** tab
   - Click **Configure**
   - Select `Battery Health Check`
   - Priority: `After`
   - Click **Save**

4. **Configure Self Service**
   - Select **Self Service** tab
   - Check **Make the policy available in Self Service**
   - Display Name: `Check Battery Health`
   - Button Name: `Check Battery`
   - Description: 
     ```
     View your Mac's battery health including cycle count, charge status, 
     and battery age. Optionally update your inventory in Jamf Pro.
     ```
   - Category: `Utilities` or `System Health`
   - Click **Save**

### Manual Installation (Testing)

```bash
# Download the script
curl -O https://raw.githubusercontent.com/SudoSunshine/battery-health-check/main/battery_health_check_v2.1.sh

# Make executable
chmod +x battery_health_check_v2.1.sh

# Run
sudo ./battery_health_check_v2.1.sh
```

## Usage

### Via Self Service (End Users)

1. Open **Self Service** app
2. Search for "Check Battery Health" or find in Utilities
3. Click **Check Battery** button
4. View battery health information
5. Optionally click **Recon** to update Jamf inventory

### Via Terminal (Testing)

```bash
# Run with defaults
sudo ./battery_health_check_v2.1.sh

# Test on desktop Mac (should show alert)
sudo ./battery_health_check_v2.1.sh  # On iMac/Mac mini
```

## Parameters

The script accepts optional Jamf Pro parameters for customization:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `$4` | jamfHelper path | `/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper` |
| `$5` | Apple coverage URL | `https://checkcoverage.apple.com/?locale=en_US` |
| `$6` | Battery icon path | System battery icon |
| `$7` | Coverage icon path | System coverage icon |

### Examples

**Spanish Locale:**
Set Parameter 5 to: `https://checkcoverage.apple.com/?locale=es_ES`

**French Locale:**
Set Parameter 5 to: `https://checkcoverage.apple.com/?locale=fr_FR`

**Custom Icon:**
Set Parameter 6 to: `/Library/IT/Icons/custom_battery.icns`

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | jamfHelper not found |
| `2` | No battery detected (desktop Mac) |
| `3` | Failed to collect battery data |

## How It Works

### Data Collection (Optimized)
- **Single ioreg call** - Collects all battery data in one system call (75% faster)
- **Single pmset call** - Gathers power status efficiently
- Parses data from stored variables (no repeated system calls)

### Battery Age Calculation
Decodes Apple's manufacture date encoding:
```
Formula: (year - 1980) * 512 + month * 32 + day
Example: June 15, 2020 = (2020-1980)*512 + 6*32 + 15 = 20,687
```

**Note:** Battery age may not be available on some M-series Macs.

### Recon Progress Tracking
- Real-time progress window
- 30-second refresh intervals
- Counter displays refresh count
- Dynamic status messages
- Success/error notifications

## Troubleshooting

### "jamfHelper not found"
**Solution:** Ensure Jamf Pro agent is installed
```bash
# Check if jamfHelper exists
ls -la "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
```

### "No battery detected"
**Cause:** Script run on desktop Mac (iMac, Mac mini, Mac Pro) or VM  
**Solution:** This is expected - script is for laptops only

### "Failed to collect battery data"
**Solutions:**
1. Restart your Mac
2. Reset SMC (Intel Macs only)
3. Contact IT support if issue persists

### Inventory update fails
**Solutions:**
1. Check internet connection
2. Verify Jamf Pro agent is installed: `/usr/local/bin/jamf`
3. Test manually: `sudo jamf recon`

## Performance

| Metric | Value |
|--------|-------|
| Execution Time | 2-3 seconds |
| Data Collection | 0.3-0.5 seconds (75% faster than v1.x) |
| Memory Usage | <20MB |
| CPU Usage | <5% |
| Recon Time | 60-120 seconds (network dependent) |

## Development

### Testing

```bash
# Syntax check
bash -n battery_health_check_v2.1.sh

# ShellCheck (if installed)
shellcheck battery_health_check_v2.1.sh
```

### Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly on macOS 13+
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

**Ellie Romero**  
📧 ellie.romero@jamf.com

## Acknowledgments

- Jamf Pro community for testing and feedback
- MacAdmins Slack for deployment best practices

## Support

- **Issues:** [GitHub Issues](https://github.com/SudoSunshine/battery-health-check/issues)
- **Discussions:** [GitHub Discussions](https://github.com/SudoSunshine/battery-health-check/discussions)
- **MacAdmins Slack:** #jamf channel

---

**Made with ❤️ for the Mac Admin community**
