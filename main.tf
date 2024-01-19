provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "cloudiq_sample_vpc" {
  cidr_block = "172.0.0.0/16"
  tags = {
    Name = "CloudIQ-Sample-VPC"
  }
}

resource "aws_subnet" "cloudiq_private_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.cloudiq_sample_vpc.id
  cidr_block              = "172.0.${count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a" 
  tags = {
    Name = "CloudIQ-Private-Subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "cloudiq_public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.cloudiq_sample_vpc.id
  cidr_block              = "172.0.${2 + count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "CloudIQ-Public-Subnet-${count.index + 1}"
  }
}

resource "aws_instance" "cloudiq_instance" {
  count                   = 4
  ami                     = "ami-023c11a32b0207432"
  instance_type           = "t2.micro"
  subnet_id               = count.index < 2 ? aws_subnet.cloudiq_private_subnet[count.index].id : aws_subnet.cloudiq_public_subnet[count.index - 2].id
  vpc_security_group_ids  = [aws_security_group.cloudiq_sg.id]

  tags = {
    Name = "CloudIQ-Instance-${count.index + 1}"
  }
}

resource "aws_security_group" "cloudiq_sg" {
  vpc_id = aws_vpc.cloudiq_sample_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
