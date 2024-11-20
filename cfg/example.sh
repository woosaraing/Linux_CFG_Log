#!/bin/bash

# 원본 로그 배열
logs=(
	"Event:4089 Time:1970-06-05 21:39:30 Severity:OK SensorType:System NIC"
	"| Msg = [LAN-0005] Dedicated LAN Link Up - Assertion"
	"Event:4090 Time:1970-06-11 11:02:43 Severity:Critical SensorType:Physical Chassis Security"
	"| Msg = [SEC-0000] Chassis Intru, General chassis intrusion - Assertion"
	"Event:4091 Time:1970-06-26 01:29:12 Severity:OK SensorType:System NIC"
	"| Msg = [LAN-0005] Dedicated LAN Link Up - Assertion"
	"Event:4092 Time:1970-07-06 16:57:02 Severity:Critical SensorType:Physical Chassis Security"
	"| Msg = [SEC-0000] Chassis Intru, General chassis intrusion - Assertion"
	"Event:4093 Time:1970-07-06 18:27:23 Severity:OK SensorType:Base OS Boot / Installation Status"
	"| Msg = [SYS-0062] Base OS/Hypervisor Installation started - Assertion"
	"Event:4094 Time:1970-07-06 18:41:06 Severity:OK SensorType:Base OS Boot / Installation Status"
	"| Msg = [SYS-0063] Base OS/Hypervisor Installation completed - Assertion"
	"Event:4095 Time:2024-11-19 09:13:33 Severity:Warning SensorType:System NIC"
	"| Msg = [LAN-0006] Dedicated LAN Link Down - Assertion"
	"Event:4096 Time:2024-11-19 09:13:41 Severity:OK SensorType:System NIC"
	"| Msg = [LAN-0005] Dedicated LAN Link Up - Assertion"
)


# 호스트네임 가져오기
hostname=$(hostname)

# 변환된 로그 출력
for ((i=0; i<${#logs[@]}; i++)); do
  log="${logs[$i]}"

  # Event 줄인지 확인
  if [[ "$log" == Event:* ]]; then
    event_id=$(echo "$log" | awk -F " " '{print $1}' | cut -d':' -f2)
    time=$(echo "$log" | awk -F " " '{print $2, $3}' | sed 's/Time://')
    severity=$(echo "$log" | awk -F " " '{print $4}' | cut -d':' -f2)
    sensor_type=$(echo "$log" | awk -F "SensorType:" '{print $2}')

    # 날짜 변환 (1970-06-26 01:29:12 -> Jun 26 01:29:12)
    formatted_date=$(date -d "$time" +"%b %d %H:%M:%S")

    # Msg 줄을 다음 반복에서 읽어오기 위해 설정
    msg_content=""
    if [[ $((i+1)) -lt ${#logs[@]} && "${logs[$((i+1))]}" == \|* ]]; then
      # Msg 내용에서 "| Msg =" 부분 제거
      msg_content=$(echo "${logs[$((i+1))]}" | sed 's/^| Msg = //')
    fi

    # 변환된 로그 출력 (한 줄로 결합)
    echo "$formatted_date $hostname: Event[$event_id] Severity $severity, SensorType: $sensor_type, $msg_content"
  fi
done
