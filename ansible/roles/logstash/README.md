Logstash (ELK)
==============

Elasticsearch, Logstash and Kibana, also known as "ELK".

About ELK
---------

* Elasticsearch is a real-time search and analytics engine. We use it for storing and searching system/web logs (https://www.elastic.co/guide/en/elasticsearch/guide/current/index.html).

* Logstash is a collection engine. It accepts data from various sources, pre-parses them and stores them in elasticsearch (https://www.elastic.co/guide/en/logstash/current/index.html).

* Kibana is a visualisation platform. Using the search results from elasticsearch, it produces more meaningful visualisations (https://www.elastic.co/guide/en/kibana/current/index.html).

Installation notes
------------------

* Installation: see tasks/main.yml, it's rather self-documented.

* For Kibana, this role will install an nginx vhost that is htpasswd protected. The password will be stored in /root/kibana-password (on log.civicrm.org).

* nginx logstash patterns were inspired from: https://www.digitalocean.com/community/tutorials/adding-logstash-filters-to-improve-centralized-logging

Troubleshooting and maintenance
===============================

"Shards failing"
----------------

If Kibana displays an errors about "shards failing", it might be because we have a lot of data indexed and elasticsearch has run out of memory.

A short-term solution can be to bump up the memory limit in elasticsearch:

In /etc/elasticsearch/elasticsearch.yml :

    indices.breaker.fielddata.limit: 75%

(the default is 60%, but you should probably not go over 80%).

Other solutions could be to increase the RAM of the VM, or to "retire" old data (un-index it). There are many posts on forums about this topic, and there are probably better solutions.
