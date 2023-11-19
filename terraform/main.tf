resource "aws_vpc" "chillipharm_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "chillipharm_vpc"
  }
}

resource "aws_internet_gateway" "chillipharm_gw" {
  vpc_id = aws_vpc.chillipharm_vpc.id

  tags = {
    Name = "chillipharm_gw"
  }
}

resource "aws_subnet" "chillipharm_subnet" {
  vpc_id                  = aws_vpc.chillipharm_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "chillipharm_subnet"
  }
}

resource "aws_route_table" "chillipharm_route_table" {
  vpc_id = aws_vpc.chillipharm_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chillipharm_gw.id
  }

  tags = {
    Name = "chillipharm_route_table"
  }
}

resource "aws_route_table_association" "chillipharm_route_table_assoc" {
  subnet_id      = aws_subnet.chillipharm_subnet.id
  route_table_id = aws_route_table.chillipharm_route_table.id
}

resource "aws_security_group" "chillipharm_sg" {
  vpc_id = aws_vpc.chillipharm_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_sg"
  }
}

resource "aws_key_pair" "chillipharm_key" {
  key_name   = "chillipharm-key"
  public_key = file("C:/Users/USER/Documents/DEV/ChilliPharm/my_key.pub")
}

resource "aws_instance" "chillipharm_instance" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.chillipharm_subnet.id
  vpc_security_group_ids = [aws_security_group.chillipharm_sg.id]
  key_name               = aws_key_pair.chillipharm_key.key_name

  tags = {
    Name = "chillipharm_instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo service docker start
              sudo systemctl start docker

              # Create a new user or ensure it exists
              sudo adduser --disabled-password --gecos "" chillipharm_user
              sudo usermod -aG sudo chillipharm_user
              
              # Add the user to the Docker group
              sudo usermod -aG docker chillipharm_user

              EOF
}

resource "aws_eip" "chillipharm_eip" {
  instance = aws_instance.chillipharm_instance.id

  tags = {
    Name = "chillipharm_eip"
  }
}
