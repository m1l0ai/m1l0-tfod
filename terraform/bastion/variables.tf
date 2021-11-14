variable "instance_count" {
	description = "Number of bastion hosts"
	type = number
	default = 1
}

variable "instance_type" {
	description = "EC2 Instance type"
	type = string
	default = "t2.micro"
}

variable subnet_ids {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}

variable security_group_ids {
  description = "Security group IDs for EC2 instances"
  type        = list(string)
}

variable "tags" {
	description = "EC2 tags"
	type = map(string)
}

variable "key_name" {
	description = "SSH Key for host"
	type = string
}