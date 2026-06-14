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

resource "aws_security_group" "wordpress_database_sg" {
  name   = "wordpress-database-sg"
  vpc_id = data.aws_vpc.wordpress_vpc.id

  tags = {
    Name = "wordpress-database-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id = aws_security_group.wordpress_database_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.wordpress_database_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_subnet" "subnet_private_1a" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-private-1a"]
  }
}

data "aws_subnet" "subnet_private_1c" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-private-1c"]
  }
}

resource "aws_db_subnet_group" "wordpress_db_subnet" {
  name       = "wordpress-db-subnet"
  subnet_ids = [data.aws_subnet.subnet_private_1a.id, data.aws_subnet.subnet_private_1c.id]

  tags = {
    Name = "wordpress-db-subnet"
  }
}

resource "aws_db_instance" "wordpress_db_1a" {
  identifier           = "wordpressdb"
  engine               = "mysql"
  engine_version       = "8.4.7"
  instance_class       = "db.m5.large"
  username             = "admin"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.4"
  skip_final_snapshot  = true
  multi_az             = true
  db_subnet_group_name = aws_db_subnet_group.wordpress_db_subnet.name
  allocated_storage    = 10
}
