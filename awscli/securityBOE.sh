#!/bin/bash
#
# script creates a csv ready to be imported into Excel.
# the columns are tab-delimited.
# Pass in credential profile and region
if [ "$#" -ne 2]; then
	echo ""
	echo "Invalid parameters"
	echo "$0 error, proper use is $0 [PROFILE] [MISSION]"
	echo ""
	exit 1
fi 

PROFILE=$1
REGION=$2
FILENAME=SecurityBoe-`date +%Y-%m-%d`.csv

#
# Get the VPC Name, VPCID, and CIDR Block from the region
#
echo -e "VPC Name\tVPCID\tCIDR" > "$FILENAME"
VPC=`aws ec2 describe-vpcs --profile "$PROFILE" --region "$REGION" --query "Vpcs[].[Tags[?Key=='Name'] | [0].Value,VpcId,CidrBlock]" --output text`
echo "$VPC" | sed 's/ /\t/' >> "$FILENAME"
echo "" >> "$FILENAME"

#
# Get the Subnets: Name, SubnetId, VPCID, AvailabilityZone
#
echo -e "Subnet-name\tSubnetId\tVpcId\tAvailability-Zone >> "$FILENAME"
SUBNETS=`aws ec2 describe-subnets --profile "$PROFILE" --region "$REGION" --query "Subnets[].[Tags[?Key=='Name'] | [0].Value,SubnetId,VpcId,AvailabilityZone]" --output text | sort -k3`
echo "$SUBNETS" | sed 's/ /\t' >> "$FILENAME"
echo "" >> "$FILENAME"

#
# 
#

