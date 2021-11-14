data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "bastion_host" {
  count = var.instance_count

  ami = data.aws_ami.amazon_linux.id

  instance_type = "t2.micro"

  subnet_id = var.subnet_ids[count.index % length(var.subnet_ids)]

  vpc_security_group_ids = var.security_group_ids

  key_name = var.key_name

  tags = {
    Name = "bastion_host"
  }
}