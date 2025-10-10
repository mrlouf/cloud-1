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

data "aws_security_group" "ansible-sg" {
  id = "sg-0a25fc5665b04e27d"
}

data "aws_security_group" "server-sg" {
  id = "sg-0ff0aa6d2bd9d10c0"
}

resource "aws_instance" "ansible_master" {
  ami                     = data.aws_ami.debian.id
  instance_type           = "t3.micro"
  vpc_security_group_ids  = [data.aws_security_group.ansible-sg.id]
  key_name                = "Asus"

  tags = {
    Name = "tf_ansible_master"
  }

  # Install Ansible on the instance at launch and make it run the playbooks
  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install git -y
              git clone --branch nponchon https://github.com/mrlouf/cloud-1.git /home/admin/
              bash /home/admin/install-ansible.sh
              ansible-playbook -i /home/admin/inventory.yaml /home/admin/main.yaml --tags install
              ansible-playbook -i /home/admin/inventory.yaml /home/admin/main.yaml --tags deploy
              EOF
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [data.aws_security_group.server-sg.id]

  tags = {
    Name = "tf_remote_server"
  }
}

output "ansible_master_ip" {
  value = aws_instance.ansible_master.public_ip
}

output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}