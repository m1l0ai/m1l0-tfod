#!/bin/bash

set -x

# Script for running one off ECS task via aws cli and jq
config_file=$1

if [[ ! -f ${config_file} ]]; then
	echo "Config file does not exist!"
	exit 1
fi

# Parse config file using jq
profile=$(cat ${config_file} | jq -r '.profile.value')
region=$(cat ${config_file} | jq -r '.region.value')
cluster_name=$(cat ${config_file} | jq -r '.cluster_name.value')
task_definition=$(cat ${config_file} | jq -r '.task_definition.value')
log_group=$(cat ${config_file} | jq -r '.log_group.value')

echo "PROFILE: ${profile}"
echo "REGION: ${region}"
echo "CLUSTER NAME: ${cluster_name}"
echo "TASK DEF: ${task_definition}"
echo "LOG GROUP: ${log_group}"

TASK_ARN=$(aws ecs run-task --cluster ${cluster_name} --task-definition ${task_definition} --profile ${profile} --region ${region} | jq -r '.tasks[].taskArn')

echo "Watching task: ${TASK_ARN}"

status="PENDING"
while [[ $status == "PENDING" ]]; do
	status=$(aws ecs describe-tasks --tasks ${TASK_ARN} --cluster ${cluster_name} | jq -r '.tasks[0] | .lastStatus')

	echo "Task Status: ${status}"

	sleep 5
done

tfod_stream=$(aws --profile ${profile} --region ${region} logs describe-log-streams --log-group-name "${log_group}" | jq -r ."logStreams | .[-1].logStreamName")

if [[ $status == "RUNNING" ]]; then
	echo "Task is running"
	echo "Tailing log..."

	aws --profile ${profile} --region ${region} logs tail /ecs/tfod --log-stream-names "${tfod_stream}" --follow --format short
fi

# If logs exit it means there's no more logs to display
# Assume task has stopped
task_info=$(aws ecs describe-tasks --tasks ${TASK_ARN} --cluster ${cluster_name})
last_status=$(echo $task_info | jq -r '.tasks[0] | .lastStatus')
stop_code=$(echo $task_info | jq -r '.tasks[0] | .stopCode')
stop_reason=$(echo $task_info | jq -r '.tasks[0] | .stoppedReason')
failures=$(echo $task_info | jq -r '.failures')

echo "Task Last Status: ${last_status}"
echo "Stop Code: ${stop_code}"
echo "Stop Reason: ${stop_reason}"
echo "Failures: ${failures[*]}"