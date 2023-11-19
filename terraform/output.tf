output "vpc_id" {
  value = aws_vpc.chillipharm_vpc.id
}

output "subnet_id" {
  value = aws_subnet.chillipharm_subnet.id
}

output "security_group_id" {
  value = aws_security_group.chillipharm_sg.id
}

output "ec2_instance_public_ip" {
  value = aws_instance.chillipharm_instance.public_ip
}

output "ec2_instance_elastic_ip" {
  value = aws_eip.chillipharm_eip.public_ip
}