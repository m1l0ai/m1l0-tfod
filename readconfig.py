import argparse
import os

from object_detection.utils import config_util


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--num_classes", type=int, help="Number of target labels")
    ap.add_argument("--min_dim", type=int, help="Min dim of input")
    ap.add_argument("--max_dim", type=int, help="Max dim of input")
    ap.add_argument("--num_steps", type=int, help="Num of training epochs")
    ap.add_argument("--batch_size", type=int, default=1, help="Batch size. Set to num of GPUS.")
    ap.add_argument("--num_examples", type=int, help="Total number of bounding boxes in test set.")

    args = vars(ap.parse_args())
    num_classes = args["num_classes"]
    min_dim = args["min_dim"]
    max_dim = args["max_dim"]
    num_steps = args["num_steps"]
    batch_size = args["batch_size"]
    num_examples = args["num_examples"]

    # num_classes = 3
    # min_dim = 600
    # max_dim = 1024
    # num_steps = 50000
    # # batch_size == num of gpus
    # # batch_size = 4
    # batch_size = 1
    # num_examples = 955

    config_file = os.path.join(os.environ.get("PRETRAINED_MODEL_DIR"), "pipeline.config")

    configs = config_util.get_configs_from_pipeline_file(config_file)

    print(configs.keys())

    fine_tune_checkpoint = os.path.join(os.environ.get("PRETRAINED_MODEL_DIR"), "checkpoint", "ckpt-0")
    fine_tune_checkpoint_type = "detection"

    label_map_path = os.path.join(os.environ.get("RECORDS_DIR"), "classes.pbtxt")

    training_record_path = os.path.join(os.environ.get("RECORDS_DIR"), "training.record")

    testing_record_path = os.path.join(os.environ.get("RECORDS_DIR"), "testing.record")

    configs["model"].faster_rcnn.num_classes = num_classes
    configs["model"].faster_rcnn.image_resizer.keep_aspect_ratio_resizer.min_dimension = min_dim
    configs["model"].faster_rcnn.image_resizer.keep_aspect_ratio_resizer.max_dimension = max_dim
    configs["model"].faster_rcnn.image_resizer.keep_aspect_ratio_resizer.pad_to_max_dimension = False

    # Configure train_config num_steps, batch_size etc
    configs["train_config"].batch_size = batch_size
    configs["train_config"].num_steps = num_steps
    configs["train_config"].fine_tune_checkpoint = fine_tune_checkpoint
    configs["train_config"].fine_tune_checkpoint_type = fine_tune_checkpoint_type
    configs["train_config"].from_detection_checkpoint = True

    # configures cosine learning rate decay to match num_steps
    configs["train_config"].optimizer.momentum_optimizer.learning_rate.cosine_decay_learning_rate.total_steps = num_steps
    configs["train_config"].optimizer.momentum_optimizer.learning_rate.cosine_decay_learning_rate.warmup_steps = num_steps // 40

    configs["train_input_config"].label_map_path = label_map_path
    configs["train_input_config"].tf_record_input_reader.input_path[0] = training_record_path

    configs["eval_config"].num_examples = num_examples

    configs["eval_input_config"].label_map_path = label_map_path
    configs["eval_input_config"].tf_record_input_reader.input_path[0] = testing_record_path

    # convert dict back to pipeline_pb2.TrainEvalPipelineConfig
    configs = config_util.create_pipeline_proto_from_configs(configs)

    # save_pipeline_config takes a dir
    save_path = os.path.join(os.environ.get("MODEL_DIR"))
    config_util.save_pipeline_config(configs, save_path)