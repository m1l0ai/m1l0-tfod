import argparse
import os
import multiprocessing
import concurrent.futures


def stream_file(input_file, output_file):
    writer = open(output_file, "wb", buffering=0)

    with open(input_file, "rb", buffering=0) as fifo:
        print("Reading FIFO pipe...{}".format(input_file))
        bytes_read = writer.write(fifo.read(1024))
        while bytes_read > 0:
            bytes_read = writer.write(fifo.read(1024))

    writer.seek(0)
    writer.close()


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--input_dir", type=str, help="Dir of files to read")
    ap.add_argument("--output_dir", type=str, help="Dir of target file")

    args = vars(ap.parse_args())
    print(args)

    executor = concurrent.futures.ThreadPoolExecutor(max_workers=3)

    for file in os.listdir(args["input_dir"]):
        print(file)
        input_file = os.path.join(args["input_dir"], file)
        output_file = os.path.join(args["output_dir"], file)

        try:
            executor.submit(stream_file, input_file, output_file)
        except FileNotFoundError as e:
            print(str(e))
        except Exception as e:
            print("Failed to copy {} to target dir > {}".format(input_file, output_file))