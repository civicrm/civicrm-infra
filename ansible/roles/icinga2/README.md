### Icinga2 role

Installs the basic packages for icinga v2. Does not install the web interface,
which I strongly recommend (includes icingacli). Supports Debian and Ubuntu.

NB: this role is based on:
https://github.com/coopsymbiotic/coopsymbiotic-ansible/tree/master/roles/icinga2

To use this role:

* Assign the "icinga-servers" group to a server in your inventory (this will be the master Icinga2 server).
* Assign the "icinga-nodes" group to monitored nodes.

The playbook checks if a server is in "icinga-servers" or not, in order to
determine whether to configure the node as a server or satellite.

### Monitoring non-Debian nodes

Most of the Coop SymbioTIC infrastructure runs on Debian-based servers. We also
monitor some Redhat/CentOS-based servers. This is not yet handled by this playbook.

On CentOS 7:

```
yum install https://packages.icinga.com/epel/icinga-rpm-release-7-latest.noarch.rpm
yum install nagios-plugins-disk
yum install nagios-plugins-load
```

On CentOS 6:

```
yum install https://packages.icinga.org/epel/6/release/noarch/icinga-rpm-release-6-1.el6.noarch.rpm
yum install icinga2

cd /usr/src
wget https://www.monitoring-plugins.org/download/monitoring-plugins-2.1.2.tar.gz
tar zxfv monitoring-plugins-2.1.2.tar.gz
cd monitoring-plugins
./configure
make
make install
```

And finally, in the host declarations on the icinga2 master, you must set the
distribution variable:

```
object Host "example.com" {
  import "generic-host"
  address = "[...]
  check_command = "ping"
  max_check_attempts = 10

  vars.distribution = "centos"
  groups = [ "http-servers", "icinga-satellites" ]
}
```

Although, for now, this is mostly to avoid running the "apt" and "mem" checks on CentOS.

### TODO

* The configuration of the server is missing some bits to configure icingaweb2:
  * nginx vhost configuration
  * letsencrypt https cert (c.f. dehydrated role)
  * icingaweb2 installation itself (which also requires creating a mysql user/db)
  * enable features-available/ido-mysql
  * create the icinga2 database (see ido-mysql, should have credentials with random pass)
  * import the icinga2 schema: mysql --defaults-file=/etc/mysql/debian.cnf icinga2 < /usr/share/icinga2-ido-mysql/schema/mysql.sql
  * configure the Monitoring Backend: https://www.icinga.com/docs/icinga2/latest/doc/02-getting-started/#enabling-the-ido-mysql-module
  * configure the Monitoring transport: use Icinga2 API, user/pass in /etc/icinga2/conf.d/api-users.conf

* Master server should include zones.d/* (see icinga2.conf and uncomment the line).

* Graphite: https://github.com/findmypast/icingaweb2-module-graphite

Graphite setup:

```
/etc/uwsgi/apps-available/graphite-api.ini


----------------
[uwsgi]
processes = 2
socket = 127.0.0.1:3031
plugins = python27

module = graphite_api.app:app

chdir = /usr/share/graphite-web
pythonpath = "['/usr/share/graphite-web'] + sys.path"

# manage-script-name = true
mount = /render=/usr/share/graphite-web/graphite.wsgi

uid = _graphite
gid = _graphite
----------------

ln -s /etc/uwsgi/apps-available/graphite-api.ini /etc/uwsgi/apps-enabled
service uwsgi restart
/etc/graphite/local_settings.py => set SECRET key
/usr/bin/graphite-manage syncdb
/usr/bin/graphite-manage createsuperuser (if 'n' to previous command)
/etc/default/graphite-carbon => CARBON_CACHE_ENABLED=true
```

nginx vhost:

```
  location ~ ^/render(.*) {
    include uwsgi_params;
    uwsgi_pass 127.0.0.1:3031;
  }
```

grafana:

```
apt-get install apt-transport-https

# add repo (package for wheezy works on jessie)
cat <<EOF >/etc/apt/sources.list.d/grafana.list
deb https://packagecloud.io/grafana/stable/debian/ jessie main
EOF

wget -O - https://packagecloud.io/gpg.key 2>/dev/null | apt-key add - 
apt-get update

apt-get install grafana

systemctl enable grafana-server.service
systemctl start grafana-server
```

Increase carbon / graphite retention times:

/etc/carbon/storage-schemas.conf

```
[icinga_default]
pattern = ^icinga2\.
retentions = 1m:2d,5m:10d,30m:90d,360m:3y
```

http://docs.icinga.org/icinga2/snapshot/doc/module/icinga2/toc#!/icinga2/snapshot/doc/module/icinga2/chapter/icinga2-features#graphite-carbon-cache-writer  
http://randsubrosa.blogspot.ca/2013/03/adjust-retention-time-for-carbon-and.html

### More about debugging Carbon retention

Get stats about what is being stored:

```
# whisper-info.py /var/lib/graphite/whisper/icinga2/smtp_symbiotic_coop/services/load/load/perfdata/load1
```

Resize files:

```
cd /var/lib/graphite/whisper/icinga2
find ./ -type f -name '*.wsp' -exec whisper-resize --xFilesFactor=0.1 --nobackup {} 1m:2d 5m:7d 30m:90d 360m:3y \;
chown -R _graphite._graphite /var/lib/graphite/whisper/icinga2
```

* About xFilesFactor: http://obfuscurity.com/2012/04/Unhelpful-Graphite-Tip-9
* Whisper file size calculator: https://m30m.github.io/whisper-calculator/

### How to declare services for satellite nodes

For example, to monitor available disk space on satellite nodes, add this to /etc/icinga2/conf/services.conf:

```
apply Service "disk" {
  check_command = "disk"

  /* make sure host.name is the same as endpoint name */
  command_endpoint = host.name

  assign where "icinga-satellites" in host.groups
}
```

NB: This assumes that your satellite nodes are in the "icinga-satellites" hostgroup.

Example:

```
object Host "foo-node.example.org" {
  import "generic-host"

  groups = [ "icinga-satellites" ]

  address = "[...]"
  address6 = "[...]"
  check_command = "ping"
}
```

I haven't found a way to automate adding a server to the correct hostgroup (with Ansible). Might be simpler to find a way to detect remote nodes.

### References

* http://docs.icinga.org/icinga2/latest/doc/module/icinga2/chapter/icinga2-client

* http://docs.icinga.org/icinga2/latest/doc/module/icinga2/chapter/troubleshooting

* https://github.com/Icinga/puppet-icinga2/blob/develop/manifests/pki/icinga.pp

* http://serverfault.com/questions/647805/how-to-set-up-icinga2-remote-client-without-using-cli-wizard

* https://lists.icinga.org/pipermail/icinga-users/2015-October/010337.html

* http://www.credativ.nl/credativ-blog/howto-icinga2-graphite-and-grafana-debian
