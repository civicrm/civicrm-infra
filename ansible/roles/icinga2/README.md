### Icinga2 role

Installs the basic packages for icinga v2. Does not install the web interface,
which I strongly recommend (includes icingacli). Supports Debian and Ubuntu.

To use this role, assign the "icinga-servers" group to a server in your inventory.
You can also use a "icinga-nodes" group for monitored nodes, but this is mostly to
simplify the deployment. The playbook only checks if a server is in "icinga-servers"
or not, in order to determine whether to configure the node as a server or satellite.

NB: this role is based on:
https://github.com/coopsymbiotic/coopsymbiotic-ansible/tree/master/roles/icinga2

### TODO

* The configuration of the server is missing some bits to configure icingaweb2.

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
