# Introduction

Continuous integration (CI) is the practice of automating build, testing,
and release during development.  Jenkins is a job-management system focused
on CI – and provides a large library of plugins for source-code management,
quality-assurance, etc.  More information, see http://jenkins-ci.org/ .

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
root@test-ubu1204-1:~# cp /root/.my.cnf /var/lib/jenkins/.my.cnf
root@test-ubu1204-1:~# chown jenkins /var/lib/jenkins/.my.cnf
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

And finally test the new username and password:

```bash
ssh jenkins@test-ubu1204-1.civicrm.osuosl.org
git config -l
```

### Register slave on master

 * In master's CLI, run: ssh-copy-id -i /var/lib/jenkins/id_rsa.pub jenkins@test-ubu1204-1.civicrm.osuosl.org
 * In Jenkins Web UI, navigate to "Manage Jenkins => Manage Nodes" and register the new node. Some notable settings:
   * # of executors: 3
   * Labels: ubuntu ubuntu1204 php53
   * Remote FS Root: /var/lib/jenkins
   * Launch method: ...Unix machine via SSH
   * Credentials: jenkins

### MySQL ramdisk

The test process for CiviCRM will frequently truncate or reinitialize the
MySQL database.  Because we don't need to keep the databases long but do
need frequent, heavy changes, it makes sense to put the the databases into a
ramdisk.  The process is loosely:

 * Install Debian's mysql-server (version 5.1+)
 * Perform some basic administration (e.g. set passwords for admin users; add /root/.my.cnf)
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

 * Download and extract a Drupal tar ball. Rename it to /var/www/drupal
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
 * Install Drush via PEAR: http://drupal.org/project/drush

### Selenium/Xvfb

TODO
 
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
