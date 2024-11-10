.PHONY: all stop

all:
	@echo "\033[1;32mDeploying all services...\033[0m"
	@ansible-playbook -i ansible/inventory ansible/playbook.yml --ask-vault-pass

stop:
	@echo "\033[1;31mStoping all services...\033[0m"
	@ansible-playbook -i ansible/inventory ansible/stop.yml --ask-vault-pass

# lancement avec debug
all-v:
	@echo "\033[1;32mDeploying all services with verbose...\033[0m"
	@ansible-playbook -i ansible/inventory ansible/playbook.yml --ask-vault-pass -vv

# stop avec debug
stop-v:
	@echo "\033[1;31mStoping all services with verbose...\033[0m"
	@ansible-playbook -i ansible/inventory ansible/stop.yml --ask-vault-pass -vv

## N'utiliser que cette commande si redifinition des envs
# encrypt:
# 	ansible-vault encrypt ansible/secrets/secrets.yml