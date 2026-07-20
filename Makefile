SHELL := /bin/bash

GRADLE := ./gradlew --no-daemon
IMAGE_NAME ?= autobol4ik/devops-engineer-from-scratch-project-315
IMAGE_TAG ?= latest
CONTAINER_NAME ?= hexlet-3-app
ANSIBLE_INVENTORY ?= inventory.yml
ANSIBLE_PLAYBOOK := ansible-playbook -i $(ANSIBLE_INVENTORY) playbook.yml

.PHONY: install test lint lint-fix frontend-check frontend-build build run start \
	docker-build docker-run prepare ansible-syntax \
	provision deploy rollback tls vault-edit

install:
	$(GRADLE) dependencies
	npm ci --prefix frontend

test:
	$(GRADLE) test

lint:
	$(GRADLE) spotlessCheck

lint-fix:
	$(GRADLE) spotlessApply

frontend-check:
	npm run lint --prefix frontend
	npm run type-check --prefix frontend

frontend-build:
	npm run build --prefix frontend

build: lint test frontend-check frontend-build
	$(GRADLE) bootJar

run:
	$(GRADLE) bootRun

start: run

docker-build:
	docker build --tag $(IMAGE_NAME):$(IMAGE_TAG) .

docker-run:
	docker run --rm --name $(CONTAINER_NAME) \
		--publish 8080:8080 \
		--publish 127.0.0.1:9090:9090 \
		--env SPRING_PROFILES_ACTIVE=dev \
		--volume hexlet-3-local-data:/tmp/bulletin-images \
		$(IMAGE_NAME):$(IMAGE_TAG)

prepare:
	ansible-galaxy role install --role-file requirements.yml --roles-path .ansible/roles
	ansible-galaxy collection install --requirements-file requirements.yml --collections-path .ansible/collections

ansible-syntax:
	ansible-playbook -i inventory.example.yml playbook.yml --syntax-check

provision:
	test -f $(ANSIBLE_INVENTORY)
	$(ANSIBLE_PLAYBOOK) --extra-vars tls_enabled=false --tags prepare,nginx

deploy:
	test -f $(ANSIBLE_INVENTORY)
	test "$(IMAGE_TAG)" != "latest"
	$(ANSIBLE_PLAYBOOK) --extra-vars app_image_tag=$(IMAGE_TAG)

rollback:
	test -n "$(ROLLBACK_TAG)"
	$(MAKE) deploy IMAGE_TAG=$(ROLLBACK_TAG)

tls:
	test -f $(ANSIBLE_INVENTORY)
	$(ANSIBLE_PLAYBOOK) --extra-vars tls_enabled=true --tags tls,nginx

vault-edit:
	ansible-vault edit group_vars/all/vault.yml
