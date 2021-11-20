#!/bin/bash

set -ex
set -o pipefail

# Function to get TF model zoo download url
download_model_url() {
	case $1 in
	"CenterNet HourGlass104 512x512")
    local tarfile="centernet_hg104_512x512_coco17_tpu-8.tar.gz";;
  "CenterNet HourGlass104 Keypoints 512x512")
    local tarfile="centernet_hg104_512x512_kpts_coco17_tpu-32.tar.gz";;
  "CenterNet HourGlass104 1024x1024")
    local tarfile="centernet_hg104_1024x1024_coco17_tpu-32.tar.gz";;
  "CenterNet HourGlass104 Keypoints 1024x1024")
    local tarfile="centernet_hg104_1024x1024_kpts_coco17_tpu-32.tar.gz";;
  "CenterNet Resnet50 V1 FPN 512x512")
    local tarfile="centernet_resnet50_v1_fpn_512x512_coco17_tpu-8.tar.gz";;
  "CenterNet Resnet50 V1 FPN Keypoints 512x512")
    local tarfile="centernet_resnet50_v1_fpn_512x512_kpts_coco17_tpu-8.tar.gz";;
  "CenterNet Resnet101 V1 FPN 512x512")
    local tarfile="http://download.tensorflow.org/models/object_detection/tf2/20200711/centernet_resnet101_v1_fpn_512x512_coco17_tpu-8.tar.gz";;
  "CenterNet Resnet50 V2 512x512")
    local tarfile="centernet_resnet50_v2_512x512_coco17_tpu-8.tar.gz";;
  "CenterNet Resnet50 V2 Keypoints 512x512")
    local tarfile="centernet_resnet50_v2_512x512_kpts_coco17_tpu-8.tar.gz";;
  "CenterNet MobileNetV2 FPN 512x512")
    local tarfile="centernet_mobilenetv2fpn_512x512_coco17_od.tar.gz";;
  "CenterNet MobileNetV2 FPN Keypoints 512x512")
    local tarfile="centernet_mobilenetv2fpn_512x512_coco17_kpts.tar.gz";;
  "EfficientDet D0 512x512")
    local tarfile="efficientdet_d0_coco17_tpu-32.tar.gz";;
  "EfficientDet D1 640x640")
    local tarfile="efficientdet_d1_coco17_tpu-32.tar.gz";;
  "EfficientDet D2 768x768")
    local tarfile="efficientdet_d2_coco17_tpu-32.tar.gz";;
  "EfficientDet D3 896x896")
    local tarfile="efficientdet_d3_coco17_tpu-32.tar.gz";;
  "EfficientDet D4 1024x1024")
    local tarfile="efficientdet_d4_coco17_tpu-32.tar.gz";;
  "EfficientDet D5 1280x1280")
    local tarfile="efficientdet_d5_coco17_tpu-32.tar.gz";;
  "EfficientDet D6 1280x1280")
    local tarfile="efficientdet_d6_coco17_tpu-32.tar.gz";;
  "EfficientDet D7 1536x1536")
    local tarfile="efficientdet_d7_coco17_tpu-32.tar.gz";;
  "SSD MobileNet v2 320x320")
    local tarfile="ssd_mobilenet_v2_320x320_coco17_tpu-8.tar.gz";;
  "SSD MobileNet V1 FPN 640x640")
    local tarfile="ssd_mobilenet_v1_fpn_640x640_coco17_tpu-8.tar.gz";;
  "SSD MobileNet V2 FPNLite 320x320")
    local tarfile="ssd_mobilenet_v2_fpnlite_320x320_coco17_tpu-8.tar.gz";;
  "SSD MobileNet V2 FPNLite 640x640")
    local tarfile="ssd_mobilenet_v2_fpnlite_640x640_coco17_tpu-8.tar.gz";;
  "SSD ResNet50 V1 FPN 640x640")
    local tarfile="ssd_resnet50_v1_fpn_640x640_coco17_tpu-8.tar.gz";;
  "SSD ResNet50 V1 FPN 1024x1024")
    local tarfile="ssd_resnet50_v1_fpn_1024x1024_coco17_tpu-8.tar.gz";;
  "SSD ResNet101 V1 FPN 640x640")
    local tarfile="ssd_resnet101_v1_fpn_640x640_coco17_tpu-8.tar.gz";;
  "SSD ResNet101 V1 FPN 1024x1024")
    local tarfile="ssd_resnet101_v1_fpn_1024x1024_coco17_tpu-8.tar.gz";;
  "SSD ResNet152 V1 FPN 640x640")
    local tarfile="ssd_resnet152_v1_fpn_640x640_coco17_tpu-8.tar.gz";;
  "SSD ResNet152 V1 FPN 1024x1024")
    local tarfile="ssd_resnet152_v1_fpn_1024x1024_coco17_tpu-8.tar.gz";;
  "Faster R-CNN ResNet50 V1 640x640")
    local tarfile="faster_rcnn_resnet50_v1_640x640_coco17_tpu-8.tar.gz";;
  "Faster R-CNN ResNet50 V1 1024x1024")
    local tarfile="faster_rcnn_resnet50_v1_1024x1024_coco17_tpu-8.tar.gz";;
  "Faster R-CNN ResNet50 V1 800x1333")
    local tarfile="faster_rcnn_resnet50_v1_800x1333_coco17_gpu-8.tar.gz";;
  "Faster R-CNN ResNet101 V1 640x640")
    local tarfile="faster_rcnn_resnet101_v1_640x640_coco17_tpu-8.tar.gz";;
  "Faster R-CNN ResNet101 V1 1024x1024")
    local tarfile="faster_rcnn_resnet101_v1_1024x1024_coco17_tpu-8.tar.gz";;
  "Faster R-CNN ResNet101 V1 800x1333")
    local tarfile="faster_rcnn_resnet101_v1_800x1333_coco17_gpu-8.tar.gz";;
  "Faster R-CNN ResNet152 V1 640x640")
    local tarfile="faster_rcnn_resnet152_v1_640x640_coco17_tpu-8.tar.gz";;
  "Faster R-CNN ResNet152 V1 1024x1024")
    local tarfile="faster_rcnn_resnet152_v1_1024x1024_coco17_tpu-8.tar.gz";;
  "Faster R-CNN ResNet152 V1 800x1333")
    local tarfile="faster_rcnn_resnet152_v1_800x1333_coco17_gpu-8.tar.gz";;
  "Faster R-CNN Inception ResNet V2 640x640")
    local tarfile="faster_rcnn_inception_resnet_v2_640x640_coco17_tpu-8.tar.gz";;
  "Faster R-CNN Inception ResNet V2 1024x1024")
    local tarfile="faster_rcnn_inception_resnet_v2_1024x1024_coco17_tpu-8.tar.gz";;
  "Mask R-CNN Inception ResNet V2 1024x1024")
    local tarfile="mask_rcnn_inception_resnet_v2_1024x1024_coco17_gpu-8.tar.gz";;
	*)
    return 1;;
  esac

  echo ${tarfile}
}

# Function to download the model from TFOD Model zoo v2
download_pretrained_models() {
	MODEL_URL="http://download.tensorflow.org/models/object_detection/tf2/20200711"

	local tarfile=$(download_model_url "$1")

	if [[ ! -z ${tarfile} ]]; then
		echo "Downloading model ${tarfile} to /tmp"
		curl -L -o "/tmp/${tarfile}" ${MODEL_URL}/${tarfile} && \
		tar -zxvf "/tmp/${tarfile}" -C "$MODEL_DIR" && \
		rm -rf "/tmp/${tarfile}"
	else
		echo "No model found!"
		exit 1
	fi
}


# usage: ./train.sh models lisa/experiments/training lisa/experiments/exported_model lisa/records "Faster R-CNN ResNet101 V1 800x1333" <model_config_override> <hyper_params.json>

if [[ $# -ne 7 ]]; then
	echo "Incorrect usage!"
	echo "Usage: $0 <tfod_source_dir> <model_training_dir> <model_export_dir> <records_dir> <pretrained_model_name> <model_config_override> <hyper_params.json>"
	exit 1
fi

echo "Setting up paths for TFOD..."
currentdir=$(pwd)
tfod_dir=${currentdir}/${1}
model_dir=${currentdir}/${2}
exported_dir=${currentdir}/${3}
# generated config file path
pipeline_config="${model_dir}/pipeline.config"

if [[ ${4} == *"s3"* ]]; then
	records_dir=${4}
else
  records_dir=${currentdir}/${4}
fi

model_config=${6}
hparams_config=${7}

echo "Current dir is: ${currentdir}"
echo "TFOD Models dir is: ${tfod_dir}"
echo "Model dir: ${model_dir}"
echo "Exported Dir: ${exported_dir}"
echo "Training Data Dir: ${records_dir}"
echo "Pipeline config filename: ${pipeline_config}"
export PYTHONPATH=${PYTHONPATH}:"${tfod_dir}/research":"${tfod_dir}/research/slim"
echo "Updated PYTHONPATH: ${PYTHONPATH}"

export PIPELINE_CONFIG_PATH="${pipeline_config}"
export MODEL_DIR="${model_dir}"
export EXPORTED_DIR="${exported_dir}"
export RECORDS_DIR="${records_dir}"

echo "Getting pretrained model..."
download_pretrained_models "${5}"

# setting the pretrained model dir
fileurl=$(download_model_url "${5}")
dirname_only=($(echo "${fileurl}" | tr '.' '\n'))

export PRETRAINED_MODEL_DIR="${model_dir}/${dirname_only[0]}"


echo "Getting training data..."
if [[ $records_dir == *"s3"* ]]; then
	echo "S3 FOUND!"

	RECORDS_PATH=/opt/tfod/records

	mkdir -p /tmp/records
	mkfifo /tmp/records/classes.pbtxt
	mkfifo /tmp/records/training.record
	mkfifo /tmp/records/testing.record

	aws s3 cp --cli-read-timeout 0 ${records_dir}/classes.pbtxt - > /tmp/records/classes.pbtxt &

	aws s3 cp --cli-read-timeout 0 ${records_dir}/training.record - > /tmp/records/training.record &

	aws s3 cp --cli-read-timeout 0 ${records_dir}/testing.record - > /tmp/records/testing.record &

	python3 readfifo.py --input_dir /tmp/records --output "${RECORDS_PATH}"

	echo "Waiting for named pipes to close..."
	sleep 5
	echo "Done"

	echo "Removing named pipes"
	rm -rf /tmp/records

	export RECORDS_DIR="${RECORDS_PATH}"
fi


# TODO: FIx
if [[ $hparams_config == *"s3"* ]]; then
  echo "Found hparams file in s3"
  hparams_tmp="/tmp/hparams.json"
  aws s3 cp ${hparams_config} ${hparams_tmp}
  hparams_config=$hparams_tmp
fi

if [[ $model_config == *"s3"* ]]; then
  echo "Found model config file in s3"
  config_tmp="/tmp/model.config"
  aws s3 cp ${model_config} ${config_tmp}
  model_config=$config_tmp
fi

num_steps=$(cat ${hparams_config} | jq -r '.train_steps')
echo "NUM STEPS: ${num_steps}"

echo "Generating config file for training..."
python3 readconfig.py --override=${model_config} \
                      --hparams=${hparams_config}

echo "Running Tensorboard in background..."
tensorboard --logdir "${MODEL_DIR}" --port 6006 --host 0.0.0.0 &
TFBOARD_PID=$!

echo "Starting training process..."
python3 models/research/object_detection/model_main_tf2.py \
	--pipeline_config_path="${PIPELINE_CONFIG_PATH}" \
	--model_dir="${MODEL_DIR}" \
	--num_train_steps=${num_steps} \
	--sample_1_of_n_eval_examples=1 \
	--alsologtostderr

# eval runs in loop for an hour 3600 secs waiting for new checkpoints; set to 300 secs / 5 mins before exiting
echo "Evaluating model..."
python3 models/research/object_detection/model_main_tf2.py \
	--pipeline_config_path="${PIPELINE_CONFIG_PATH}" \
	--model_dir="${MODEL_DIR}" \
	--checkpoint_dir="${MODEL_DIR}" \
	--eval_timeout=300 \
	--alsologtostderr

echo "Exporting model..."
python3 models/research/object_detection/exporter_main_v2.py \
	--input_type image_tensor \
	--pipeline_config_path "${PIPELINE_CONFIG_PATH}" \
	--trained_checkpoint_dir "${MODEL_DIR}" \
	--output_directory "${EXPORTED_DIR}"


kill -09 ${TFBOARD_PID}