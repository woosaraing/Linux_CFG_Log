#!/bin/bash

LOG_FILE="/root/knu_log/cfg/cfg_event_log"
LAST_ID_FILE="/root/knu_log/cfg/last_event_id"
IPMI="/root/knu_log/cfg/IPMICFG-Linux.x86_64"

LAST_ID=""
if [[ -f "$LAST_ID_FILE" ]]; then
        LAST_ID=$(cat "$LAST_ID_FILE")
fi

FULL_LOG=$($IPMI -sel list)

NEW_LAST_ID=$(echo "$FULL_LOG" |tail -n 2 |grep Event |cut -d ":" -f 2 |cut -d " " -f 1)


if [[ -z "$LAST_ID" ]]; then
    echo "$FULL_LOG" >> "$LOG_FILE"
else
    echo "$FULL_LOG" | awk -v id="$LAST_ID" '
    /Event:/ {
        if (match($0, id)) found = 1
        if (found) {
		if (NR > 1) print prev_line  # 이전 줄 출력
            	print                        # 현재 줄 출력
            	getline next_line            # 다음 줄 읽기
            	print next_line              # 다음 줄 출력
        	}
    	}
    { prev_line = $0 }  # 현재 줄을 prev_line에 저장
    ' >> "$LOG_FILE"
fi
echo "$NEW_LAST_ID" > "$LAST_ID_FILE"
