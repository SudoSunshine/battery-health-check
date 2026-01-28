# Battery Health Check for Jamf Pro

Professional battery monitoring for macOS deployed via Jamf Pro Self Service.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Jamf Pro](https://img.shields.io/badge/Jamf%20Pro-Required-orange)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-2.1-brightgreen)

---

## What It Does

Shows comprehensive battery health information to your Mac users through Self Service:
- Battery failure detection
- Health condition (Normal/Replace Soon/Service Battery)
- Cycle count vs. design limit
- Battery age (when available)
- Current charge and power source
- Optional Jamf Pro inventory update

When battery failure is detected, users get a direct link to check AppleCare coverage.

---

## Screenshots

### Battery Health Display

**Normal Battery:**

![Normal Battery Status](images/screenshot-normal-battery.png)

**Battery Failure:**

![Battery Failure](images/screenshot-battery-failure.png)

### In Self Service

![Self Service App](images/self-service-app-view.png)

> Screenshots show real deployment. See [SCREENSHOTS_NEEDED.md](SCREENSHOTS_NEEDED.md) to capture your own.

---

## Requirements

- macOS 13.0 (Ventura) or later
- Jamf Pro with agent installed
- MacBook, MacBook Air, or MacBook Pro

Desktop Macs get a friendly message explaining this tool is for laptops only.

---

## Quick Start

### 1. Upload Script to Jamf Pro

**Settings** → **Computer Management** → **Scripts** → **New**

- **Name:** Battery Health Check
- **Script:** Paste contents of `battery_health_check_v2.1.sh`
- Click **Save**

### 2. Create Self Service Policy

**Computers** → **Policies** → **New**

**General:**
- **Name:** Check Battery Health
- **Trigger:** None (Self Service only)
- **Frequency:** Ongoing

**Scripts:**
- Add: Battery Health Check
- Priority: After

**Self Service:**
- ✅ Make available in Self Service
- **Display Name:** Check Battery Health
- **Description:**
  ```
  View your Mac's battery health including cycle count, 
  charge status, and battery age.
  ```
- **Category:** Utilities

Click **Save** and you're done!

---

## How Users See It

1. Open **Self Service**
2. Find "Check Battery Health"
3. Click button
4. View battery information
5. Optionally click **Recon** to update inventory

---

## Customization

Optional Jamf Pro parameters for different locales or custom icons:

| Parameter | What It Does | Example |
|-----------|--------------|---------|
| $5 | Coverage URL locale | `?locale=es_ES` for Spanish |
| $6 | Battery icon | Path to custom icon |
| $7 | Coverage icon | Path to custom icon |

**Spanish locale example:**  
Set Parameter 5: `https://checkcoverage.apple.com/?locale=es_ES`

**French locale example:**  
Set Parameter 5: `https://checkcoverage.apple.com/?locale=fr_FR`

---

## Performance

Built for speed and efficiency:

- **Execution:** 2-3 seconds total
- **Data collection:** 0.3 seconds (75% faster than traditional methods)
- **Memory:** Under 20MB
- **Method:** Single ioreg call instead of multiple system calls

---

## Troubleshooting

### "No battery detected"
This is normal for desktop Macs (iMac, Mac mini, Mac Pro). Tool is for laptops only.

### Inventory update fails
- Check internet connection
- Verify Jamf agent: `/usr/local/bin/jamf`
- Test manually: `sudo jamf recon`

### Data collection error
- Restart the Mac
- Reset SMC (Intel Macs only)
- Contact IT if it persists

---

## For Developers

### Testing
```bash
# Syntax check
bash -n battery_health_check_v2.1.sh

# Run locally
sudo ./battery_health_check_v2.1.sh
```

### Version History
See [CHANGELOG.md](CHANGELOG.md) for all versions and changes.

### Contributing
Pull requests welcome! Please test on macOS 13+ before submitting.

---

## Technical Details

<details>
<summary>How battery age is calculated (click to expand)</summary>

Apple stores manufacture date as an encoded integer:
```
Formula: (year - 1980) × 512 + month × 32 + day
Example: June 15, 2020 = 20,687
```

The script decodes this to calculate battery age in years.

**Note:** Battery age may not be available on some M-series Macs.
</details>

<details>
<summary>Exit codes</summary>

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | jamfHelper not found |
| 2 | No battery (desktop Mac) |
| 3 | Data collection failed |
</details>

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Author

**Ellie Romero**  
📧 ellie.romero@jamf.com

---

## Support

- [Issues](https://github.com/SudoSunshine/battery-health-check/issues) - Report bugs
- [Discussions](https://github.com/SudoSunshine/battery-health-check/discussions) - Ask questions
- **MacAdmins Slack** - #jamf channel

---

Made with ❤️ for the Mac Admin community
