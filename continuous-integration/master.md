# Setup master node

# Maintenance

### If Jenkins is not responding

Jenkins runs behind nginx:

    sudo systemctl status jenkins
    sudo systemctl restart jenkins

Jenkins takes a minute to fully start. It will display a "please while while Jenkins is starting" type of message during that time.

# Setup master node

### Install Jenkins

We are using the Debian packages maintained by Jenkins. c.f. /etc/apt/sources.list.d/jenkins.list

```
deb http://pkg.jenkins.io/debian-stable binary/
```

Jenkins defaults to port 8080 and nginx proxies https connections (c.f. /etc/nginx/sites-enabled/test.civicrm.org).

In the past (before 2017-01-24), Jenkins used to run using tomcat. More information about that is available in previous git versions of this document.

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
