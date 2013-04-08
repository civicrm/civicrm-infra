How to Add a new Host
=====================

(Note: Each step should be run on either the new virtual machine -- VM -- or on the management system -- MANAGE)

VM: Update /etc/hosts
```
140.211.167.144 manage.civicrm.osuosl.org manage
```

VM: Update /etc/resolv.conf
```
search civicrm.osuosl.org
```

VM: Verify hostname
```
hostname -f
```

VM: Install puppet
```
apt-get install puppet facter
```

VM: Update /etc/puppet/puppet.conf
```
server=manage.civicrm.osuosl.org
```

VM: Submit key
```
puppetd --test -v
```

MANAGE: Create node config file under /etc/puppet/manifests/node/, e.g.
```
node "NEWHOSTNAME" {
  include civicrmorg::baseline
  include civicrmorg::client
  include civicrmorg::www
}
```

MANAGE: Make sure new file is loaded
```
/etc/init.d/puppetmaster restart
```

MANAGE: Accept the key
```
puppetca --list
puppetca --sign NEWHOSTNAME.civicrm.osuosl.org
```

VM: Activate new setup
```
puppetd --test -v
```
