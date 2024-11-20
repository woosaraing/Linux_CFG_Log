#!/bin/bash

LOG_FILE="/root/knu_log/cfg/log_message"
LAST_ID_FILE="/root/knu_log/cfg/last_log_id"
IPMI="/root/knu_log/cfg/IPMICFG-Linux.x86_64"

hostname=$(hostname)

while true; do
    LAST_ID=""
    if [[ -f "$LAST_ID_FILE" ]]; then
        LAST_ID=$(cat "$LAST_ID_FILE")
    fi
	
	echo "a"
    FULL_LOG=$($IPMI -sel list)
	echo "b"
    NEW_LAST_ID=$(echo "$FULL_LOG" | tail -n 2 | grep "Event" | cut -d ":" -f 2 | cut -d " " -f 1)

    found=false
    while IFS= read -r line; do
        if [[ "$line" == Event:* ]]; then
            event_id=$(echo "$line" | awk -F " " '{print $1}' | cut -d':' -f2)
            time=$(echo "$line" | awk -F " " '{print $2, $3}' | sed 's/Time://')
            severity=$(echo "$line" | awk -F " " '{print $4}' | cut -d':' -f2)
            sensor_type=$(echo "$line" | awk -F "SensorType:" '{print $2}')

            if [[ "$event_id" == "$LAST_ID" ]]; then
                found=true
		echo "$event_id"
            fi

            if [[ "$found" == true ]]; then
                formatted_date=$(date -d "$time" +"%b %d %H:%M:%S")
                IFS= read -r msg_line
                msg_content=$(echo "$msg_line" | sed 's/^| Msg = //')

                echo "$formatted_date $hostname: Event[$event_id] Severity $severity, SensorType: $sensor_type, $msg_content" >> "$LOG_FILE"
            fi
        fi
    done <<< "$FULL_LOG"
    echo "$NEW_LAST_ID" > "$LAST_ID_FILE"
    sleep 60
done
