import argparse
import os
import json
import sys

from object_detection.utils import config_util
from object_detection.protos import pipeline_pb2
from google.protobuf import text_format


def _update_optimizer_with_manual_step_learning_rate(
    optimizer, initial_learning_rate, learning_rate_scaling):
    """Adds a learning rate schedule."""
    manual_lr = optimizer.learning_rate.manual_step_learning_rate
    manual_lr.initial_learning_rate = initial_learning_rate
    for i in range(3):
        schedule = manual_lr.schedule.add()
        schedule.step = int(i * 200000 * 4.5)
        schedule.learning_rate = initial_learning_rate * learning_rate_scaling**i

"""
NOTE:

For most config we can specify the full path in the config file e.g. model.faster_rcnn.image_resizer.keep_aspect_ratio_resizer.min_dimension
"""


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--override", type=str, help="Path to override model config")
    ap.add_argument("--hparams", type=str, help="Path to override hyper params")

    args = vars(ap.parse_args())
    print(args)

    # parse model overrides
    config_override = None
    if args["override"] is not None:
        with open(args["override"], "r") as f:
            config_override = f.read()

    config_file = os.path.join(os.environ.get("PRETRAINED_MODEL_DIR"), "pipeline.config")

    label_map_path = os.path.join(os.environ.get("RECORDS_DIR"), "classes.pbtxt")

    training_record_path = os.path.join(os.environ.get("RECORDS_DIR"), "training.record")

    testing_record_path = os.path.join(os.environ.get("RECORDS_DIR"), "testing.record")

    updated_configs = config_util.get_configs_from_pipeline_file(config_file, config_override=config_override)
    print(updated_configs)

    hparams_dict = {}
    hparams_dict["label_map_path"] = label_map_path
    hparams_dict["train_input_path"] = training_record_path
    hparams_dict["eval_input_path"] = testing_record_path

    if args["hparams"] is not None:
        with open(args["hparams"], "r") as f:
            hparams_dict.update(json.loads(f.read()))

    # # Update the hyperparameters using provided json file
    updated_configs = config_util.merge_external_params_with_configs(updated_configs, kwargs_dict=hparams_dict)

    fine_tune_checkpoint = os.path.join(os.environ.get("PRETRAINED_MODEL_DIR"), "checkpoint", "ckpt-0")
    fine_tune_checkpoint_type = hparams_dict.get("fine_tune_checkpoint_type", "classification")
    num_examples = hparams_dict.get("num_examples", None)
    batch_size = hparams_dict.get("batch_size", None)

    updated_configs["train_config"].fine_tune_checkpoint = fine_tune_checkpoint
    updated_configs["train_config"].fine_tune_checkpoint_type = fine_tune_checkpoint_type
    if num_examples is not None:
        updated_configs["eval_config"].num_examples = num_examples

    if batch_size is not None:
        updated_configs["eval_config"].batch_size = batch_size

    print("Updated config \n{}".format(updated_configs))

    configs = config_util.create_pipeline_proto_from_configs(updated_configs)
    # save_pipeline_config takes a dir
    save_path = os.path.join(os.environ.get("MODEL_DIR"))
    config_util.save_pipeline_config(configs, save_path)