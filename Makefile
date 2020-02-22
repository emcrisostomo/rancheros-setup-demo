DOCKER_MACHINE_PATH:=       /usr/local/bin/docker-machine
DOCKER_MACHINE_CACHE:=      ~/.docker/machine/cache
DOCKER_VERSION:=            0.16.2
DOCKER_MACHINE_URL_PREFIX:= https://github.com/docker/machine/releases/download/v$(DOCKER_VERSION)/docker-machine-$(shell uname -s)-$(shell uname -m)
VM_NAME:=                   rancheros-vm
VM_CPU_COUNT:=              2
VM_RAM_SIZE:=               2048
VM_DISK_SIZE:=              8000

.PHONY: install-docker-machine
install-docker-machine: $(DOCKER_MACHINE_PATH)

$(DOCKER_MACHINE_PATH):
	curl -fsL $(DOCKER_MACHINE_URL_PREFIX) > $${TMPDIR}/docker-machine
	cp $${TMPDIR}/docker-machine $(DOCKER_MACHINE_PATH)
	chmod +x $(DOCKER_MACHINE_PATH)

.PHONY: uninstall-docker-machine
uninstall-docker-machine:
	rm $(DOCKER_MACHINE_PATH)

.PHONY: create-vm-virtualbox
create-vm-virtualbox:
	VM_DRIVER=virtualbox \
	VM_NAME=$(VM_NAME) \
		./create-rancher-instance

.PHONY: create-vm-vmware-fusion
create-vm-vmware-fusion:
	VM_DRIVER=vmwarefusion \
	VM_NAME=$(VM_NAME) \
		./create-rancher-instance

.PHONY: remove-machine
remove-machine:
	docker-machine rm $(VM_NAME)

list-docker-machine-versions:
	curl -s https://api.github.com/repos/docker/machine/tags | jq -r '.[].name'

$(DOCKER_MACHINE_CACHE):
	mkdir -p $@
