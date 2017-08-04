LDAP client
===========

This documentation is specific to the CiviCRM-org infrastructure.

How to test LDAP
----------------

```
$ ldapsearch -v -H ldaps://manage.civicrm.osuosl.org/ -D uid=USERNAME,ou=people,dc=civicrm,dc=org -W -x -b dc=civicrm,dc=org -d1
```

(where `USERNAME` is your username)

```
$ getent passwd [username]
```

(where `[username]` is an actual username). This should return an entry equivalent to those found in `passwd`.
