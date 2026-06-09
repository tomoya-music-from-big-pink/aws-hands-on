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

resource "aws_vpc" "wordpress_vpc" {
  cidr_block = "11.0.0.0/16"

  tags = {
    Name = "wordpress-vpc"
  }
}

resource "aws_subnet" "wordpress_public_1a" {
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = "11.0.0.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "wordpress-public-1a"
  }
}

resource "aws_subnet" "wordpress_public_1c" {
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = "11.0.1.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "wordpress-public-1c"
  }
}

resource "aws_subnet" "wordpress_private_1a" {
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = "11.0.2.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "wordpress-private-1a"
  }
}

resource "aws_subnet" "wordpress_private_1c" {
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = "11.0.3.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "wordpress-private-1c"
  }
}

resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id = aws_vpc.wordpress_vpc.id

  tags = {
    Name = "wordpress-igw"
  }
}

resource "aws_route_table" "wordpress_route_table" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress_igw.id
  }

  tags = {
    Name = "wordpress-route-table"
  }
}

resource "aws_route_table_association" "public_1a_association" {
  subnet_id      = aws_subnet.wordpress_public_1a.id
  route_table_id = aws_route_table.wordpress_route_table.id
}

resource "aws_route_table_association" "public_1c_association" {
  subnet_id      = aws_subnet.wordpress_public_1c.id
  route_table_id = aws_route_table.wordpress_route_table.id
}