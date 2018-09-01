#
# Misc aws cli commands
#
# Get list of Topics alarms are published to
aws cloudwatch describe-alarms --query "MetricAlarms[].[AlarmName]" --state-value INSUFFICIENT_DATA --output text

# Get list of ec2 instances that have an impaired state 
IMPAIRED=`aws ec2 describe-instance-status --include-all-instances --query \ 
  "InstanceStatuses[].[InstanceId,SystemStatus.Status,InstanceStatus.Status]" --output text \
  grep impaired 

# Get list of ec2 instances that have a specific value in a specific tag
FAILED=`aws ec2 describe-instances --query "Reservations[].Instances[].[Tags[?Key=='buildStatus'] | [0].Value]" --output text | grep failed`

# Get the size of an s3 bucket
STORAGE=`aws cloudwatch get-metric-statistics --profile $PROFILE --region $REGION --metric-name BucketSizeBytes --unit Bytes --start-time 2018-08-21T00:00:00 --end-time 2018-08-22T00:00:00 --period 86400  --namespace AWS/S3 --statistics Average --dimensions Name=BucketName,Value=$BUCKET Name=StorageType,Value=StandardStorage --output text | awk '{print $1 " " $2 " " $3}'`

# Get the number of objects in an s3 bucket
OBJECTS=`aws cloudwatch get-metric-statistics --profile $PROFILE --region $REGION --metric-name NumberOfObjects --unit Count --start-time 2018-08-21T00:00:00 --end-time 2018-08-22T00:00:00 --period 86400  --namespace AWS/S3 --statistics Average --dimensions Name=BucketName,Value=$BUCKET Name=StorageType,Value=AllStorageTypes --output text | awk '{print $2}'`
	
# Get CPU utilization
CPU=`aws cloudwatch get-metric-statistics --metric-name CPUUtilization --start-time "$SDATE"T00:00:00 --end-time "$ENDATE"T00:00:00 --period 3600 --namespace AWS/EC2 --statistics Average --dimensions Name=InstanceId,Value=$INSTANCE --output text | sort -k3 | awk '{print $3 " " $2 " " $1}' 

# Get list of security groups and delete them, delete will fail if group is in use
SGROUPS=($(aws ec2 describe-security-groups --query "SecurityGroups[].[GroupId]" --output text))
for ((j=0;j<${#SGROUPS[@]};j++)); do
	SG=`echo ${SGROUPS[j]} | tr -d "\n" | tr -d "\r"`
	aws ec2 delete-security-group --group-id "$SG"
done

#
# Find ports that are open to the world by security groups 
#
PORTS=($(aws ec2 describe-security-groups --query "SecurityGroups[].[IpPermissions[].[FromPort]]" --output text | sourt -u))
for ((i=0;i<${#PORTS[@]};i++)); do	
	PORT=`echo ${PORT[i]} | tr -d "\n" | tr-d "\r"`
	if [ "$PORT" != "22" ] && [ "$PORT" != "80" ]; then
		OPEN_SG=`aws ec2 delete-security-group --filter "Name=ip-permission.cide,Values=0.0.0.0/0" "Name=ip-permission.from-port,Values=$PORT" --query "SecurityGroups[].[GroupId,GroupName]" --output text | awk '{print $1 " " $2}' `
		echo "$OPEN_SG"
	fi 
done

# Find multi-part uploads
BUCKETS=($(aws s3 ls | awk '{print $3}'))
for ((j=0;j<${#BUCKETS[@]};j++)); do
	BUCKET=`echo ${BUCKETS[j]} | tr -d "\n" | tr -d "\r"`
	echo $BUCKET
	UPLOADS=`aws s3api list-multipart-uploads --bucket $BUCKET \
	  --query "Uploads[].[Initiated,Key,Owner.DisplayName]" --output text`
done

# get instance PrivateIp based upon Tags, pass in the Tag name and value to search for
function get_ip {
	IP=`aws ec2 describe-instances --filter "Name=tag:$1,Values=$2" \
	  --query "Reservations[].Instances[].[PrivateIpAddress]" --output text \
	  head -1`
	  echo "$IP"
}


