provider "aws" {
  region = "eu-north-1"
}

# -_-_-_- DATA SOURCES -_-_-_- #

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

data "aws_key_pair" "asus" {
  key_name = "Asus"
}

# -_-_-_- RESOURCES -_-_-_- #

resource "tls_private_key" "ansible" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ansible" {
  key_name   = "ansible-key"
  public_key = tls_private_key.ansible.public_key_openssh
}

resource "aws_instance" "ansible_master" {
  ami                     = data.aws_ami.debian.id
  instance_type           = "t3.micro"
  vpc_security_group_ids  = [data.aws_security_group.ansible-sg.id]
  key_name                = data.aws_key_pair.asus.key_name
  subnet_id               = "subnet-024953d6418267e70"

  tags = {
    Name = "tf_ansible_master"
  }

  # Install Ansible on the instance at launch and make it run the playbooks
  user_data = <<-EOF
    #!/bin/bash
    apt update
    apt install git -y
    
    # Injecte la clé Ansible pour que le Master communique avec les serveurs
    cat > /home/admin/.ssh/id_rsa << 'KEYEOF'
${tls_private_key.ansible.private_key_pem}
KEYEOF
    chmod 600 /home/admin/.ssh/id_rsa
    chown admin:admin /home/admin/.ssh/id_rsa
    
    git clone --branch nponchon https://github.com/mrlouf/cloud-1.git /home/admin/
    bash /home/admin/install-ansible.sh
    ansible-playbook -i /home/admin/inventory.yaml /home/admin/main.yaml --tags install
    ansible-playbook -i /home/admin/inventory.yaml /home/admin/main.yaml --tags deploy
    EOF
}

resource "aws_instance" "web_server" {
  ami                     = data.aws_ami.debian.id
  instance_type           = "t3.micro"
  vpc_security_group_ids  = [data.aws_security_group.server-sg.id]
  key_name                = aws_key_pair.ansible.key_name
  subnet_id               = "subnet-029e33fb3e3342fac"

  depends_on              = [aws_key_pair.ansible]

  tags = {
    Name = "tf_remote_server"
  }
}

output "ansible_master_ip" {
  value = aws_instance.ansible_master.public_dns
}

output "web_server_ip" {
  value = aws_instance.web_server.public_dns
}