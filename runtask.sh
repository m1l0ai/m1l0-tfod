#!/bin/bash

set -x

# Script for running one off ECS task via aws cli and jq
# Usage: runtask <tf output config file> <s3_records_source> <pretrain_model_name> <s3_model_config> <s3_hparams_config>
# E.g. runtask config.json s3://tfod "Faster R-CNN ResNet101 V1 800x1333" s3://tfod/testconfig.config s3://tfod/testparams.json

if [[ $# -ne 5 ]]; then
	echo "Invalid invocation!"
	echo "Usage: $0 <tf output config file> <s3_records_source> <pretrain_model_name> <s3_model_config> <s3_hparams_config>"
	exit 1
fi

config_file=$1
records_source=$2
pretrained_model_name=$3
custom_model_config=$4
custom_model_hparams=$5

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

overrides=$(jq -n \
	            --arg rs "${records_source}" \
	            --arg pmn "${pretrained_model_name}" \
	            --arg cmc "${custom_model_config}" \
	            --arg cmhp "${custom_model_hparams}" \
	            '{containerOverrides: [{"name": "tfod", "command": ["models", "experiments/training", "experiments/exported_model", $rs, $pmn, $cmc, $cmhp]}]}')

TASK_ARN=$(aws ecs run-task --cluster ${cluster_name} --task-definition ${task_definition} --profile ${profile} --region ${region} --overrides "${overrides}" | jq -r '.tasks[].taskArn')

echo "Watching task: ${TASK_ARN}"

status="PENDING"
while [[ $status == "PENDING" ]]; do
	status=$(aws ecs describe-tasks --tasks ${TASK_ARN} --cluster ${cluster_name} | jq -r '.tasks[0] | .lastStatus')

	echo "Task Status: ${status}"

	sleep 5
done

tfod_stream=$(aws --profile ${profile} --region ${region} logs describe-log-streams --log-group-name "${log_group}" | jq -r ."logStreams | .[-1].logStreamName")

if [[ $status == "RUNNING" ]]; then
	echo "Setting up port forwarding for Tensorboard..."
	instance_arn=$(aws ecs describe-tasks --tasks ${TASK_ARN} --cluster ${cluster_name} | jq -r '.tasks[0] | .containerInstanceArn')
  echo "Local port binding to Instance ARN: ${instance_arn}"
  
  container_id=$(aws ecs describe-container-instances --container-instances ${instance_arn} --cluster ${cluster_name} | jq -r '.containerInstances[0] | .ec2InstanceId')
  echo "Setting up local port forwarding for ${container_id}"
  
  aws ssm start-session --target ${container_id} --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["6006"], "localPortNumber":["6006"]}' &
  TFBOARD_PID=$!

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

kill -09 ${TFBOARD_PID}