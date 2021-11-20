.PHONY: train local-run ecs-run setup apply teardown rutask-config

build-docker:
	docker build -t m1l0/tfod:latest -f Dockerfile .

ecs-push:
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ECR_TARGET}

	docker tag m1l0/tfod:latest ${AWS_ECR_TARGET}/m1l0/tfod:latest

	docker push ${AWS_ECR_TARGET}/m1l0/tfod:latest

local-run:
	docker run --gpus all --rm -v "${LOCAL_DATA_PATH}":/opt/tfod/records m1l0/tfod:latest "models" "experiments/training" "experiments/exported_model" "records" "faster_rcnn_resnet101_v1_800x1333_coco17_gpu-8" 3 600 1024 50000 1 955

ecs-run:
	docker run --gpus all --rm -e AWS_PROFILE=${AWS_PROFILE} -v "${AWS_ROOT}":"/root/.aws:ro" m1l0/tfod:latest "models" "experiments/training" "experiments/exported_model" ${S3_DATA} "faster_rcnn_resnet101_v1_800x1333_coco17_gpu-8" 3 600 1024 50000 1 955

train:
	python models/research/object_detection/model_main_tf2.py \
	--pipeline_config_path="${PIPELINE_CONFIG_PATH}" \
	--model_dir="${MODEL_DIR}" \
	--num_train_steps=50000 \
	--sample_1_of_n_eval_examples=1 \
	--alsologtostderr

setup:
	terraform -chdir=terraform init

apply:
	terraform -chdir=terraform fmt
	terraform -chdir=terraform validate
	terraform -chdir=terraform plan -out=myplan -var-file=config.tfvars
	terraform -chdir=terraform apply myplan

teardown:
	terraform -chdir=terraform destroy -var-file=config.tfvars

runtask-config:
	terraform -chdir=terraform output -json > configs.json