LOG_FILE="/root/knu_log/ipmi_event_log.txt"
LAST_ID_FILE="/root/knu_log/last_event_id.txt"

if [[ -f $LAST_ID_FILE ]]; then
	LAST_ID=$(cat $LAST_ID_FILE)
else
	LAST_ID=""
fi

if [[ -z $LAST_ID ]]; then
	ipmitool sel list > /root/knu_log/latest_ipmi_events.txt
else
	ipmitool sel list | awk -v last_id="$LAST_ID" '$1 > last_id' > /tmp/latest_ipmi_events.txt
fi

if [[ -s /root/knu_log/latest_ipmi_events.txt ]]; then
	cat /root/knu_log/latest_ipmi_events.txt >> $LOG_FILE
	LAST_ID=$(tail -n 1 /root/knu_log/latest_ipmi_events.txt | awk '{print $1}')
	echo $LAST_ID > $LAST_ID_FILE
fi

echo "" > /root/knu_log/latest_ipmi_events.txt
