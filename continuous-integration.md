# Introduction

Continuous integration (CI) is the practice of automating build, testing,
and release during development.  Jenkins is a job-management system focused
on CI – and provides a large library of plugins for source-code management,
quality-assurance, etc.  More information, see http://jenkins-ci.org/ .

# Maintenance

### If Jenkins is not responding

Restart Tomcat on test.civicrm.org:

    sudo service tomcat6 restart

It will take a few minutes to start. You may at first see a 503 "service not available", then eventually Jenkins will show that it is in the process of starting.

# Setup master node

### Install Tomcat with Jenkins

(Note: I was unable to get the Jenkins Debian package to work with HTTPS
under Ubuntu 12.04 -- even with various configurations of
/etc/default/jenkins, mod_jk, and mod_proxy_ajp.)

```
apt-get install tomcat6 libapache2-mod-jk
cd /var/lib/tomcat6/webapps/
service tomcat6 stop

mkdir -p /var/backups/jenkins
mv ROOT /var/backups/jenkins/ROOT.orig
wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war -O ROOT.war

mkdir /var/lib/jenkins
chown tomcat6.tomcat6 /var/lib/jenkins
echo export JENKINS_HOME=/var/lib/jenkins >> /etc/default/tomcat6

vi /etc/tomcat6/server.xml
## Enable the AJP connector

vi /etc/libapache2-mod-jk/workers.properties
## Set tomcat_home and java_home

## In /etc/apache2, setup an Apache VHost as appropriate. Include "JkMount /* ajp13_worker"

service tomcat6 start
```

See also: https://wiki.jenkins-ci.org/display/JENKINS/Tomcat

### Configure authentication / authorization

 * Visit http://my-server.example.com:8080/configureSecurity
 * Enable LDAP:
   * Server: ldaps://manage.civicrm.osuosl.org
   * Root DN: dc=civicrm,dc=org
   * User search base: ou=People
   * User search filter: uid={0}
   * Group search base: ou=groups
   * Save
   * (Note: The certificate required for SSL should have been pre-authorized via puppet.)
 * In a separate browser, login to ensure that LDAP works
 * Visit http://my-server.example.com:8080/configureSecurity (again)
 * Set "Authorization" to "Matrix-based security" and use an administrative group from LDAP

### Setup master SSH credentials

```bash
root@test-master:~# cd /var/lib/jenkins/
root@test-master:/var/lib/jenkins# ssh-keygen -f id_rsa
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
root@test-master:/var/lib/jenkins# chown tomcat6.tomcat6 id_rsa*
root@test-master:/var/lib/jenkins# chmod 600 id_rsa*
```

In Jenkins, navigate to "Manage Jenkins => Manage Credentials" and add:

 * Scope: System
 * Username: jenkins
 * Private Key: File on Jenkins master: /var/lib/jenkins/id_rsa

### Disable jobs on Master

Jobs should always run on slaves. Navigate to "Manage Jenkins => Manage
Nodes => master" and set the "# of executors" to 0.

### ulimit

ulimit: Extend the file open limit in "/etc/security/limits.conf", e.g.:

```
*                soft    nofile          12288
*                hard    nofile          16384
```

Note: Omitting this step will lead to startup errors when doing the startup over SSH.
Note: Omitting this step has been circumstantially implicated in very quirky behavior (i.e. disappearing information)

# Setup slave node

See also: https://wiki.jenkins-ci.org/display/JENKINS/Distributed+builds

### Create user on slave

```bash
root@test-ubu1204-1:~# adduser --system --home /var/lib/jenkins --shell /bin/bash jenkins
Adding system user `jenkins' (UID 107) ...
Adding new user `jenkins' (UID 107) with group `nogroup' ...
Creating home directory `/var/lib/jenkins' ...
root@test-ubu1204-1:~# makepasswd
ranDOmlYg3N3rAteD
root@test-ubu1204-1:~# passwd jenkins
Enter new UNIX password: ranDOmlYg3N3rAteD
Retype new UNIX password: ranDOmlYg3N3rAteD
passwd: password updated successfully
root@test-ubu1204-1:~# adduser jenkins ssh-user
root@test-ubu1204-1:~# sudo -u jenkins -H vi /var/lib/jenkins/.gitconfig
```

And setup an identity:

```
[color]
        ui = true
[user]
        name = Jenkins
        email = jenkins@test-ubu1204-1.civicrm.osuosl.org
```

Finally, use the new username and password to grant Jenkins access to SSH
the new system -- and test that it works:

```bash
me@localhost:~$ ssh test-master.civicrm.osuosl.org
me@test-master:~$ sudo ssh-copy-id -i /var/lib/jenkins/id_rsa.pub jenkins@HOSTNAME.civicrm.osuosl.org
[sudo] password for me:
The authenticity of host 'HOSTNAME.civicrm.osuosl.org (111.111.111.111)' can't be established.
RSA key fingerprint is 11:11:11:11:11:11:11:11:11:11:11:11:11:11:11:11.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'HOSTNAME.civicrm.osuosl.org' (RSA) to the list of known hosts.
jenkins@HOSTNAME.civicrm.osuosl.org's password:
Now try logging into the machine, with "ssh 'jenkins@HOSTNAME.civicrm.osuosl.org'", and check in:

  ~/.ssh/authorized_keys

to make sure we haven't added extra keys that you weren't expecting.
me@test-master:~$ sudo ssh -i /var/lib/jenkins/id_rsa jenkins@HOSTNAME.civicrm.osuosl.org
jenkins@HOSTNAME:$ git config -l
```

### File ACLs

In /etc/fstab, add option "acl" to the root partition (or whichever partition contains /var/www).

Remount the partiation (e.g. "mount -o remount /")

### MySQL ramdisk

The test process for CiviCRM will frequently truncate or reinitialize the
MySQL database.  Because we don't need to keep the databases long but do
need frequent, heavy changes, it makes sense to put the the databases into a
ramdisk.  The process is loosely:

 * Install Debian's mysql-server (version 5.1+)
 * Perform some basic administration (e.g. set passwords for admin users; add /root/.my.cnf and /var/lib/jenkins/.my.cnf with proper owner/permissions)
 * Shutdown the database
 * Make a snapshot of the raw DB files for use after reboots – "rsync -va /var/lib/mysql to /var/lib/mysql.tmpl"
 * Mount /var/lib/mysql using tmpfs in /etc/fstab – "none    /var/lib/mysql  tmpfs   size=768m,mode=1777     0 0"
 * In /etc/init.d/mysql (Debian) or /etc/init/mysql (Ubuntu), add these steps to the startup process:

```bash
## We store DB on ramdisk which disappears
if [ ! -f /var/lib/mysql/.loaded ]; then
  rsync -va --delete /var/lib/mysql.tmpl/./ /var/lib/mysql/./
  touch /var/lib/mysql/.loaded
fi
```

 * Reboot system and make sure MySQL comes back online

### Drupal/Apache

Each test of CiviCRM will require creating a Drupal site. If there are
concurrent tests (e.g.  concurrent "executors"), then each each executor
will need its own Drupal site.  We'll prepare a pool.

 * Download and extract a Drupal tar ball. Rename it to /var/www/drupal. Make sure "jenkins" has read/write access to this dir.
 * In /etc/hosts, add aliases for 127.0.0.1 called "jenkins-0.localhost jenkins-1.localhost jenkins-2.localhost jenkins-3.localhost jenkins-4.localhost"
 * In /etc/apache2, add a vhost with "ServerName jenkins-0.localhost" and "SeverAlias" options for every other hostname.

```
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName jenkins-0.localhost
        ServerAlias jenkins-1.localhost
        ServerAlias jenkins-2.localhost
        ServerAlias jenkins-3.localhost
        ServerAlias jenkins-4.localhost
        ServerAlias jenkins-5.localhost

        DocumentRoot /var/www/drupal
        <Directory />
                Options FollowSymLinks
                AllowOverride None
        </Directory>
        <Directory /var/www/drupal/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride FileInfo AuthConfig Limit Indexes Options
                Order allow,deny
                allow from all
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

 * a2enmod rewrite
 * Note: There is no need to create a database for each site – DBs will be automatically dropped and created.
 * Install Drush and Console_Table via PEAR: http://drupal.org/project/drush

### Selenium/Xvfb

Puppet should have already installed xvfb and created a script for launching
Selenium with xvfb.  You must manually install a browser and launch the
script:

```bash
me@host:~$ sudo -H screen
root@host:/home/me$ apt-get install firefox
root@host:/home/me$ sudo -u selenium -H /home/selenium/bin/selenium-node.sh
```

NOTE: We sometimes experience problems with Selenium failing to support new
versions of Firefox. For Ubuntu servers, one can manually download a
specific deb (e.g. for Firefox v37) from [sourceforge](http://sourceforge.net/projects/ubuntuzilla/files/mozilla/apt/pool/main/f/firefox-mozilla-build/).

### Register slave on master

 * In Jenkins Web UI, navigate to "Manage Jenkins => Manage Nodes" and register the new node. Some example settings:
   * # of executors: 3
   * Labels: ubuntu ubuntu1204 php53
   * Remote FS Root: /var/lib/jenkins
   * Launch method: ...Unix machine via SSH
   * Credentials: jenkins

# Upgrade notes #

(Not yet tested)

```
[ -f /var/backups/jenkins/ROOT.war ] && rm -f /var/backups/jenkins/ROOT.war
[ -d /var/backups/jenkins/ROOT ] && rm -f /var/backups/jenkins/ROOT
mkdir -p /var/backups/jenkins
service tomcat6 stop
mv ROOT ROOT.war /var/backups/jenkins
wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war -O ROOT.war
service tomcat6 start
```

# Job configuration notes

TODO
