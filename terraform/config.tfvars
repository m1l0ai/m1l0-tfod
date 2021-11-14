aws_credentials      = ""
aws_region           = ""
aws_profile          = ""
m1l0_keyname         = ""
public_subnet_count  = 1
private_subnet_count = 3

# NOTE: Sometimes provision can fail as theres not enough capacity for p3 instances

#instance_type = "p3.8xlarge"
#gpus          = 4
#cpu           = 10240
#memory        = 204800


instance_type = "p3.2xlarge"
gpus          = 1
cpu           = 6144
memory        = 53248

# container image of tfod
container_image = ""

# BATCH SIZE MUST MATCH GPUS above..
batch_size       = 1
num_classes      = 3
min_dim          = 600
max_dim          = 1024
num_steps        = 50000
num_examples     = 955
pretrained_model = "Faster R-CNN ResNet101 V1 800x1333"
records_uri      = ""

# container image of artifacts sidecar
backup_image  = "m1l0/artifactsv2:latest"

# target s3 bucket to backup training checkpoints and exported model
backup_bucket = ""