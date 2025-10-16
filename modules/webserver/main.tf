resource "aws_eip" "webserv_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "webserv_eip_association" {
  instance_id    = aws_instance.web_server.id
  allocation_id  = aws_eip.webserv_eip.id
}

resource "aws_security_group" "webserv_sg" {
  name        = var.sg_name
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = var.vpc_id

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
    Name = var.sg_name
  }
}

resource "aws_instance" "web_server" {
  ami                     = var.ami
  instance_type           = var.instance_type
  vpc_security_group_ids  = [aws_security_group.webserv_sg.id]
  key_name                = var.key_name
  subnet_id               = var.subnet_id

  tags = {
    Name = var.instance_name
  }
}
