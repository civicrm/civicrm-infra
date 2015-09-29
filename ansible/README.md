Ansible playbooks for the CiviCRM internal infrastructure. These playbooks
are not for deploying CiviCRM itself, they are for managing the servers that
run the civicrm.org website, the issue tracker, the wiki and the test servers.

This is very much work in progress. Most of the servers are still managed by
Puppet.

### Getting started

Installing Ansible:

```
sudo apt-get install ansible
```

Get a copy of this playbook:

```
git clone git@github.com:civicrm/civicrm-infra.git
```

Get the private files for the CiviCRM infra. The files are in /etc/ansible/ of log.c.o.o.
This includes, for example, SSL certificates. Most of the inventory data is included in this
playbook ('production' file) because it was already documented publicly in ../hosts.md.

Run a dry-run simulation of the playbook:

```
cd civicrm-infra/ansible/
ansible-playbook -i production --check ./site.yml
```

Run on a specific node:

```
cd civicrm-infra/ansible/
ansible-playbook -i production --check -l log.civicrm.osuosl.org ./site.yml
```

Do an actual run (not simulated) on a specific node (you probably never want to run this globally):

```
cd civicrm-infra/ansible/
ansible-playbook -i production -l log.civicrm.osuosl.org ./site.yml
```

### Misc that needs proper documentation

* We use a 'deploy' ssh user to connect to all nodes. Currently this is using an ssh key that allows logins only from two specific IP addresses (notably manage.c.o.o).

* All sysadmins should have an account on manage.c.o.o that allows them to have a copy of civicrm-infra in their home directory, a copy of the key (which is protected by a passphrase), and access to the secret files in /etc/ansible/.

* When doing changes to the playbooks, commit as your own user, so that we know "who changed what".

* Similarly, when running ansible-deploy, do so as your user, this way the {{ ansible_managed }} tag shows your name.
