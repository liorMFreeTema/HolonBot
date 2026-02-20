#!/bin/bash

# 1. GET THE RAW DATA
# (Replace these with your actual commands to query the vehicle)
RAW_VERSION_DATA=$(cat /etc/os-release) # Example command
RAW_MCU_DATA=$(echo "MCU Firmware: v2.4.1-stable") # Example command
RAW_FRAMES_DATA=$(echo "Frames per second: 30") # Example command
RAW_EQ_STATUS=$(echo "EyeQ Status: ONLINE | Errors: 0") # Example command

# 2. TEXT ANALYSIS (Extracting the exact values)

# Example A: Use 'awk' to get the text after a specific word or colon
# If RAW_MCU_DATA is "MCU Firmware: v2.4.1-stable", this grabs everything after the colon.
MCU_VERSION=$(echo "$RAW_MCU_DATA" | awk -F': ' '{print $2}')

# Example B: Use 'grep' and 'awk' to pull a specific number
# Extracts just the number "30" from the frames data
FRAMES_RUNNING=$(echo "$RAW_FRAMES_DATA" | grep -oE '[0-9]+')

# Example C: Check if a word exists to create a 1 (Yes) or 0 (No) status
# If "ONLINE" is in the EQ status, set to 1, otherwise 0
if echo "$RAW_EQ_STATUS" | grep -q "ONLINE"; then
    EQ_UP=1
else
    EQ_UP=0
fi

# Example D: Get a string without quotes (e.g., getting the Ubuntu version)
SW_VERSION=$(echo "$RAW_VERSION_DATA" | grep "VERSION_ID" | cut -d'"' -f2)


# 3. FORMAT FOR INFLUXDB (Line Protocol)
# InfluxDB needs data in this exact format: measurement,tag=value field=value,field=value
# Note: String fields must be wrapped in double quotes (\"), numbers are not.

HOSTNAME=$(hostname)

echo "vehicle_telemetry,host=$HOSTNAME mcu_version=\"$MCU_VERSION\",sw_version=\"$SW_VERSION\",frames=$FRAMES_RUNNING,eq_status=$EQ_UP"
