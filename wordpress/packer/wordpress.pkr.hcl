packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "ami_id" {
  type = string
}

source "amazon-ebs" "wordpress" {
  ami_name      = "wordpress"
  instance_type = "t2.micro"
  region        = "ap-northeast-1"
  source_ami    = "${var.ami_id}"
  ssh_username  = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.wordpress"]
  provisioner "ansible" {
    playbook_file = "../ansible/site.yml"
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3"
    ]
  }
}
