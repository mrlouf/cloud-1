provider "aws" {
  region = "eu-north-1"
}

# Alias debian AMI to be reused
data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-13-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["136693071363"] # Debian
}

resource "aws_instance" "ansible_master" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ansible-sg.id]

  tags = {
    Name = "DebianAnsibleMaster"
  }
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.server-sg.id]

  tags = {
    Name = "DebianWebServer"
  }
}

resource "aws_security_group" "server-sg" {
  name        = "server-sg"
  description = "allow ssh AND http connection"
  vpc_id      = "vpc-05ae2da1e076b6992"

  ingress {
    description      = ""
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = ""
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "from ansible-sg"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = ["sg-0a25fc5665b04e27d"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ansible-sg" {
  name        = "ansible-sg"
  description = "allow ssh connection"
  vpc_id      = "vpc-05ae2da1e076b6992"

  egress {
    description      = ""
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "ssh from Asus"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["79.154.192.154/32"]
  }
}