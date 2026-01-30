# Battery Health Check for Jamf Pro

Battery monitoring tool for macOS deployed via Jamf Pro Self Service.

![Shell](https://img.shields.io/badge/shell-bash-yellow.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-2.1-green.svg)
![Jamf Pro](https://img.shields.io/badge/Jamf%20Pro-11.0+-orange.svg)
![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)

---

## Features

- Battery failure detection
- Health condition (Normal/Replace Soon/Service Battery)
- Cycle count vs. design limit
- Battery age calculation (when available)
- Current charge and power source
- Optional inventory update
- AppleCare coverage link on failure

---

## Requirements

- macOS 13.0+
- Jamf Pro agent
- MacBook/MacBook Air/MacBook Pro only

---

## Installation

### 1. Upload Script

**Settings** → **Computer Management** → **Scripts** → **New**

- **Name:** Battery Health Check
- **Script:** Paste contents of `battery_health_check_v2.1.sh`
- Save

### 2. Create Policy

**Computers** → **Policies** → **New**

**General:**
- **Name:** Check Battery Health
- **Trigger:** None (Self Service only)
- **Frequency:** Ongoing

**Scripts:**
- Add: Battery Health Check
- Priority: After

**Self Service:**
- Make available in Self Service
- **Display Name:** Check Battery Health
- **Description:** View battery health including cycle count, charge status, and battery age
- **Category:** Utilities

---

## Configuration

Optional parameters for localization:

| Parameter | Purpose | Example |
|-----------|---------|---------|
| $5 | Coverage URL locale | `https://checkcoverage.apple.com/?locale=es_ES` |
| $6 | Battery icon path | `/path/to/icon.icns` |
| $7 | Coverage icon path | `/path/to/icon.icns` |

---

## Performance

- Execution: ~2 seconds
- Data collection: 0.3 seconds (75% faster via single ioreg call)
- Memory: <20MB

---

## Troubleshooting

**No battery detected**  
Expected on desktop Macs (iMac, Mac mini, Mac Pro)

**Inventory update fails**  
Check internet connection and verify Jamf agent: `/usr/local/bin/jamf`

**Data collection error**  
Restart Mac or reset SMC (Intel only)

---

## Development

**Testing:**
```bash
bash -n battery_health_check_v2.1.sh  # Syntax check
sudo ./battery_health_check_v2.1.sh   # Run locally
```

**Version history:**  
See [CHANGELOG.md](CHANGELOG.md)

**Contributing:**  
Test on macOS 13+ before submitting PRs

---

## Technical Details

<details>
<summary>Battery age calculation</summary>

Apple encodes manufacture date as: `(year - 1980) × 512 + month × 32 + day`

Example: June 15, 2020 = 20,687

Note: May not be available on some M-series Macs.
</details>

<details>
<summary>Exit codes</summary>

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | jamfHelper not found |
| 2 | No battery detected |
| 3 | Data collection failed |
</details>

---

## License

MIT - see [LICENSE](LICENSE)

---

## Author

Ellie Romero  
ellie.romero@jamf.com

---

## Support

- [Issues](https://github.com/SudoSunshine/battery-health-check/issues)
- [Discussions](https://github.com/SudoSunshine/battery-health-check/discussions)
- [MacAdmins Slack](https://join.slack.com/t/macadmins/shared_invite/zt-3ixgiyv84-f6Hhnpk36Ep0Ua1nN1OD3g) - #jamf channel
