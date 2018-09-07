kvm-server
==========

Role to configure KVM servers (to host virtual-machines).

Based on: https://github.com/coopsymbiotic/coopsymbiotic-ansible/tree/master/roles/kvm-server

ZFS setup
---------

Assuming the server has been setup with minimal RAID-1 15GB partitions to boot and that the rest has not been allocated (ex: https://wiki.symbiotic.coop/serveurs/x2.symbiotic.coop). Most of our servers are EG-32 or EG-32-S servers with 2x450GB SSD disks.

Pool setup:

* create new extended partition on both disks with cfdisk
* create new regular linux partition on both disks (/dev/sdX5) with cfdisk
* run "partprobe"
* create a new pool: zpool create -f zxNN mirror /dev/sda5 /dev/sdb5

NB: in the above, NN is the 'x' number. Ex: the pool on x2.symbiotic.coop is zx2.

Create partitions for the VMs:

* create new partitions:
* zfs create -V 50G zx2/av201
* zfs create -V 25G zx2/ddm
* zfs create -V 25G zx2/smtp

New VM creation
---------------

Canonical documentation: https://wiki.symbiotic.coop/serveurs/x2.symbiotic.coop (internal wiki).

IP and DNS management:

* In the OVH control panel, assign an IPv4 address and "bridge" it, wait for the MAC to be generated.
* Repeat the process for an IPv6 subnet.
* In Gandi (where we manage symbiotic.coop), add a new A/AAAA entry for the new IPs.

Create a new partition for the VM:

* `zfs create -V 40G zx2/[short-client-name]`
* `zx2` is our convention for pool names, where x2 is the server's name and suffixed by `z` for ZFS.

Copy a preseed example from another host, and:

* Change the MAC address of the VM (using the MAC of the bridged IP)
* Change the hostname
* Change the IPv4 address (the preseed doesn't have IPv6 info)

Now launch the installation:

```
virt-install --name av201 --ram 8192 --disk path=/dev/zvol/zx2/av201 --vcpus 4 --os-type linux --os-variant virtio26 --network bridge=br0 --graphics vnc,listen=127.0.0.1 --noautoconsole --location 'http://ftp.ca.debian.org/debian/dists/jessie/main/installer-amd64/' --extra-args 'ks=file:/av201.ks' --initrd-inject=/root/av201.ks
```

The automatic installer will get stuck on the network configuration. Use `virt-manager` to fix the network, continue the install (which should be mostly automatic).

Post-installation:

* Change the main sudoer's password
* Setup and run ansible.
