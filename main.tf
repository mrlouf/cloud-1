provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian/images/hvm-ssd/debian-12-amd64-*"]
  }

  owners = ["self"]
}

resource "aws_instance" "ansible_master" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"

  tags = {
    Name = "DebianAnsibleMaster"
  }
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"

  tags = {
    Name = "DebianWebServer"
  }
}
