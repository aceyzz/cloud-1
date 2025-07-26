#
# by @cedmulle
#
ANSIBLE_PLAYBOOK=ansible-playbook
INVENTORY=ansible/inventory/inventory.ini
VAULT=--ask-vault-pass
BECOME=--ask-become-pass

CYAN=\033[0;36m
RED=\033[0;31m
GREY=\033[0;37m
GOLD=\033[0;33m
NC=\033[0m

help:
	@echo ""
	@echo "$(GOLD)Available commands:$(NC)"
	@echo " $(RED)make init$(NC)		$(GREY)- IMPORTANT! Import secrets inside the project$(NC)"
	@echo " $(CYAN)make deploy$(NC)		$(GREY)- Full deployment of the webapp$(NC)"
	@echo " $(CYAN)make stop$(NC)		$(GREY)- Stop containers (without removal)$(NC)"
	@echo " $(CYAN)make delete$(NC)		$(GREY)- Stop and remove volumes$(NC)"
	@echo " $(CYAN)make reset$(NC)		$(GREY)- Full cleanup (containers, images, volumes, remote folder)$(NC)"
	@echo " $(CYAN)make clean$(NC)		$(GREY)- Remove secrets from the project$(NC)"
	@echo " $(CYAN)make help$(NC)		$(GREY)- Show this help$(NC)"
	@echo ""

init:
	@echo "$(GOLD)Importing secrets...$(NC)"
	@/bin/bash ./scripts/add_secrets.sh

deploy:
	@$(ANSIBLE_PLAYBOOK) ansible/playbook.yml -i $(INVENTORY) $(VAULT) $(BECOME)

stop:
	@$(ANSIBLE_PLAYBOOK) ansible/cleanup.yml -i $(INVENTORY) $(VAULT) $(BECOME) --tags stop

delete:
	@$(ANSIBLE_PLAYBOOK) ansible/cleanup.yml -i $(INVENTORY) $(VAULT) $(BECOME) --tags stop_and_remove

reset:
	@$(ANSIBLE_PLAYBOOK) ansible/cleanup.yml -i $(INVENTORY) $(VAULT) $(BECOME) --tags reset

clean:
	@echo "$(GOLD)Cleaning up...$(NC)"
	@/bin/bash ./scripts/remove_secrets.sh

.PHONY: help deploy stop delete reset