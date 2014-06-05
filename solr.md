# Apache Solr Experimental Installation

Solr is not used in production. However, we do have a basic installation for
experimentation.

## Installation

```bash
adduser --home /srv/www/solr solr
su - solr
wget ${SOME_MIRROR}/4.7.2/solr-4.7.2.tgz
tar xvzf solr-4.7.2.tgz
wget ${SOME_MIRROR}/apachesolr-7.x-1.6.tar.gz
tar xvzf apachesolr-7.x-1.6.tar.gz
rsync -va apachesolr/solr-conf/solr-4.x/./ solr-4.7.2/example/solr/collection1/conf/./
vi ~/solr-4.7.2/example/solr/collection1/conf/solrconfig.xml
## fix duplicate tags: <useCompoundFile> <ramBufferSizeMB> <mergeFactor>
```

## User Accounts

Solr does not have its own access-control mechanisms, but you can use the
Java container to configure access-control.  See
http://muddyazian.blogspot.com/2013/11/how-to-require-password-authentication.html
or https://wiki.apache.org/solr/SolrSecurity#Path_Based_Authentication .

In particular, note the files:

 * etc/jetty.xml
 * solr-webapp/webapp/WEB-INF/web.xml
 * etc/realm.properties

## Startup / Shutdown

The service is experimental and must be started and stopped manually.

 * Connect to java-test via SSH. 
 * Use [screen](http://www.rackaid.com/blog/linux-screen-tutorial-and-how-to/). Attach to
   an existing session if one exists -- or start a new session.
 * To start service in the screen session: "su - solr" and then "cd solr-4.7.2/example" and "java -jar start.jar".
   Disconnect from the screen session (Ctrl-A D).
 * To stop service, simply press Ctrl-C.
