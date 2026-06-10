terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = "ap-northeast-1"
}

data "aws_vpc" "wordpress_vpc" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-vpc"]
  }
}

resource "aws_security_group" "wordpress_sg" {
  name   = "wordpress-sg"
  vpc_id = data.aws_vpc.wordpress_vpc.id

  tags = {
    Name = "wordpress-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_ami" "wordpress_ami" {
  filter {
    name   = "name"
    values = ["wordpress"]
  }
}

data "aws_subnet" "subnet_public_1a" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-public-1a"]
  }
}

data "aws_subnet" "subnet_public_1c" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-public-1c"]
  }
}

resource "aws_instance" "wordpress_1a" {
  ami                         = data.aws_ami.wordpress_ami.id
  instance_type               = "t3.micro"
  key_name                    = "ec2"
  subnet_id                   = data.aws_subnet.subnet_public_1a.id
  vpc_security_group_ids      = [aws_security_group.wordpress_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "wordpress-1a"
  }
}

resource "aws_instance" "wordpress_1c" {
  ami                         = data.aws_ami.wordpress_ami.id
  instance_type               = "t3.micro"
  key_name                    = "ec2"
  subnet_id                   = data.aws_subnet.subnet_public_1c.id
  vpc_security_group_ids      = [aws_security_group.wordpress_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "wordpress-1c"
  }
}
