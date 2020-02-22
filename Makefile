DOCKER_MACHINE_PATH:=       /usr/local/bin/docker-machine
DOCKER_MACHINE_CACHE:=      ~/.docker/machine/cache
DOCKER_VERSION:=            0.16.2
DOCKER_MACHINE_URL_PREFIX:= https://github.com/docker/machine/releases/download/v$(DOCKER_VERSION)/docker-machine-$(shell uname -s)-$(shell uname -m)
RANCHEROS_ISO_URL:=         https://releases.rancher.com/os/latest/rancheros.iso
RANCHEROS_VMWARE_ISO_URL:=  https://releases.rancher.com/os/latest/vmware/rancheros-autoformat.iso
RANCHEROS_ISO_PATH:=        $(DOCKER_MACHINE_CACHE)/rancheros.iso
RANCHEROS_VMWARE_ISO_PATH:= $(DOCKER_MACHINE_CACHE)/rancheros-autoformat.iso
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
create-vm-virtualbox: $(RANCHEROS_ISO_PATH)
	docker-machine \
    create -d virtualbox \
    --virtualbox-boot2docker-url $(RANCHEROS_ISO_PATH) \
    --virtualbox-cpu-count $(VM_CPU_COUNT) \
    --virtualbox-memory $(VM_RAM_SIZE) \
    --virtualbox-disk-size $(VM_DISK_SIZE) \
    $(VM_NAME)

.PHONY: create-vm-vmware-fusion
create-vm-vmware-fusion: $(RANCHEROS_VMWARE_ISO_PATH)
	docker-machine \
    create -d vmwarefusion \
    --vmwarefusion-no-share \
    --vmwarefusion-cpu-count $(VM_CPU_COUNT) \
    --vmwarefusion-memory-size $(VM_RAM_SIZE) \
    --vmwarefusion-disk-size $(VM_DISK_SIZE) \
    --vmwarefusion-boot2docker-url $(RANCHEROS_VMWARE_ISO_PATH) \
    $(VM_NAME)

.PHONY: remove-machine
remove-machine:
	docker-machine rm $(VM_NAME)

.PHONY: remove-isos
remove-isos:
	rm -f $(RANCHEROS_ISO_PATH) $(RANCHEROS_VMWARE_ISO_PATH)

list-docker-machine-versions:
	curl -s https://api.github.com/repos/docker/machine/tags | jq -r '.[].name'

$(RANCHEROS_ISO_PATH): | $(DOCKER_MACHINE_CACHE)
	curl -f -L $(RANCHEROS_ISO_URL) > $(RANCHEROS_ISO_PATH)

$(RANCHEROS_VMWARE_ISO_PATH): | $(DOCKER_MACHINE_CACHE)
	curl -f -L $(RANCHEROS_VMWARE_ISO_URL) > $(RANCHEROS_VMWARE_ISO_PATH)

$(DOCKER_MACHINE_CACHE):
	mkdir -p $@
