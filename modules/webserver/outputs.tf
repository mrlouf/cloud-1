output "public_ip" {
  value = aws_eip.webserv_eip.public_ip
}
