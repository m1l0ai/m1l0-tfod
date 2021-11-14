output "public_ip" {
	description = "Public IP of EC2"
	value = aws_instance.bastion_host.*.public_ip
}