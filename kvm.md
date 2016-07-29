KVM servers
===========

At the moment of this writing, this documentation mostly concerns the KVM setup on `padthai.c.o`. On most other servers are managed by other solutions, either Ganeti at OSUOSL or cloud providers.

Besides this document, there are also scattered bits of docs in the Ansible files:

* ansible/host_vars/padthai.civicrm.org
* ansible/roles/kvm-server/

Using virt-manager
------------------

virt-manager is neat. Add your ssh key to /root/.ssh/authorized_keys on the KVM host, then connect to that KVM host using virt-manager from your laptop/desktop/space station.

It helps with starting/stopping/restarting VMs, as well as for accessing the Linux console of a VM.

Creating a new VM
-----------------

Example:

```
virt-install --name test-ubu1604-1 --ram 8192 --disk path=/dev/zvol/zpadthai/test-ubu1604-1 \
  --vcpus 4 --os-type linux --os-variant virtio26 --network bridge=br0 \
  --graphics vnc,listen=0.0.0.0 --noautoconsole \
  --location 'http://archive.ubuntu.com/ubuntu/dists/xenial/main/installer-amd64/'
  --extra-args 'ks=file:/test-ubu1604-1.ks' --initrd-inject=/root/test-ubu1604-1.ks
```

In this case, the /root/test-ubu1604-1.ks file contents is:

```
lang en_US
langsupport en_US
keyboard us
timezone Etc/UTC
text
install
skipx
reboot

url --url http://ca.archive.ubuntu.com/ubuntu/

rootpw --disabled
auth --useshadow --enablemd5
user bgm --fullname "bgm" --password foofoo1234

bootloader --location=mbr
zerombr yes
clearpart --all --initlabel
part swap --size=1024
part / --fstype=ext4 --size=1 --grow

network --device=eth0 --bootproto=static --ip=192.95.2.131 --netmask=255.255.255.248 --nameserver=8.8.8.8 --gateway=192.95.2.129 --noipv6
firewall --disabled

%packages
ubuntu-minimal
openssh-server
python
```

VM IP bridging at OVH
---------------------

OVH supports briding the IPs directly at the switch level, avoiding the need to route through the host VM (http://help.ovh.com/BridgeClient). Most of the VMs have been configured this way because it makes routing easier.

To manage the IPs, login to the OVH control panel > dedicated servers > manage IPs. OVH will generate a MAC for the NIC, and this MAC must be configured in /etc/network/interfaces otherwise the briding will not work (obviously).

Example /etc/network/interfaces:

```
auto ens3
iface ens3 inet static
    hwaddress ether 02:00:00:27:76:97
    address 192.95.2.131
    netmask 255.255.255.255
    broadcast 192.95.2.131
    post-up /sbin/ip route add 167.114.158.0/24 dev ens3
    post-up /sbin/ip route add default via 167.114.158.254
    # dns-* options are implemented by the resolvconf package, if installed
    dns-nameservers 8.8.8.8

iface ens3 inet6 static
    address 2607:5300:60:71d0:200::
    netmask 72
    gateway 2607:5300:60:71d0::1
```

Mounting the partition of a VM
------------------------------

Padthai uses ZFS. You can mount a VM partition using like this:

```
mount /dev/zvol/zpadthai/test-ubu1604-1-part5 /mnt/
```

Don't do this while the VM is running! :-)
