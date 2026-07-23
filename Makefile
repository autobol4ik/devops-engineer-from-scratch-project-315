SHELL := /bin/bash

APP_SOURCE_REF := 36d2fb85cfe95d343bad9ca6369afdfd21b83150
ROLLBACK_IMAGE_REPOSITORY ?= autobol4ik/devops-engineer-from-scratch-project-315
ANSIBLE_INVENTORY ?= inventory.yml
ANSIBLE_PLAYBOOK := ansible-playbook -i $(ANSIBLE_INVENTORY) playbook.yml

.PHONY: prepare boundary validate-app-source-ref ansible-lint ansible-syntax \
	check provision deploy rollback tls vault-edit print-app-source-ref

prepare:
	ansible-galaxy role install --role-file requirements.yml --roles-path .ansible/roles
	ansible-galaxy collection install --requirements-file requirements.yml --collections-path .ansible/collections

boundary:
	@for path in src frontend gradle Dockerfile build.gradle.kts \
		settings.gradle.kts gradlew gradlew.bat terraform k8s; do \
		test ! -e "$$path" || { \
			echo "$$path belongs in the application repository"; \
			exit 1; \
		}; \
	done

validate-app-source-ref:
	@printf '%s\n' "$(APP_SOURCE_REF)" | grep -Eq '^[0-9a-f]{40}$$'

ansible-lint:
	ansible-lint --exclude .ansible/ --profile production playbook.yml roles/

ansible-syntax:
	ansible-playbook -i inventory.example.yml playbook.yml --syntax-check

check: boundary validate-app-source-ref ansible-lint ansible-syntax

provision:
	test -f $(ANSIBLE_INVENTORY)
	$(ANSIBLE_PLAYBOOK) --extra-vars tls_enabled=false --tags prepare,nginx

deploy: validate-app-source-ref
	test -f $(ANSIBLE_INVENTORY)
	$(ANSIBLE_PLAYBOOK) --extra-vars app_image_tag=$(APP_SOURCE_REF)

rollback:
	@printf '%s\n' "$(ROLLBACK_TAG)" | grep -Eq '^[0-9a-f]{40}$$'
	test -f $(ANSIBLE_INVENTORY)
	$(ANSIBLE_PLAYBOOK) --extra-vars \
		app_image_repository=$(ROLLBACK_IMAGE_REPOSITORY) \
		app_image_tag=$(ROLLBACK_TAG)

tls:
	test -f $(ANSIBLE_INVENTORY)
	$(ANSIBLE_PLAYBOOK) --extra-vars tls_enabled=true --tags tls,nginx

vault-edit:
	ansible-vault edit group_vars/all/vault.yml

print-app-source-ref:
	@printf '%s\n' "$(APP_SOURCE_REF)"
