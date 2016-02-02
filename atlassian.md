# Atlassian Services (JIRA, Confluence)

## Basic Info

 * Confluence and Jira run in standalone flavour and both have their own Tomcats packaged.
 * Both are installed on /srv partition (/srv/www/confluence and /srv/www/jira), so disk space issues shouldn't be a problem.
 * Both run as their own users. Please do not run them as root!

## Managing Services

 * Stop JIRA: sudo -u jira -H /srv/www/jira/atlassian-jira/bin/shutdown.sh
 * Start JIRA: sudo -u jira -H /srv/www/jira/atlassian-jira/bin/startup.sh
 * Stop Confluence: sudo -u confluence -H /srv/www/confluence/atlassian-confluence-4.1.3/bin/shutdown.sh
 * Start Confluence: sudo -u confluence -H /srv/www/confluence/atlassian-confluence-4.1.3/bin/startup.sh

Note that java services are sometimes rather slow to restart.  Hence you should
 * execute the appropriate shutdown command (described above)
 * kill any lagging process, e.g.
   * 'ps uax|grep confluence' or 'ps uax|grep jira' then 'sudo kill -9 [pid]'
   * launch 'top' as root, find the processes and kill them with 'k' then type the PID
 * execute the appropriate startup command (described above)
 * hold your breath for 5 minutes
Then the wiki should be back to normal.

To view logs:

 * for Confluence Tomcat logs: /srv/www/confluence/atlassian-confluence-4.1.3/logs
 * for Confluence own logs: /srv/www/confluence/confluence-home/logs
 * for Jira Tomcat logs: /srv/www/jira/atlassian-jira-4.4.4-standalone/logs
 * for Jira own logs: /srv/www/jira/jira-home/log

## Potential memory issues, the simple way
Both Jira and Confluence need quite a lot of memory. At the moment, they have settings which should be optimal, but in case of problems (with other apps or Java apps /watch out for OutOfMemory exception/ on sushi not having enough memory) settings should be tweaked. This is done in:

 * /srv/www/jira/atlassian-jira-4.4.4-standalone/bin/setenv.sh (in the first line, which right now looks like this: JAVA_OPTS="-Xms256m -Xmx512m -XX:MaxPermSize=384m -XX:+UseCompressedOops $JAVA_OPTS -Djava.awt.headless=true ")
 * /srv/www/confluence/atlassian-confluence-4.1.3/bin/setenv.sh (all over the file, setting environment variables /current values listed as well/: JVM_MINIMUM_MEMORY="64m" , JVM_MAXIMUM_MEMORY="320m", JIRA_MAX_PERM_SIZE="256m")

Three most important
 * -Xms / JVM_MINIMUM_MEMORY - size of memory used at the start, shouldn't need tweaking unless any of the apps won't start
 * -Xmx / JVM_MAXIMUM_MEMORY - maximum amount of memory that can be taken for storing data
 * -XX:MaxPermSize / JIRA_MAX_PERM_SIZE - maximum amount of memory for compiled classes, templates, etc

Maximum amount of memory used up by single application can be estimated doing following calculation: (Xmx + MaxPermSize) * 1.5
If you need to, please tweak memory settings with caution, read a bit of Atlassian wiki and stuff like that - don't make random changes.

## Confluence: JMX Console

To investigate issues like run-away threads or memory leaks, one can use the JMX console. Steps:

 * SSH into the server
 * Review the CATALINA_OPTS in /srv/www/confluence/atlassian-confluence-4.1.3/bin/setenv.sh – these will tell you the JMX TCP port and the credential file.
 * Review the credential file (eg /srv/www/confluence/atlassian-confluence-4.1.3/conf/jmxremote.password) – this will provide a username and password.
 * On your local workstation, launch "jconsole". Be sure to include the server's hostname as well as the port, username, and password mentioned above.

See also:

 * https://confluence.atlassian.com/display/DOC/Live+Monitoring+Using+the+JMX+Interface
 * http://tomcat.apache.org/tomcat-5.5-doc/monitoring.html#Enabling%20JMX%20Remote

## Confluence: Copy form Production (java-prod) to Staging (java-test)

To transfer the wiki-related files (executables and data) from java-prod to java-test:

```
root@java-prod$ cd /srv/www/confluence
root@java-prod$ find ! -user confluence
  -> Just in case there was something funny; looks OK

root@java-prod$ rsync -Prav --exclude backup --exclude .ssh /srv/www/confluence/./ confluence@java-test:/srv/www/confluence/./
```

To transfer the wiki-related databases from java-prod to java-test:

```
root@java-prod$ grep hibernate /srv/www/confluence/confluence-home/confluence.cfg.xml
  -> Determine old mysql db/user/pass, e.g. "confluence_new"/"confluence_new"/"pass"

root@java-test$ mysql -u root -p
  -> Create identical mysql db/user/pass
  create database confluence_new;
  GRANT ALL PRIVILEGES ON confluence_new.* TO 'confluence_new'@'localhost' IDENTIFIED BY 'pass';

root@java-prod$ mysqldump -u root -p confluence_new \
  | bzip2 > /srv/www/confluence/backup/`date +%Y-%m-%d`-confluence_new.sql.bz2

root@java-prod$ chmod og= /srv/www/confluence/`date +%Y-%m-%d`-confluence_new.sql.bz2
root@java-prod$ rsync -Prav /srv/www/confluence/./ confluence@java-test:/srv/www/confluence/./

root@java-test$ bzcat ~confluence/backup/YYYY-MM-DD-HH-MM-confluence_new.sql.bz2 \
  | mysql -u root -p confluence_new
```

Finally, you can start the new service on java-test.

Note: The new instance can (at time of writing) be addressed as
"https://wiki-test.civicrm.org/confluence/".  Some pages (such as
the administrator's "Plugin" screen) may break due to the URL change – fix
this by navigating to the Confluence administration area fixing
"Configuration => General Configuration => Server Base Url".

You can also change the URL in the database directly:

```
UPDATE BANDANA
SET BANDANAVALUE = replace(BANDANAVALUE, 'http://wiki.civicrm.org', 'https://wiki-test.civicrm.org')
WHERE BANDANACONTEXT = '_GLOBAL' and BANDANAKEY = 'atlassian.confluence.settings';
```

Then restart Confluence.

## Confluence: Upgrade

 * For full instructions, see http://confluence.atlassian.com/display/DOC/Upgrading+Confluence
 * As a best-practice, one should first copy Confluence from production (sushi) to staging (biryani) and perform an upgrade on staging.
 * Navigate to http://www.atlassian.com/software/confluence/download?os=linux and find the download URL for the Linux 64-bit installer
 * Download and execute the installer on the server, e.g.
   * mkdir ~/download
   * cd ~/download
   * wget 'http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-4.2.2-x64.bin'
   * ./atlassian-confluence-4.2.2-x64.bin
 * After running the upgrade, the Confluence web path may have changed from "/confluence" to "/". This can be fixed by editing "server.xml" and to the <Context> tag, e.g.
   *  <Context path="/confluence" ...>
