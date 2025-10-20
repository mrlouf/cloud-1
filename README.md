# cloud-1

Automated deployment of a web application on a remote server.

## Objective

This project aims at automating the containerised deployment of a WordPress webpage and its associated services (database, nginx, etc.) on an instance of a cloud provider (AWS, Azure...) using Ansible.
The deployment should be done in a single command from the local machine.
Althought not mandatory, this project uses Terraform to create and manage the cloud infrastructure.

## Prerequisites

- Terraform and Ansible installed on the local machine (you can use the scripts `install_terraform.sh` and `install_ansible.sh`).

## Setup Instructions

1. Use the scripts `setup_terraform.sh` and `setup_ansible.sh` to set up the environment.
2. Configure your cloud provider credentials in the Terraform configuration files or using `aws configure` for AWS.
3. Modify the main.tf to use your own key pair for SSH access to the remote server.
4. Use Terraform to create the infrastructure:
   ```bash
   terraform init
   terraform apply
   ```
5. Once the infrastructure is set up, provide Ansible with the public IP address of the remote server in the inventory file and the .env file.
6. Run the Ansible playbook to deploy the web application:
   ```bash
   ansible-playbook main.yml --tags "install,deploy"
   ```
7. Access the deployed WordPress webpage using the public IP address of the remote server.

## Notes

- Ansible uses SSH to connect to the remote server, so ensure that your SSH key is correctly configured and that the security group allows SSH access on port 22.
- **Running `terraform apply` will create resources that may incur costs. Remember to destroy the resources using `terraform destroy` when they are no longer needed.**

## References

https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create<br>
https://docs.ansible.com/ansible/latest/getting_started/index.html<br>
https://medium.com/@tinashemadangure/getting-started-with-ansible-a-step-by-step-guide-6c4e7bd6f80f<br>
