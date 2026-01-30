#!/bin/bash

################################################################################
# Battery Health Check Script for Jamf Pro Self Service
#
# Author: Ellie Romero
# Email: ellie.romero@jamf.com
# Date: January 30, 2026
# Version: 2.2
#
# Description:
#   Displays battery health information via jamfHelper including failure
#   detection, cycle count, charge level, and battery age.
#   Designed for MacBook deployment via Jamf Pro Self Service.
#
# Usage:
#   Deploy via Self Service policy (recommended)
#   Manual: sudo /path/to/battery_health_check.sh
#
# Parameters:
#   $4 - jamfHelper path (optional, uses default if empty)
#   $5 - Apple coverage URL (optional, default: en_US locale)
#   $6 - Battery icon path (optional, uses system icon)
#   $7 - Coverage icon path (optional, uses system icon)
#
# Exit Codes:
#   0 - Success
#   1 - jamfHelper not found
#   2 - No battery detected (desktop Mac)
#   3 - Failed to collect battery data
#
# Requirements:
#   macOS 13.0+, Jamf Pro agent, MacBook/MacBook Air/MacBook Pro
#
################################################################################

################################################################################
# CONSTANTS
################################################################################

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_JAMFHELPER_NOT_FOUND=1
readonly EXIT_NO_BATTERY=2
readonly EXIT_DATA_COLLECTION_ERROR=3

# Date calculation constants (Apple's battery date encoding)
readonly APPLE_DATE_BASE_YEAR=1980
readonly APPLE_DATE_YEAR_MULTIPLIER=512
readonly APPLE_DATE_MONTH_MULTIPLIER=32
readonly DAYS_PER_YEAR=365.25
readonly SECONDS_PER_DAY=86400

# Status icons
readonly ICON_SUCCESS="✓"
readonly ICON_FAILURE="✗"
readonly ICON_WARNING="⚠"
readonly ICON_NEUTRAL="•"

# Window configuration
readonly WINDOW_TYPE="utility"
readonly DIALOG_TITLE="Battery Health Check"

################################################################################
# JAMF PRO PARAMETERS (with defaults)
################################################################################

jamfHelper="${4:-/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper}"
coverageURL="${5:-https://checkcoverage.apple.com/?locale=en_US}"
batteryIcon="${6:-/System/Library/CoreServices/Batteries.app/Contents/Resources/AppIcon.icns}"
coverageIcon="${7:-/System/Library/CoreServices/Coverage Details.app/Contents/Resources/AppIcon.icns}"

# Static paths
readonly alertIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"

################################################################################
# GLOBAL VARIABLES (initialized empty, populated by functions)
################################################################################

# Raw data (collected once for efficiency)
batteryDataRaw=""
pmsetDataRaw=""

# Battery metrics
failureStatus=""
failureResult=""
batteryCondition=""
conditionIcon=""
cycleCount=""
currentCapacity=""
designCycleCount=""
mfgDate=""
batteryAge=""
chargingStatus=""
powerSource=""

# Display message
message=""

################################################################################
# HELPER FUNCTIONS
################################################################################

################################################################################
# Show jamfHelper dialog (DRY helper)
################################################################################
show_dialog() {
    local title="$1"
    local description="$2"
    local icon="$3"
    local button1="$4"
    local button2="${5:-}"
    local defaultButton="${6:-1}"
    local timeout="${7:-}"
    
    local cmd=("$jamfHelper" -windowType "$WINDOW_TYPE" -title "$title" -description "$description" -icon "$icon")
    
    [[ -n "$button1" ]] && cmd+=(-button1 "$button1")
    [[ -n "$button2" ]] && cmd+=(-button2 "$button2" -cancelButton 2)
    [[ -n "$defaultButton" ]] && cmd+=(-defaultButton "$defaultButton")
    [[ -n "$timeout" ]] && cmd+=(-timeout "$timeout")
    
    "${cmd[@]}"
}

################################################################################
# NUMBERED FUNCTIONS (main workflow)
################################################################################

################################################################################
# 1. Verify jamfHelper exists
################################################################################
check_jamfhelper() {
    if [[ ! -f "$jamfHelper" ]]; then
        echo "Error: jamfHelper not found at $jamfHelper" >&2
        exit "$EXIT_JAMFHELPER_NOT_FOUND"
    fi
}

################################################################################
# 2. Detect if battery exists
################################################################################
check_battery_exists() {
    batteryDataRaw=$(ioreg -r -c "AppleSmartBattery" 2>/dev/null)
    
    if [[ -z "$batteryDataRaw" ]]; then
        show_dialog \
            "$DIALOG_TITLE" \
            "Battery health check cannot be performed on this Mac.

This device does not have a battery (Mac mini, Mac Studio, iMac, Mac Pro, Virtual Machine), or the system does not recognize the battery.

This tool is designed for Laptops only." \
            "$alertIcon" \
            "OK"
        
        exit "$EXIT_NO_BATTERY"
    fi
}

################################################################################
# 3. Collect battery information (optimized - single ioreg call)
################################################################################
collect_battery_info() {
    # Collect pmset data once for efficiency
    pmsetDataRaw=$(pmset -g batt 2>/dev/null)
    
    # Parse battery failure status
    failureStatus=$(echo "$batteryDataRaw" | grep "PermanentFailureStatus" | awk '{print $3}' | sed 's/"//g')
    
    case "$failureStatus" in
        "1")
            failureResult="Battery Failure Detected $ICON_FAILURE"
            ;;
        "0")
            failureResult="No Failure Detected $ICON_SUCCESS"
            ;;
        *)
            failureResult="Status Unknown $ICON_WARNING"
            ;;
    esac
    
    # Get battery condition from macOS system_profiler
    batteryCondition=$(system_profiler SPPowerDataType 2>/dev/null | grep "Condition" | awk -F': ' '{print $2}' | xargs)
    batteryCondition="${batteryCondition:-Normal}"
    
    # Set condition icon based on battery health
    case "$batteryCondition" in
        "Normal")
            conditionIcon="$ICON_SUCCESS"
            ;;
        "Replace Soon"|"Replace Now"|"Service Battery")
            conditionIcon="$ICON_WARNING"
            ;;
        *)
            conditionIcon="$ICON_NEUTRAL"
            ;;
    esac
    
    # Parse battery metrics from stored ioreg data
    # Note: Use grep -v "BatteryData" to avoid pollution from raw battery data sections
    cycleCount=$(echo "$batteryDataRaw" | grep -w "CycleCount" | grep -v "BatteryData" | awk '{print $3}')
    currentCapacity=$(echo "$batteryDataRaw" | grep -w "CurrentCapacity" | grep -v "BatteryData" | awk '{print $3}')
    designCycleCount=$(echo "$batteryDataRaw" | grep -w "DesignCycleCount9C" | awk '{print $3}')
    mfgDate=$(echo "$batteryDataRaw" | grep '"ManufactureDate"' | grep -v "BatteryData" | head -1 | awk '{print $3}')
    
    # Calculate battery age from manufacture date
    calculate_battery_age
    
    # Parse charging status and power source from stored pmset data
    chargingStatus=$(echo "$pmsetDataRaw" | grep -o "'[^']*'" | head -1 | tr -d "'" 2>/dev/null)
    chargingStatus="${chargingStatus:-Unknown}"
    
    powerSource=$(echo "$pmsetDataRaw" | head -1 | awk '{print $4, $5}' | tr -d "'" 2>/dev/null)
    [[ -z "$powerSource" || "$powerSource" == " " ]] && powerSource="Unknown"
    
    # Validate that critical data was successfully collected
    if [[ -z "$cycleCount" || -z "$currentCapacity" ]]; then
        echo "Error: Failed to collect critical battery data" >&2
        
        show_dialog \
            "Data Collection Error" \
            "Unable to retrieve battery information from the system.

This may indicate a hardware or system issue.

Please restart your Mac and try again. If the problem persists, contact IT support." \
            "$alertIcon" \
            "OK"
        
        exit "$EXIT_DATA_COLLECTION_ERROR"
    fi
}

################################################################################
# 3a. Calculate battery age (helper for collect_battery_info)
################################################################################
calculate_battery_age() {
    batteryAge=""
    
    # Validate manufacture date is numeric
    if [[ -z "$mfgDate" || ! "$mfgDate" =~ ^[0-9]+$ ]]; then
        return
    fi
    
    # Decode Apple's date format
    # Apple stores manufacture date as: (year - 1980) * 512 + month * 32 + day
    # Example: June 15, 2020 = (2020-1980)*512 + 6*32 + 15 = 20,687
    local year=$(( (mfgDate / APPLE_DATE_YEAR_MULTIPLIER) + APPLE_DATE_BASE_YEAR ))
    local month=$(( (mfgDate % APPLE_DATE_YEAR_MULTIPLIER) / APPLE_DATE_MONTH_MULTIPLIER ))
    local day=$(( mfgDate % APPLE_DATE_MONTH_MULTIPLIER ))
    
    # Validate date components are within reasonable ranges
    if [[ $year -lt $APPLE_DATE_BASE_YEAR || $year -gt 2100 ]]; then
        return
    fi
    
    if [[ $month -lt 1 || $month -gt 12 ]]; then
        return
    fi
    
    if [[ $day -lt 1 || $day -gt 31 ]]; then
        return
    fi
    
    # Calculate battery age in years
    local mfgDateFormatted
    mfgDateFormatted=$(printf "%04d-%02d-%02d" "$year" "$month" "$day")
    
    local currentDate
    currentDate=$(date +%s)
    
    local mfgDateSeconds
    mfgDateSeconds=$(date -j -f "%Y-%m-%d" "$mfgDateFormatted" +%s 2>/dev/null)
    
    if [[ -n "$mfgDateSeconds" ]]; then
        local ageInDays=$(( (currentDate - mfgDateSeconds) / SECONDS_PER_DAY ))
        local ageInYears
        ageInYears=$(echo "scale=1; $ageInDays / $DAYS_PER_YEAR" | bc 2>/dev/null)
        batteryAge="Battery Age: ${ageInYears} years"
    fi
}

################################################################################
# 4. Build display message
################################################################################
build_message() {
    # Start with failure result and condition (icons on right)
    message="$failureResult
Health Status: $batteryCondition $conditionIcon
"
    
    # Add battery age only if available
    if [[ -n "$batteryAge" ]]; then
        message+="$batteryAge
"
    fi
    
    # Add remaining battery information
    message+="Cycle Count: $cycleCount of $designCycleCount
Current Charge: $currentCapacity%
Power: $powerSource ($chargingStatus)"
}

################################################################################
# 5. Display results to user
################################################################################
display_results() {
    if [[ "$failureStatus" == "1" ]]; then
        # Battery failure detected - show coverage check option
        local userChoice
        userChoice=$(show_dialog \
            "$DIALOG_TITLE" \
            "$message" \
            "$coverageIcon" \
            "Check Coverage" \
            "Close" \
            1)
        
        # If user clicks "Check Coverage", open Apple's website
        if [[ "$userChoice" == "0" ]]; then
            open "$coverageURL"
        fi
    else
        # Normal battery status - show information only
        show_dialog \
            "$DIALOG_TITLE" \
            "$message" \
            "$batteryIcon" \
            "OK"
    fi
}

################################################################################
# MAIN EXECUTION
################################################################################

check_jamfhelper
check_battery_exists
collect_battery_info
build_message
display_results

exit "$EXIT_SUCCESS"
