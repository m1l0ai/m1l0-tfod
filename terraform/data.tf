data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_ecs_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

data "aws_ami" "amazon_ecs_linux_gpu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-gpu-hvm-*-x86_64-ebs"]
  }
}

data "template_file" "init" {
  template = file("./container_init.tpl")

  vars = {
    clustername = "${module.ecs.this_ecs_cluster_name}"
    region      = "${data.aws_region.current.name}"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "container_init.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.init.rendered
  }
}