#!/bin/bash
#
# cloudwatch alarm delete if instance no longer exists
#
VALID_INSTANCE_IDS=`aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId]" \
  --filter "Name=instance-state-code,Values=16" --output text`

ALARM_INSTANCE_IDS=`aws cloudwatch describe-alarms --state-value INSUFFICIENT_DATA | \
  jq '.["MetricAlarms"][] | select( .Namespace | contains("STS")) | {InstanceId: .Dimensions[0].Value}' | grep InstanceId | awk -F : '{print $2}' | tr -d '\"'`

for ALARM_INSTANCE_ID in $ALARM_INSTANCE_IDS; do
	FOUND=false
	for VALID_INSTANCE_ID in $VALID_INSTANCE_IDS; do
		if [ "$VALID_INSTANCE_ID" == "$ALARM_INSTANCE_ID" ]; then
			FOUND=true
			echo "Alarm with instance_id $VALID_INSTANCE_ID is valid"
			break
		fi 
	done
	if [ "$FOUND" == "false" ]; then
		echo "The following instance is no longer valid: $ALARM_INSTANCE_ID"
		INSTANCE_ALARM=`aws cloudwatch describe-alarms --state-value INSUFFICIENT_DATA | jq '.["MetricAlarms"][] | select( .Namespace | contains("STS")) | {AlarmName: .AlarmName}' | 	  grep $ALARM_INSTANCE_ID | awk -F : '{print $2}' | tr -d '\"'`
		echo "The following alarm is no longer valid : $INSTANCE_ALARM"
		aws cloudwatch delete-alarms --alarm-names $INSTANCE_ALARM
	fi
done

		