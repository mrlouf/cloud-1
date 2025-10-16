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

locals {
  servers = {
    server1 = {
      name	= "tf_remote_server_1"
      sg	= "webserv-sg-1"
    }
    server2 = {
      name	= "tf_remote_server_2"
      sg	= "webserv-sg-2"
    }
  }
}

module "web_server" {
  for_each	= local.servers
  source	= "./modules/webserver"
  ami		= data.aws_ami.debian.id
  instance_type	= "t3.micro"
  key_name	= data.aws_key_pair.asus.key_name
  subnet_id	= "subnet-029e33fb3e3342fac"
  vpc_id	= "vpc-05ae2da1e076b6992"
  instance_name	= each.value.name
  sg_name	= each.value.sg
}

output "web_server_ips" {
  value = {
    for k, m in module.web_server : k => m.public_ip
  }
}
