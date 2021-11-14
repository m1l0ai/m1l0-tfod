variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "aws_credentials" {
  description = "Path to AWS credentials"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_profile" {
  description = "AWS Profile to use"
  type        = string
  default     = ""
  sensitive   = true
}

variable "m1l0_keyname" {
  description = "Name of M1L0 SSH key"
  type        = string
  default     = "M1L0Key"
}

variable "tfod_service_name" {
  description = "Name of TFOD"
  type        = string
  default     = "tfod"
}

variable "vpc_cidr_block" {
  description = "CIDR Block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR block for private subnet"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24"
  ]
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR Block for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24"
  ]
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = ""
}

variable "container_image" {
  description = "Docker image name for TFOD"
  type        = string
  default     = ""
}

variable "gpus" {
  description = "Number of gpus to use"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "vCPU to use for task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory to use for task"
  type        = number
  default     = 512
}

variable "num_classes" {
  description = "Number of categories for training"
  type        = number
  default     = 1
}

variable "min_dim" {
  description = "Minimum dimension for input image"
  type        = number
  default     = 600
}

variable "max_dim" {
  description = "Maximum dimension for input image"
  type        = number
  default     = 1024
}

variable "num_steps" {
  description = "Num of training epochs"
  type        = number
  default     = 50000
}

variable "batch_size" {
  description = "Training Batch size"
  type        = number
  default     = 1
}

variable "num_examples" {
  description = "Num of samples for evaluation"
  type        = number
  default     = 1
}

variable "backup_image" {
  description = "Docker image name for backing up artifacts"
  type        = string
  default     = ""
}

variable "backup_bucket" {
  description = "S3 Bucket to store artifacts"
  type        = string
  default     = ""
}

variable "exported_bucket" {
  description = "S3 Bucket to store artifacts"
  type        = string
  default     = ""
}

variable "pretrained_model" {
  description = "Name of pre-trained model from TF Model Zoo"
  type        = string
  default     = ""
}

variable "records_uri" {
  description = "URI of records for training and testing"
  type        = string
  default     = ""
}