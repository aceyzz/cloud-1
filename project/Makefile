#
# by @cedmulle
#
ANSIBLE_PLAYBOOK=ansible-playbook
INVENTORY=ansible/inventory/inventory.ini

VAULT_PASS_PATH=/home/xvi/Desktop/.ansible_pass.txt
VAULT_PASS_FILE=--vault-password-file
VAULT=$(VAULT_PASS_FILE) $(VAULT_PASS_PATH)

BECOME=--ask-become-pass

CYAN=\033[1;36m
GREY=\033[3;37m
GOLD=\033[3;33m
LIME=\033[1;32m
NC=\033[0m

help:
	@echo ""
	@echo " $(LIME)make init$(NC)		$(GREY)- IMPORTANT! Import secrets inside the project$(NC)"
	@echo " $(CYAN)make deploy$(NC)		$(GREY)- Full deployment of the webapp$(NC)"
	@echo " $(CYAN)make stop$(NC)		$(GREY)- Stop containers (without removal)$(NC)"
	@echo " $(CYAN)make delete$(NC)		$(GREY)- Stop and remove volumes$(NC)"
	@echo " $(CYAN)make reset$(NC)		$(GREY)- Full cleanup (containers, images, volumes, remote folder)$(NC)"
	@echo " $(CYAN)make clean$(NC)		$(GREY)- Backup (and optionnaly remove) .env from the project. Useful before pushing.$(NC)"
	@echo " $(CYAN)make encrypt$(NC)		$(GREY)- Encrypt envs files$(NC)"
	@echo " $(CYAN)make decrypt$(NC)		$(GREY)- Decrypt envs files$(NC)"
	@echo " $(CYAN)make help$(NC)		$(GREY)- Show this help$(NC)"
	@echo ""

init:
	@echo "$(GOLD)Importing secrets...$(NC)"
	@/bin/bash ./scripts/add_secrets.sh

deploy:
	@$(ANSIBLE_PLAYBOOK) ansible/playbook.yml -i $(INVENTORY) $(VAULT) $(BECOME)

stop:
	@$(ANSIBLE_PLAYBOOK) ansible/cleanup.yml -i $(INVENTORY) $(BECOME) --tags stop

delete:
	@$(ANSIBLE_PLAYBOOK) ansible/cleanup.yml -i $(INVENTORY) $(BECOME) --tags stop_and_remove

reset:
	@$(ANSIBLE_PLAYBOOK) ansible/cleanup.yml -i $(INVENTORY) $(BECOME) --tags reset

clean:
	@echo "$(GOLD)Cleaning up...$(NC)"
	@/bin/bash ./scripts/remove_secrets.sh

encrypt:
	@echo "$(GOLD)Encrypting envs file...$(NC)"
	@ansible-vault encrypt app/.env $(VAULT)
	@ansible-vault encrypt app/.raspberry.env $(VAULT)
	@ansible-vault encrypt app/.azure.env $(VAULT)
	@echo "$(LIME)All encryption done!$(NC)"

decrypt:
	@echo "$(GOLD)Decrypting envs file...$(NC)"
	@ansible-vault decrypt app/.env $(VAULT)
	@ansible-vault decrypt app/.raspberry.env $(VAULT)
	@ansible-vault decrypt app/.azure.env $(VAULT)
	@echo "$(LIME)All decryption done!$(NC)"

.PHONY: help deploy stop delete reset