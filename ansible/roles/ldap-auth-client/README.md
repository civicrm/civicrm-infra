LDAP client
===========

This documentation is specific to the CiviCRM-org infrastructure.

How to test LDAP
----------------

```
$ ldapsearch -v -H ldaps://manage.civicrm.osuosl.org/ -D uid=USERNAME,ou=people,dc=civicrm,dc=org -W -x -b dc=civicrm,dc=org -d1
```

(where `USERNAME` is your username)
