#!/bin/bash
#
# Set profile from credentials
# Get all regions and loop through
# won't delete groups in use or the default security group in a VPC
#

PROFILE=ppramis-cs-development
REGIONS=($(aws ec2 describe-regions --query "Regions[].[RegionName]" --output text | sort))

#for ((i=0;i<${#REGIONS[@]}; do
	REGION=`echo ${REGIONS[i]} | tr -d "\n" | tr -d "\r"`
	SGROUPS=($(aws ec2 describe-security-groups --profile "$PROFILE" --region "$REGION" --query "SecurityGroups[].[GroupId]" --output text))
	for ((j=0;j<${#SGROUPS[@]};j++)); do
		SG=`echo ${SGROUPS[j]} | tr -d "\n" | tr -d "\r"`
		aws ec2 delete-security-group --region "$REGION" --profile "$PROFILE" --group-id "$SG"
	done
done

