#!/bin/bash
#
# delete Logstash log files
# preserve last 45 days
# depends on naming convention for log file: mm-dd-yyyy.log
# need to switch the name around to sort properly
#
SDATE=`date -d "-45 days" +%Y-%m-%d`
DIR={some directory}
cd $DIR
LOGS=($(ls -la | grep .log | sort -k9 | awk '{print $9}'))

for LOG in "$LOGS[@]}"; do
	LOG=`echo $LOG | tr -d "\n" | tr -d "\r"
	LOGA=${LOG:6:4}-${LOG:0:5}${LOG:10:4}
	if [[ "$LOGA" < "$SDATE".log ]]; then
		rm "$DIR"/"$LOG"
	else
		echo "Keeping $DIR/$LOG"
	fi
done
	