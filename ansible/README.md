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

Recommended: install Ansible 1.9 or higher. These playbooks are developed on Ansible 2.0.

Get a copy of this playbook:

```
git clone --recursive git@github.com:civicrm/civicrm-infra.git
```

Get the private files for the CiviCRM infra. The files are in /etc/ansible/ of manage.c.o.o.
This includes, for example, SSL certificates. Most of the inventory data is included in this
playbook ('production' file) because it was already documented publicly in ../hosts.md.

Run a dry-run simulation of the playbook:

```
cd civicrm-infra/ansible/
ansible-playbook --check ./site.yml
```

Run on a specific node:

```
cd civicrm-infra/ansible/
ansible-playbook --check -l log.civicrm.osuosl.org ./site.yml
```

Run on a specific node with a specific tag

```
cd civicrm-infra/ansible/
ansible-playbook --check -l log.civicrm.osuosl.org --tags logstash-servers ./site.yml
```

Do an actual run (not simulated) on a specific node (you probably never want to run this globally):

```
cd civicrm-infra/ansible/
ansible-playbook -l log.civicrm.osuosl.org ./site.yml
```

### Using inventory from Google Cloud

Google Cloud includes some ephemeral hosts (with short-lived names and IPs).
If you would like to connect to these with Ansible, then add the dynamic inventory:

1. (__One-Time Setup__) Install Google CLI tools (https://cloud.google.com/sdk/docs/install) and authenticate the connection.
2. (__Day-to-Day__) Run the script `./bin/update-gcloud`

To change the naming or grouping conventions for ephemeral hosts, modify `bin/update-gcloud`. You can
simply re-run the command to see if it generates the intended inventory.

### Managing a host in Ansible

1- Ensure that you have the private files in /etc/ansible/files (ex: you are running from manage.c.o.o).

2- Add the host to the 'production' inventory.

3- Run the following setup:

```
ansible-playbook -l example.civicrm.osuosl.org --become-user=root --ask-become-pass ./setup.yml
```

### Security model of the deploy user

To manage a host with Ansible, a "deploy" user must be configured. This is
required by Ansible in order to ssh to the host and "push" configurations
(unlike Puppet, where the host contacts the puppetmaster at regular intervals,
in order to pull configurations).

This type of push model requires certain precautions, since a specific account
uses the same ssh key for all hosts.

* the ssh pubkey for deployment is restricted to specific IP adresses used for management (e.g. IP restrictions in the authorized_keys).

* the ssh private key is encrypted with a passphrase.

In a sense, the security model is equivalent or better to either:

* if the puppetmaster gets hacked, malicious configurations can be deployed to any other host.

* if any LDAP password of an admin is hacked, the attacker can gain privileged access to any host.

Of course, we always aim to improve the security model. This is only a quick overview of the situation to reassure against frequent concerns.

### Misc that needs proper documentation

* We use a 'deploy' ssh user to connect to all nodes. Currently this is using an ssh key that allows logins only from two specific IP addresses (notably manage.c.o.o).

* All sysadmins should have an account on manage.c.o.o that allows them to have a copy of civicrm-infra in their home directory, a copy of the key (which is protected by a passphrase), and access to the secret files in /etc/ansible/.

* When doing changes to the playbooks, commit as your own user, so that we know "who changed what".

* Similarly, when running ansible-deploy, do so as your user, this way the {{ ansible_managed }} tag shows your name.

* Common commands for deploying buildkit updates:

    ```bash
    ## Include an ephemeral worker nodes
    ./bin/update-gcloud

    ## Push updates for Jenkins jobs and control scripts on test nodes (/opt/buildkit)
    ansible-playbook playbooks/buildkit/update_opt.yml
    ansible-playbook playbooks/buildkit/update_opt_bin.yml

    ## Push updates for buildkit tools (/opt/buildkit and /home/*/bknix*), but _not_ system services
    ansible-playbook playbooks/buildkit/update_all_repos.yml
    ```
