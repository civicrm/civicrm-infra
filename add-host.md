How to Add a New Host
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

MANAGE: Create node configuration under /etc/puppet/manifests/node/. You
might add another in the misc.pp file or create a new file.  A new file
wouuld look like:
```
node "NEWHOSTNAME" {
  include civicrmorg::baseline
  include civicrmorg::access
  include civicrmorg::ldapclient
  include civicrmorg::www
}
```

MANAGE: If you created a new file, then make sure it's loaded
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

VM: Enable puppet on system start
```
vi /etc/default/puppet
/etc/init.d/puppet start
```
