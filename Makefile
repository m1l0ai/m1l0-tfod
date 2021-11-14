.PHONY: train setup apply teardown runtask

build-docker:
	docker build -t m1l0/tfod:latest -f Dockerfile .

ecs-push: build-docker
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ECR_TARGET}

	docker tag m1l0/tfod:latest ${AWS_ECR_TARGET}/m1l0/tfod:latest

	docker push ${AWS_ECR_TARGET}/m1l0/tfod:latest

local-run:
	docker run --gpus all --rm -v "${LOCAL_DATA_PATH}":/opt/tfod/records m1l0/tfod:latest "models" "experiments/training" "experiments/exported_model" "records" "Faster R-CNN ResNet101 V1 800x1333" 3 600 1024 50000 1 955

setup:
	terraform -chdir=terraform init

apply:
	terraform -chdir=terraform plan -out=myplan -var-file=config.tfvars
	terraform -chdir=terraform apply myplan

teardown:
	terraform -chdir=terraform destroy -var-file=config.tfvars

runtask:
	terraform -chdir=terraform output -json > configs.json
	./runtask.sh configs.json