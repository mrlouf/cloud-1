all:
	@echo "➡️  Install dependencies and deploy the app"
	ansible-playbook main.yml --tags="install,deploy"

# Install Docker
install:
	@echo "➡️  Install docker on the server..."
#	awk -F= '{print $1 ": " $2}' .env > group_vars/all.yml
	ansible-playbook main.yml --tags="install"

# Deploy all
deploy:
	@echo "➡️  Running Ansible playbook"
	ansible-playbook main.yml --tags="deploy"

# Clean containers remotely
stop:
	@echo "➡️  Stopping the containers"
	ansible-playbook main.yml --tags="stop"

# Create instances using Terraform
create:
	@echo "➡️  Creating the instances"
	terraform apply

# Destroy the instances using Terraform
destroy:
	@echo "➡️  Destroying the instances"
	terraform destroy

.PHONY: all install deploy stop create destroy
