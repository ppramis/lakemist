#!/bin/bash
#
# Snippet for passing parameters to a sample cloudformation template
#
function exit_with_error {
	c="$?"
	echo "returned error code: $c; aborting $0"
	exit "$c"
}

PARAMETERS="\
ParameterKey=VpcId,ParameterValue=${VpcId} \
ParameterKey=Network,ParameterValue=${NETWWORK} \
ParameterKey=Environment,ParameterValue=${ENVIRONMENT} \
"

aws cloudformation create-stack --no-verify-ssl --template-body file:://cf-securitygroups.yml --stack-name ${STACK_NAME} --parameters ${$PARAMETERS} --region ${REGION} || exit_with_error

echo "Successfully completed: $0"