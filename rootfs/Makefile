BUILDER=tx2-builder-vm
CORES=8
STORAGE=64 # give 64GB for this VM

create-vm:
	kvm-install-vm create -c $(CORES) -d $(STORAGE) -t ubuntu2004 $(BUILDER)
	echo $(BUILDER) > ./builder-inventory

remove-vm:
	kvm-install-vm remove $(BUILDER)
	rm ./builder-inventory

make-builder:
	./waitforhost.sh $(BUILDER) ansible-playbook ./playbooks/setup-builder.yml -i ./builder-inventory -b -u ubuntu


kernel:
	./waitforhost.sh $(BUILDER) ansible-playbook ./playbooks/kernel.yml -i ./builder-inventory -b -u ubuntu


rootfs:
	./waitforhost.sh $(BUILDER) ansible-playbook ./playbooks/patch-rootfs.yml -i ./builder-inventory -b -u ubuntu -vv
