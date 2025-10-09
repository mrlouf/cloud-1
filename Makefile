ANSIBLE_HOST=ubuntu@13.60.243.82
TARGET_HOST=ubuntu@172.31.34.105
ANSIBLE_KEY=~/.ssh/serv1.pem
TARGET_KEY=~/.ssh/id_rsa

all: copy install deploy

# Copy files to the ansible instance
copy:
	@echo "➡️  Copying deployment files to Ansible node..."
	scp -i $(ANSIBLE_KEY) -r inventory.yaml .env ./app/ ./books $(ANSIBLE_HOST):~/cloud-1

# Install Docker
install:
	@echo "➡️  Install docker on the server..."
	ssh -i $(ANSIBLE_KEY) $(ANSIBLE_HOST) \
		"cd ~/cloud-1 && ansible-playbook -i inventory.yaml ./books/install-Docker.yaml"

# Deploy all
deploy:
	@echo "➡️  Running Ansible playbook from Ansible node..."
	ssh -i $(ANSIBLE_KEY) $(ANSIBLE_HOST) \
		"cd ~/cloud-1 && ansible-playbook -i inventory.yaml ./books/deploy-inception.yaml"

# Clean containers remotely
stop:
	ssh -i $(ANSIBLE_KEY) $(ANSIBLE_HOST) \
		"cd ~/cloud-1 && ansible-playbook -i inventory.yaml ./books/stop-inception.yaml"

