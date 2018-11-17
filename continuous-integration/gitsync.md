# Setup gitsync worker

See also: https://wiki.jenkins-ci.org/display/JENKINS/Distributed+builds

## Create `gitsync` user

```bash
root@HOSTNAME:~# adduser gitsync
Adding system user `gitsync' (UID 1234) ...
Adding new user `gitsync' (UID 1234) with group `nogroup' ...
Creating home directory `/home/gitsync' ...
root@HOSTNAME:~# makepasswd
ranDOmlYg3N3rAteD
root@HOSTNAME:~# passwd gitsync
Enter new UNIX password: ranDOmlYg3N3rAteD
Retype new UNIX password: ranDOmlYg3N3rAteD
passwd: password updated successfully
root@HOSTNAME:~# adduser gitsync ssh-user
root@HOSTNAME:~# sudo -u gitsync -H vi ~gitsync/.gitconfig
```

And setup an identity:

```
[color]
        ui = true
[user]
        name = Gitsync
        email = gitsync@HOSTNAME.civicrm.org
```

Use the new username and password to grant Jenkins access to SSH
into the new system. Test that it works.

```bash
me@localhost:~$ ssh test-master.civicrm.osuosl.org
me@test-master:~$ sudo -i ssh-copy-id -i /var/lib/jenkins/id_rsa.pub gitsync@HOSTNAME.civicrm.org
[sudo] password for me:
The authenticity of host 'HOSTNAME.civicrm.org (111.111.111.111)' can't be established.
RSA key fingerprint is 11:11:11:11:11:11:11:11:11:11:11:11:11:11:11:11.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'HOSTNAME.civicrm.org' (RSA) to the list of known hosts.
gitsync@HOSTNAME.civicrm.org's password:
Now try logging into the machine, with "ssh 'gitsync@HOSTNAME.civicrm.org'", and check in:

  ~/.ssh/authorized_keys

to make sure we haven't added extra keys that you weren't expecting.
me@test-master:~$ sudo ssh -i /var/lib/jenkins/id_rsa gitsync@HOSTNAME.civicrm.org
gitsync@HOSTNAME:$ git config -l
```

## Initialize repos

Make a folder to hold repos:

```
gitsync@HOSTNAME:~$ mkdir ~/src
```

Then go to https://test.civicrm.org/job/CiviCRM-Github-Gitlab-Sync/ and
follow the setup instruction for each of the currently enabled repos.

## Prefill SSH host key cache

Make a test connection to `lab.civicrm.org`. We don't need this complete (and we don't have stored credentials
for a full connection), but we should populate the cache of SSH known hosts.

```
gitsync@HOSTNAME:~$ ssh git@lab.civicrm.org
The authenticity of host 'lab.civicrm.org (2605:bc80:3010:102:0:3:4:0)' can't be established.
ECDSA key fingerprint is SHA256:0l1Vf00MOoq1rJAooxVppIKkn3AcDaniusatGbCBD6s.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'lab.civicrm.org,2605:bc80:3010:102:0:3:4:0' (ECDSA) to the list of known hosts.
git@lab.civicrm.org's password: 
```

## Register worker on master

The worker needs to have Java JRE 8+ available

```
sudo apt-get install openjdk-8-jre-headless
```

In Jenkins Web UI, navigate to "Manage Jenkins => Manage Nodes" and register the new node. Some example settings:

* Number of executors: 3
* Labels: bknix
* Remote FS Root: /home/gitsync
    * Launch method: ...slave agents machine via SSH
    * Credentials: gisync
    * Host Key Verification Strategy: Manually provided key
        * (Copy from a file like `/etc/ssh/ssh_host_rsa_key.pub` or `/etc/ssh/ssh_host_ecdsa_key.pub`)

