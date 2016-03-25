LDAP for CiviCRM.org websites
=============================

We expose the civicrm.org database as an LDAP server using LdapJS.
This is made possible using the following bits:

* CiviCRM extension: https://github.com/mlutfy/org.civicrm.ldapauthapi
* CiviLDAP forked from: https://github.com/TechToThePeople/ldapcivi (patch: https://gist.github.com/mlutfy/17622c2764472fbf71d0)

Confluence
----------

* Go to Space > Administration, then from the menu click on "user directories".
* Click on "Add directory", select "type = LDAP".

Parameters:

* Name: civicrm.org
* Type: OpenLDAP (Read-Only Posix Schema)
* Host: civicrm.org
* Port: 1389, ✔ use SSL
* User: dc=civicrm,dc=org
* Password: see settings.ldap.password in config/civicrmorg.js on www-prod.
* Base DN: dc=civicrm,dc=org
* LDAP Authorizations: Read-only, with local groups.
* LDAP Authorizations: Default group: confluence-users
* Schema options: LDAP username RDN: cn
* Schema options: Password encoding: plaintext
