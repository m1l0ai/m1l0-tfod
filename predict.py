# https://tensorflow-object-detection-api-tutorial.readthedocs.io/en/latest/auto_examples/plot_object_detection_checkpoint.html#sphx-glr-auto-examples-plot-object-detection-checkpoint-py

# Usage
# python predict.py --model lisa/experiments/exported_model \
# --labels lisa/records/classes.pbtxt \
# --num_classes 3 --image lisa/vid0/frameAnnotations-vid_cmp2.avi_annotations/pedestrian_1323804463.avi_image1.png

import argparse
import logging
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2' # Suppress TensorFlow logging (1)
import time

import cv2
import imutils
import numpy as np
import tensorflow as tf
tf.get_logger().setLevel('ERROR') # Suppress TensorFlow logging (2)


from object_detection.utils import label_map_util
from object_detection.utils import config_util
from object_detection.utils import visualization_utils as viz_utils


def load_saved_model(model_path):
    """
    Loads the saved model
    """
    model = tf.saved_model.load(os.path.join(model_path, "saved_model"))
    return model


def load_image(img_path):
    """
    Loads image into np array
    """
    img = cv2.imread(img_path)
    (h, w) = img.shape[:2]

    if w > h and w > 1000:
        img = imutils.resize(img, width=1000)
    elif h > w and h > 1000:
        img = imutils.resize(img, height=1000)

    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    return (h, w), np.asarray(img)


if __name__ == "__main__":
    logger = logging.getLogger()

    ap = argparse.ArgumentParser()
    ap.add_argument("--model", type=str, required=True, help="Path for exported model")
    ap.add_argument("--labels", type=str, required=True, help="Path to Labels File")
    ap.add_argument("--min_confidence", type=float, default=0.5, help="Min prob to filter weak detections...")
    ap.add_argument("--output_dir", type=str, default="testresults", help="Directory to store test results")
    ap.add_argument("--output_file_prefix", type=str, default="result", help="Prefix for output file")
    ap.add_argument("--images", nargs="+", help="Images for inference")

    args = vars(ap.parse_args())

    if not os.path.exists(args["output_dir"]):
        os.mkdir(args["output_dir"])

    gpus = tf.config.list_physical_devices("GPU")
    for gpu in gpus:
        tf.config.experimental.set_memory_growth(gpu, True)

    print("Loading model...")
    start_time = time.time()

    detection_model = load_saved_model(args["model"])

    end_time = time.time()
    elapsed_time = end_time - start_time
    print("Model loading took {} secs".format(elapsed_time))

    category_idx = label_map_util.create_category_index_from_labelmap(args["labels"], use_display_name=True)

    for idx, img in enumerate(args["images"]):
        print("Object detection for image {}".format(img))
        (h, w), image_np = load_image(img)
        input_tensor = tf.convert_to_tensor(image_np)
        input_tensor = np.expand_dims(input_tensor, axis=0)
        image_copy = image_np.copy()

        print("Start detection...")
        start_time = time.time()
        detections = detection_model(input_tensor)
        num_detections = int(detections.pop("num_detections"))
        detections = {key: value[0, :num_detections].numpy() for key, value in detections.items()}
        detections["num_detections"] = num_detections
        detections["detection_classes"] = detections["detection_classes"].astype(np.int64)

        viz_utils.visualize_boxes_and_labels_on_image_array(
            image_copy,
            detections['detection_boxes'],
            detections['detection_classes'],
            detections['detection_scores'],
            category_idx,
            use_normalized_coordinates=True,
            max_boxes_to_draw=200,
            min_score_thresh=args["min_confidence"],
            agnostic_mode=False)

        end_time = time.time()
        elapsed_time = end_time - start_time
        print("Inference took: {} secs".format(elapsed_time))

        # cv2.imshow("Output", image_copy)
        # cv2.waitKey(0)
        saved_path = os.path.join("testresults", "{}{}.png".format(args["output_file_prefix"], idx+1))
        cv2.imwrite(saved_path, image_copy)