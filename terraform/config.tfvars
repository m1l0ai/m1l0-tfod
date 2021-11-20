aws_credentials      = ""
aws_region           = ""
aws_profile          = ""
m1l0_keyname         = ""
public_subnet_count  = 1
private_subnet_count = 1

# NOTE: Sometimes provision can fail as theres not enough capacity for p3 instances

instance_type = "p3.2xlarge"
gpus          = 1
cpu           = 6144
memory        = 53248

# container image of tfod
container_image = ""

# container image of artifacts sidecar
backup_image  = "m1l0/artifactsv2:latest"

# target s3 bucket to backup training checkpoints and exported model
backup_bucket = ""

# Name of top subdir in target bucket
project_name = ""

# Name of unique subdir to store training artifacts to 
project_id = ""

# Subnet to use. Defaults to first subnet (0) if not specified
subnet_id = 0
