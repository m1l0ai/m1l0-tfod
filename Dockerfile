ARG TENSORFLOW=2.6.0-gpu

FROM tensorflow/tensorflow:${TENSORFLOW} as builder

SHELL ["/bin/bash", "-c"]

ENV TZ=Europe/Moscow \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8

RUN apt-get update && apt-get install -y \
    git \
    protobuf-compiler \
    curl \
    wget \
    unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws && \
    rm -rf awscliv2.zip

WORKDIR /opt/tfod

COPY train.sh readfifo.py readconfig.py ./
RUN chmod +x train.sh && \
    mkdir -p records experiments/evaluation experiments/exported_model experiments/training

RUN git clone https://github.com/tensorflow/models.git && \
    cd models/research/ && \
    protoc object_detection/protos/*.proto --python_out=. && \
    cp object_detection/packages/tf2/setup.py . && \
    python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install --no-cache-dir . && \
    python3 -m pip install opencv-python-headless==4.5.3.56 && \
    python3 object_detection/builders/model_builder_tf2_test.py


ENTRYPOINT ["/bin/bash", "train.sh"]