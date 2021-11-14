### M1L0 TFOD Toolkit

[Prepare the dataset]: https://tensorflow-object-detection-api-tutorial.readthedocs.io/en/latest/training.html#preparing-the-dataset

[LISA Traffic signs dataset]: http://cvrr.ucsd.edu/LISA/lisa-traffic-sign-dataset.html

[List of models]: https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/tf2_detection_zoo.md

[EC2 instance types]: https://aws.amazon.com/ec2/instance-types/

[TaskDef docs]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html

[M1L0 Artifacts sidecar]: https://hub.docker.com/r/m1l0/artifactsv2

[sample TFOD project]: https://github.com/cheeyeo/tfod_rcnn_example


Simple set of utils to work with TensorFlow Object detection framework V2.

It packages the TFOD model zoo into a docker container with a custom training script to train a specific object detector on AWS ECS.

It also includes a set of terraform scripts to help with AWS deployment.


**NOTE** There is no support for the preparation of datasets for training with TFOD as its impossible to preempt how the dataset is annotated, in what format, and how to extract the bounding box target values. As such I refer you to the [Prepare the dataset] section on the TFOD documentation or refer to this [sample TFOD project] for more ideas.


### Local Setup

* Build the image and push it to AWS ECR / Dockerhub or use it locally.

	```
	docker build -t mytofd:latest -f Dockerfile .

	# optional but needed to run on AWS
	docker push mytfod:latest
	```

* To run locally:
	```
	export LOCAL_DATA_PATH="dataset"

	docker run \
	--gpus all \
	--rm -v "${LOCAL_DATA_PATH}":/opt/tfod/records -v"${LOCAL_SAVED_MODEL_PATH}":/opt/tfod/experiments/exported_model m1l0/tfod:latest "models" "experiments/training" "experiments/exported_model" "records" "Faster R-CNN ResNet101 V1 800x1333" 3 600 1024 50000 1 955
	```

	The docker image has a working dir of **/opt/tfod** and the above binds the local records dir into **/opt/tfod/records**

	The arguments are passed to `train.sh` and as follows:
	* "models": dir of cloned tfod models repo in container
	* "experiments/training": working dir to store model checkpoints
	* "experiments/exported_model": directory where exported model after training is saved
	* "records": directory of records path in container

	The remaining arguments are used by `readconfig.py` to generate a custom training config file:

	* "Faster R-CNN ResNet101 V1 800x1333": name of pretrained model to use. Refer to the following [List of models]
	* "3": Number of class labels
	* "600": Min dimension to resize images to
	* "1024": Max dimension to resize images to
	* "50000": Number of training steps
	* "1": Batch size. Set this to match number of GPU
	* "955": Size of test set.


### AWS Setup

For training on ECS, the terraform scripts create the following resources:

* Custom VPC with 1 public subnet, 3 private subnets
* ECS cluster
* Required security groups and IAM roles
* 1 EC2 GPU container instance
* Task definition 

Pre-requisities:

* Build and deploy the m1l0/tfod image using the dockerfile provided.

* The [M1L0 Artifacts sidecar] image is defined in the task defintion via config.tfvars and will be used as sidecar container to backup training artifacts to S3

* Edit `terraform/config.tfvars` with the right parameters.

* Run `make setup` to setup terraform

* Run `make apply` to provision the resources

* Once the container instance has connected to the cluster ( check the ECS Agent tab for the cluster), run `make runtask` which invokes `runtask.sh` which creates a training task based on the task definition provided above.

	The script by default tails the training logs of the main TFOD container.

	**NOTE** The script does not exit even if logs have stopped. You need to exit the script manually. 

* If successful, you should see a stream of the logs:

	```
	...

	2021-11-13T21:47:13 INFO:tensorflow:Step 48100 per-step time 0.117s
	2021-11-13T21:47:13 I1113 21:47:13.077878 140227122984768 model_lib_v2.py:700] Step 48100 per-step time 0.117s
	2021-11-13T21:47:13 INFO:tensorflow:{'Loss/BoxClassifierLoss/classification_loss': 0.005494753,
	2021-11-13T21:47:13  'Loss/BoxClassifierLoss/localization_loss': 0.029663853,
	2021-11-13T21:47:13  'Loss/RPNLoss/localization_loss': 0.0020761527,
	2021-11-13T21:47:13  'Loss/RPNLoss/objectness_loss': 0.00037709906,
	2021-11-13T21:47:13  'Loss/regularization_loss': 0.0,
	2021-11-13T21:47:13  'Loss/total_loss': 0.037611857,
	2021-11-13T21:47:13  'learning_rate': 3.7432907e-05}
	2021-11-13T21:47:13 I1113 21:47:13.078210 140227122984768 model_lib_v2.py:701] {'Loss/BoxClassifierLoss/classification_loss': 0.005494753,
	2021-11-13T21:47:13  'Loss/BoxClassifierLoss/localization_loss': 0.029663853,
	2021-11-13T21:47:13  'Loss/RPNLoss/localization_loss': 0.0020761527,
	2021-11-13T21:47:13  'Loss/RPNLoss/objectness_loss': 0.00037709906,
	2021-11-13T21:47:13  'Loss/regularization_loss': 0.0,
	2021-11-13T21:47:13  'Loss/total_loss': 0.037611857,
	2021-11-13T21:47:13  'learning_rate': 3.7432907e-05}
	2021-11-13T21:47:22 INFO:tensorflow:Step 48200 per-step time 0.090s
	2021-11-13T21:47:22 I1113 21:47:22.030618 140227122984768 model_lib_v2.py:700] Step 48200 per-step time 0.090s
	...
	```

* Check the backup_target specified for the artifacts. You should see 2 subfolders in the bucket: `training` and `exported_model`

	The `exported_model` contains the final trained model.

* Exported the saved model to localhost for inference:
	
	```
	aws s3 --recursive s3://exported_model <local dir>
	```

* Test the model with the `predict.py` script:

	```
	python predict.py \
	 --model exported_model \
	 --labels records_dir/classes.pbtxt \
	 --images "image1, image2" 
	 --output_dir "results" \
	 --output_file_prefix "result"
	 --min_confidence 0.5
	```
	The script detects and localizes the found objects within each image by drawing bounding boxes and class label for each of them.

Below are some samples of inference for a model trained on the [LISA Traffic signs dataset]:

![Detect pedestrain sign](examples/pedestrian.png)
![Detect stop sign](examples/stopsign.png)
![Detect signal sign](examples/signal.png)


### Issues

* **NOTE**: Sometimes the provision of p3 ec2 instances might fail due to insufficient resources in the AZ. Change the subnet_id in the ecs instance block in `main.tf` until it works. As of this writing, I am unable to provision beyond `p3.2xlarge` instances


* The ecs instance profile may already exists so need to delete it if it does:

	```
	aws iam list-instance-profiles

	aws iam delete-instance-profile --instance-profile tfod-ecsInstanceProfile
	```

* Number of GPUS used have to match the batch_size in config file else it fails with:

	```
	ValueError: The `global_batch_size` 1 is not divisible by `num_replicas_in_sync` 4 
	```


### References

[Prepare the dataset]

[List of models]

[sample TFOD project]