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

resource "aws_lb_target_group" "wordpress_lb_target_group" {
  name     = "wordpress-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.wordpress_vpc.id
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    path                = "/wp-includes/images/blank.gif"
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
}

data "aws_instance" "wordpress_1a" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-1a"]
  }
}

data "aws_instance" "wordpress_1c" {
  filter {
    name   = "tag:Name"
    values = ["wordpress-1c"]
  }
}

resource "aws_lb_target_group_attachment" "wordpress_1a_attatchement" {
  target_group_arn = aws_lb_target_group.wordpress_lb_target_group.arn
  target_id        = data.aws_instance.wordpress_1a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "wordpress_1c_attatchement" {
  target_group_arn = aws_lb_target_group.wordpress_lb_target_group.arn
  target_id        = data.aws_instance.wordpress_1c.id
  port             = 80
}

resource "aws_security_group" "wordpress_elb_sg" {
  name   = "wordpress-elb-sg"
  vpc_id = data.aws_vpc.wordpress_vpc.id

  tags = {
    Name = "wordpress-elb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.wordpress_elb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.wordpress_elb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
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

resource "aws_lb" "wordpress_lb" {
  name               = "wordpress-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wordpress_elb_sg.id]
  subnets            = [data.aws_subnet.subnet_public_1a.id, data.aws_subnet.subnet_public_1c.id]

  tags = {
    Name = "wordpress-lb"
  }
}

resource "aws_lb_listener" "wordpress_lb_listener" {
  load_balancer_arn = aws_lb.wordpress_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_lb_target_group.arn
  }
}