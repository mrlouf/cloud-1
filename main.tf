provider "aws" {
  region = "eu-north-1"
}

################################
# -_-_-_- DATA SOURCES -_-_-_- #
################################

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

data "aws_key_pair" "asus" {
  key_name = "Asus"
}

#################################
# -_-_-_-_- RESOURCES -_-_-_-_- #
#################################

resource "aws_security_group" "webserv_sg" {
  name        = "webserv-sg"
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = "vpc-05ae2da1e076b6992"

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Using 0.0.0.0/0 for demo purposes; restrict to local IP for prod would be a good idea
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf_webserv_sg"
  }
}

resource "aws_instance" "web_server" {
  ami                     = data.aws_ami.debian.id
  instance_type           = "t3.micro"
  vpc_security_group_ids  = [resource.aws_security_group.webserv_sg.id]
  key_name                = data.aws_key_pair.asus.key_name
  subnet_id               = "subnet-029e33fb3e3342fac"

  tags = {
    Name = "tf_remote_server"
  }
}

output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}